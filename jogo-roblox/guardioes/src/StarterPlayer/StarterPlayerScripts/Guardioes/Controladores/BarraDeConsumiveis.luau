--!strict
-- NÃO EXECUTADO NO STUDIO. Barra de consumíveis (Bancada): 3 espaços, teclas 2, 3 e 4 (o bálsamo também no
-- L1 do controle) ou toque. Mostra quantos tem e a recarga. O servidor decide se pode usar; a barra só pede.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")

local G = ReplicatedStorage:WaitForChild("Guardioes")
local Remotos = require(G.Rede.Remotos)
local Mensagens = require(G.Util.Mensagens)
local Consumiveis = require(G.Config.Consumiveis)

local EC = Remotos.EventoConsumivel
local EI = Remotos.EventoInventario
local jogador = Players.LocalPlayer

local BarraDeConsumiveis = { Nome = "BarraDeConsumiveis" }

local ctxSalvo: any = nil
local hud: any
local ev: RemoteEvent
local quantos: { [string]: number } = {}
local recargaAte: { [string]: number } = {} -- tipo de efeito → os.clock() local
local botoes: { [string]: TextButton } = {}
local barra: Frame

local TECLAS = { [2] = Enum.KeyCode.Two, [3] = Enum.KeyCode.Three, [4] = Enum.KeyCode.Four }

local function atualizar()
	local agora = os.clock()
	local algum = false
	for _, c in Consumiveis.lista do
		local b = botoes[c.id]
		local n = quantos[c.id] or 0
		if n > 0 then
			algum = true
		end
		local falta = (recargaAte[c.efeito.tipo] or 0) - agora
		b.Text = string.format("[%d] %s\n×%d%s", c.tecla, c.nome, n, if falta > 0 then string.format(" · %ds", math.ceil(falta)) else "")
		b.BackgroundColor3 = if n == 0 then Color3.fromRGB(30, 30, 38) elseif falta > 0 then Color3.fromRGB(44, 44, 60) else Color3.fromRGB(52, 70, 60)
		b.TextColor3 = if n == 0 then Color3.fromRGB(120, 120, 130) else Color3.new(1, 1, 1)
	end
	barra.Visible = algum -- sem nenhum consumível, a barra não ocupa a tela
end

local function pedir(id: string)
	if (quantos[id] or 0) <= 0 then
		return
	end
	ev:FireServer(Remotos.Consumivel.USAR, id)
end

function BarraDeConsumiveis.Init(ctx: any)
	ctxSalvo = ctx
	ev = Remotos.evento("Consumivel")
	local tela = Instance.new("ScreenGui")
	tela.Name = "GuardioesConsumiveis"
	tela.ResetOnSpawn = false
	tela.Parent = jogador:WaitForChild("PlayerGui")
	barra = Instance.new("Frame")
	barra.AnchorPoint = Vector2.new(0.5, 1)
	-- acima das barras de vida e estamina, no centro de baixo
	barra.Position, barra.Size = UDim2.new(0.5, 0, 1, -130), UDim2.fromOffset(3 * 128, 44)
	barra.BackgroundTransparency = 1
	barra.Visible = false
	barra.Parent = tela
	for i, c in Consumiveis.lista do
		local b = Instance.new("TextButton")
		b.Position, b.Size = UDim2.fromOffset((i - 1) * 128, 0), UDim2.fromOffset(122, 44)
		b.BorderSizePixel = 0
		b.Font = Enum.Font.GothamBold
		b.TextSize = 11
		b.TextWrapped = true
		b.Parent = barra
		b.Activated:Connect(function()
			pedir(c.id)
		end)
		botoes[c.id] = b
	end
end

function BarraDeConsumiveis.Start()
	hud = ctxSalvo.obter("HudDeCombate")
	Remotos.evento("Inventario").OnClientEvent:Connect(function(tipo: number, a: any)
		if tipo == EI.MATERIAIS and typeof(a) == "table" then
			table.clear(quantos)
			for _, m in a do
				if Consumiveis.porId[m.id] then
					quantos[m.id] = m.qtd
				end
			end
			atualizar()
		end
	end)
	ev.OnClientEvent:Connect(function(tipo: number, a: any, b: any, c: any)
		if tipo == EC.USOU and typeof(b) == "number" and typeof(c) == "string" then
			recargaAte[c] = os.clock() + b
			atualizar()
		elseif tipo == EC.REJEITADO then
			hud.aviso(Mensagens.texto(a))
		end
	end)
	for _, c in Consumiveis.lista do
		local teclas = { TECLAS[c.tecla] }
		if c.efeito.tipo == "Cura" then
			table.insert(teclas, Enum.KeyCode.ButtonL1)
		end
		ContextActionService:BindAction("GuardioesConsumivel_" .. c.id, function(_n, s, _o)
			if s == Enum.UserInputState.Begin then
				pedir(c.id)
			end
			return Enum.ContextActionResult.Sink
		end, false, table.unpack(teclas))
	end
	task.spawn(function()
		while true do
			task.wait(0.5)
			if barra.Visible then
				atualizar() -- contagem regressiva da recarga
			end
		end
	end)
end

return BarraDeConsumiveis
