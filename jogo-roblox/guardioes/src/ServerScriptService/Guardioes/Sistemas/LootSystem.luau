--!strict
-- NÃO EXECUTADO NO STUDIO. LootSystem: recompensa por inimigo derrotado.
--  * Saque PESSOAL: cada jogador que causou ao menos 10% do dano rola o próprio saque (ninguém "rouba").
--  * Proteção contra azar por jogador e por item (Loot/Saque: 'garantiaEm').
--  * Entrega pelo InventorySystem (salvo) e XP pelo ProgressionSystem.
--  * O contador de azar vale pela sessão (salvar entre sessões: próxima etapa, campo no perfil).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local G = ReplicatedStorage:WaitForChild("Guardioes")
local Saque = require(G.Loot.Saque)
local Loot = require(G.Config.Loot)

local LootSystem = { Nome = "LootSystem" }

local azar: { [Player]: { [string]: { [string]: number } } } = {}
local ctxSistemas: any = nil

function LootSystem.Init(ctx: any)
	ctxSistemas = ctx
end

function LootSystem.Start()
	local inimigos = ctxSistemas.obter("EnemySystem")
	local inventario = ctxSistemas.obter("InventorySystem")
	local progressao = ctxSistemas.obter("ProgressionSystem")
	local companheiros = ctxSistemas.obter("CompanionSystem")
	inimigos.morreu.conectar(function(ini: any, contribuicao: { [Player]: number })
		local tabela = Loot.porInimigo[ini.cfg.id]
		if not tabela then
			return
		end
		for _, p in Saque.elegiveis(contribuicao, Loot.minimoDeContribuicao) do
			if p.Parent then
				azar[p] = azar[p] or {}
				local meu = azar[p][ini.cfg.id] or {}
				azar[p][ini.cfg.id] = meu
				local itens = Saque.rolar(tabela, meu, math.random)
				-- criatura farejadora por perto: 30% de chance de +1 no primeiro material do saque
				local _, _, raiz = companheiros.ativa(p)
				local onde = ini.raiz and ini.raiz.Position
				if next(itens) and raiz and onde and (raiz.Position - onde).Magnitude <= 40
					and (companheiros.ativaTemHabilidade(p, "FarejarMaterial") or companheiros.ativaTemHabilidade(p, "FaroDeCristal"))
					and math.random() < 0.3 then
					local ids = {}
					for id in itens do
						table.insert(ids, id)
					end
					table.sort(ids)
					itens[ids[1]] += 1
				end
				if next(itens) then
					inventario.darMateriais(p, itens, "saque:" .. ini.cfg.id)
				end
				if tabela.xp > 0 then
					progressao.ganharXp(p, tabela.xp, "inimigo:" .. ini.cfg.id)
				end
			end
		end
	end)
	Players.PlayerRemoving:Connect(function(p)
		azar[p] = nil
	end)
end

return LootSystem
