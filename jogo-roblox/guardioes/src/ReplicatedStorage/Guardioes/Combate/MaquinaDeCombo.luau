--!strict
-- NÃO EXECUTADO. Máquina de estados do combate de um personagem. LÓGICA PURA: não usa nenhuma API do Roblox;
-- o tempo ('agora', em segundos) é sempre passado de fora. O servidor roda a máquina oficial; o cliente roda
-- uma cópia só para resposta imediata (animação), e o servidor corrige quando discordar.
--
-- Estados: Ocioso → Preparo → Golpe → Recuperacao → (próximo golpe guardado | Ocioso)
--          Esquiva (cancela Preparo/Recuperacao/Defesa) · Defesa (segurar) · Atordoado
-- golpe: 1..#combo = passos do combo; -1 = ataque pesado; 0 = nenhum.

export type Golpe = { preparo: number, golpe: number, recuperacao: number }
export type Arma = { combo: { Golpe }, pesado: Golpe }
export type ConfigCombo = {
	esquiva: { duracao: number, invulInicio: number, invulFim: number, recarga: number },
	aparar: { janela: number },
	combo: { janelaContinuar: number, bufferAntecipado: number },
}

export type Estado = "Ocioso" | "Preparo" | "Golpe" | "Recuperacao" | "Esquiva" | "Defesa" | "Atordoado"

export type Maquina = {
	estado: Estado,
	desde: number,
	golpe: number,
	fila: boolean,
	filaPesado: boolean,
	ultimoPasso: number,
	fimUltimoGolpe: number,
	semErro: boolean,
	esquivaLiberadaEm: number,
	defesaDesde: number,
	atordoadoAte: number,
}

export type Evento = { tipo: string, golpe: number }

local PESADO = -1

local MaquinaDeCombo = {}
MaquinaDeCombo.PESADO = PESADO

function MaquinaDeCombo.nova(agora: number): Maquina
	return {
		estado = "Ocioso",
		desde = agora,
		golpe = 0,
		fila = false,
		filaPesado = false,
		ultimoPasso = 0,
		fimUltimoGolpe = -math.huge,
		semErro = true,
		esquivaLiberadaEm = -math.huge,
		defesaDesde = -math.huge,
		atordoadoAte = -math.huge,
	}
end

function MaquinaDeCombo.golpeDe(arma: Arma, golpe: number): Golpe
	if golpe == PESADO then
		return arma.pesado
	end
	local g = arma.combo[golpe]
	assert(g ~= nil, "golpe inválido: " .. tostring(golpe))
	return g
end

local function iniciar(m: Maquina, golpe: number, quando: number)
	m.estado = "Preparo"
	m.desde = quando
	m.golpe = golpe
	m.fila = false
	m.filaPesado = false
	if golpe == 1 or golpe == PESADO then
		m.semErro = true
	end
end

-- próximo passo do combo se o anterior terminou há pouco; senão recomeça do 1
local function proximoPasso(m: Maquina, arma: Arma, cfg: ConfigCombo, agora: number): number
	local n = #arma.combo
	if m.ultimoPasso >= 1 and m.ultimoPasso < n and (agora - m.fimUltimoGolpe) <= cfg.combo.janelaContinuar then
		return m.ultimoPasso + 1
	end
	return 1
end

-- fim previsto da sequência atual (preparo + golpe + recuperação)
local function fimDaSequencia(m: Maquina, arma: Arma): number
	local g = MaquinaDeCombo.golpeDe(arma, m.golpe)
	if m.estado == "Preparo" then
		return m.desde + g.preparo + g.golpe + g.recuperacao
	elseif m.estado == "Golpe" then
		return m.desde + g.golpe + g.recuperacao
	end
	return m.desde + g.recuperacao
end

-- Pedido de ataque. Retorna (aceito, motivo). Motivos: "iniciado", "guardado", "cedo", nome do estado bloqueante.
function MaquinaDeCombo.pedirAtaque(m: Maquina, arma: Arma, cfg: ConfigCombo, agora: number, pesado: boolean): (boolean, string)
	if m.estado == "Ocioso" then
		if pesado then
			iniciar(m, PESADO, agora)
		else
			iniciar(m, proximoPasso(m, arma, cfg, agora), agora)
		end
		return true, "iniciado"
	elseif m.estado == "Preparo" or m.estado == "Golpe" or m.estado == "Recuperacao" then
		if fimDaSequencia(m, arma) - agora <= cfg.combo.bufferAntecipado then
			m.fila = true
			m.filaPesado = pesado
			return true, "guardado"
		end
		return false, "cedo"
	end
	return false, m.estado
end

