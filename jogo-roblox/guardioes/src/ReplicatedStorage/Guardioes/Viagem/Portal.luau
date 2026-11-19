--!strict
-- NÃO EXECUTADO. Portais entre dimensões (places) — LÓGICA PURA.
-- Regras: só para dimensão liberada (requisitos), nunca para a própria, só se o place existir (placeId > 0),
-- e as mesmas da viagem rápida (a pé, fora de combate) — essas o servidor confere com Viagem.pode.
-- TeleportData chega do CLIENTE e pode ser forjado: só serve para escolher ONDE aparecer (cosmético), e mesmo
-- assim passa por lerChegada. O progresso vem sempre do DataStore.

local P = {}

-- em qual dimensão este servidor está (pelo PlaceId); sem correspondência (Studio, place 0) = o hub
function P.dimensaoAtual(placeId: number, dimensoes: { any }): string
	local hub = dimensoes[1].id
	for _, d in dimensoes do
		if d.hub then
			hub = d.id
		end
		if placeId ~= 0 and d.placeId == placeId then
			return d.id
		end
	end
	return hub
end

function P.porId(dimensoes: { any }, id: string): any?
	for _, d in dimensoes do
		if d.id == id then
			return d
		end
	end
	return nil
end

-- estado de um destino para a lista do portal: "aqui" | "emConstrucao" | "bloqueada" | "ok"
function P.estado(dim: any, atual: string, liberada: boolean): string
	if dim.id == atual then
		return "aqui"
	end
	if type(dim.placeId) ~= "number" or dim.placeId <= 0 then
		return "emConstrucao"
	end
	if not dim.hub and not liberada then
		return "bloqueada" -- voltar ao hub é sempre permitido
	end
	return "ok"
end

function P.dadosDeChegada(origem: string): { [string]: any }
	return { chegada = "Portal", de = origem }
end

-- lê o TeleportData com desconfiança: só aceita o formato exato e uma origem conhecida
function P.lerChegada(dados: any, dimensoes: { any }): string?
	if type(dados) ~= "table" or dados.chegada ~= "Portal" or type(dados.de) ~= "string" or #dados.de > 64 then
		return nil
	end
	return if P.porId(dimensoes, dados.de) then dados.de else nil
end

return P
