--!strict
-- NÃO EXECUTADO NO STUDIO. Interface de companheiros, montaria e avisos de livros (cliente).
--  * Painel recolhível (aba "Criaturas", tecla K): um cartão por criatura com estágio, vínculo, XP, o que
--    falta para evoluir (sem segredos) e botões Ativar · Comando · Afagar · Evoluir · Montar.
--    Funciona igual no PC e no toque (botões grandes, sem botões fixos extras na tela).
--  * Atalhos PC/controle: T comando · H afagar · V montar/desmontar · K painel.
--  * Placas de nome das criaturas por perto (atributos replicados do modelo).
--  * Avisos de livros lidos/recusados.
-- O servidor valida tudo; a interface só pede e mostra.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local Workspace = game:GetService("Workspace")

local G = ReplicatedStorage:WaitForChild("Guardioes")
local Remotos = require(G.Rede.Remotos)
local Mensagens = require(G.Util.Mensagens)

local C = Remotos.Companheiro
local EC = Remotos.EventoCompanheiro
local MO = Remotos.Montaria
local EM = Remotos.EventoMontaria
local EL = Remotos.EventoLivro
local jogador = Players.LocalPlayer

local PainelDeCompanheiros = { Nome = "PainelDeCompanheiros" }

local COMANDOS = { "Acompanhar", "Permanecer", "Retornar" }

local evCompanheiro: RemoteEvent
local evMontaria: RemoteEvent
local evLivro: RemoteEvent
local hud: any
local loco: any
local ctxSalvo: any = nil
local lista: { any } = {}
local montado = false
local painel: Frame
local rolagem: ScrollingFrame
local aba: TextButton

local function legivel(id: string): string
	return (string.gsub(id, "(%l)(%u)", "%1 %2"))
end

local function textoFalta(f: any): string
	if f.tipo == "xp" then
		return string.format("XP %d/%d", f.tem, f.precisa)
	elseif f.tipo == "vinculo" then
		return string.format("Vínculo %d/%d", f.tem, f.precisa)
	elseif f.tipo == "marco" then
		return "Marco: " .. legivel(f.id)
	elseif f.tipo == "desafio" then
		return "Desafio: " .. legivel(f.id)
	elseif f.tipo == "maximo" then
		return "Estágio máximo"
	end
	return legivel(f.id)
end

local function ativa(): any?
	for _, c in lista do
		if c.ativa then
			return c
		end
	end
	return nil
end

local function botao(pai: Instance, texto: string, x: number, largura: number, acao: () -> ())
	local b = Instance.new("TextButton")
	b.Size = UDim2.fromOffset(largura, 30)
	b.Position = UDim2.fromOffset(x, 92)
	b.BackgroundColor3 = Color3.fromRGB(52, 60, 92)
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 13
	b.Text = texto
	b.AutoButtonColor = true
	b.Parent = pai
	b.Activated:Connect(acao)
	return b
end

local function rotulo(pai: Instance, texto: string, y: number, tamanho: number, cor: Color3?)
	local t = Instance.new("TextLabel")
	t.Size = UDim2.new(1, -16, 0, tamanho + 4)
	t.Position = UDim2.fromOffset(8, y)
	t.BackgroundTransparency = 1
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.TextColor3 = cor or Color3.new(1, 1, 1)
	t.Font = Enum.Font.Gotham
	t.TextSize = tamanho
	t.TextTruncate = Enum.TextTruncate.AtEnd
	t.Text = texto
	t.Parent = pai
	return t
end

