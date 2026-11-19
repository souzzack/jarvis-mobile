--!strict
-- NÃO EXECUTADO. Regras de uso de uma habilidade especial — LÓGICA PURA.
-- Pode usar se: a forma ativa do artefato é a da especial (ou, saindo da locomoção, se o estágio permite
-- o uso em voo), não está em recarga e há estamina. O servidor desconta estamina e aplica o efeito.

export type Contexto = {
	formaAtiva: string?, -- nil durante a troca de forma
	tipoAtivo: string?, -- "Combate" | "Defesa" | "Locomocao"
	estagio: number,
	agora: number,
	recargaAte: number,
	estamina: number,
}

local E = {}

-- (pode, motivo, saiDaLocomocao)
function E.pode(esp: any, c: Contexto): (boolean, string, boolean)
	if c.formaAtiva == nil then
		return false, "transformando", false
	end
	local saindo = false
	if c.formaAtiva ~= esp.forma then
		if c.tipoAtivo == "Locomocao" and esp.usoEmVoo and c.estagio >= esp.usoEmVoo then
			saindo = true
		elseif c.tipoAtivo == "Locomocao" then
			return false, "formaDeLocomocao", false
		else
			return false, "outraForma", false
		end
	end
	if c.agora < c.recargaAte then
		return false, "recarga", false
	end
	if c.estamina < (esp.custoEstamina or 0) then
		return false, "estamina", false
	end
	return true, "ok", saindo
end

return E
