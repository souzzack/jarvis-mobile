--!strict
-- NÃO EXECUTADO NO STUDIO. HUD de progresso (cliente):
--  * nível e barra de XP (canto superior esquerdo);
--  * missões ativas com o progresso (lado direito);
--  * avisos de saque ("+2 Fragmento de Faísca") e de missão concluída;
--  * janela "Bolsa" (tecla I ou aba na tela): materiais e artefatos com Equipar / Evoluir e o que falta para o
--    próximo estágio. Tudo é pedido ao servidor, que decide.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")

local G = ReplicatedStorage:WaitForChild("Guardioes")
local Remotos = require(G.Rede.Remotos)
local Materiais = require(G.Config.Materiais)

local A = Remotos.Artefato
local EA = Remotos.EventoArtefato
local EI = Remotos.EventoInventario
local EM = Remotos.EventoMissao
local EP = Remotos.EventoProgressao
local jogador = Players.LocalPlayer

local HudDeProgresso = { Nome = "HudDeProgresso" }

local hud: any
local ctxSalvo: any = nil
local evArtefato: RemoteEvent
local tela: ScreenGui
local rotuloNivel: TextLabel
local barraXp: Frame
local quadroMissoes: Frame
local janela: Frame
local listaJanela: ScrollingFrame
local abaBolsa: TextButton
local materiais: { any } = {}
local artefatos: { any } = {}
local equipamentos: { any } = {}
local totaisEquip: any = nil
local capacidadeEquip: any = nil
local evEquip: RemoteEvent
local faltas: { [string]: string } = {}

local function texto(pai: Instance, t: string, pos: UDim2, tam: UDim2, tamanhoFonte: number, cor: Color3?): TextLabel
	local l = Instance.new("TextLabel")
	l.Position, l.Size = pos, tam
	l.BackgroundTransparency = 1
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextColor3 = cor or Color3.new(1, 1, 1)
	l.Font = Enum.Font.Gotham
	l.TextSize = tamanhoFonte
	l.TextWrapped = true
	l.Text = t
	l.Parent = pai
	return l
end

local function nomeMaterial(id: string): string
	local m = Materiais.porId[id]
	return if m then m.nome else id
end

local function desenharMissoes(lista: { any })
	for _, f in quadroMissoes:GetChildren() do
		f:Destroy()
	end
	local y = 0
	for _, m in lista do
		texto(quadroMissoes, m.nome, UDim2.fromOffset(0, y), UDim2.new(1, 0, 0, 18), 15, Color3.fromRGB(255, 220, 140))
		y += 18
		for _, linha in m.linhas do
			texto(quadroMissoes, "• " .. linha, UDim2.fromOffset(6, y), UDim2.new(1, -6, 0, 16), 13, Color3.fromRGB(220, 225, 240))
			y += 16
		end
		y += 6
	end
end

