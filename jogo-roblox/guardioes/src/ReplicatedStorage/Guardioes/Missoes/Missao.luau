--!strict
-- NÃO EXECUTADO. Progresso de missão — LÓGICA PURA.
-- Objetivo = { id, tipo, alvo, qtd }. Evento = { tipo, alvo, qtd? }. Um evento avança todo objetivo de mesmo
-- tipo e alvo ("*" no alvo do objetivo aceita qualquer um). Contagem nunca passa da meta.
-- Tipos usados hoje: derrotar, derrotarComCriatura, ler, montar, voar, planar, evento.

export type Objetivo = { id: string, tipo: string, alvo: string, qtd: number, descricao: string? }
export type Evento = { tipo: string, alvo: string, qtd: number? }

local Mi = {}

-- devolve (mudou, concluida)
function Mi.registrar(progresso: { [string]: number }, missao: any, ev: Evento): (boolean, boolean)
	local mudou = false
	for _, o in missao.objetivos do
		if o.tipo == ev.tipo and (o.alvo == "*" or o.alvo == ev.alvo) then
			local atual = progresso[o.id] or 0
			if atual < o.qtd then
				progresso[o.id] = math.min(o.qtd, atual + (ev.qtd or 1))
				mudou = true
			end
		end
	end
	return mudou, Mi.concluida(progresso, missao)
end

function Mi.concluida(progresso: { [string]: number }, missao: any): boolean
	for _, o in missao.objetivos do
		if (progresso[o.id] or 0) < o.qtd then
			return false
		end
	end
	return true
end

-- texto curto de acompanhamento ("Faíscas derrotadas 3/5")
function Mi.resumo(progresso: { [string]: number }, missao: any): { string }
	local linhas = {}
	for _, o in missao.objetivos do
		table.insert(linhas, string.format("%s %d/%d", o.descricao or o.id, math.min(o.qtd, progresso[o.id] or 0), o.qtd))
	end
	return linhas
end

return Mi
