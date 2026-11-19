--!strict
-- NÃO EXECUTADO NO STUDIO. ConsumableSystem: usar os consumíveis da Bancada (Config/Consumiveis).
--  * O cliente só pede USAR(id). O servidor confere posse, recarga por tipo de efeito, voo e atordoamento
--    (Consumiveis/Consumivel, lógica pura), CONSOME (InventorySystem.transacao) e só então aplica o efeito.
--  * Cura em pulsos de 0,5 s (para no máximo da vida; morrer interrompe). Energia e estamina: na hora.
--  * Recargas ficam só em memória (sair do jogo não é jeito de ganhar tempo: os valores são curtos).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local G = ReplicatedStorage:WaitForChild("Guardioes")
local Consumivel = require(G.Consumiveis.Consumivel)
local Consumiveis = require(G.Config.Consumiveis)
local LimiteDeTaxa = require(G.Util.LimiteDeTaxa)
local Remotos = require(G.Rede.Remotos)

local EC = Remotos.EventoConsumivel

local ConsumableSystem = { Nome = "ConsumableSystem" }

local evento: RemoteEvent
local ctxSistemas: any = nil
local inventario: any
local combate: any
local movimento: any
local recargas: { [Player]: { [string]: number } } = {}
local baldes: { [Player]: LimiteDeTaxa.Balde } = {}

local function humanoide(p: Player): Humanoid?
	local ch = p.Character
	return if ch then ch:FindFirstChildOfClass("Humanoid") else nil
end

local function usar(p: Player, id: string)
	local cfg = Consumiveis.porId[id]
	local hum = humanoide(p)
	local estadoLoco = movimento.estado(p)
	local e: Consumivel.Estado = {
		agora = os.clock(),
		emVoo = estadoLoco ~= nil and estadoLoco ~= "Solo" and estadoLoco ~= "Montado", -- no ar (voo, planador, pouso…)
		atordoado = combate.atordoado(p),
		vivo = hum ~= nil and hum.Health > 0,
		recargas = recargas[p] or {},
	}
	recargas[p] = e.recargas
	local pode, motivo = Consumivel.podeUsar(cfg, e, if cfg then inventario.contar(p, id) else 0)
	if not pode then
		evento:FireClient(p, EC.REJEITADO, motivo)
		return
	end
	local ok = inventario.transacao(p, { consumir = { [id] = 1 } })
	if not ok then
		evento:FireClient(p, EC.REJEITADO, "naoPossui")
		return
	end
	Consumivel.marcarRecarga(cfg, e)
	local ef = cfg.efeito
	if ef.tipo == "Cura" and hum then
		local h = hum :: Humanoid
		task.spawn(function()
			for _, v in Consumivel.pulsosDeCura(ef.valor, ef.duracao) do
				if h.Health <= 0 or not h.Parent then
					return
				end
				h.Health = math.min(h.MaxHealth, h.Health + v)
				task.wait(0.5)
			end
		end)
	elseif ef.tipo == "Energia" then
		movimento.recuperarEnergia(p, ef.valor)
	elseif ef.tipo == "Estamina" then
		combate.recuperarEstamina(p, ef.valor)
	end
	evento:FireClient(p, EC.USOU, id, cfg.recarga, ef.tipo)
end

function ConsumableSystem.Init(ctx: any)
	ctxSistemas = ctx
	evento = Remotos.evento("Consumivel")
end

function ConsumableSystem.Start()
	inventario = ctxSistemas.obter("InventorySystem")
	combate = ctxSistemas.obter("CombatSystem")
	movimento = ctxSistemas.obter("MovementSystem")
	evento.OnServerEvent:Connect(function(p: Player, tipo: any, id: any)
		local b = baldes[p]
		if not b then
			b = LimiteDeTaxa.novo(4, 2, os.clock())
			baldes[p] = b
		end
		if not LimiteDeTaxa.consumir(b, os.clock()) then
			return
		end
		if tipo == Remotos.Consumivel.USAR and typeof(id) == "string" and Consumiveis.porId[id] then
			usar(p, id)
		end
	end)
	Players.PlayerRemoving:Connect(function(p)
		recargas[p] = nil
		baldes[p] = nil
	end)
end

return ConsumableSystem
