--!strict
-- NÃO EXECUTADO NO STUDIO. SecretRegistry: carrega e CONFERE as configs dos mistérios uma vez, na partida.
-- Entrada com erro (enigma de tipo desconhecido, marca apontando para nada…) é desligada com aviso no log,
-- em vez de quebrar o servidor. Ninguém mais lê as configs direto: todos pedem aqui.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local G = ReplicatedStorage:WaitForChild("Guardioes")
local Enigma = require(G.MysterySystems.Enigma)

local Investigacoes = require(script.Parent.Config.InvestigationChapters)
local Puzzles = require(script.Parent.Config.Puzzles)
local Secrets = require(script.Parent.Config.Secrets)
local Ocultas = require(script.Parent.Config.HiddenDimensions)
local Artefatos = require(script.Parent.Config.SecretArtifacts)

local R = {}

R.investigacoes = Investigacoes
R.puzzles = {} :: { [string]: any }
R.marcas = {} :: { [string]: any }
R.capacidades = Secrets.capacidades
R.recompensas = Secrets.recompensas
R.registros = Secrets.registros
R.conhecimentos = Secrets.conhecimentos
R.receitas = Secrets.receitas
-- pesquisas = as de Secrets + as dos artefatos ??? (nome escondido até a etapa que revela)
R.pesquisas = {} :: { [string]: any }
for id, ps in Secrets.pesquisas do
	R.pesquisas[id] = ps
end
for id, a in Artefatos do
	R.pesquisas["Artefato_" .. id] = {
		nome = a.artefato.nome, nomeOculto = "Artefato desconhecido (???)", revelaNomeNaEtapa = a.revelaNomeNaEtapa or 4,
		etapas = a.pesquisa,
	}
end
R.sal = Secrets.sal
R.dimensoes = Ocultas.dimensoes
R.portais = Ocultas.portais
R.artefatos = Artefatos

local function aviso(t: string)
	warn("[Guardioes] mistérios: " .. t)
end

for id, cfg in Puzzles do
	local ok, problema = Enigma.validarConfig(cfg)
	if ok then
		R.puzzles[id] = cfg
	else
		aviso("enigma " .. id .. " desligado (" .. tostring(problema) .. ")")
	end
end

for id, m in Secrets.marcas do
	local ok = false
	if m.tipo == "pista" then
		-- 'pista' (uma) ou 'pistas' (uma por capítulo: a mesma marca diz coisas diferentes ao longo da história)
		local inv = Investigacoes[m.investigacao]
		local lista = m.pistas or { m.pista }
		ok = #lista > 0
		for _, pistaId in lista do
			local achou = false
			for _, cap in (inv and inv.capitulos) or {} do
				if cap.pistas[pistaId] then
					achou = true
				end
			end
			ok = ok and achou
		end
	elseif m.tipo == "enigma" then
		local pz = R.puzzles[m.puzzle]
		-- elemento de enigma: 'elementos' (sequência, alinhamento…), 'itens' (coleta) ou 'alvos' (exploração)
		ok = pz ~= nil and (table.find(pz.elementos or pz.itens or pz.alvos or {}, m.elemento) ~= nil)
	elseif m.tipo == "portal" then
		ok = Ocultas.portais[m.portal] ~= nil
	end
	if ok then
		R.marcas[id] = m
	else
		aviso("marca " .. id .. " desligada (aponta para algo que não existe)")
	end
end

-- configuração de uma pista (em qualquer capítulo) e o número do capítulo
function R.pista(invId: string, pistaId: string): (any?, number?)
	local inv = Investigacoes[invId]
	for n, cap in (inv and inv.capitulos) or {} do
		if cap.pistas[pistaId] then
			return cap.pistas[pistaId], n
		end
	end
	return nil, nil
end

-- onde está cada enigma na investigação (para marcar o objetivo certo)
function R.investigacao(id: string): any?
	return Investigacoes[id]
end

return R