local function desenharJanela()
	for _, f in listaJanela:GetChildren() do
		if not f:IsA("UIListLayout") then
			f:Destroy()
		end
	end
	local y = 0
	texto(listaJanela, "Materiais", UDim2.fromOffset(8, y), UDim2.new(1, -16, 0, 20), 15, Color3.fromRGB(255, 220, 140))
	y += 22
	if #materiais == 0 then
		texto(listaJanela, "(vazio)", UDim2.fromOffset(12, y), UDim2.new(1, -16, 0, 16), 13)
		y += 18
	end
	for _, m in materiais do
		texto(listaJanela, string.format("%s × %d", m.nome, m.qtd), UDim2.fromOffset(12, y), UDim2.new(1, -16, 0, 16), 13)
		y += 18
	end
	y += 8
	texto(listaJanela, "Artefatos", UDim2.fromOffset(8, y), UDim2.new(1, -16, 0, 20), 15, Color3.fromRGB(255, 220, 140))
	y += 22
	for _, a in artefatos do
		local cartao = Instance.new("Frame")
		cartao.Position = UDim2.fromOffset(4, y)
		cartao.Size = UDim2.new(1, -8, 0, 104)
		cartao.BackgroundColor3 = if a.equipado then Color3.fromRGB(38, 46, 74) else Color3.fromRGB(26, 30, 46)
		cartao.BorderSizePixel = 0
		cartao.Parent = listaJanela
		texto(cartao, string.format("%s · %s · estágio %d%s", a.nome, a.raridade == "Oculta" and "???" or a.raridade, a.estagio, if a.teste then " · teste" else ""), UDim2.fromOffset(8, 4), UDim2.new(1, -16, 0, 18), 14)
		texto(cartao, "Próximo: " .. (a.proximoEstagio or "estágio máximo"), UDim2.fromOffset(8, 24), UDim2.new(1, -16, 0, 30), 12, Color3.fromRGB(190, 200, 230))
		if faltas[a.guid] then
			texto(cartao, faltas[a.guid], UDim2.fromOffset(8, 52), UDim2.new(1, -16, 0, 16), 12, Color3.fromRGB(230, 200, 140))
		end
		local function botao(rotulo: string, x: number, acao: () -> ())
			local b = Instance.new("TextButton")
			b.Position, b.Size = UDim2.fromOffset(x, 72), UDim2.fromOffset(90, 26)
			b.BackgroundColor3 = Color3.fromRGB(52, 60, 92)
			b.TextColor3 = Color3.new(1, 1, 1)
			b.Font = Enum.Font.GothamBold
			b.TextSize = 13
			b.Text = rotulo
			b.Parent = cartao
			b.Activated:Connect(acao)
		end
		if not a.equipado then
			botao("Equipar", 8, function()
				evArtefato:FireServer(A.EQUIPAR, a.guid)
			end)
		end
		if a.proximoEstagio then
			botao("Evoluir", 104, function()
				evArtefato:FireServer(A.EVOLUIR, a.guid)
			end)
		end
		y += 110
	end
	-- equipamentos (armaduras e acessórios)
	y += 6
	local titulo = if capacidadeEquip then string.format("Equipamentos (%d/%d no Depósito)", capacidadeEquip.tem, capacidadeEquip.cabe) else "Equipamentos"
	texto(listaJanela, titulo, UDim2.fromOffset(8, y), UDim2.new(1, -16, 0, 20), 15, Color3.fromRGB(255, 220, 140))
	y += 22
	if totaisEquip then
		texto(listaJanela, string.format("Defesa %d · Vida +%d · Energia de voo +%d", totaisEquip.defesa, totaisEquip.vidaBonus, totaisEquip.energiaVoo), UDim2.fromOffset(12, y), UDim2.new(1, -16, 0, 16), 12, Color3.fromRGB(190, 200, 230))
		y += 20
	end
	if #equipamentos == 0 then
		texto(listaJanela, "(nenhum — fabrique na Forja da base)", UDim2.fromOffset(12, y), UDim2.new(1, -16, 0, 16), 13)
		y += 18
	end
	local ocupados: { [string]: boolean } = {}
	for _, it in equipamentos do
		if it.encaixe then
			ocupados[it.encaixe] = true
		end
	end
	for _, it in equipamentos do
		local c = Instance.new("Frame")
		c.Position, c.Size = UDim2.fromOffset(4, y), UDim2.new(1, -8, 0, 62)
		c.BackgroundColor3 = if it.encaixe then Color3.fromRGB(38, 46, 74) else Color3.fromRGB(26, 30, 46)
		c.BorderSizePixel = 0
		c.Parent = listaJanela
		local partes = {}
		for k, v in it.atributos do
			table.insert(partes, string.format("%s %s", k, tostring(v)))
		end
		texto(c, string.format("%s +%d · %s · %s%s", it.nome, it.melhoria or 0, it.raridade, it.tipo, if it.encaixe then " (equipado)" else ""), UDim2.fromOffset(8, 4), UDim2.new(1, -16, 0, 16), 13)
		if it.proximaMelhoria then
			local m = Instance.new("TextButton")
			m.Position, m.Size = UDim2.new(1, -96, 0, 46), UDim2.fromOffset(88, 14)
			m.BackgroundColor3 = Color3.fromRGB(70, 60, 40)
			m.TextColor3 = Color3.new(1, 1, 1)
			m.Font = Enum.Font.GothamBold
			m.TextSize = 11
			m.Text = string.format("Melhorar +%d", (it.melhoria or 0) + 1)
			m.Parent = c
			m.Activated:Connect(function()
				evEquip:FireServer(Remotos.Equipamento.MELHORAR, it.guid)
			end)
		end
		texto(c, table.concat(partes, " · ") .. (if it.efeito then " — " .. it.efeito else ""), UDim2.fromOffset(8, 20), UDim2.new(1, -110, 0, 30), 11, Color3.fromRGB(190, 200, 230))
		if not it.encaixe then
			-- desmontar abre espaço no Depósito; pede um segundo clique (devolve só parte do material)
			local d = Instance.new("TextButton")
			d.Position, d.Size = UDim2.new(1, -190, 0, 46), UDim2.fromOffset(88, 14)
			d.BackgroundColor3 = Color3.fromRGB(80, 40, 44)
			d.TextColor3 = Color3.new(1, 1, 1)
			d.Font = Enum.Font.GothamBold
			d.TextSize = 11
			d.Text = "Desmontar"
			d.Parent = c
			local armado = false
			d.Activated:Connect(function()
				if not armado then
					armado = true
					d.Text = "Confirmar?"
					task.delay(3, function()
						if d.Parent then
							armado = false
							d.Text = "Desmontar"
						end
					end)
					return
				end
				evEquip:FireServer(Remotos.Equipamento.DESMONTAR, it.guid)
			end)
		end
		local b = Instance.new("TextButton")
		b.Position, b.Size = UDim2.new(1, -96, 0, 18), UDim2.fromOffset(88, 26)
		b.BackgroundColor3 = Color3.fromRGB(52, 60, 92)
		b.TextColor3 = Color3.new(1, 1, 1)
		b.Font = Enum.Font.GothamBold
		b.TextSize = 13
		b.Text = if it.encaixe then "Retirar" else "Equipar"
		b.Parent = c
		b.Activated:Connect(function()
			if it.encaixe then
				evEquip:FireServer(Remotos.Equipamento.RETIRAR, it.encaixe)
			else
				local encaixe = it.tipo
				if it.tipo == "Acessorio" then
					encaixe = if ocupados.Acessorio1 then "Acessorio2" else "Acessorio1"
				end
				evEquip:FireServer(Remotos.Equipamento.EQUIPAR, it.guid, encaixe)
			end
		end)
		y += 68
	end
	listaJanela.CanvasSize = UDim2.fromOffset(0, y)