-- Avança o tempo. Devolve os eventos ocorridos ("Golpe" = início da janela ativa: hora de testar o acerto;
-- "FimGolpe" = recuperação terminou; "FimEsquiva"; "FimAtordoado"). Aguenta saltos grandes de tempo.
function MaquinaDeCombo.atualizar(m: Maquina, arma: Arma, cfg: ConfigCombo, agora: number): { Evento }
	local eventos: { Evento } = {}
	for _ = 1, 16 do -- limite de transições por chamada (proteção contra laço infinito)
		local mudou = false
		if m.estado == "Preparo" then
			local g = MaquinaDeCombo.golpeDe(arma, m.golpe)
			if agora >= m.desde + g.preparo then
				m.estado = "Golpe"
				m.desde += g.preparo
				table.insert(eventos, { tipo = "Golpe", golpe = m.golpe })
				mudou = true
			end
		elseif m.estado == "Golpe" then
			local g = MaquinaDeCombo.golpeDe(arma, m.golpe)
			if agora >= m.desde + g.golpe then
				m.estado = "Recuperacao"
				m.desde += g.golpe
				mudou = true
			end
		elseif m.estado == "Recuperacao" then
			local g = MaquinaDeCombo.golpeDe(arma, m.golpe)
			local fim = m.desde + g.recuperacao
			if agora >= fim then
				local golpeFeito = m.golpe
				table.insert(eventos, { tipo = "FimGolpe", golpe = golpeFeito })
				m.fimUltimoGolpe = fim
				m.ultimoPasso = if golpeFeito == PESADO then 0 else golpeFeito
				if m.fila then
					if m.filaPesado then
						iniciar(m, PESADO, fim)
					else
						local semErro = m.semErro
						iniciar(m, proximoPasso(m, arma, cfg, fim), fim)
						if m.golpe ~= 1 then
							m.semErro = semErro
						end
					end
				else
					m.estado = "Ocioso"
					m.desde = fim
					m.golpe = 0
				end
				mudou = true
			end
		elseif m.estado == "Esquiva" then
			if agora >= m.desde + cfg.esquiva.duracao then
				m.estado = "Ocioso"
				m.desde += cfg.esquiva.duracao
				table.insert(eventos, { tipo = "FimEsquiva", golpe = 0 })
				mudou = true
			end
		elseif m.estado == "Atordoado" then
			if agora >= m.atordoadoAte then
				m.estado = "Ocioso"
				m.desde = m.atordoadoAte
				table.insert(eventos, { tipo = "FimAtordoado", golpe = 0 })
				mudou = true
			end
		end
		if not mudou then
			break
		end
	end
	return eventos
end

-- Esquiva: permitida em Ocioso, Preparo (cancela o golpe), Recuperacao e Defesa; nunca na janela ativa do golpe.
function MaquinaDeCombo.pedirEsquiva(m: Maquina, cfg: ConfigCombo, agora: number): (boolean, string)
	if agora < m.esquivaLiberadaEm then
		return false, "recarga"
	end
	if m.estado == "Golpe" or m.estado == "Esquiva" or m.estado == "Atordoado" then
		return false, m.estado
	end
	if m.estado == "Preparo" or m.estado == "Recuperacao" then
		m.ultimoPasso = 0 -- cancelar quebra o combo
	end
	m.estado = "Esquiva"
	m.desde = agora
	m.golpe = 0
	m.fila = false
	m.esquivaLiberadaEm = agora + cfg.esquiva.duracao + cfg.esquiva.recarga
	return true, "iniciado"
end

function MaquinaDeCombo.iniciarDefesa(m: Maquina, agora: number): (boolean, string)
	if m.estado == "Ocioso" or m.estado == "Recuperacao" then
		if m.estado == "Recuperacao" then
			m.ultimoPasso = 0
		end
		m.estado = "Defesa"
		m.desde = agora
		m.defesaDesde = agora
		m.golpe = 0
		m.fila = false
		return true, "iniciado"
	end
	return false, m.estado
end

function MaquinaDeCombo.soltarDefesa(m: Maquina, agora: number)
	if m.estado == "Defesa" then
		m.estado = "Ocioso"
		m.desde = agora
	end
end

function MaquinaDeCombo.atordoar(m: Maquina, duracao: number, agora: number)
	m.estado = "Atordoado"
	m.desde = agora
	m.atordoadoAte = math.max(m.atordoadoAte, agora + duracao)
	m.golpe = 0
	m.fila = false
	m.ultimoPasso = 0
end

function MaquinaDeCombo.invulneravel(m: Maquina, cfg: ConfigCombo, agora: number): boolean
	if m.estado ~= "Esquiva" then
		return false
	end
	local t = agora - m.desde
	return t >= cfg.esquiva.invulInicio and t <= cfg.esquiva.invulFim
end

function MaquinaDeCombo.defendendo(m: Maquina): boolean
	return m.estado == "Defesa"
end

function MaquinaDeCombo.aparando(m: Maquina, cfg: ConfigCombo, agora: number): boolean
	return m.estado == "Defesa" and (agora - m.defesaDesde) <= cfg.aparar.janela
end

-- o servidor informa se o golpe acertou algo; um golpe vazio tira o bônus de "combo perfeito"
function MaquinaDeCombo.registrarResultado(m: Maquina, acertou: boolean)
	if not acertou then
		m.semErro = false
	end
end

function MaquinaDeCombo.comboPerfeito(m: Maquina, arma: Arma, golpe: number): boolean
	return golpe == #arma.combo and m.semErro
end

return MaquinaDeCombo
