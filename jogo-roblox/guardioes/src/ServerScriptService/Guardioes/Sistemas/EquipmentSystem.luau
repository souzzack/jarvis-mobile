--!strict
-- NÃO EXECUTADO NO STUDIO. EquipmentSystem: armaduras e acessórios (GDD 7.4).
--  * Itens com GUID em perfil.equipamentos (nascem só no servidor: fabricação). Encaixes em perfil.equipado.
--  * EQUIPAR(guid, encaixe) / RETIRAR(encaixe): o servidor confere posse, tipo × encaixe e que o mesmo item não
--    fique em dois encaixes; grava numa transação (a validação do perfil recusa estados impossíveis).
--  * Efeitos (Equipamento/Equipamento.totais, com orçamento de raridade e tetos): defesa e aparo no
--    CombatSystem, vida no ProgressionSystem, energia de voo no MovementSystem.
--  * A ARMA continua sendo o artefato equipado (MetamorphicArtifactSystem); a relíquia vem depois.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local G = ReplicatedStorage:WaitForChild("Guardioes")
local Eq = require(G.Equipamento.Equipamento)
local Catalogo = require(G.Config.Equipamentos)
local Raridades = require(G.Config.Raridades)
local LimiteDeTaxa = require(G.Util.LimiteDeTaxa)
local Remotos = require(G.Rede.Remotos)

local EQ = Remotos.Equipamento
local EE = Remotos.EventoEquipamento

local EquipmentSystem = { Nome = "EquipmentSystem" }

local evento: RemoteEvent
local playerData: any
local combate: any
local progressao: any
local movimento: any
local ctxSistemas: any = nil
local baldes: { [Player]: LimiteDeTaxa.Balde } = {}

local function aplicar(p: Player)
	local perfil = playerData.obter(p)
	if not perfil then
		return
	end
	local t = Eq.totais(perfil.equipado, perfil.equipamentos, Catalogo.porId, Raridades.porId)
	combate.definirEquipamento(p, t.defesa, t.janelaAparar)
	progressao.definirVidaExtra(p, t.vidaBonus)
	movimento.definirEnergiaExtra(p, t.energiaVoo)
	local itens = {}
	for guid, item in perfil.equipamentos do
		local cfg = Catalogo.porId[item.id]
		if cfg then
			table.insert(itens, {
				guid = guid, id = item.id, nome = cfg.nome, tipo = cfg.tipo, raridade = cfg.raridade,
				atributos = cfg.atributos, efeito = cfg.efeito, encaixe = Eq.ondeEsta(perfil.equipado, guid),
			})
		end
	end
	table.sort(itens, function(a, b)
		return a.nome < b.nome
	end)
	evento:FireClient(p, EE.LISTA, itens, t)
end

local function equipar(p: Player, guid: string, encaixe: string)
	local perfil = playerData.obter(p)
	if not perfil then
		return
	end
	local item = perfil.equipamentos[guid]
	local cfg = item and Catalogo.porId[item.id]
	if not cfg then
		evento:FireClient(p, EE.REJEITADO, "naoPossui")
		return
	end
	local ok, motivo = Eq.podeEquipar(cfg, encaixe)
	if not ok then
		evento:FireClient(p, EE.REJEITADO, motivo)
		return
	end
	local gravou = playerData.atualizar(p, function(pf)
		local antes = Eq.ondeEsta(pf.equipado, guid)
		if antes then
			pf.equipado[antes] = nil -- mudar de encaixe (ex.: acessório 1 → 2)
		end
		pf.equipado[encaixe] = guid
		return true
	end)
	if gravou then
		aplicar(p)
	end
end

local function retirar(p: Player, encaixe: string)
	local gravou = playerData.atualizar(p, function(pf)
		if pf.equipado[encaixe] == nil then
			return false
		end
		pf.equipado[encaixe] = nil
		return true
	end)
	if gravou then
		aplicar(p)
	end
end

function EquipmentSystem.Init(ctx: any)
	ctxSistemas = ctx
	evento = Remotos.evento("Equipamento")
end

function EquipmentSystem.Start()
	playerData = ctxSistemas.obter("PlayerDataSystem")
	combate = ctxSistemas.obter("CombatSystem")
	progressao = ctxSistemas.obter("ProgressionSystem")
	movimento = ctxSistemas.obter("MovementSystem")
	local inventario = ctxSistemas.obter("InventorySystem")
	playerData.carregado.conectar(function(p: Player)
		aplicar(p)
	end)
	inventario.mudou.conectar(function(p: Player)
		aplicar(p) -- item fabricado aparece na lista
	end)
	Players.PlayerAdded:Connect(function(p)
		p.CharacterAdded:Connect(function()
			task.defer(aplicar, p) -- personagem novo: vida e energia com o bônus
		end)
	end)
	for _, p in Players:GetPlayers() do
		p.CharacterAdded:Connect(function()
			task.defer(aplicar, p)
		end)
	end
	evento.OnServerEvent:Connect(function(p: Player, tipo: any, a: any, b: any)
		local bl = baldes[p]
		if not bl then
			bl = LimiteDeTaxa.novo(6, 3, os.clock())
			baldes[p] = bl
		end
		if not LimiteDeTaxa.consumir(bl, os.clock()) then
			return
		end
		if tipo == EQ.EQUIPAR and typeof(a) == "string" and typeof(b) == "string" and #a <= 64 then
			equipar(p, a, b)
		elseif tipo == EQ.RETIRAR and typeof(a) == "string" then
			retirar(p, a)
		end
	end)
	Players.PlayerRemoving:Connect(function(p)
		baldes[p] = nil
	end)
end

return EquipmentSystem
