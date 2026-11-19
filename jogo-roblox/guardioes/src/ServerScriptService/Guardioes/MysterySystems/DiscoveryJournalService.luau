--!strict
-- NÃO EXECUTADO NO STUDIO. DiscoveryJournalService: monta e envia o ATLAS DOS ARQUIVISTAS (seção 5).
-- Usa MysterySystems/Diario (lógica pura) e preenche os textos das pistas com a ordem DO JOGADOR. Só vai para o
-- cliente o que ele já descobriu; investigações não descobertas não existem para ele.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local G = ReplicatedStorage:WaitForChild("Guardioes")
local Diario = require(G.MysterySystems.Diario)

local S = {}
local deps: any = nil

function S.iniciar(d: any)
	deps = d
end

local function textoDaPista(p: Player): (string, string, any) -> string
	return function(invId: string, _pistaId: string, pc: any): string
		local texto = pc.texto
		if string.find(texto, "{%d}") then
			-- o enigma do capítulo desta investigação que usa a ordem
			local nomes = {}
			for puzzleId, cfg in deps.registro.puzzles do
				if cfg.objetivo and cfg.objetivo.investigacao == invId and cfg.nomes then
					for i, el in deps.puzzles.ordemDe(p, puzzleId) do
						nomes[tostring(i)] = cfg.nomes[el] or "?"
					end
				end
			end
			texto = string.gsub(texto, "{(%d)}", function(n: string)
				return nomes[n] or "?"
			end)
		end
		return texto
	end
end

function S.montar(p: Player): any?
	local perfil = deps.playerData.obter(p)
	if not perfil then
		return nil
	end
	local portaisCfg = {}
	for id, pc in deps.registro.portais do
		portaisCfg[id] = { nome = pc.nome }
	end
	local m = table.clone(perfil.misterios)
	m.portais = deps.portais.paraDiario(perfil)
	local v = Diario.montar(m, {
		investigacoes = deps.registro.investigacoes, registros = deps.registro.registros,
		conhecimentos = deps.registro.conhecimentos, receitas = deps.registro.receitas, portais = portaisCfg,
	}, textoDaPista(p), deps.Investigacao)
	v.pesquisas = deps.pesquisa.paraDiario(p, perfil)
	return v
end

return S
