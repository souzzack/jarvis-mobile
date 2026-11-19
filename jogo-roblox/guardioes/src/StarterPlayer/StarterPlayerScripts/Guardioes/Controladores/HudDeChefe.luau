--!strict
-- NÃO EXECUTADO NO STUDIO. Barra do chefe (topo da tela) e aviso da fase de carga.
-- A vida vem dos atributos replicados do modelo (Vida/VidaMax/Imune); a barra some longe do chefe.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local G = ReplicatedStorage:WaitForChild("Guardioes")
local Remotos = require(G.Rede.Remotos)

local EC = Remotos.EventoChefe
local jogador = Players.LocalPlayer
local DISTANCIA = 90

local HudDeChefe = { Nome = "HudDeChefe" }

local hud: any
local ctxSalvo: any = nil
local quadro: Frame
local enche: Frame
local nome: TextLabel
local chefeId: string? = nil
local cargaAte = 0

local function modeloDoChefe(): Model?
	local pasta = Workspace:FindFirstChild("GuardioesInimigos")
	if not pasta or not chefeId then
		return nil
	end
	for _, m in pasta:GetChildren() do
		if m:GetAttribute("GuardioesId") == chefeId then
			return m :: Model
		end
	end
	return nil
end

function HudDeChefe.Init(ctx: any)
	ctxSalvo = ctx
	local tela = Instance.new("ScreenGui")
	tela.Name = "GuardioesHudChefe"
	tela.ResetOnSpawn = false
	tela.Parent = jogador:WaitForChild("PlayerGui")
	quadro = Instance.new("Frame")
	quadro.Size, quadro.Position = UDim2.fromOffset(420, 16), UDim2.new(0.5, -210, 0, 52)
	quadro.BackgroundColor3 = Color3.fromRGB(20, 22, 34)
	quadro.BorderSizePixel = 0
	quadro.Visible = false
	quadro.Parent = tela
	enche = Instance.new("Frame")
	enche.Size = UDim2.fromScale(1, 1)
	enche.BackgroundColor3 = Color3.fromRGB(184, 140, 255)
	enche.BorderSizePixel = 0
	enche.Parent = quadro
	nome = Instance.new("TextLabel")
	nome.Size, nome.Position = UDim2.new(1, 0, 0, 20), UDim2.fromOffset(0, -22)
	nome.BackgroundTransparency = 1
	nome.TextColor3 = Color3.new(1, 1, 1)
	nome.Font = Enum.Font.GothamBold
	nome.TextSize = 16
	nome.Parent = quadro
end

function HudDeChefe.Start()
	hud = ctxSalvo.obter("HudDeCombate")
	Remotos.evento("Chefe").OnClientEvent:Connect(function(tipo: number, a: any, b: any)
		if tipo == EC.INICIO then
			chefeId = a
		elseif tipo == EC.CARGA then
			cargaAte = os.clock() + (a or 0)
			hud.aviso(string.format("Os pilares acenderam! Quebre os %d antes da descarga", b or 0))
		elseif tipo == EC.FIM_CARGA then
			cargaAte = 0
			hud.aviso(if a == "Sucesso" then "A Rainha caiu! Ataque agora!" else "DESCARGA!")
		elseif tipo == EC.DERROTADO then
			hud.aviso(tostring(a) .. " derrotada")
		end
	end)
	RunService.Heartbeat:Connect(function()
		local m = modeloDoChefe()
		local hrp = jogador.Character and jogador.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
		if not m or not m.PrimaryPart or not hrp or ((m.PrimaryPart :: BasePart).Position - (hrp :: BasePart).Position).Magnitude > DISTANCIA then
			quadro.Visible = false
			return
		end
		quadro.Visible = true
		local v = (m:GetAttribute("Vida") :: number?) or 0
		local vm = (m:GetAttribute("VidaMax") :: number?) or 1
		enche.Size = UDim2.fromScale(math.clamp(v / vm, 0, 1), 1)
		local imune = m:GetAttribute("Imune") == true
		enche.BackgroundColor3 = if imune then Color3.fromRGB(127, 231, 255) else Color3.fromRGB(184, 140, 255)
		local resta = cargaAte - os.clock()
		nome.Text = tostring(m:GetAttribute("Nome") or "Chefe") .. (if resta > 0 then string.format("  — carga %.0f s", resta) else "")
	end)
end

return HudDeChefe
