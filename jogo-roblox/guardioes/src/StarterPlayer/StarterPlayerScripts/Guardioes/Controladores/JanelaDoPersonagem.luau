--!strict
-- NÃO EXECUTADO NO STUDIO. Tela do personagem (tecla P ou aba): raça, habilidades aprendidas e livros.
--  * Sem raça salva: a tela abre sozinha com as raças (vantagens E limitações à vista) para escolher.
--  * Habilidades: o que o personagem SABE (lista do servidor). Livros: lidos, conhecidos com o requisito em
--    texto público, e os ocultos como "???" (sem revelar o segredo).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")

local G = ReplicatedStorage:WaitForChild("Guardioes")
local Remotos = require(G.Rede.Remotos)
local Habilidades = require(G.Config.Locomocao.Habilidades)
local Mensagens = require(G.Util.Mensagens)

local RA = Remotos.Raca
local ER = Remotos.EventoRaca
local EL = Remotos.EventoLocomocao
local ELi = Remotos.EventoLivro
local jogador = Players.LocalPlayer

local JanelaDoPersonagem = { Nome = "JanelaDoPersonagem" }

local hud: any
local ctxSalvo: any = nil
local evRaca: RemoteEvent
local janela: Frame
local rolagem: ScrollingFrame
local aba: TextButton
local racas: { any } = {}
local racaAtual: string? = nil
local podeTrocar = false
local habilidades: { string } = {}
local livros: { any } = {}

