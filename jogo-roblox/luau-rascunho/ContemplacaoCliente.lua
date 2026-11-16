--!strict
-- RASCUNHO, NÃO TESTADO NO STUDIO.
-- Lugar sugerido: StarterPlayerScripts, dentro do controlador de ajudantes que já existir no cliente.
-- Decide QUANDO a Contemplação Celestial acontece. A animação e os efeitos são só visuais (cliente).
-- A descoberta no diário é pedida ao servidor, que valida e salva (DescobertasServico).

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Magnata = ReplicatedStorage:WaitForChild("Magnata")
local SeteEstrelas = require(Magnata.Dados.SeteEstrelas)
local pedirDescoberta = Magnata.Remotos:WaitForChild("PedirDescoberta") :: RemoteEvent

local PARADO_PARA_DISPARAR = 12 -- segundos
local INTERVALO_MINIMO = 60 -- segundos entre contemplações CONCLUÍDAS
local DISTANCIA_MAXIMA = 40 -- studs da câmera; mais longe não roda os efeitos

local player = Players.LocalPlayer
local ultimoInput = os.clock()
local liberadaEm = 0

local function marcarInput()
	ultimoInput = os.clock()
end
UserInputService.InputBegan:Connect(marcarInput)
UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseWheel or input.UserInputType == Enum.UserInputType.Touch then marcarInput() end
end)

local function jogadorParado(): boolean
	local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if hum and hum.MoveDirection.Magnitude > 0.05 then
		marcarInput()
		return false
	end
	return os.clock() - ultimoInput >= PARADO_PARA_DISPARAR
end

-- `ajudante` é o controlador de estados do Axolote Nebular (o mesmo que roda Idle, Trabalho etc.).
-- Ele precisa expor: estado(), tempoNoEstado(), pedir(estado), visivel(), posicao().
return function(ajudante: any)
	return function()
		-- chamado uma vez por quadro pelo controlador central de ajudantes, nunca em loop próprio
		local agora = os.clock()
		if ajudante:estado() == "contemplacao" then
			if not jogadorParado() then
				ajudante:pedir("idle") -- interrupção suave: o controlador faz a transição e apaga os efeitos
			end
			return
		end
		if ajudante:estado() ~= "idle" or ajudante:tempoNoEstado() < 2 then return end
		if agora < liberadaEm then return end
		if not jogadorParado() then return end
		local cam = Workspace.CurrentCamera
		if not ajudante:visivel() or (cam.CFrame.Position - ajudante:posicao()).Magnitude > DISTANCIA_MAXIMA then return end

		ajudante:pedir("contemplacao", {
			aoChegarNoPulso = function()
				pedirDescoberta:FireServer(SeteEstrelas.ID_DESCOBERTA) -- o servidor decide se registra
			end,
			aoConcluir = function()
				liberadaEm = os.clock() + INTERVALO_MINIMO
			end,
		})
	end
end
