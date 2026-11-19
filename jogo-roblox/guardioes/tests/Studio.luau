--!strict
-- NÃO EXECUTADO. Rodar os testes no Roblox Studio (com o Rojo sincronizado, fica em ServerStorage.GuardioesTestes).
-- Na barra de comandos do Studio (modo Edit ou Run):
--   require(game.ServerStorage.GuardioesTestes.Studio)()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rodar = require(script.Parent.Rodar)

return function()
	local G = ReplicatedStorage:WaitForChild("Guardioes")
	local M = {
		MaquinaDeCombo = require(G.Combate.MaquinaDeCombo),
		Dano = require(G.Combate.Dano),
		Estamina = require(G.Combate.Estamina),
		Postura = require(G.Combate.Postura),
		Alcance = require(G.Combate.Alcance),
		LimiteDeTaxa = require(G.Util.LimiteDeTaxa),
		Raridades = require(G.Config.Raridades),
		CfgCombate = require(G.Config.Combate),
		Espada = require(G.Config.Armas.Espada),
	}
	local specs = {}
	for _, m in script.Parent.Specs:GetChildren() do
		if m:IsA("ModuleScript") then
			table.insert(specs, { nome = m.Name, fn = require(m) :: any })
		end
	end
	table.sort(specs, function(a, b)
		return a.nome < b.nome
	end)
	return Rodar(M, specs)
end
