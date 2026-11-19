--!strict
-- NÃO EXECUTADO NO STUDIO. Interface mínima de locomoção: barra de energia de voo (só aparece quando importa:
-- no ar ou recuperando) e o nome do estado atual. Avisos de requisito usam o HudDeCombate (um lugar só).
-- As telas completas (companheiros, livros, artefatos, transportes) estão planejadas em docs/07, seção 14.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local G = ReplicatedStorage:WaitForChild("Guardioes")
local Remotos = require(G.Rede.Remotos)

local EL = Remotos.EventoLocomocao
local jogador = Players.LocalPlayer

local HudDeLocomocao = { Nome = "HudDeLocomocao" }

local NOMES: { [string]: string } = {
	Decolagem = "Decolando", Pairar = "Pairando", Voo = "Voando", Impulso = "Impulso!", Descida = "Descendo",
	Pouso = "Pousando", Interrompido = "Caindo", Planando = "Planando", Montado = "Montado",
}

local quadro: Frame
local enche: Frame
local rotulo: TextLabel
local loco: any
local valor, maximo = 100, 100

local function visivel(): boolean
	local estado = loco.estado()
	return estado ~= "Solo" or valor < maximo - 0.5
end

local function atualizar()
	enche.Size = UDim2.fromScale(math.clamp(valor / math.max(1, maximo), 0, 1), 1)
	enche.BackgroundColor3 = if valor / maximo < 0.25 then Color3.fromRGB(255, 120, 90) else Color3.fromRGB(110, 190, 255)
	local estado = loco.estado()
	rotulo.Text = NOMES[estado] or ""
	local alvo = if visivel() then 0 else 1
	TweenService:Create(quadro, TweenInfo.new(0.3), { BackgroundTransparency = if alvo == 0 then 0 else 1 }):Play()
	TweenService:Create(enche, TweenInfo.new(0.3), { BackgroundTransparency = alvo }):Play()
	TweenService:Create(rotulo, TweenInfo.new(0.3), { TextTransparency = alvo }):Play()
end

function HudDeLocomocao.Init(ctx: any)
	loco = ctx.obter("ControleDeLocomocao")
	local tela = Instance.new("ScreenGui")
	tela.Name = "GuardioesHudLocomocao"
	tela.ResetOnSpawn = false
	tela.Parent = jogador:WaitForChild("PlayerGui")
	quadro = Instance.new("Frame")
	quadro.Size = UDim2.fromOffset(260, 8)
	quadro.Position = UDim2.new(0, 24, 1, -84)
	quadro.BackgroundColor3 = Color3.fromRGB(20, 22, 34)
	quadro.BorderSizePixel = 0
	quadro.Parent = tela
	enche = Instance.new("Frame")
	enche.Size = UDim2.fromScale(1, 1)
	enche.BorderSizePixel = 0
	enche.Parent = quadro
	rotulo = Instance.new("TextLabel")
	rotulo.Size = UDim2.fromOffset(160, 16)
	rotulo.Position = UDim2.fromOffset(0, -18)
	rotulo.BackgroundTransparency = 1
	rotulo.TextXAlignment = Enum.TextXAlignment.Left
	rotulo.TextColor3 = Color3.new(1, 1, 1)
	rotulo.Font = Enum.Font.GothamBold
	rotulo.TextSize = 14
	rotulo.Parent = quadro
end

function HudDeLocomocao.Start()
	local evento = Remotos.evento("Locomocao")
	evento.OnClientEvent:Connect(function(tipo: number, a: any, b: any)
		if tipo == EL.ENERGIA and typeof(a) == "number" and typeof(b) == "number" then
			valor, maximo = a, b
			atualizar()
		end
	end)
	loco.mudouEstado.conectar(function()
		atualizar()
	end)
	atualizar()
end

return HudDeLocomocao
