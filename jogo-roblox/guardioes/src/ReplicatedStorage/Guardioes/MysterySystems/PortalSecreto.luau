--!strict
-- NÃO EXECUTADO. PASSAGENS SECRETAS (SecretDimensionService, seção 8) — LÓGICA PURA.
-- Estados por jogador: "oculto" (não descoberto) → "selado" (descoberto, condições ainda não cumpridas) →
-- "aberto" (pode atravessar). Atravessar ainda exige que o DESTINO exista: um place (placeId > 0) ou uma área
-- deste place (noPlace = true). Sem nenhum dos dois, o estado é "emConstrucao" e ninguém viaja para o nada.

local PS = {}

-- descoberto: o perfil tem a marca; cumpre: as condições do portal (avaliadas pelo servidor com Requisitos)
function PS.estado(descoberto: boolean, cumpre: boolean): string
	if not descoberto then
		return "oculto"
	end
	return if cumpre then "aberto" else "selado"
end

-- pode atravessar agora? (estado, destino, grupo)
function PS.podeAtravessar(estado: string, destino: any?, tamanhoDoGrupo: number, portal: any): (boolean, string)
	if estado == "oculto" then
		return false, "naoDescoberto"
	end
	if estado == "selado" then
		return false, "portalSelado"
	end
	local temPlace = destino ~= nil and type(destino.placeId) == "number" and destino.placeId > 0
	if not destino or not (temPlace or destino.noPlace == true) then
		return false, "emConstrucao"
	end
	local g = portal.grupo or { min = 1, max = 1 }
	if tamanhoDoGrupo < (g.min or 1) then
		return false, "grupoPequeno"
	end
	if tamanhoDoGrupo > (g.max or 1) then
		return false, "grupoGrande"
	end
	return true, "ok"
end

return PS
