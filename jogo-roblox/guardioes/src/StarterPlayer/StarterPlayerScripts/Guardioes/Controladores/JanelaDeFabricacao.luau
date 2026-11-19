--!strict
-- NÃO EXECUTADO NO STUDIO. Janela de fabricação + avisos de restauração (cliente).
--  * Abre quando o servidor manda a LISTA (prompt "Fabricar" de uma estação). Cada receita mostra materiais,
--    o que falta e o botão Fabricar (o servidor confere tudo de novo).
--  * Restauração: ao usar o prompt "Restaurar", mostra etapa atual, o que falta e quando alguém te ajudou.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local G = ReplicatedStorage:WaitForChild("Guardioes")
local Remotos = require(G.Rede.Remotos)
local Materiais = require(G.Config.Materiais)
local Mensagens = require(G.Util.Mensagens)

local F = Remotos.Fabricacao
local EF = Remotos.EventoFabricacao
local ER = Remotos.EventoRestauracao
local jogador = Players.LocalPlayer

local JanelaDeFabricacao = { Nome = "JanelaDeFabricacao" }

local hud: any
local ctxSalvo: any = nil
local evFab: RemoteEvent
local janela: Frame
local lista: ScrollingFrame

local function nomeMat(id: string): string
	local m = Materiais.porId[id]
	return if m then m.nome else (string.gsub(id, "(%l)(%u)", "%1 %2"))
end

local function rotulo(pai: Instance, t: string, y: number, tam: number, cor: Color3?)
	local l = Instance.new("TextLabel")
	l.Position, l.Size = UDim2.fromOffset(8, y), UDim2.new(1, -16, 0, tam + 4)
	l.BackgroundTransparency = 1
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextWrapped = true
	l.TextColor3 = cor or Color3.new(1, 1, 1)
	l.Font = Enum.Font.Gotham
	l.TextSize = tam
	l.Text = t
	l.Parent = pai
end

local function textoFalta(f: any): string
	if f.tipo == "material" then
		return string.format("%s %d/%d", nomeMat(f.id), f.tem, f.precisa)
	elseif f.tipo == "estacao" then
		return "Precisa estar na estação"
	elseif f.tipo == "restauracao" then
		return "Restaurar: " .. (string.gsub(f.id, "(%l)(%u)", "%1 %2"))
	end
	return (string.gsub(f.id, "(%l)(%u)", "%1 %2"))
end

local function mostrar(receitas: { any })
	for _, f in lista:GetChildren() do
		f:Destroy()
	end
	local y = 0
	if #receitas == 0 then
		rotulo(lista, "Nenhuma receita conhecida para esta estação.", y, 14)
		y += 24
	end
	for _, r in receitas do
		local c = Instance.new("Frame")
		c.Position, c.Size = UDim2.fromOffset(4, y), UDim2.new(1, -8, 0, 110)
		c.BackgroundColor3 = if r.pode then Color3.fromRGB(38, 56, 60) else Color3.fromRGB(26, 30, 46)
		c.BorderSizePixel = 0
		c.Parent = lista
		rotulo(c, r.nome, 4, 15, Color3.fromRGB(255, 220, 140))
		local mats = {}
		for id, q in r.materiais do
			table.insert(mats, string.format("%s × %d", nomeMat(id), q))
		end
		rotulo(c, "Materiais: " .. table.concat(mats, ", "), 24, 12)
		if not r.pode then
			local fs = {}
			for _, f in r.faltando do
				table.insert(fs, textoFalta(f))
			end
			rotulo(c, "Falta: " .. table.concat(fs, " · "), 52, 12, Color3.fromRGB(230, 200, 140))
		end
		local b = Instance.new("TextButton")
		b.Position, b.Size = UDim2.fromOffset(8, 78), UDim2.fromOffset(100, 26)
		b.BackgroundColor3 = if r.pode then Color3.fromRGB(60, 120, 80) else Color3.fromRGB(60, 60, 70)
		b.TextColor3 = Color3.new(1, 1, 1)
		b.Font = Enum.Font.GothamBold
		b.TextSize = 13
		b.Text = "Fabricar"
		b.Parent = c
		b.Activated:Connect(function()
			evFab:FireServer(F.FABRICAR, r.id)
		end)
		y += 116
	end
	lista.CanvasSize = UDim2.fromOffset(0, y)
	janela.Visible = true
