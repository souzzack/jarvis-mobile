--!strict
-- NÃO EXECUTADO. Nível do jogador (1 a 60) — LÓGICA PURA. Valores (T).
-- XP para passar do nível n: floor(100 × n^1,5). Vida máxima: 100 + 4 por nível, × modificador de raça.

local N = {}
N.MAX = 60

function N.xpParaProximo(n: number): number
	return math.floor(100 * n ^ 1.5)
end

-- soma XP e sobe quantos níveis couberem. No nível máximo a XP para de acumular.
-- Retorna (nivel, xp, niveisGanhos).
function N.ganhar(nivel: number, xp: number, quanto: number): (number, number, number)
	if quanto <= 0 or nivel >= N.MAX then
		return nivel, (if nivel >= N.MAX then 0 else xp), 0
	end
	local ganhos = 0
	xp += math.floor(quanto)
	while nivel < N.MAX and xp >= N.xpParaProximo(nivel) do
		xp -= N.xpParaProximo(nivel)
		nivel += 1
		ganhos += 1
	end
	if nivel >= N.MAX then
		xp = 0
	end
	return nivel, xp, ganhos
end

function N.vidaMaxima(nivel: number, multiplicadorRaca: number?): number
	return math.floor((100 + 4 * (nivel - 1)) * (multiplicadorRaca or 1))
end

return N
