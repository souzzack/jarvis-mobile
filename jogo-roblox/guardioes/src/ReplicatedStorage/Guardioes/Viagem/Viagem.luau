--!strict
-- NÃO EXECUTADO. Regras da viagem rápida — LÓGICA PURA.
-- Só para pontos já DESCOBERTOS (ou a própria base), a pé e fora de combate, com recarga.
-- (A viagem nunca é atalho para fugir de luta: dano recente bloqueia.)

export type Contexto = {
	descoberto: boolean,
	estado: string, -- estado de locomoção
	montado: boolean,
	agora: number,
	ultimoDano: number,
	ultimaViagem: number,
	semCombateSeg: number,
	recargaSeg: number,
}

local V = {}

function V.pode(c: Contexto): (boolean, string)
	if not c.descoberto then
		return false, "naoDescoberto"
	end
	if c.estado ~= "Solo" or c.montado then
		return false, "locomocao"
	end
	if c.agora - c.ultimoDano < c.semCombateSeg then
		return false, "emCombate"
	end
	if c.agora - c.ultimaViagem < c.recargaSeg then
		return false, "recarga"
	end
	return true, "ok"
end

-- descoberta por proximidade (o servidor mede a distância)
function V.descobre(distancia: number, raio: number): boolean
	return distancia <= raio
end

return V
