--!strict
-- NÃO EXECUTADO NO STUDIO. FlightCamera: câmera ESTABILIZADA para voo.
-- Não substitui a câmera do Roblox (o jogador continua girando com mouse/dedo) e NUNCA rola o horizonte:
-- só ajusta o campo de visão com a velocidade e eleva um pouco o ponto de mira, sempre suavizado.
-- Opção de conforto: atributo "GuardioesCameraCalma" = true no jogador desliga a variação de FOV.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local jogador = Players.LocalPlayer

local CameraDeVoo = { Nome = "CameraDeVoo" }

local FOV_EXTRA_VELOCIDADE = 12 -- graus a mais na velocidade máxima do perfil
local FOV_EXTRA_IMPULSO = 7
local FOV_TETO = 95
local SUAVE_FOV = 3 -- 1/s (lento de propósito: nada de "soco" na tela)
local SUAVE_OFFSET = 4

local loco: any
local fovBase = 70
local offset = 0

function CameraDeVoo.Init(ctx: any)
	loco = ctx.obter("ControleDeLocomocao")
end

function CameraDeVoo.Start()
	local cam = Workspace.CurrentCamera
	if cam then
		fovBase = cam.FieldOfView
	end
	RunService.RenderStepped:Connect(function(dt)
		local c = Workspace.CurrentCamera
		local ch = jogador.Character
		local hum = ch and ch:FindFirstChildOfClass("Humanoid")
		if not c or not hum then
			return
		end
		local estado = loco.estado()
		local perfil = loco.perfil()
		local noAr = estado ~= "Solo" and estado ~= "Montado"
		local alvo = fovBase
		if noAr and perfil and not jogador:GetAttribute("GuardioesCameraCalma") then
			local frac = math.clamp(loco.velocidade() / math.max(1, perfil.velMax), 0, 1.4)
			alvo = fovBase + FOV_EXTRA_VELOCIDADE * frac + (if loco.impulso() then FOV_EXTRA_IMPULSO else 0)
		end
		alvo = math.min(alvo, FOV_TETO)
		c.FieldOfView += (alvo - c.FieldOfView) * math.min(1, dt * SUAVE_FOV)
		-- mira um pouco acima do corpo em voo: dá para ler o cenário à frente e abaixo
		local alvoOffset = if noAr then 1.2 else 0
		offset += (alvoOffset - offset) * math.min(1, dt * SUAVE_OFFSET)
		hum.CameraOffset = Vector3.new(0, offset, 0)
	end)
end

return CameraDeVoo