end

local function alternarJanela()
	janela.Visible = not janela.Visible
	abaBolsa.Text = if janela.Visible then "Fechar (I)" else "Bolsa (I)"
	if janela.Visible then
		desenharJanela()
	end
end

function HudDeProgresso.Init(ctx: any)
	ctxSalvo = ctx
	evArtefato = Remotos.evento("Artefato")
	tela = Instance.new("ScreenGui")
	tela.Name = "GuardioesHudProgresso"
	tela.ResetOnSpawn = false
	tela.Parent = jogador:WaitForChild("PlayerGui")
	rotuloNivel = texto(tela, "Nv 1", UDim2.fromOffset(24, 12), UDim2.fromOffset(80, 22), 18)
	rotuloNivel.Font = Enum.Font.GothamBold
	local fundo = Instance.new("Frame")
	fundo.Position, fundo.Size = UDim2.fromOffset(90, 18), UDim2.fromOffset(180, 8)
	fundo.BackgroundColor3 = Color3.fromRGB(20, 22, 34)
	fundo.BorderSizePixel = 0
	fundo.Parent = tela
	barraXp = Instance.new("Frame")
	barraXp.Size = UDim2.fromScale(0, 1)
	barraXp.BackgroundColor3 = Color3.fromRGB(255, 205, 80)
	barraXp.BorderSizePixel = 0
	barraXp.Parent = fundo
	quadroMissoes = Instance.new("Frame")
	quadroMissoes.Position, quadroMissoes.Size = UDim2.new(1, -280, 0, 80), UDim2.fromOffset(260, 260)
	quadroMissoes.BackgroundTransparency = 1
	quadroMissoes.Parent = tela
	abaBolsa = Instance.new("TextButton")
	abaBolsa.Size = UDim2.fromOffset(120, 32)
	abaBolsa.Position = UDim2.new(0, 152, 0.5, -200)
	abaBolsa.BackgroundColor3 = Color3.fromRGB(38, 46, 74)
	abaBolsa.TextColor3 = Color3.new(1, 1, 1)
	abaBolsa.Font = Enum.Font.GothamBold
	abaBolsa.TextSize = 14
	abaBolsa.Text = "Bolsa (I)"
	abaBolsa.Parent = tela
	janela = Instance.new("Frame")
	janela.Size = UDim2.fromOffset(320, 380)
	janela.Position = UDim2.new(0, 152, 0.5, -160)
	janela.BackgroundColor3 = Color3.fromRGB(18, 20, 32)
	janela.BackgroundTransparency = 0.1
	janela.BorderSizePixel = 0
	janela.Visible = false
	janela.Parent = tela
	listaJanela = Instance.new("ScrollingFrame")
	listaJanela.Size, listaJanela.Position = UDim2.new(1, -8, 1, -8), UDim2.fromOffset(4, 4)
	listaJanela.BackgroundTransparency = 1
	listaJanela.BorderSizePixel = 0
	listaJanela.ScrollBarThickness = 6
	listaJanela.Parent = janela
	abaBolsa.Activated:Connect(alternarJanela)
