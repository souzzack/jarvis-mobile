--!strict
-- NÃO EXECUTADO NO STUDIO. Viagem rápida (cliente) + avisos da base pessoal.
--  * Tecla M ou aba "Viagem (M)": lista os pontos descobertos e "Minha base"; o servidor valida tudo
--    (descoberto, a pé, sem combate recente, recarga).
--  * Portal ("Atravessar" no portal): a mesma janela lista as DIMENSÕES com o estado de cada uma
--    (aqui, liberada, bloqueada com o requisito público, em construção). O servidor confere tudo de novo.
--  * Base: avisos de melhoria, de colheita e do que falta para o próximo nível.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")

local G = ReplicatedStorage:WaitForChild("Guardioes")
local Remotos = require(G.Rede.Remotos)
local Materiais = require(G.Config.Materiais)
local Mensagens = require(G.Util.Mensagens)

local VI = Remotos.Viagem
local EV = Remotos.EventoViagem
local EB = Remotos.EventoBase
local jogador = Players.LocalPlayer

local JanelaDeViagem = { Nome = "JanelaDeViagem" }

local hud: any
local ctxSalvo: any = nil
local evViagem: RemoteEvent
local janela: Frame
local lista: ScrollingFrame
local aba: TextButton
local pontos: { any } = {}
local destinos: { any }? = nil -- lista do portal (quando a janela foi aberta por um portal)
local ROTULO = { aqui = "você está aqui", ok = "atravessar", bloqueada = "bloqueada", emConstrucao = "em construção" }

local function nomeMat(id: string): string
	local m = Materiais.porId[id]
	return if m then m.nome else id
end

local function desenharPortal(ds: { any })
	for i, d in ds do
		local b = Instance.new("TextButton")
		b.Size, b.Position = UDim2.new(1, -8, 0, 52), UDim2.fromOffset(4, (i - 1) * 56)
		b.BackgroundColor3 = if d.estado == "ok" then Color3.fromRGB(70, 52, 120) else Color3.fromRGB(30, 30, 42)
		b.TextColor3 = if d.estado == "ok" then Color3.new(1, 1, 1) else Color3.fromRGB(150, 150, 165)
		b.Font = Enum.Font.GothamBold
		b.TextSize = 13
		b.TextWrapped = true
		b.Text = string.format("%s — %s%s", d.nome, ROTULO[d.estado] or d.estado, if d.requisito then "\n" .. d.requisito else "")
		b.AutoButtonColor = d.estado == "ok"
		b.Parent = lista
		b.Activated:Connect(function()
			if d.estado == "ok" then
				evViagem:FireServer(VI.ATRAVESSAR, d.id)
			end
		end)
	end
	lista.CanvasSize = UDim2.fromOffset(0, #ds * 56)
end

local function desenhar()
	for _, f in lista:GetChildren() do
		f:Destroy()
	end
	if destinos then
		desenharPortal(destinos)
		return
	end
	for i, pt in pontos do
		local b = Instance.new("TextButton")
		b.Size, b.Position = UDim2.new(1, -8, 0, 36), UDim2.fromOffset(4, (i - 1) * 40)
		b.BackgroundColor3 = if pt.id == "MinhaBase" then Color3.fromRGB(60, 80, 60) else Color3.fromRGB(38, 46, 74)
		b.TextColor3 = Color3.new(1, 1, 1)
		b.Font = Enum.Font.GothamBold
		b.TextSize = 14
		b.Text = pt.nome
		b.Parent = lista
		b.Activated:Connect(function()
			evViagem:FireServer(VI.VIAJAR, pt.id)
		end)
	end
	lista.CanvasSize = UDim2.fromOffset(0, #pontos * 40)
end

local function alternar()
	destinos = nil -- a tecla M sempre abre a viagem rápida
	janela.Visible = not janela.Visible
	aba.Text = if janela.Visible then "Fechar (M)" else "Viagem (M)"
	if janela.Visible then
		evViagem:FireServer(VI.LISTAR)
		desenhar()
	end
end

function JanelaDeViagem.Init(ctx: any)
	ctxSalvo = ctx
	evViagem = Remotos.evento("Viagem")
	local tela = Instance.new("ScreenGui")
	tela.Name = "GuardioesViagem"
	tela.ResetOnSpawn = false
	tela.Parent = jogador:WaitForChild("PlayerGui")
	aba = Instance.new("TextButton")
	aba.Size, aba.Position = UDim2.fromOffset(120, 32), UDim2.new(0, 280, 0.5, -200)
	aba.BackgroundColor3 = Color3.fromRGB(38, 46, 74)
	aba.TextColor3 = Color3.new(1, 1, 1)
	aba.Font = Enum.Font.GothamBold
	aba.TextSize = 14
	aba.Text = "Viagem (M)"
	aba.Parent = tela
	aba.Activated:Connect(alternar)
	janela = Instance.new("Frame")
	janela.Size, janela.Position = UDim2.fromOffset(240, 260), UDim2.new(0, 280, 0.5, -160)
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

function JanelaDeViagem.Start()
	hud = ctxSalvo.obter("HudDeCombate")
	evViagem.OnClientEvent:Connect(function(tipo: number, a: any)
		if tipo == EV.LISTA and typeof(a) == "table" then
			pontos = a
			if janela.Visible then
				desenhar()
			end
		elseif tipo == EV.DESCOBERTO then
			hud.aviso("Ponto de viagem descoberto: " .. tostring(a))
		elseif tipo == EV.REJEITADO then
			hud.aviso(Mensagens.texto(a))
		elseif tipo == EV.CHEGOU then
			janela.Visible = false
			aba.Text = "Viagem (M)"
		elseif tipo == EV.PORTAL and typeof(a) == "table" then
			destinos = a
			janela.Visible = true
			aba.Text = "Fechar (M)"
			desenhar()
		elseif tipo == EV.ATRAVESSANDO then
			janela.Visible = false
			aba.Text = "Viagem (M)"
			hud.aviso("Atravessando para " .. tostring(a) .. "…")
		end
	end)
	Remotos.evento("Base").OnClientEvent:Connect(function(tipo: number, a: any, b: any)
		if tipo == EB.MELHOROU then
			hud.aviso(string.format("%s agora no nível %d", tostring(a), b or 0))
		elseif tipo == EB.COLHEU and typeof(a) == "table" then
			local partes = {}
			for id, q in a do
				table.insert(partes, string.format("+%d %s", q, nomeMat(id)))
			end
			hud.aviso(if #partes > 0 then table.concat(partes, "  ") else "O jardim ainda está crescendo")
		elseif tipo == EB.REJEITADO then
			if typeof(b) == "table" and #b > 0 then
				local partes = {}
				for _, f in b do
					if f.tipo == "material" then
						table.insert(partes, string.format("%s %d/%d", nomeMat(f.id), f.tem, f.precisa))
					elseif f.tipo == "nivelJogador" then
						table.insert(partes, string.format("Nível %d/%d", f.tem, f.precisa))
					elseif f.tipo == "maximo" then
						table.insert(partes, "nível máximo")
					end
				end
				hud.aviso("Para melhorar falta: " .. table.concat(partes, " · "))
			else
				hud.aviso(Mensagens.texto(a))
			end
		end
	end)
	ContextActionService:BindAction("GuardioesViagem", function(_n, s, _o)
		if s == Enum.UserInputState.Begin then
			alternar()
		end
		return Enum.ContextActionResult.Sink
	end, false, Enum.KeyCode.M)
end

return JanelaDeViagem
