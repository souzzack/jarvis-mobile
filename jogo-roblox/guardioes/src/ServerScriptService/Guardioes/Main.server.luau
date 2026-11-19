--!strict
-- NÃO EXECUTADO NO STUDIO. Ponto de entrada do servidor de Guardiões do Multiverso.
-- Carrega os sistemas na ordem, chama Init em todos e depois Start em todos.
-- Coexistência: não toca em ServerScriptService.Magnata nem em nada do tycoon antigo.

local Sistemas = script.Parent:WaitForChild("Sistemas")

type Sistema = { Nome: string, Init: (ctx: any) -> (), Start: () -> () }

-- ordem importa só para o Init; no Start todos já se conhecem
local ORDEM = {
	"PlayerDataSystem", -- perfil salvo (os outros escutam 'carregado')
	"EnemySystem",
	"CombatSystem",
	"MovementAbilitySystem", -- habilidades e raça (antes do movimento, que lê os dois)
	"MovementSystem", -- locomoção: voo, planador, prancha (núcleo único)
	"InventorySystem", -- materiais e artefatos com GUID (salvos + teste em memória)
	"MetamorphicArtifactSystem", -- formas dos artefatos (usa movimento, combate e inventário)
	"SpecialAbilitySystem", -- habilidades especiais de armas e escudos
	"CompanionSystem", -- criaturas companheiras, IA, crescimento
	"MountSystem", -- montarias (usa companheiros e movimento)
	"ProgressionSystem", -- nível, XP e vida por raça
	"RaceSystem", -- escolha de raça (provisória até o balanceamento)
	"EquipmentSystem", -- armaduras e acessórios (defesa, vida, aparo, energia, melhorias)
	"TransportSystem", -- transportes comuns e tela de gerenciamento (preferido salvo)
	"MagicBookSystem", -- livros mágicos (usa dados e habilidades)
	"CraftingSystem", -- fabricação nas estações (transação atômica no inventário)
	"RestorationSystem", -- restauração de estruturas por jogador, com ajuda cooperativa
	"PersonalBaseSystem", -- base pessoal: parcela, Forja, Jardim, Expositor
	"BossSystem", -- minibosses com mecânicas (Rainha-Bobina: carga; Cão-Trovão Alfa: matilha)
	"DimensionSystem", -- viagem rápida (pontos descobertos e a própria base)
	"LootSystem", -- saque pessoal com proteção contra azar
	"QuestSystem", -- missões por eventos (usa quase todos os anteriores)
	"CompanySystem", -- companhias (guildas de jogadores): cofre, cargos, convites
}

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
