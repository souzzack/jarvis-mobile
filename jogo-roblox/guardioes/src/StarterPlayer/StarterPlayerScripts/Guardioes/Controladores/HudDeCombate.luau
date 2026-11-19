--!strict
-- NÃO EXECUTADO NO STUDIO. HUD provisório do protótipo de combate (visual simples, fora do MagnataHUD).
-- Vida (Humanoid), estamina (eventos do servidor), barra de vida/postura dos inimigos (atributos replicados),
-- marcador do alvo da mira, números de dano e aviso de telegrafia.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local jogador = Players.LocalPlayer

local HudDeCombate = { Nome = "HudDeCombate" }

local tela: ScreenGui
local barraVida: Frame
local barraEstamina: Frame
local textoAviso: TextLabel
local marcador: BillboardGui
local barrasInimigos: { [Model]: BillboardGui } = {}

local function barra(pai: Instance, y: number, cor: Color3): Frame
	local fundo = Instance.new("Frame")
	fundo.Size = UDim2.fromOffset(260, 14)
	fundo.Position = UDim2.new(0, 24, 1, y)
	fundo.BackgroundColor3 = Color3.fromRGB(20, 22, 34)
	fundo.BorderSizePixel = 0
	fundo.Parent = pai
	local enche = Instance.new("Frame")
	enche.Name = "Enche"
	enche.Size = UDim2.fromScale(1, 1)
	enche.BackgroundColor3 = cor
	enche.BorderSizePixel = 0
	enche.Parent = fundo
	return enche
end

local function barraDoInimigo(m: Model): BillboardGui
	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.fromOffset(120, 22)
	bb.StudsOffset = Vector3.new(0, 4, 0)
	bb.AlwaysOnTop = true
	bb.MaxDistance = 60
	local nome = Instance.new("TextLabel")
	nome.Size = UDim2.new(1, 0, 0, 10)
	nome.BackgroundTransparency = 1
	nome.TextColor3 = Color3.new(1, 1, 1)
	nome.TextScaled = true
	nome.Text = tostring(m:GetAttribute("Nome") or m.Name)
	nome.Parent = bb
	local vida = Instance.new("Frame")
	vida.Name = "Vida"
	vida.Position = UDim2.fromOffset(0, 12)
	vida.Size = UDim2.new(1, 0, 0, 6)
	vida.BackgroundColor3 = Color3.fromRGB(230, 70, 80)
	vida.BorderSizePixel = 0
	vida.Parent = bb
	local post = Instance.new("Frame")
	post.Name = "Postura"
	post.Position = UDim2.fromOffset(0, 19)
	post.Size = UDim2.new(0, 0, 0, 3)
	post.BackgroundColor3 = Color3.fromRGB(255, 205, 80)
	post.BorderSizePixel = 0
	post.Parent = bb
	bb.Adornee = m.PrimaryPart
	bb.Parent = tela
	local function atualizar()
		local v = (m:GetAttribute("Vida") :: number?) or 0
		local vm = (m:GetAttribute("VidaMax") :: number?) or 1
		local p = (m:GetAttribute("Postura") :: number?) or 0
		local pm = (m:GetAttribute("PosturaMax") :: number?) or 1
		vida.Size = UDim2.new(math.clamp(v / vm, 0, 1), 0, 0, 6)
		post.Size = UDim2.new(math.clamp(p / pm, 0, 1), 0, 0, 3)
	end
	m:GetAttributeChangedSignal("Vida"):Connect(atualizar)
	m:GetAttributeChangedSignal("Postura"):Connect(atualizar)
	atualizar()
	return bb
end

local function acharInimigo(id: string): Model?
	local pasta = Workspace:FindFirstChild("GuardioesInimigos")
	if not pasta then
		return nil
	end
	for _, m in pasta:GetChildren() do
		if m:GetAttribute("GuardioesId") == id then
			return m :: Model
		end
	end
	return nil
end

function HudDeCombate.estamina(valor: number, max: number)
	barraEstamina.Size = UDim2.fromScale(math.clamp(valor / math.max(1, max), 0, 1), 1)
end

function HudDeCombate.aviso(texto: string?)
	if not texto then
		return
	end
	textoAviso.Text = texto
	textoAviso.TextTransparency = 0
	TweenService:Create(textoAviso, TweenInfo.new(1.2, Enum.EasingStyle.Sine), { TextTransparency = 1 }):Play()
end

function HudDeCombate.marcarAlvo(m: Model?)
	marcador.Adornee = if m then m.PrimaryPart else nil
	marcador.Enabled = m ~= nil
end