end

function HudDeProgresso.Start()
	hud = ctxSalvo.obter("HudDeCombate")
	Remotos.evento("Progressao").OnClientEvent:Connect(function(tipo: number, nivel: any, xp: any, prox: any, subiu: any)
		if tipo == EP.NIVEL then
			rotuloNivel.Text = "Nv " .. tostring(nivel)
			barraXp.Size = UDim2.fromScale(math.clamp((xp or 0) / math.max(1, prox or 1), 0, 1), 1)
			if subiu then
				hud.aviso("Nível " .. tostring(nivel) .. "!")
			end
		end
	end)
	Remotos.evento("Missoes").OnClientEvent:Connect(function(tipo: number, a: any)
		if tipo == EM.LISTA and typeof(a) == "table" then
			desenharMissoes(a)
		elseif tipo == EM.CONCLUIDA then
			hud.aviso("Missão concluída: " .. tostring(a))
		end
	end)
	Remotos.evento("Inventario").OnClientEvent:Connect(function(tipo: number, a: any)
		if tipo == EI.MATERIAIS and typeof(a) == "table" then
			materiais = a
			if janela.Visible then
				desenharJanela()
			end
		elseif tipo == EI.SAQUE and typeof(a) == "table" then
			local partes = {}
			for id, q in a do
				table.insert(partes, string.format("+%d %s", q, nomeMaterial(id)))
			end
			hud.aviso(table.concat(partes, "  "))
		end
	end)
	evEquip = Remotos.evento("Equipamento")
	evEquip.OnClientEvent:Connect(function(tipo: number, a: any, b: any, c: any)
		if tipo == Remotos.EventoEquipamento.LISTA and typeof(a) == "table" then
			equipamentos, totaisEquip = a, b
			capacidadeEquip = if typeof(c) == "table" then c else nil
			if janela.Visible then
				desenharJanela()
			end
		elseif tipo == Remotos.EventoEquipamento.REJEITADO then
			hud.aviso(require(G.Util.Mensagens).texto(a))
		elseif tipo == Remotos.EventoEquipamento.DESMONTOU then
			hud.aviso(tostring(a) .. " desmontado")
		elseif tipo == Remotos.EventoEquipamento.MELHOROU then
			hud.aviso(string.format("%s agora +%d", tostring(a), b or 0))
		elseif tipo == Remotos.EventoEquipamento.FALTA and typeof(b) == "table" then
			local partes = {}
			for _, f in b do
				table.insert(partes, string.format("%s %d/%d", nomeMaterial(f.id), f.tem or 0, f.precisa or 0))
			end
			hud.aviso("Para melhorar falta: " .. table.concat(partes, " · "))
		end
	end)
	evArtefato.OnClientEvent:Connect(function(tipo: number, a: any, b: any)
		if tipo == EA.INVENTARIO and typeof(a) == "table" then
			artefatos = a
		elseif tipo == EA.EVOLUIU then
			faltas[a] = nil
			hud.aviso("Artefato evoluiu: estágio " .. tostring(b))
		elseif tipo == EA.FALTA and typeof(b) == "table" then
			local partes = {}
			for _, f in b do
				if f.tipo == "material" then
					table.insert(partes, string.format("%s %d/%d", nomeMaterial(f.id), f.tem, f.precisa))
				elseif f.tipo == "maximo" then
					table.insert(partes, "estágio máximo")
				else
					table.insert(partes, (string.gsub(f.id, "(%l)(%u)", "%1 %2")))
				end
			end
			faltas[a] = "Falta: " .. table.concat(partes, " · ")
		end -- (recusas já são avisadas pelo TransformacaoDeArtefato)
		if janela.Visible then
			desenharJanela()
		end
	end)
	ContextActionService:BindAction("GuardioesBolsa", function(_n, s, _o)
		if s == Enum.UserInputState.Begin then
			alternarJanela()
		end
		return Enum.ContextActionResult.Sink
	end, false, Enum.KeyCode.I)
end

return HudDeProgresso
