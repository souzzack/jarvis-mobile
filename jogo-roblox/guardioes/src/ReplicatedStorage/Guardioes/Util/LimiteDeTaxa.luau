--!strict
-- NÃO EXECUTADO. Balde de fichas para limitar pedidos de rede por jogador. LÓGICA PURA (tempo vem de fora).

export type Balde = { fichas: number, capacidade: number, recargaPorSeg: number, t: number, excedidos: number }

local LimiteDeTaxa = {}

function LimiteDeTaxa.novo(capacidade: number, recargaPorSeg: number, agora: number): Balde
	return { fichas = capacidade, capacidade = capacidade, recargaPorSeg = recargaPorSeg, t = agora, excedidos = 0 }
end

function LimiteDeTaxa.consumir(b: Balde, agora: number, n: number?): boolean
	local custo = n or 1
	if agora > b.t then
		b.fichas = math.min(b.capacidade, b.fichas + (agora - b.t) * b.recargaPorSeg)
		b.t = agora
	end
	if b.fichas + 1e-9 >= custo then
		b.fichas -= custo
		return true
	end
	b.excedidos += 1
	return false
end

return LimiteDeTaxa
