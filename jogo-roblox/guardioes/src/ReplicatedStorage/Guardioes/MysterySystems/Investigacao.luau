--!strict
-- NÃO EXECUTADO. INVESTIGAÇÃO (Mistérios, complemento 03, seção 4) — LÓGICA PURA, sem nenhum segredo dentro.
-- O conteúdo (capítulos, pistas, objetivos, textos) vem de ServerScriptService/Guardioes/MysterySystems/Config
-- e é passado como 'cfg'. Estados: Undiscovered → Discovered → Investigating → ReadyToSolve → Completed.
--  * Uma investigação tem CAPÍTULOS; só capítulos com lancado = true aceitam pistas/objetivos/conclusão.
--  * Completed só quando TODOS os capítulos foram concluídos (um capítulo não lançado nunca é concluído).
--  * Toda mudança passa por estas funções no SERVIDOR; o cliente nunca envia pistas nem objetivos.

export type Estado = "Undiscovered" | "Discovered" | "Investigating" | "ReadyToSolve" | "Completed"
export type Progresso = {
	estado: string,
	capitulo: number, -- capítulo atual (1..#capitulos)
	pistas: { [string]: boolean },
	objetivos: { [string]: boolean },
	capitulosConcluidos: { [string]: boolean }, -- chave = tostring(n)
	versaoConteudo: number,
}

local I = {}

I.ESTADOS = { "Undiscovered", "Discovered", "Investigating", "ReadyToSolve", "Completed" }

function I.novo(cfg: any): Progresso
	return { estado = "Undiscovered", capitulo = 1, pistas = {}, objetivos = {}, capitulosConcluidos = {}, versaoConteudo = cfg.versaoConteudo or 1 }
end

local function capituloAtual(p: Progresso, cfg: any): any?
	return cfg.capitulos[p.capitulo]
end

-- objetivo cumprido? ("pistas": todas as pistas listadas; "enigma"/"evento": marcado pelo servidor)
local function objetivoFeito(p: Progresso, obj: any): boolean
	if obj.tipo == "pistas" then
		for _, id in obj.pistas do
			if not p.pistas[id] then
				return false
			end
		end
		return true
	end
	return p.objetivos[obj.id] == true
end

-- objetivos que o jogador JÁ PODE ver (visivelApos = outro objetivo cumprido)
function I.objetivosVisiveis(p: Progresso, cfg: any): { any }
	local cap = capituloAtual(p, cfg)
	local l = {}
	if not cap or not cap.lancado then
		return l
	end
	local porId = {}
	for _, o in cap.objetivos do
		porId[o.id] = o
	end
	for _, o in cap.objetivos do
		local pre = o.visivelApos and porId[o.visivelApos]
		if not pre or objetivoFeito(p, pre) then
			table.insert(l, { id = o.id, nome = o.nome, feito = objetivoFeito(p, o), tipo = o.tipo })
		end
	end
	return l
end

function I.recalcular(p: Progresso, cfg: any): string
	if p.estado == "Undiscovered" then
		return p.estado
	end
	local todos = true
	for n = 1, #cfg.capitulos do
		if not p.capitulosConcluidos[tostring(n)] then
			todos = false
		end
	end
	if todos then
		p.estado = "Completed"
		return p.estado
	end
	local cap = capituloAtual(p, cfg)
	if not cap or not cap.lancado then
		p.estado = "Investigating" -- esperando o próximo capítulo ser lançado
		return p.estado
	end
	-- pronto para resolver: tudo feito menos o(s) objetivo(s) final(is) (tipo enigma/evento)
	local faltamPistas, faltamFinais = false, false
	local algumaPista = false
	for _, o in cap.objetivos do
		if not objetivoFeito(p, o) then
			if o.tipo == "pistas" then
				faltamPistas = true
			else
				faltamFinais = true
			end
		end
	end
	for id in cap.pistas do
		if p.pistas[id] then
			algumaPista = true
		end
	end
	if not faltamPistas and faltamFinais then
		p.estado = "ReadyToSolve"
	elseif algumaPista then
		p.estado = "Investigating"
	else
		p.estado = "Discovered"
	end
	return p.estado
end

function I.descobrir(p: Progresso, cfg: any): boolean
	if p.estado ~= "Undiscovered" then
		return false
	end
	p.estado = "Discovered"
	I.recalcular(p, cfg)
	return true
end

-- (ok, motivo). A pista precisa existir no capítulo ATUAL e lançado.
function I.registrarPista(p: Progresso, cfg: any, pistaId: string): (boolean, string)
	local cap = capituloAtual(p, cfg)
	if not cap or not cap.lancado then
		return false, "capituloIndisponivel"
	end
	if not cap.pistas[pistaId] then
		return false, "pistaDeOutroCapitulo"
	end
	if p.pistas[pistaId] then
		return false, "jaRegistrada"
	end
	if p.estado == "Undiscovered" then
		if cfg.descobertaPor ~= pistaId and not cap.pistas[pistaId].descobre then
			return false, "naoDescoberta" -- esta pista só faz sentido depois de achar o começo da investigação
		end
		p.estado = "Discovered"
	end
	p.pistas[pistaId] = true
	I.recalcular(p, cfg)
	return true, "ok"
end

-- objetivo marcado pelo servidor (enigma resolvido, evento). Só se estiver visível e no capítulo atual.
function I.registrarObjetivo(p: Progresso, cfg: any, objetivoId: string): (boolean, string)
	if p.estado == "Undiscovered" then
		return false, "naoDescoberta"
	end
	local visivel = false
	for _, o in I.objetivosVisiveis(p, cfg) do
		if o.id == objetivoId and o.tipo ~= "pistas" then
			visivel = true
		end
	end
	if not visivel then
		return false, "objetivoIndisponivel"
	end
	if p.objetivos[objetivoId] then
		return false, "jaRegistrado"
	end
	p.objetivos[objetivoId] = true
	I.recalcular(p, cfg)
	return true, "ok"
end

-- conclui o capítulo atual (todos os objetivos). Devolve (ok, motivo, recompensaId?)
function I.concluirCapitulo(p: Progresso, cfg: any): (boolean, string, string?)
	local cap = capituloAtual(p, cfg)
	if not cap or not cap.lancado then
		return false, "capituloIndisponivel", nil
	end
	for _, o in cap.objetivos do
		if not objetivoFeito(p, o) then
			return false, "faltamObjetivos", nil
		end
	end
	local chave = tostring(p.capitulo)
	if p.capitulosConcluidos[chave] then
		return false, "jaConcluido", nil
	end
	p.capitulosConcluidos[chave] = true
	if p.capitulo < #cfg.capitulos then
		p.capitulo += 1
	end
	I.recalcular(p, cfg)
	return true, "ok", cap.recompensa
end

-- confere um progresso salvo contra a configuração (antes de gravar e ao carregar): nada impossível
function I.validar(p: any, cfg: any): (boolean, string?)
	if type(p) ~= "table" or not table.find(I.ESTADOS, p.estado) then
		return false, "estado"
	end
	if type(p.capitulo) ~= "number" or p.capitulo < 1 or p.capitulo > #cfg.capitulos or p.capitulo ~= math.floor(p.capitulo) then
		return false, "capitulo"
	end
	for chave in p.capitulosConcluidos do
		local n = tonumber(chave)
		local cap = n and cfg.capitulos[n]
		if not cap or not cap.lancado then
			return false, "capituloNaoLancado" -- nunca concluir capítulo futuro
		end
	end
	for id in p.pistas do
		local existe = false
		for _, cap in cfg.capitulos do
			if cap.pistas and cap.pistas[id] then
				existe = true
			end
		end
		if not existe then
			return false, "pistaInexistente"
		end
	end
	if p.estado == "Completed" then
		for n = 1, #cfg.capitulos do
			if not p.capitulosConcluidos[tostring(n)] then
				return false, "completedSemCapitulos"
			end
		end
	end
	return true, nil
end

return I
