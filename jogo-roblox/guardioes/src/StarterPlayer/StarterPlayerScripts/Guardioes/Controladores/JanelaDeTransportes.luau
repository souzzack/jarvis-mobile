--!strict
-- NÃO EXECUTADO NO STUDIO. Tela de gerenciamento de transportes (Sistema 14), tecla J ou aba.
-- Mostra todos os meios: disponível ou o requisito (texto público, sem segredos), velocidade e custo de
-- energia. "Preferido" define o que a tecla de voo usa (Asas, Voo mágico ou Prancha de viagem); o servidor
-- confere a posse e salva. Os de artefato usam a tecla de forma; a montaria, a de montar.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")

local G = ReplicatedStorage:WaitForChild("Guardioes")
local Remotos = require(G.Rede.Remotos)
local Mensagens = require(G.Util.Mensagens)

local TR = Remotos.Transporte
local ET = Remotos.EventoTransporte
local jogador = Players.LocalPlayer

local JanelaDeTransportes = { Nome = "JanelaDeTransportes" }

local ctxSalvo: any = nil
local hud: any
local loco: any
local ev: RemoteEvent
local janela: Frame
local lista: ScrollingFrame
local aba: TextButton
local itens: { any } = {}
local preferido: string? = nil

local function desenhar()
	for _, f in lista:GetChildren() do
		f:Destroy()
	end
	for i, t in itens do
		local c = Instance.new("Frame")
		c.Position, c.Size = UDim2.fromOffset(4, (i - 1) * 56), UDim2.new(1, -8, 0, 52)
		c.BackgroundColor3 = if t.id == preferido then Color3.fromRGB(40, 70, 56) elseif t.disponivel then Color3.fromRGB(38, 46, 74) else Color3.fromRGB(26, 28, 38)
		c.BorderSizePixel = 0
		c.Parent = lista
		local l = Instance.new("TextLabel")
		l.Position, l.Size = UDim2.fromOffset(8, 4), UDim2.new(1, -110, 0, 44)
		l.BackgroundTransparency = 1
		l.TextXAlignment = Enum.TextXAlignment.Left
		l.TextYAlignment = Enum.TextYAlignment.Top
		l.TextWrapped = true
		l.Font = Enum.Font.Gotham
		l.TextSize = 12
		l.TextColor3 = if t.disponivel then Color3.new(1, 1, 1) else Color3.fromRGB(150, 150, 165)
		local dados = if t.velMax then string.format("vel. %d · energia %s/s%s", t.velMax, tostring(t.custo), if (t.impulso or 0) > 0 then " · impulso" else "") else ""
		l.Text = string.format("%s%s\n%s", t.nome, if t.id == preferido then "  ★ preferido" else "", if t.disponivel then dados else "Falta: " .. t.requisito)
		l.Parent = c
		if t.disponivel and t.preferivel and t.id ~= preferido then
			local b = Instance.new("TextButton")
			b.Position, b.Size = UDim2.new(1, -100, 0, 12), UDim2.fromOffset(92, 28)
			b.BackgroundColor3 = Color3.fromRGB(52, 60, 92)
			b.TextColor3 = Color3.new(1, 1, 1)
			b.Font = Enum.Font.GothamBold
			b.TextSize = 12
			b.Text = "Preferir"
			b.Parent = c
			b.Activated:Connect(function()
				ev:FireServer(TR.PREFERIR, t.id)
			end)
		end
	end
	lista.CanvasSize = UDim2.fromOffset(0, #itens * 56)
end

local function alternar()
	janela.Visible = not janela.Visible
	aba.Text = if janela.Visible then "Fechar (J)" else "Transportes (J)"
	if janela.Visible then
		ev:FireServer(TR.LISTAR)
		desenhar()
	end
end

function JanelaDeTransportes.Init(ctx: any)
	ctxSalvo = ctx
	ev = Remotos.evento("Transporte")
	local tela = Instance.new("ScreenGui")
	tela.Name = "GuardioesTransportes"
	tela.ResetOnSpawn = false
	tela.Parent = jogador:WaitForChild("PlayerGui")
	aba = Instance.new("TextButton")
	aba.Size, aba.Position = UDim2.fromOffset(140, 32), UDim2.new(0, 556, 0.5, -200)
	aba.BackgroundColor3 = Color3.fromRGB(38, 46, 74)
	aba.TextColor3 = Color3.new(1, 1, 1)
	aba.Font = Enum.Font.GothamBold
	aba.TextSize = 14
	aba.Text = "Transportes (J)"
	aba.Parent = tela
	aba.Activated:Connect(alternar)
	janela = Instance.new("Frame")
	janela.Size, janela.Position = UDim2.fromOffset(360, 400), UDim2.new(0, 556, 0.5, -160)
	janela.BackgroundColor3 = Color3.fromRGB(18, 20, 32)
	janela.BackgroundTransparency = 0.1
	janela.BorderSizePixel = 0
	janela.Visible = false
	janela.Parent = tela
	lista = Instance.new("ScrollingFrame")
	lista.Size, lista.Position = UDim2.new(1, -8, 1, -8), UDim2.fromOffset(4, 4)
	lista.BackgroundTransparency = 1
	lista.BorderSizePixel = 0
	lista.ScrollBarThickness = 6
	lista.Parent = janela
end

function JanelaDeTransportes.Start()
	hud = ctxSalvo.obter("HudDeCombate")
	loco = ctxSalvo.obter("ControleDeLocomocao")
	ev.OnClientEvent:Connect(function(tipo: number, a: any, b: any)
		if tipo == ET.LISTA and typeof(a) == "table" then
			itens, preferido = a, b
			-- a tecla de voo só usa o preferido se ele estiver disponível agora
			local ok = false
			for _, t in itens do
				if t.id == preferido and t.disponivel then
					ok = true
				end
			end
			loco.definirPreferido(if ok then preferido else nil)
			if janela.Visible then
				desenhar()
			end
		elseif tipo == ET.REJEITADO then
			hud.aviso(Mensagens.texto(a))
		end
	end)
	ContextActionService:BindAction("GuardioesTransportes", function(_n, s, _o)
		if s == Enum.UserInputState.Begin then
			alternar()
		end
		return Enum.ContextActionResult.Sink
	end, false, Enum.KeyCode.J)
end

return JanelaDeTransportes