local function texto(t: string, y: number, tam: number, cor: Color3?): number
	local l = Instance.new("TextLabel")
	l.Position, l.Size = UDim2.fromOffset(8, y), UDim2.new(1, -16, 0, 0)
	l.AutomaticSize = Enum.AutomaticSize.Y
	l.BackgroundTransparency = 1
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextWrapped = true
	l.TextColor3 = cor or Color3.new(1, 1, 1)
	l.Font = Enum.Font.Gotham
	l.TextSize = tam
	l.Text = t
	l.Parent = rolagem
	-- altura estimada (linhas de ~40 caracteres)
	return y + (tam + 4) * math.max(1, math.ceil(#t / 40))
end

local function desenhar()
	for _, f in rolagem:GetChildren() do
		f:Destroy()
	end
	local y = 4
	local amarelo = Color3.fromRGB(255, 220, 140)
	y = texto("Raça", y, 16, amarelo)
	for _, r in racas do
		local atual = r.id == racaAtual
		y = texto((if atual then "● " else "○ ") .. r.nome .. " — " .. r.identidade, y, 13, if atual then Color3.fromRGB(140, 230, 150) else nil)
		y = texto("  + " .. table.concat(r.vantagens, "; "), y, 12, Color3.fromRGB(190, 220, 255))
		y = texto("  − " .. table.concat(r.limitacoes, "; "), y, 12, Color3.fromRGB(230, 190, 170))
		if podeTrocar and not atual then
			local b = Instance.new("TextButton")
			b.Position, b.Size = UDim2.fromOffset(12, y), UDim2.fromOffset(120, 24)
			b.BackgroundColor3 = Color3.fromRGB(52, 60, 92)
			b.TextColor3 = Color3.new(1, 1, 1)
			b.Font = Enum.Font.GothamBold
			b.TextSize = 13
			b.Text = "Escolher " .. r.nome
			b.Parent = rolagem
			b.Activated:Connect(function()
				evRaca:FireServer(RA.ESCOLHER, r.id)
			end)
			y += 30
		end
		y += 4
	end
	if podeTrocar then
		y = texto("(Valores provisórios: a troca é livre até o nível 5.)", y, 11, Color3.fromRGB(170, 170, 190))
	end
	y += 8
	y = texto("Habilidades aprendidas", y, 16, amarelo)
	if #habilidades == 0 then
		y = texto("Nenhuma ainda.", y, 13)
	end
	for _, id in habilidades do
		local h = Habilidades.porId[id]
		y = texto("• " .. (if h then h.nome .. " — " .. h.descricao else id), y, 12)
	end
	y += 8
	y = texto("Livros", y, 16, amarelo)
	for _, l in livros do
		if l.lido then
			y = texto("✓ " .. l.nome .. (if l.ensina then " (" .. l.ensina .. ")" else ""), y, 13, Color3.fromRGB(140, 230, 150))
		else
			y = texto("◇ " .. l.nome .. (if l.requisito then " — " .. l.requisito else ""), y, 12)
		end
	end
	rolagem.CanvasSize = UDim2.fromOffset(0, y + 10)
end

local function abrir(v: boolean)
	janela.Visible = v
	aba.Text = if v then "Fechar (P)" else "Personagem (P)"
	if v then
		desenhar()
	end
end

function JanelaDoPersonagem.Init(ctx: any)
	ctxSalvo = ctx
	evRaca = Remotos.evento("Raca")
	local tela = Instance.new("ScreenGui")
	tela.Name = "GuardioesPersonagem"
	tela.ResetOnSpawn = false
	tela.Parent = jogador:WaitForChild("PlayerGui")
	aba = Instance.new("TextButton")
	aba.Size, aba.Position = UDim2.fromOffset(140, 32), UDim2.new(0, 408, 0.5, -200)
	aba.BackgroundColor3 = Color3.fromRGB(38, 46, 74)
	aba.TextColor3 = Color3.new(1, 1, 1)
	aba.Font = Enum.Font.GothamBold
	aba.TextSize = 14
	aba.Text = "Personagem (P)"
	aba.Parent = tela
	aba.Activated:Connect(function()
		abrir(not janela.Visible)
	end)
	janela = Instance.new("Frame")
	janela.Size, janela.Position = UDim2.fromOffset(360, 420), UDim2.new(0.5, -180, 0.5, -210)
	janela.BackgroundColor3 = Color3.fromRGB(18, 20, 32)
	janela.BackgroundTransparency = 0.05
	janela.BorderSizePixel = 0
	janela.Visible = false
	janela.Parent = tela
	rolagem = Instance.new("ScrollingFrame")
	rolagem.Size, rolagem.Position = UDim2.new(1, -8, 1, -8), UDim2.fromOffset(4, 4)
	rolagem.BackgroundTransparency = 1
	rolagem.BorderSizePixel = 0
	rolagem.ScrollBarThickness = 6
	rolagem.Parent = janela
end

function JanelaDoPersonagem.Start()
	hud = ctxSalvo.obter("HudDeCombate")
	evRaca.OnClientEvent:Connect(function(tipo: number, a: any, b: any, c: any, d: any)
		if tipo == ER.LISTA and typeof(a) == "table" then
			racas, racaAtual, podeTrocar = a, b, c == true
			if d == true then
				abrir(true) -- primeira vez: escolher a raça
			elseif janela.Visible then
				desenhar()
			end
		elseif tipo == ER.DEFINIDA then
			racaAtual = a
			hud.aviso("Raça: " .. tostring(b))
			if janela.Visible then
				desenhar()
			end
		elseif tipo == ER.REJEITADO then
			hud.aviso(Mensagens.texto(a))
		end
	end)
	Remotos.evento("Locomocao").OnClientEvent:Connect(function(tipo: number, a: any, b: any)
		if tipo == EL.HABILIDADES and typeof(a) == "table" then
			habilidades = a
			if typeof(b) == "string" then
				racaAtual = b
			end
			if janela.Visible then
				desenhar()
			end
		end
	end)
	Remotos.evento("Livro").OnClientEvent:Connect(function(tipo: number, a: any)
		if tipo == ELi.LISTA and typeof(a) == "table" then
			livros = a
			if janela.Visible then
				desenhar()
			end
		end
	end)
	ContextActionService:BindAction("GuardioesPersonagem", function(_n, s, _o)
		if s == Enum.UserInputState.Begin then
			abrir(not janela.Visible)
		end
		return Enum.ContextActionResult.Sink
	end, false, Enum.KeyCode.P)
end

return JanelaDoPersonagem