end

function JanelaDeFabricacao.Init(ctx: any)
	ctxSalvo = ctx
	evFab = Remotos.evento("Fabricacao")
	local tela = Instance.new("ScreenGui")
	tela.Name = "GuardioesFabricacao"
	tela.ResetOnSpawn = false
	tela.Parent = jogador:WaitForChild("PlayerGui")
	janela = Instance.new("Frame")
	janela.Size, janela.Position = UDim2.fromOffset(340, 360), UDim2.new(0.5, -170, 0.5, -180)
	janela.BackgroundColor3 = Color3.fromRGB(18, 20, 32)
	janela.BackgroundTransparency = 0.05
	janela.BorderSizePixel = 0
	janela.Visible = false
	janela.Parent = tela
	local fechar = Instance.new("TextButton")
	fechar.Size, fechar.Position = UDim2.fromOffset(28, 28), UDim2.new(1, -32, 0, 4)
	fechar.Text = "×"
	fechar.TextSize = 20
	fechar.TextColor3 = Color3.new(1, 1, 1)
	fechar.BackgroundColor3 = Color3.fromRGB(60, 40, 50)
	fechar.Parent = janela
	fechar.Activated:Connect(function()
		janela.Visible = false
	end)
	lista = Instance.new("ScrollingFrame")
	lista.Size, lista.Position = UDim2.new(1, -8, 1, -40), UDim2.fromOffset(4, 36)
	lista.BackgroundTransparency = 1
	lista.BorderSizePixel = 0
	lista.ScrollBarThickness = 6
	lista.Parent = janela
	local titulo = Instance.new("TextLabel")
	titulo.Size, titulo.Position = UDim2.new(1, -40, 0, 28), UDim2.fromOffset(8, 4)
	titulo.BackgroundTransparency = 1
	titulo.TextXAlignment = Enum.TextXAlignment.Left
	titulo.TextColor3 = Color3.new(1, 1, 1)
	titulo.Font = Enum.Font.GothamBold
	titulo.TextSize = 16
	titulo.Text = "Fabricação"
	titulo.Parent = janela
end

function JanelaDeFabricacao.Start()
	hud = ctxSalvo.obter("HudDeCombate")
	evFab.OnClientEvent:Connect(function(tipo: number, a: any, b: any)
		if tipo == EF.LISTA and typeof(b) == "table" then
			mostrar(b)
		elseif tipo == EF.FEITO then
			hud.aviso("Fabricado: " .. tostring(a))
		elseif tipo == EF.REJEITADO then
			hud.aviso(Mensagens.texto(b))
		end
	end)
	Remotos.evento("Restauracao").OnClientEvent:Connect(function(tipo: number, _id: any, a: any)
		if tipo == ER.ESTADO and typeof(a) == "table" then
			if a.estado == "Restaurada" then
				hud.aviso(string.format("%s restaurada! %s", a.nome, a.funcao or ""))
			else
				local fs = {}
				for id, q in a.falta or {} do
					table.insert(fs, string.format("%s × %d", nomeMat(id), q))
				end
				hud.aviso(string.format("%s — etapa %d/%d: %s. Falta: %s", a.nome, a.etapa + 1, a.total, a.etapaNome or "", table.concat(fs, ", ")))
			end
		elseif tipo == ER.AJUDOU then
			hud.aviso("Etapa concluída com a ajuda de " .. tostring(a))
		end
	end)
end

return JanelaDeFabricacao
