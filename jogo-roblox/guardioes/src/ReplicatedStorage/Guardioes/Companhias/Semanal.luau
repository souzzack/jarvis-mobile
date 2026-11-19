--!strict
-- NÃO EXECUTADO. Objetivos semanais da companhia — LÓGICA PURA (sem require: roda igual no Studio e no Lune).
-- Estado guardado no registro da companhia (c.semanal):
--   { semana, objetivos = { { id, tipo, alvo, feito, concluido } }, contribuicao = { [objId] = { [uid] = qtd } } }

local S = {}

local DIA = 86400
local SEGUNDA_1970 = 4 * DIA -- 01/01/1970 foi quinta; a primeira segunda foi 05/01

function S.semana(agora: number): number
	return (agora - SEGUNDA_1970) // (7 * DIA)
end

function S.fimDaSemana(semana: number): number
	return SEGUNDA_1970 + (semana + 1) * 7 * DIA
end

local function hash(texto: string): number
	local h = 2166136261
	for i = 1, #texto do
		h = bit32.bxor(h, string.byte(texto, i))
		h = ((h % 256) * 16777216 + h * 403) % 4294967296 -- FNV-1a sem passar de 2^53
	end
	return h
end

-- índices sorteados (sem repetir) de 1..total; fixo por (companhia, semana)
function S.sortear(companhiaId: string, semana: number, total: number, quantos: number): { number }
	local s = hash(companhiaId .. "#" .. semana)
	local t = {}
	for i = 1, total do
		t[i] = i
	end
	for i = total, 2, -1 do
		s = (s * 1664525 + 1013904223) % 4294967296
		local j = (s % i) + 1
		t[i], t[j] = t[j], t[i]
	end
	local r = {}
	for i = 1, math.min(quantos, total) do
		r[i] = t[i]
	end
	return r
end

function S.alvo(base: number, membros: number, cfg: any): number
	local f = math.min(cfg.tetoCrescimento, 1 + cfg.crescimentoPorMembro * math.max(0, membros - 1))
	return math.max(1, math.floor(base * f + 0.5))
end

-- estado da semana atual: o mesmo, ou um novo se a semana virou. Não muda o estado recebido.
function S.preparar(estado: any?, companhiaId: string, agora: number, membros: number, cfg: any): (any, boolean)
	local sem = S.semana(agora)
	if estado and estado.semana == sem then
		return estado, false
	end
	local objs = {}
	local contrib = {}
	for _, i in S.sortear(companhiaId, sem, #cfg.lista, cfg.porSemana) do
		local o = cfg.lista[i]
		table.insert(objs, { id = o.id, tipo = o.tipo, alvo = S.alvo(o.alvo, membros, cfg), feito = 0, concluido = false })
		contrib[o.id] = {}
	end
	return { semana = sem, objetivos = objs, contribuicao = contrib }, true
end

-- soma progresso de um tipo (todos os objetivos abertos daquele tipo). uid em texto.
function S.registrar(estado: any, tipo: string, uid: string, qtd: number): boolean
	if qtd <= 0 then
		return false
	end
	local mudou = false
	for _, o in estado.objetivos do
		if o.tipo == tipo and not o.concluido then
			o.feito = math.min(o.alvo, o.feito + qtd)
			local c = estado.contribuicao[o.id]
			c[uid] = (c[uid] or 0) + qtd
			mudou = true
		end
	end
	return mudou
end

-- marca os que acabaram de concluir. Devolve { { id, contribuintes = { uid } } } (uma vez só por objetivo)
function S.concluir(estado: any, membros: number, cfg: any): { any }
	local novos = {}
	local minimo = math.min(cfg.minContribuintes, math.max(1, membros))
	for _, o in estado.objetivos do
		if not o.concluido and o.feito >= o.alvo then
			local quem = {}
			for uid, q in estado.contribuicao[o.id] do
				if q > 0 then
					table.insert(quem, uid)
				end
			end
			if #quem >= minimo then
				o.concluido = true
				table.sort(quem)
				table.insert(novos, { id = o.id, contribuintes = quem })
			end
		end
	end
	return novos
end

return S