function HudDeCombate.numeroDeDano(id: string, tipo: string, dano: number)
	local m = acharInimigo(id)
	if not m or not m.PrimaryPart then
		return
	end
	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.fromOffset(80, 30)
	bb.StudsOffset = Vector3.new(math.random() * 2 - 1, 3, 0)
	bb.AlwaysOnTop = true
	bb.Adornee = m.PrimaryPart
	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundTransparency = 1
	t.TextScaled = true
	t.Font = Enum.Font.GothamBold
	t.Text = if tipo == "Acerto" then tostring(dano) else tipo
	t.TextColor3 = if tipo == "Acerto" then Color3.fromRGB(255, 240, 200) else Color3.fromRGB(160, 220, 255)
	t.Parent = bb
	bb.Parent = tela
	TweenService:Create(bb, TweenInfo.new(0.7), { StudsOffset = bb.StudsOffset + Vector3.new(0, 2, 0) }):Play()
	TweenService:Create(t, TweenInfo.new(0.7), { TextTransparency = 1 }):Play()
	task.delay(0.75, function()
		bb:Destroy()
	end)
end

function HudDeCombate.recebeu(tipo: string, dano: number)
	if tipo == "Aparado" then
		HudDeCombate.aviso("Aparado!")
	elseif tipo == "Esquivado" then
		HudDeCombate.aviso("Esquivou")
	elseif tipo == "Defendido" then
		HudDeCombate.aviso("Defendido (" .. dano .. ")")
	end
end

-- telegrafia: a criatura pisca antes de atacar (leitura do golpe sem depender de som)
function HudDeCombate.telegrafia(id: string, _ataque: string, duracao: number)
	local m = acharInimigo(id)
	if not m then
		return
	end
	local h = Instance.new("Highlight")
	h.FillColor = Color3.fromRGB(255, 230, 120)
	h.OutlineColor = Color3.fromRGB(255, 255, 255)
	h.FillTransparency = 0.7
	h.Parent = m
	TweenService:Create(h, TweenInfo.new(duracao, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { FillTransparency = 0.1 }):Play()
	task.delay(duracao + 0.1, function()
		h:Destroy()
	end)
end

function HudDeCombate.Init(_ctx: any)
	tela = Instance.new("ScreenGui")
	tela.Name = "GuardioesHudCombate"
	tela.ResetOnSpawn = false
	tela.IgnoreGuiInset = false
	tela.Parent = jogador:WaitForChild("PlayerGui")
	barraVida = barra(tela, -64, Color3.fromRGB(230, 70, 80))
	barraEstamina = barra(tela, -44, Color3.fromRGB(120, 220, 140))
	textoAviso = Instance.new("TextLabel")
	textoAviso.Size = UDim2.fromOffset(320, 40)
	textoAviso.Position = UDim2.new(0.5, -160, 0.3, 0)
	textoAviso.BackgroundTransparency = 1
	textoAviso.TextScaled = true
	textoAviso.Font = Enum.Font.GothamBold
	textoAviso.TextColor3 = Color3.new(1, 1, 1)
	textoAviso.TextTransparency = 1
	textoAviso.Parent = tela
	marcador = Instance.new("BillboardGui")
	marcador.Size = UDim2.fromOffset(18, 18)
	marcador.StudsOffset = Vector3.new(0, 5.5, 0)
	marcador.AlwaysOnTop = true
	marcador.Enabled = false
	local seta = Instance.new("TextLabel")
	seta.Size = UDim2.fromScale(1, 1)
	seta.BackgroundTransparency = 1
	seta.Text = "▼"
	seta.TextScaled = true
	seta.TextColor3 = Color3.fromRGB(255, 220, 120)
	seta.Parent = marcador
	marcador.Parent = tela
end

function HudDeCombate.Start()
	local function personagem(ch: Model)
		local h = ch:WaitForChild("Humanoid") :: Humanoid
		local function vida()
			barraVida.Size = UDim2.fromScale(math.clamp(h.Health / math.max(1, h.MaxHealth), 0, 1), 1)
		end
		h.HealthChanged:Connect(vida)
		vida()
	end
	if jogador.Character then
		personagem(jogador.Character)
	end
	jogador.CharacterAdded:Connect(personagem)
	local pasta = Workspace:WaitForChild("GuardioesInimigos")
	local function novo(m: Instance)
		if m:IsA("Model") then
			task.defer(function()
				if m.Parent and m.PrimaryPart then
					barrasInimigos[m] = barraDoInimigo(m)
				end
			end)
		end
	end
	for _, m in pasta:GetChildren() do
		novo(m)
	end
	pasta.ChildAdded:Connect(novo)
	pasta.ChildRemoved:Connect(function(m)
		local bb = barrasInimigos[m :: Model]
		if bb then
			bb:Destroy()
			barrasInimigos[m :: Model] = nil
		end
	end)
end

return HudDeCombate
