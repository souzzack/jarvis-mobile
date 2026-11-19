--!strict
-- NÃO EXECUTADO. MovementStateMachine: o estado de locomoção de UM personagem. LÓGICA PURA (tempo e contexto
-- vêm de fora). O servidor roda a oficial; o cliente roda uma cópia para responder na hora.
--
-- Estados (nomes do documento → aqui):
--   Grounded=Solo · Takeoff=Decolagem · Hover=Pairar · Flight=Voo · Boost=Impulso · Descent=Descida
--   Landing=Pouso · Interrupted=Interrompido · (extras) Planando · Montado
--
-- Regra central: existe UM 'modo' por vez (o perfil que move o corpo). Não há dois voos, nem voo + montaria,
-- nem prancha + planador ao mesmo tempo: toda entrada num modo exige sair do anterior.
--
--   Solo ──decolar──▶ Decolagem ──(tempo)──▶ Pairar ◀──(parado/movendo)──▶ Voo ◀──impulso──▶ Impulso
--    ▲  ▲                                          │ pousar                    │
--    │  └──(tempo)── Pouso ◀──(tocou o chão)── Descida ◀──────────────────────┘
--    │                                             ▲
--    │                     Interrompido ──(tempo)──┘   (energia 0, zona proibida, atordoado, golpe forte)
--    └─(tocou o chão)── Planando ◀──abrirPlanador── Solo no ar / Descida / Interrompido
--   Solo ◀─desmontar─▶ Montado ──decolar(montaria voadora)──▶ Decolagem … Pouso ──▶ Montado

export type Estado = "Solo" | "Decolagem" | "Pairar" | "Voo" | "Impulso" | "Descida" | "Pouso" | "Interrompido" | "Planando" | "Montado"

export type Maquina = {
	estado: Estado,
	desde: number,
	modo: string?, -- id do perfil ativo (nil = a pé)
	tipoModo: string?, -- "Motorizado" | "Plataforma" | "Planador" | "Montaria"
	montariaId: string?, -- guid da criatura montada (fica até desmontar)
	interrompidoAte: number,
	motivo: string?,
}

-- o que o servidor (ou o cliente) mede do mundo a cada passo
export type Contexto = {
	noSolo: boolean,
	altura: number, -- studs acima do chão
	zonaProibida: boolean, -- zona sem voo (interiores, arenas de chefe, áreas de história)
	espacoLivre: boolean, -- há espaço acima/em volta para decolar ou montar
	atordoado: boolean,
	energia: number,
	movendo: boolean, -- há entrada horizontal
}

export type PerfilMin = { id: string, tipo: string, decolagem: number, pouso: number, velImpulso: number, montaria: boolean? }
export type Evento = { tipo: string, motivo: string? }

local NO_AR: { [string]: boolean } = { Decolagem = true, Pairar = true, Voo = true, Impulso = true, Descida = true, Interrompido = true, Planando = true }
local MOTORIZADO: { [string]: boolean } = { Decolagem = true, Pairar = true, Voo = true, Impulso = true }

local M = {}

function M.nova(agora: number): Maquina
	return { estado = "Solo", desde = agora, modo = nil, tipoModo = nil, montariaId = nil, interrompidoAte = -math.huge, motivo = nil }
end

local function ir(m: Maquina, e: Estado, agora: number)
	m.estado = e
	m.desde = agora
end

local function voltarAoChao(m: Maquina, agora: number)
	if m.montariaId then
		ir(m, "Montado", agora)
		m.modo, m.tipoModo = "Montaria", "Montaria"
	else
		ir(m, "Solo", agora)
		m.modo, m.tipoModo = nil, nil
	end
	m.motivo = nil
end

function M.noAr(m: Maquina): boolean
	return NO_AR[m.estado] == true
end

function M.motorizado(m: Maquina): boolean
	return MOTORIZADO[m.estado] == true
end

-- ataque de arma só a pé e parado no chão (a prancha nunca causa dano de espada)
function M.podeAtacar(m: Maquina): boolean
	return m.estado == "Solo"
end

-- a energia de voo só recupera a pé ou montado no chão
function M.recuperaEnergia(m: Maquina): boolean
	return m.estado == "Solo" or m.estado == "Montado"
end

-- Decolar com um perfil motorizado ou plataforma. Retorna (aceito, motivo).
function M.decolar(m: Maquina, p: PerfilMin, ctx: Contexto, energiaMin: number, agora: number): (boolean, string)
	local deMontaria = m.estado == "Montado"
	if not (m.estado == "Solo" or m.estado == "Planando" or deMontaria) then
		return false, m.estado
	end
	-- perfil de montaria voadora só a partir de Montado; perfis próprios nunca enquanto montado
	if deMontaria and not p.montaria then
		return false, "montado"
	end
	if not deMontaria and p.montaria then
		return false, "semMontaria"
	end
	if ctx.zonaProibida then
		return false, "zonaProibida"
	end
	if ctx.atordoado then
		return false, "atordoado"
	end
	if not ctx.espacoLivre then
		return false, "semEspaco"
	end
	if ctx.energia < energiaMin then
		return false, "energia"
	end
	ir(m, "Decolagem", agora)
	m.modo = p.id
	m.tipoModo = p.tipo
	return true, "iniciado"
end

function M.abrirPlanador(m: Maquina, p: PerfilMin, ctx: Contexto, alturaMin: number, agora: number): (boolean, string)
	if not (m.estado == "Solo" or m.estado == "Descida" or m.estado == "Interrompido") then
		return false, m.estado
	end
	if m.montariaId then
		return false, "montado"
	end
	if ctx.noSolo or ctx.altura < alturaMin then
		return false, "baixo"
	end
	if ctx.atordoado then
		return false, "atordoado"
	end
	ir(m, "Planando", agora)
	m.modo = p.id
	m.tipoModo = "Planador"
	return true, "iniciado"
