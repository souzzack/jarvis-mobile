--!strict
-- Mapa que muda com o progresso, SÓ para este jogador (a estante da Biblioteca do Vazio que se abre depois da
-- leitura). Parts com o atributo "GuardioesRevelaApos" = id de objetivo somem (sem colisão) quando o jogador
-- já cumpriu esse objetivo. O servidor publica os objetivos cumpridos em Player:GetAttribute("GuardioesObjetivosFeitos").
-- Nada aqui dá progresso: é só a visão local do mapa; pistas e enigmas continuam validados no servidor.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ObjetivosFeitos = require(ReplicatedStorage:WaitForChild("Guardioes"):WaitForChild("MysterySystems"):WaitForChild("ObjetivosFeitos"))

local Estantes = { Nome = "EstantesDaBiblioteca" }

local jogador = Players.LocalPlayer
local abertas: { [Instance]: boolean } = {}

local function feitos(): { [string]: boolean }
	return ObjetivosFeitos.ler(jogador:GetAttribute("GuardioesObjetivosFeitos"))
end

local function abrir(parte: BasePart, animar: boolean)
	if abertas[parte] then
		return
	end
	abertas[parte] = true
	parte.CanCollide = false
	parte.CanQuery = false
	-- desce no chão (a estante "se reorganiza"); sem animação ao entrar no jogo
	local destino = parte.CFrame * CFrame.new(0, -parte.Size.Y - 0.5, 0)
	if animar then
		TweenService:Create(parte, TweenInfo.new(2.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), { CFrame = destino, Transparency = 1 }):Play()
	else
		parte.CFrame = destino
		parte.Transparency = 1
	end
end

local function aplicar(animar: boolean)
	local f = feitos()
	for _, d in Workspace:GetDescendants() do
		local id = d:GetAttribute("GuardioesRevelaApos")
		if d:IsA("BasePart") and typeof(id) == "string" and f[id] then
			abrir(d, animar)
		end
	end
end

function Estantes.Init(_ctx: any) end

function Estantes.Start()
	aplicar(false)
	jogador:GetAttributeChangedSignal("GuardioesObjetivosFeitos"):Connect(function()
		aplicar(true)
	end)
	-- partes que carregam depois (streaming)
	Workspace.DescendantAdded:Connect(function(d)
		if d:IsA("BasePart") and d:GetAttribute("GuardioesRevelaApos") then
			task.defer(aplicar, false)
		end
	end)
end

return Estantes
