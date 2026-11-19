--!strict
-- NÃO EXECUTADO NO STUDIO. Habilidade especial da arma/escudo (cliente).
-- Tecla 1 · R1 (controle) · botão "Especial" (toque, só quando o artefato equipado tem especial pública).
-- O servidor decide tudo; aqui só: pedir, fazer o impulso do PRÓPRIO corpo (avanço/subida) quando o servidor
-- confirma, mostrar recarga e o brilho nos outros jogadores.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")

local G = ReplicatedStorage:WaitForChild("Guardioes")
local Remotos = require(G.Rede.Remotos)
local Mensagens = require(G.Util.Mensagens)
local Especiais = require(G.Config.Especiais)

local ES = Remotos.Especial
local EE = Remotos.EventoEspecial
local EA = Remotos.EventoArtefato
local jogador = Players.LocalPlayer

local ControleDeEspecial = { Nome = "ControleDeEspecial" }

local evento: RemoteEvent
local hud: any
local ctxSalvo: any = nil
local prontoEm = 0

local function brilho(ch: Model, cor: Color3, duracao: number)
	local h = Instance.new("Highlight")
	h.FillColor = cor
	h.FillTransparency = 0.6
	h.OutlineColor = Color3.new(1, 1, 1)
	h.Parent = ch
	Debris:AddItem(h, duracao)
end

local function impulso(avanco: number, vertical: number)
	local ch = jogador.Character
	local hrp = ch and ch:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not hrp then
		return
	end
	local h = hrp :: BasePart
	if avanco > 0 then
		local at = Instance.new("Attachment")
		at.Parent = h
		local lv = Instance.new("LinearVelocity")
		lv.Attachment0 = at
		lv.MaxForce = 1e5
		lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
		lv.PrimaryTangentAxis, lv.SecondaryTangentAxis = Vector3.xAxis, Vector3.zAxis
		local f = h.CFrame.LookVector
		lv.PlaneVelocity = Vector2.new(f.X, f.Z).Unit * (avanco / 0.2)
		lv.RelativeTo = Enum.ActuatorRelativeTo.World
		lv.Parent = h
		Debris:AddItem(lv, 0.2)
		Debris:AddItem(at, 0.2)
	end
	if vertical > 0 then
		h.AssemblyLinearVelocity = Vector3.new(h.AssemblyLinearVelocity.X, vertical, h.AssemblyLinearVelocity.Z)
	end
end

local function usar()
	if os.clock() < prontoEm then
		hud.aviso(Mensagens.texto("recarga"))
		return
	end
	evento:FireServer(ES.USAR)
end

local function botaoToque(mostrar: boolean)
	if not UserInputService.TouchEnabled then
		return
	end
	if mostrar then
		ContextActionService:BindAction("GuardioesToqueEspecial", function(_n, s, _o)
			if s == Enum.UserInputState.Begin then
				usar()
			end
			return Enum.ContextActionResult.Sink
		end, true)
		ContextActionService:SetTitle("GuardioesToqueEspecial", "Especial")
		ContextActionService:SetPosition("GuardioesToqueEspecial", UDim2.new(1, -390, 1, -230))
	else
		ContextActionService:UnbindAction("GuardioesToqueEspecial")
	end
end

function ControleDeEspecial.Init(ctx: any)
	ctxSalvo = ctx
	evento = Remotos.evento("Especial")
end

function ControleDeEspecial.Start()
	hud = ctxSalvo.obter("HudDeCombate")
	ContextActionService:BindAction("GuardioesEspecial", function(_n, s, _o)
		if s == Enum.UserInputState.Begin then
			usar()
		end
		return Enum.ContextActionResult.Sink
	end, false, Enum.KeyCode.One, Enum.KeyCode.ButtonR1)
	evento.OnClientEvent:Connect(function(tipo: number, a: any, b: any, c: any, d: any, e: any, f: any)
		if tipo == EE.USOU then
			prontoEm = os.clock() + (c or 0)
			impulso(d or 0, e or 0)
			if b == "Bastiao" and jogador.Character then
				brilho(jogador.Character, Color3.fromRGB(140, 230, 120), f or 1.5)
			end
		elseif tipo == EE.REJEITADO then
			hud.aviso(Mensagens.texto(a))
		elseif tipo == EE.ACERTO then
			hud.numeroDeDano(a, b, c)
		elseif tipo == EE.EFEITO then
			local p = Players:GetPlayerByUserId(a)
			if p and p ~= jogador and p.Character then
				brilho(p.Character, Color3.fromRGB(160, 220, 255), 0.4)
			end
		end
	end)
	-- botão de toque só quando o artefato equipado tem especial conhecida
	Remotos.evento("Artefato").OnClientEvent:Connect(function(tipo: number, a: any)
		if tipo == EA.INVENTARIO and typeof(a) == "table" then
			local tem = false
			for _, item in a do
				if item.equipado and Especiais.porArtefato[item.id] then
					tem = true
				end
			end
			botaoToque(tem)
		end
	end)
end

return ControleDeEspecial