local function cicloComando(c: any)
	local i = table.find(COMANDOS, c.comando or "Acompanhar") or 1
	evCompanheiro:FireServer(C.COMANDO, c.guid, COMANDOS[i % #COMANDOS + 1])
end

local function montarOuDesmontar()
	evMontaria:FireServer(if montado then MO.DESMONTAR else MO.MONTAR)
end

local function redesenhar()
	for _, filho in rolagem:GetChildren() do
		if filho:IsA("Frame") then
			filho:Destroy()
		end
	end
	for i, c in lista do
		local cartao = Instance.new("Frame")
		cartao.Size = UDim2.new(1, -8, 0, 130)
		cartao.Position = UDim2.fromOffset(4, (i - 1) * 136)
		cartao.BackgroundColor3 = if c.ativa then Color3.fromRGB(38, 46, 74) else Color3.fromRGB(26, 30, 46)
		cartao.BorderSizePixel = 0
		cartao.Parent = rolagem
		rotulo(cartao, string.format("%s — %s (%s)%s", c.nome, c.especieNome, c.estagio, if c.teste then " · teste" else ""), 6, 15)
		local linha = string.format("Vínculo %d · XP %d", c.nivelVinculo, c.xp)
		if c.especializacao then
			linha ..= " · " .. legivel(c.especializacao)
		end
		if c.ativa then
			linha ..= " · " .. (c.comando or "")
		end
		rotulo(cartao, linha, 28, 13, Color3.fromRGB(190, 200, 230))
		local falta: string
		if c.podeEvoluir then
			falta = "Pronta para evoluir!"
		else
			local partes = {}
			for k, f in c.faltando do
				if k <= 3 then
					table.insert(partes, textoFalta(f))
				end
			end
			falta = (if c.estagio == "Adulto" then "" else "Para evoluir: ") .. table.concat(partes, " · ")
		end
		rotulo(cartao, falta, 50, 12, if c.podeEvoluir then Color3.fromRGB(140, 230, 150) else Color3.fromRGB(230, 200, 140))
		if c.montariaTipo then
			rotulo(cartao, "Montaria " .. string.lower(c.montariaTipo) .. (if c.podeMontar then "" else " (quando adulta)"), 70, 12, Color3.fromRGB(160, 200, 255))
		end
		if not c.ativa then
			botao(cartao, "Ativar", 8, 80, function()
				evCompanheiro:FireServer(C.ATIVAR, c.guid)
			end)
		else
			botao(cartao, "Comando", 8, 76, function()
				cicloComando(c)
			end)
			botao(cartao, "Afagar", 88, 64, function()
				evCompanheiro:FireServer(C.AFAGAR, c.guid)
			end)
			if c.podeEvoluir then
				botao(cartao, "Evoluir", 156, 64, function()
					evCompanheiro:FireServer(C.EVOLUIR, c.guid)
				end)
			end
			if c.podeMontar then
				botao(cartao, if montado then "Desmontar" else "Montar", 224, 80, montarOuDesmontar)
			end
		end
	end
	rolagem.CanvasSize = UDim2.fromOffset(0, #lista * 136)
end

local function alternarPainel()
	painel.Visible = not painel.Visible
	aba.Text = if painel.Visible then "Fechar (K)" else "Criaturas (K)"
end

-- placas de nome das criaturas
local function placa(m: Instance)
	if not m:IsA("Model") then
		return
	end
	task.defer(function()
		local raiz = m.PrimaryPart
		if not raiz then
			return
		end
		local bb = Instance.new("BillboardGui")
		bb.Size = UDim2.fromOffset(140, 30)
		bb.StudsOffset = Vector3.new(0, raiz.Size.Y / 2 + 1.5, 0)
		bb.MaxDistance = 50
		bb.AlwaysOnTop = false
		bb.Adornee = raiz
		local t = Instance.new("TextLabel")
		t.Size = UDim2.fromScale(1, 1)
		t.BackgroundTransparency = 1
		t.TextColor3 = Color3.new(1, 1, 1)
		t.TextStrokeTransparency = 0.5
		t.Font = Enum.Font.GothamBold
		t.TextScaled = true
		t.Parent = bb
		local function atualizar()
			t.Text = string.format("%s · %s", tostring(m:GetAttribute("Nome") or ""), tostring(m:GetAttribute("Estagio") or ""))
		end
		m:GetAttributeChangedSignal("Nome"):Connect(atualizar)
		m:GetAttributeChangedSignal("Estagio"):Connect(atualizar)
		atualizar()
		bb.Parent = m
	end)
end

function PainelDeCompanheiros.Init(ctx: any)
	ctxSalvo = ctx
	evCompanheiro = Remotos.evento("Companheiro")
	evMontaria = Remotos.evento("Montaria")
	evLivro = Remotos.evento("Livro")
	local tela = Instance.new("ScreenGui")
	tela.Name = "GuardioesCompanheiros"
	tela.ResetOnSpawn = false
	tela.Parent = jogador:WaitForChild("PlayerGui")
	aba = Instance.new("TextButton")
	aba.Size = UDim2.fromOffset(120, 32)
	aba.Position = UDim2.new(0, 24, 0.5, -200)
	aba.BackgroundColor3 = Color3.fromRGB(38, 46, 74)
	aba.TextColor3 = Color3.new(1, 1, 1)
	aba.Font = Enum.Font.GothamBold
	aba.TextSize = 14
	aba.Text = "Criaturas (K)"
	aba.Parent = tela
	painel = Instance.new("Frame")
	painel.Size = UDim2.fromOffset(320, 360)
	painel.Position = UDim2.new(0, 24, 0.5, -160)
	painel.BackgroundColor3 = Color3.fromRGB(18, 20, 32)
	painel.BackgroundTransparency = 0.1
	painel.BorderSizePixel = 0
	painel.Visible = false
	painel.Parent = tela
	rolagem = Instance.new("ScrollingFrame")
	rolagem.Size = UDim2.new(1, -8, 1, -8)
	rolagem.Position = UDim2.fromOffset(4, 4)
	rolagem.BackgroundTransparency = 1
	rolagem.ScrollBarThickness = 6
	rolagem.BorderSizePixel = 0
	rolagem.Parent = painel
	aba.Activated:Connect(alternarPainel)
end

function PainelDeCompanheiros.Start()
	hud = ctxSalvo.obter("HudDeCombate")
	loco = ctxSalvo.obter("ControleDeLocomocao")

	evCompanheiro.OnClientEvent:Connect(function(tipo: number, a: any, b: any)
		if tipo == EC.LISTA and typeof(a) == "table" then
			lista = a
			redesenhar()
		elseif tipo == EC.REJEITADO then
			hud.aviso(if b == "faltaRequisito" then "Ainda faltam requisitos" else Mensagens.texto(b))
		elseif tipo == EC.EVOLUIU then
			hud.aviso("Sua criatura cresceu: " .. tostring(b) .. "!")
		end
	end)
	evMontaria.OnClientEvent:Connect(function(tipo: number, a: any, b: any)
		if tipo == EM.MONTADO then
			montado = a == true
			loco.definirMontariaVoadora(montado and b == true)
			redesenhar()
		elseif tipo == EM.REJEITADO then
			hud.aviso(Mensagens.texto(b))
		end
	end)
	evLivro.OnClientEvent:Connect(function(tipo: number, _id: any, a: any, b: any)
		if tipo == EL.LIDO then
			local nomes = if typeof(b) == "table" and #b > 0 then table.concat(b, ", ") else "um segredo"
			hud.aviso(string.format("%s: aprendeu %s", tostring(a), nomes))
		elseif tipo == EL.RECUSADO then
			hud.aviso(Mensagens.texto(a) or (if typeof(a) == "string" then a else nil))
		end
	end)

	local function acaoTecla(fn: () -> ())
		return function(_n: string, s: Enum.UserInputState, _o: InputObject)
			if s == Enum.UserInputState.Begin then
				fn()
			end
			return Enum.ContextActionResult.Sink
		end
	end
	ContextActionService:BindAction("GuardioesPainelCriaturas", acaoTecla(alternarPainel), false, Enum.KeyCode.K)
	ContextActionService:BindAction("GuardioesComandoCriatura", acaoTecla(function()
		local c = ativa()
		if c then
			cicloComando(c)
		end
	end), false, Enum.KeyCode.T, Enum.KeyCode.DPadLeft)
	ContextActionService:BindAction("GuardioesAfagar", acaoTecla(function()
		local c = ativa()
		if c then
			evCompanheiro:FireServer(C.AFAGAR, c.guid)
		end
	end), false, Enum.KeyCode.H, Enum.KeyCode.DPadRight)
	ContextActionService:BindAction("GuardioesMontar", acaoTecla(montarOuDesmontar), false, Enum.KeyCode.V, Enum.KeyCode.DPadDown)

	local pasta = Workspace:WaitForChild("GuardioesCompanheiros")
	for _, m in pasta:GetChildren() do
		placa(m)
	end
	pasta.ChildAdded:Connect(placa)
end

return PainelDeCompanheiros
