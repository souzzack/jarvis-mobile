--!strict
-- NÃO EXECUTADO NO STUDIO. Diário de Descobertas (segredos ???), tecla Y ou aba.
-- Mostra só o que o SERVIDOR mandou: etapas feitas com nome e texto; as outras como "???" (com a dica vaga
-- quando já estão ao alcance). O Artefato Desconhecido aparece com a descrição revelada aos poucos.
-- Também: examinar as margens dos livros lidos, a contagem da contemplação e a constelação no céu.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local TextService = game:GetService("TextService")

local G = ReplicatedStorage:WaitForChild("Guardioes")
local Remotos = require(G.Rede.Remotos)
local Livros = require(G.Config.LivrosMagicos)

local SG = Remotos.Segredo
local ES = Remotos.EventoSegredo
local jogador = Players.LocalPlayer

local DiarioDeDescobertas = { Nome = "DiarioDeDescobertas" }

local ctxSalvo: any = nil
local hud: any
local ev: RemoteEvent
local tela: ScreenGui
local janela: Frame
local lista: ScrollingFrame
local aba: TextButton
local contagem: TextLabel
local ceu: Frame
local dados: { etapas: { any }, artefato: string?, margens: { any } } = { etapas = {}, artefato = nil, margens = {} }
local y = 0

local function texto(t: string, tamanho: number, cor: Color3?, negrito: boolean?)
	local l = Instance.new("TextLabel")
	l.Position = UDim2.fromOffset(6, y)
	local fonte = if negrito then Enum.Font.GothamBold else Enum.Font.Gotham
	local altura = TextService:GetTextSize(t, tamanho, fonte, Vector2.new(372, 10000)).Y
	l.Size = UDim2.new(1, -12, 0, altura)
	l.BackgroundTransparency = 1
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextWrapped = true
	l.Font = fonte
	l.TextSize = tamanho
	l.TextColor3 = cor or Color3.new(1, 1, 1)
	l.Text = t
	l.Parent = lista
	y += altura + 4
end

local function nomeDoLivro(id: string): string
	local l = Livros.porId and Livros.porId[id]
	return if l and not l.oculto then l.nome else id
end

local function desenhar()
	for _, f in lista:GetChildren() do
		f:Destroy()
	end
	y = 0
	texto("Diário de Descobertas", 16, nil, true)
	for _, e in dados.etapas do
		local cor = if e.feita then Color3.fromRGB(240, 220, 150) elseif e.texto then Color3.fromRGB(190, 190, 210) else Color3.fromRGB(110, 110, 130)
		texto((if e.feita then "★ " else "· ") .. e.nome, 14, cor, e.feita)
		if e.texto then
			texto((if e.outroMundo then "(outro mundo) " else "") .. e.texto, 12, Color3.fromRGB(170, 170, 190))
		end
	end
	if dados.artefato then
		texto("Artefato Desconhecido", 14, Color3.fromRGB(200, 170, 255), true)
		texto(dados.artefato, 12, Color3.fromRGB(200, 190, 230))
	end
	if #dados.margens > 0 then
		texto("Margens dos livros", 14, nil, true)
		for _, m in dados.margens do
			if m.examinada then
				texto(nomeDoLivro(m.livro) .. ": " .. (m.texto or ""), 12, Color3.fromRGB(180, 200, 180))
			else
				local b = Instance.new("TextButton")
				b.Position, b.Size = UDim2.fromOffset(6, y), UDim2.new(1, -12, 0, 26)
				b.BackgroundColor3 = Color3.fromRGB(52, 60, 92)
				b.TextColor3 = Color3.new(1, 1, 1)
				b.Font = Enum.Font.GothamBold
				b.TextSize = 12
				b.Text = "Examinar as margens: " .. nomeDoLivro(m.livro)
				b.Parent = lista
				b.Activated:Connect(function()
					ev:FireServer(SG.EXAMINAR_MARGEM, m.livro)
				end)
				y += 30
			end
		end
	end
	lista.CanvasSize = UDim2.fromOffset(0, y + 8)
end

-- a constelação no céu: anel de 6 estrelas em volta da Sétima; a do início brilha mais (dica dos pilares)
local function mostrarConstelacao(cores: { string }, inicio: number)
	for _, f in ceu:GetChildren() do
		f:Destroy()
	end
	local function estrela(x: number, yy: number, cor: Color3, tamanho: number)
		local e = Instance.new("Frame")
		e.AnchorPoint = Vector2.new(0.5, 0.5)
		e.Position = UDim2.new(0.5, x, 0.5, yy)
		e.Size = UDim2.fromOffset(tamanho, tamanho)
		e.BackgroundColor3 = cor
		e.BorderSizePixel = 0
		local canto = Instance.new("UICorner")
		canto.CornerRadius = UDim.new(1, 0)
		canto.Parent = e
		e.Parent = ceu
	end
	for i, hex in cores do
		local a = math.pi / 2 + (i - 1) * math.pi / 3
		local raio = if i % 2 == 1 then 90 else 72 -- dois triângulos de raios diferentes
		estrela(math.cos(a) * raio, -math.sin(a) * raio, Color3.fromHex(hex), if i == inicio then 22 else 10)
	end
	estrela(0, 0, Color3.fromHex("#FFF4D6"), 14)
	ceu.Visible = true
	task.delay(10, function()
		ceu.Visible = false
	end)
