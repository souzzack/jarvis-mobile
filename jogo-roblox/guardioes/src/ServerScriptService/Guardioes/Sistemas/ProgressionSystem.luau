--!strict
-- NÃO EXECUTADO NO STUDIO. ProgressionSystem: nível e XP do jogador (salvos) e efeitos de raça na vida.
-- XP só vem do servidor (saque, missões). Vida máxima = Progressao/Nivel.vidaMaxima × modificador da raça.
-- (Maestria de arma e afinidade por dimensão: próximas etapas, mesmo padrão.)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local G = ReplicatedStorage:WaitForChild("Guardioes")
local Nivel = require(G.Progressao.Nivel)
local Sinal = require(G.Util.Sinal)
local Remotos = require(G.Rede.Remotos)

local EP = Remotos.EventoProgressao

local ProgressionSystem = { Nome = "ProgressionSystem" }
ProgressionSystem.subiuDeNivel = Sinal.novo() -- (p, nivel)

local evento: RemoteEvent
local playerData: any
local habilidades: any
local ctxSistemas: any = nil
local vidaExtra: { [Player]: number } = {} -- equipamento (EquipmentSystem)

local function dados(p: Player): (number, number)
	local perfil = playerData.obter(p)
	if not perfil then
		return 1, 0
	end
	return perfil.nivel, perfil.xp
end

local function aplicarVida(p: Player, curar: boolean)
	local ch = p.Character
	local hum = ch and ch:FindFirstChildOfClass("Humanoid")
	if not hum then
		return
	end
	local raca = habilidades.raca(p)
	local nivel = dados(p)
	local vida = Nivel.vidaMaxima(nivel, if raca then raca.modsVida else nil) + (vidaExtra[p] or 0)
	hum.MaxHealth = vida
	hum.Health = if curar then vida else math.min(hum.Health, vida)
end

local function enviar(p: Player, subiu: boolean)
	local nivel, xp = dados(p)
	evento:FireClient(p, EP.NIVEL, nivel, xp, Nivel.xpParaProximo(nivel), subiu)
end

function ProgressionSystem.definirVidaExtra(p: Player, extra: number)
	vidaExtra[p] = extra
	aplicarVida(p, false)
end

function ProgressionSystem.nivel(p: Player): number
	return (dados(p))
end

-- só o servidor chama (saque, missões)
function ProgressionSystem.ganharXp(p: Player, quanto: number, origem: string): boolean
	if quanto <= 0 then
		return false
	end
	local ganhos = 0
	local novoNivel = 1
	local ok = playerData.atualizar(p, function(perfil)
		perfil.nivel, perfil.xp, ganhos = Nivel.ganhar(perfil.nivel, perfil.xp, quanto)
		novoNivel = perfil.nivel
		return true
	end)
	if not ok then
		return false
	end
	local _ = origem
	if ganhos > 0 then
		aplicarVida(p, true) -- subir de nível cura
		ProgressionSystem.subiuDeNivel.disparar(p, novoNivel)
	end
	enviar(p, ganhos > 0)
	return true
end

function ProgressionSystem.Init(ctx: any)
	ctxSistemas = ctx
	evento = Remotos.evento("Progressao")
end

function ProgressionSystem.Start()
	playerData = ctxSistemas.obter("PlayerDataSystem")
	habilidades = ctxSistemas.obter("MovementAbilitySystem")
	playerData.carregado.conectar(function(p: Player)
		aplicarVida(p, true)
		enviar(p, false)
	end)
	local function entrar(p: Player)
		p.CharacterAdded:Connect(function(ch)
			ch:WaitForChild("Humanoid", 10)
			aplicarVida(p, true)
			enviar(p, false)
		end)
	end
	for _, p in Players:GetPlayers() do
		entrar(p)
	end
	Players.PlayerAdded:Connect(entrar)
	Players.PlayerRemoving:Connect(function(p)
		vidaExtra[p] = nil
	end)
	habilidades.mudou.conectar(function(p: Player)
		aplicarVida(p, false) -- a raça pode ter chegado com o perfil
	end)
end

return ProgressionSystem