end

function M.fecharPlanador(m: Maquina, agora: number): (boolean, string)
	if m.estado ~= "Planando" then
		return false, m.estado
	end
	ir(m, "Solo", agora) -- cai normalmente (o personagem volta à física comum)
	m.modo, m.tipoModo = nil, nil
	return true, "fechado"
end

function M.impulso(m: Maquina, p: PerfilMin, ligar: boolean, agora: number): (boolean, string)
	if ligar then
		if not (m.estado == "Voo" or m.estado == "Pairar") then
			return false, m.estado
		end
		if p.velImpulso <= 0 then
			return false, "semImpulso"
		end
		ir(m, "Impulso", agora)
	elseif m.estado == "Impulso" then
		ir(m, "Voo", agora)
	end
	return true, "ok"
end

function M.pousar(m: Maquina, agora: number): (boolean, string)
	if not (m.estado == "Pairar" or m.estado == "Voo" or m.estado == "Impulso") then
		return false, m.estado
	end
	ir(m, "Descida", agora)
	return true, "iniciado"
end

function M.montar(m: Maquina, montariaId: string, ctx: Contexto, agora: number): (boolean, string)
	if m.estado ~= "Solo" then
		return false, m.estado
	end
	if not ctx.noSolo then
		return false, "noAr"
	end
	if ctx.zonaProibida then
		return false, "zonaProibida"
	end
	if not ctx.espacoLivre then
		return false, "semEspaco"
	end
	if ctx.atordoado then
		return false, "atordoado"
	end
	m.montariaId = montariaId
	ir(m, "Montado", agora)
	m.modo, m.tipoModo = "Montaria", "Montaria"
	return true, "iniciado"
end

function M.desmontar(m: Maquina, agora: number): (boolean, string)
	if m.estado ~= "Montado" then
		return false, if m.montariaId then "emVoo" else m.estado
	end
	m.montariaId = nil
	ir(m, "Solo", agora)
	m.modo, m.tipoModo = nil, nil
	return true, "ok"
end

-- Interrupção forçada (energia, zona, golpe, atordoamento, troca de forma de artefato). Só no ar.
function M.interromper(m: Maquina, motivo: string, duracao: number, agora: number): boolean
	if not M.noAr(m) or m.estado == "Interrompido" then
		return false
	end
	ir(m, "Interrompido", agora)
	m.interrompidoAte = agora + duracao
	m.motivo = motivo
	return true
end

-- Volta ao chão sem transição (renascer, desconectar, teleporte do servidor). A montaria é liberada.
function M.reiniciar(m: Maquina, agora: number)
	m.montariaId = nil
	voltarAoChao(m, agora)
end

-- Avança o tempo e aplica regras automáticas. Devolve eventos para efeitos e para a rede.
function M.atualizar(m: Maquina, p: PerfilMin?, ctx: Contexto, duracaoInterrupcao: number, agora: number): { Evento }
	local ev: { Evento } = {}
	local e = m.estado

	-- regras de segurança que valem para todo voo motorizado
	if MOTORIZADO[e] or e == "Descida" then
		local motivo: string? = nil
		if ctx.zonaProibida then
			motivo = "zonaProibida"
		elseif ctx.atordoado then
			motivo = "atordoado"
		elseif ctx.energia <= 0 and e ~= "Descida" then
			motivo = "energia"
		end
		if motivo then
			M.interromper(m, motivo, duracaoInterrupcao, agora)
			table.insert(ev, { tipo = "Interrompido", motivo = motivo })
			return ev
		end
	end

	if e == "Decolagem" then
		if p and agora >= m.desde + p.decolagem then
			ir(m, "Pairar", agora)
			table.insert(ev, { tipo = "Decolou" })
		end
	elseif e == "Pairar" then
		if ctx.movendo then
			ir(m, "Voo", agora)
		end
	elseif e == "Voo" then
		if not ctx.movendo then
			ir(m, "Pairar", agora)
		end
	elseif e == "Descida" then
		if ctx.noSolo or ctx.altura <= 0.5 then
			ir(m, "Pouso", agora)
			table.insert(ev, { tipo = "TocouSolo" })
		end
	elseif e == "Pouso" then
		if not p or agora >= m.desde + p.pouso then
			voltarAoChao(m, agora)
			table.insert(ev, { tipo = "Pousou" })
		end
	elseif e == "Interrompido" then
		if ctx.noSolo then
			voltarAoChao(m, agora)
			table.insert(ev, { tipo = "Pousou" })
		elseif agora >= m.interrompidoAte then
			ir(m, "Descida", agora) -- queda amortecida até o chão; o planador pode ser aberto
		end
	elseif e == "Planando" then
		if ctx.noSolo then
			voltarAoChao(m, agora)
			table.insert(ev, { tipo = "Pousou" })
		elseif ctx.atordoado then
			ir(m, "Solo", agora)
			m.modo, m.tipoModo = nil, nil
			table.insert(ev, { tipo = "Interrompido", motivo = "atordoado" })
		end
	end

	-- voo motorizado encostando no chão (sem pedir pouso): pousa sozinho, depois de um respiro após decolar
	if (m.estado == "Pairar" or m.estado == "Voo") and ctx.noSolo and agora - m.desde > 0.3 and m.tipoModo ~= "Plataforma" then
		ir(m, "Pouso", agora)
		table.insert(ev, { tipo = "TocouSolo" })
	end
	return ev
end

return M