end

local function alternar()
	janela.Visible = not janela.Visible
	aba.Text = if janela.Visible then "Fechar (Y)" else "Descobertas (Y)"
	if janela.Visible then
		ev:FireServer(SG.DIARIO)
		desenhar()
	end
end

function DiarioDeDescobertas.Init(ctx: any)
	ctxSalvo = ctx
	ev = Remotos.evento("Segredo")
	tela = Instance.new("ScreenGui")
	tela.Name = "GuardioesDescobertas"
	tela.ResetOnSpawn = false
	tela.Parent = jogador:WaitForChild("PlayerGui")
	aba = Instance.new("TextButton")
	aba.Size, aba.Position = UDim2.fromOffset(140, 32), UDim2.new(0, 848, 0.5, -200)
	aba.BackgroundColor3 = Color3.fromRGB(46, 38, 74)
	aba.TextColor3 = Color3.new(1, 1, 1)
	aba.Font = Enum.Font.GothamBold
	aba.TextSize = 14
	aba.Text = "Descobertas (Y)"
	aba.Parent = tela
	aba.Activated:Connect(alternar)
	janela = Instance.new("Frame")
	janela.Size, janela.Position = UDim2.fromOffset(400, 440), UDim2.new(0, 848, 0.5, -160)
	janela.BackgroundColor3 = Color3.fromRGB(20, 16, 34)
	janela.BackgroundTransparency = 0.08
	janela.BorderSizePixel = 0
	janela.Visible = false
	janela.Parent = tela
	lista = Instance.new("ScrollingFrame")
	lista.Size, lista.Position = UDim2.new(1, -8, 1, -8), UDim2.fromOffset(4, 4)
	lista.BackgroundTransparency = 1
	lista.BorderSizePixel = 0
	lista.ScrollBarThickness = 6
	lista.Parent = janela
	contagem = Instance.new("TextLabel")
	contagem.AnchorPoint = Vector2.new(0.5, 0)
	contagem.Position, contagem.Size = UDim2.new(0.5, 0, 0, 300), UDim2.fromOffset(320, 30) -- fora da área segura de cima
	contagem.BackgroundTransparency = 0.4
	contagem.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
	contagem.TextColor3 = Color3.fromRGB(220, 220, 255)
	contagem.Font = Enum.Font.GothamBold
	contagem.TextSize = 16
	contagem.Visible = false
	contagem.Parent = tela
	ceu = Instance.new("Frame")
	ceu.AnchorPoint = Vector2.new(0.5, 0.5)
	ceu.Position, ceu.Size = UDim2.fromScale(0.5, 0.35), UDim2.fromOffset(240, 240)
	ceu.BackgroundTransparency = 1
	ceu.Visible = false
	ceu.Parent = tela
end

function DiarioDeDescobertas.Start()
	hud = ctxSalvo.obter("HudDeCombate")
	local fim = 0
	ev.OnClientEvent:Connect(function(tipo: number, a: any, b: any, c: any)
		if tipo == ES.DIARIO and typeof(a) == "table" then
			dados = { etapas = a, artefato = if typeof(b) == "string" then b else nil, margens = if typeof(c) == "table" then c else {} }
			if janela.Visible then
				desenhar()
			end
		elseif tipo == ES.AVISO and typeof(a) == "string" then
			hud.aviso(a)
		elseif tipo == ES.DESCOBERTA and typeof(a) == "string" then
			hud.aviso("Descoberta: " .. a)
		elseif tipo == ES.CONSTELACAO and typeof(a) == "table" and typeof(b) == "number" then
			mostrarConstelacao(a, b)
		elseif tipo == ES.CONTEMPLANDO and typeof(a) == "number" then
			if a <= 0 then
				contagem.Visible = false
				fim = 0
				return
			end
			fim = os.clock() + a
			contagem.Visible = true
			task.spawn(function()
				local meu = fim
				while contagem.Visible and fim == meu and os.clock() < fim do
					contagem.Text = string.format("Contemplando o céu… %d", math.ceil(fim - os.clock()))
					task.wait(0.2)
				end
			end)
		end
	end)
	ContextActionService:BindAction("GuardioesDescobertas", function(_n, s, _o)
		if s == Enum.UserInputState.Begin then
			alternar()
		end
		return Enum.ContextActionResult.Sink
	end, false, Enum.KeyCode.Y)
end

return DiarioDeDescobertas
