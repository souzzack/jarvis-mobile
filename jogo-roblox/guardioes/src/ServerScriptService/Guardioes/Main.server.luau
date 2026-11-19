--!strict
-- NÃO EXECUTADO NO STUDIO. Ponto de entrada do servidor de Guardiões do Multiverso.
-- Carrega os sistemas na ordem, chama Init em todos e depois Start em todos.
-- Coexistência: não toca em ServerScriptService.Magnata nem em nada do tycoon antigo.

local Sistemas = script.Parent:WaitForChild("Sistemas")

type Sistema = { Nome: string, Init: (ctx: any) -> (), Start: () -> () }

-- ordem importa só para o Init; no Start todos já se conhecem
local ORDEM = { "EnemySystem", "CombatSystem" }

local carregados: { [string]: Sistema } = {}
local ctx = {}
function ctx.obter(nome: string): any
	local s = carregados[nome]
	assert(s, "sistema não carregado: " .. nome)
	return s
end

for _, nome in ORDEM do
	local mod = Sistemas:FindFirstChild(nome)
	assert(mod and mod:IsA("ModuleScript"), "faltou o módulo " .. nome)
	carregados[nome] = require(mod) :: any
end

for _, nome in ORDEM do
	carregados[nome].Init(ctx)
end
for _, nome in ORDEM do
	task.spawn(carregados[nome].Start)
end

print("[Guardioes] servidor iniciado: " .. table.concat(ORDEM, ", "))
