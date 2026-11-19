--!strict
-- NÃO EXECUTADO NO STUDIO. ATLAS DOS ARQUIVISTAS — diário de investigação (tecla L, aba ou toque).
-- Mostra SÓ o que o servidor mandou (o que o jogador descobriu): investigações descobertas, pistas encontradas,
-- objetivos visíveis, estado, registros, conhecimentos, receitas secretas, pesquisas e portais descobertos.
-- Capítulos futuros aparecem só como "ainda não disponível". Rolagem e botões grandes para o celular.
-- Também mostra a reação da criatura investigativa e o retorno dos enigmas (sem revelar a ordem).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local TextService = game:GetService("TextService")
local Workspace = game:GetService("Workspace")

local G = ReplicatedStorage:WaitForChild("Guardioes")
local Remotos = require(G.Rede.Remotos)
local Mensagens = require(G.Util.Mensagens)
local Materiais = require(G.Config.Materiais)

local MI = Remotos.Misterio
local EM = Remotos.EventoMisterio
local jogador = Players.LocalPlayer

local Atlas = { Nome = "AtlasDosArquivistas" }

local ctxSalvo: any = nil
local hud: any
local ev: RemoteEvent
local janela: Frame
local lista: ScrollingFrame
local aba: TextButton
local dados: any = nil
local y = 0

local ESTADO = {
	Discovered = "Descoberta", Investigating = "Investigando", ReadyToSolve = "Pronta para resolver", Completed = "Concluída",
}
local COR_ESTADO = {
	Discovered = Color3.fromRGB(170, 170, 200), Investigating = Color3.fromRGB(140, 190, 255),
	ReadyToSolve = Color3.fromRGB(255, 210, 120), Completed = Color3.fromRGB(140, 220, 150),
}

local function texto(t: string, tamanho: number, cor: Color3?, negrito: boolean?, recuo: number?)
	local fonte = if negrito then Enum.Font.GothamBold else Enum.Font.Gotham
	local r = recuo or 0
	local largura = math.max(200, lista.AbsoluteSize.X - 24) -- a largura real (celular ou computador)
	local altura = TextService:GetTextSize(t, tamanho, fonte, Vector2.new(largura - r, 10000)).Y
	local l = Instance.new("TextLabel")
	l.Position, l.Size = UDim2.fromOffset(6 + r, y), UDim2.new(1, -12 - r, 0, altura)
	l.BackgroundTransparency = 1
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextYAlignment = Enum.TextYAlignment.Top
	l.TextWrapped = true
	l.Font = fonte
	l.TextSize = tamanho
	l.TextColor3 = cor or Color3.new(1, 1, 1)
	l.Text = t
	l.Parent = lista
	y += altura + 4
end

local function botao(t: string, fn: () -> ())
	local b = Instance.new("TextButton")
	b.Position, b.Size = UDim2.fromOffset(12, y), UDim2.new(1, -24, 0, 34) -- alto o bastante para o toque
	b.BackgroundColor3 = Color3.fromRGB(70, 52, 120)
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 13
	b.Text = t
	b.Parent = lista
	b.Activated:Connect(fn)
	y += 40
end

local function nomeMat(id: string): string
	local m = Materiais.porId[id]
	return if m then m.nome else id
end

local function desenhar()
	for _, f in lista:GetChildren() do
		f:Destroy()
	end
	y = 0
	texto("Atlas dos Arquivistas", 18, Color3.fromRGB(230, 210, 255), true)
	if not dados or #dados.investigacoes == 0 then
		texto("Nenhuma investigação ainda. Observe o mundo com atenção: inscrições, símbolos, coisas fora do lugar…", 13, Color3.fromRGB(170, 170, 190))
	end
	for _, inv in (dados and dados.investigacoes) or {} do
		y += 6
		texto(inv.nome, 16, Color3.new(1, 1, 1), true)
		texto(ESTADO[inv.estado] or inv.estado, 12, COR_ESTADO[inv.estado], true)
		texto(inv.descricao, 12, Color3.fromRGB(190, 190, 210))
		if inv.capitulo then
			if inv.capitulo.disponivel then
				texto(string.format("Capítulo %d — %s", inv.capitulo.n, inv.capitulo.nome), 13, Color3.fromRGB(230, 220, 180), true)
			elseif inv.estado ~= "Completed" then
				texto(string.format("Capítulo %d — ainda não disponível. A história continua numa próxima atualização.", inv.capitulo.n), 12, Color3.fromRGB(150, 150, 170))
			end
		end
		if #inv.objetivos > 0 then
			texto("Objetivos", 13, Color3.fromRGB(255, 220, 140), true, 6)
			for _, o in inv.objetivos do
				texto((if o.feito then "✔ " else "○ ") .. o.nome, 12, if o.feito then Color3.fromRGB(150, 220, 160) else Color3.new(1, 1, 1), false, 12)
			end
		end
		if #inv.pistas > 0 then
			texto("Pistas", 13, Color3.fromRGB(255, 220, 140), true, 6)
			for _, pt in inv.pistas do
				texto("• " .. pt.nome, 12, Color3.fromRGB(220, 220, 240), true, 12)
				texto(pt.texto, 12, Color3.fromRGB(190, 190, 210), false, 20)
			end
		end
		if inv.capitulosFuturos > 0 then
			texto(string.format("%d capítulo(s) ainda por vir.", inv.capitulosFuturos), 11, Color3.fromRGB(130, 130, 150), false, 6)
		end
	end
	if dados and #dados.registros > 0 then
		y += 6
		texto("Registros", 16, Color3.fromRGB(230, 210, 255), true)
		for _, r in dados.registros do
			local rotulo = ({ RegistroAntigo = "Registro antigo", ConhecimentoProibido = "Conhecimento proibido", FragmentoDesconhecido = "Fragmento desconhecido" } :: any)[r.categoria]
			texto(r.titulo .. (if rotulo then "  · " .. rotulo else ""), 13, if r.categoria == "FragmentoDesconhecido" then Color3.fromRGB(200, 170, 255) else Color3.new(1, 1, 1), true, 6)
			texto(r.texto, 12, Color3.fromRGB(190, 190, 210), false, 12)
		end
	end
	if dados and #dados.conhecimentos > 0 then
		y += 6
		texto("Conhecimentos", 16, Color3.fromRGB(230, 210, 255), true)
		for _, c in dados.conhecimentos do
			texto(c.nome .. " — " .. c.texto, 12, Color3.fromRGB(200, 200, 220), false, 6)
		end
	end
	if dados and #dados.receitas > 0 then
		y += 6
		texto("Receitas reveladas", 16, Color3.fromRGB(230, 210, 255), true)
		for _, r in dados.receitas do
			local partes = {}
			for id, q in r.materiais or {} do
				table.insert(partes, string.format("%s ×%d", nomeMat(id), q))
			end
			texto(string.format("%s — %s (%s nv %d)", r.nome, table.concat(partes, ", "), tostring(r.estacao), r.estacaoNivel or 1), 12, Color3.new(1, 1, 1), false, 6)
			botao("Fabricar (perto da " .. tostring(r.estacao) .. ")", function()
				ev:FireServer(MI.FABRICAR_SECRETO, r.id)
			end)
		end
	end
	if dados and dados.pesquisas and #dados.pesquisas > 0 then
		y += 6
		texto("Pesquisas", 16, Color3.fromRGB(230, 210, 255), true)
		for _, ps in dados.pesquisas do
			texto(string.format("%s — etapa %d de %d", ps.nome, math.min(ps.etapa, ps.total), ps.total), 13, Color3.new(1, 1, 1), true, 6)
			for i, e in ps.etapas do
				texto(string.format("%d. %s%s", i, e.nome, if e.feita then " ✔" else ""), 12, if e.feita then Color3.fromRGB(150, 220, 160) else Color3.fromRGB(170, 170, 190), false, 12)
			end
		end
	end
	if dados and #dados.portais > 0 then
		y += 6
		texto("Passagens", 16, Color3.fromRGB(230, 210, 255), true)
		for _, pt in dados.portais do
			texto(string.format("%s — %s", pt.nome, if pt.estado == "aberto" then "aberta" elseif pt.estado == "selado" then "selada" else pt.estado), 12, Color3.new(1, 1, 1), false, 6)
		end
	end
	lista.CanvasSize = UDim2.fromOffset(0, y + 12)
end

local function alternar()
	janela.Visible = not janela.Visible
	aba.Text = if janela.Visible then "Fechar (L)" else "Atlas (L)"
	if janela.Visible then
		ev:FireServer(MI.VER_DIARIO)
		desenhar()
	end
end

-- marca luminosa local onde a criatura reagiu (só no cliente do dono; some sozinha)
local function brilho(pos: Vector3)
	local b = Instance.new("Part")
	b.Anchored, b.CanCollide, b.CanQuery, b.CanTouch = true, false, false, false
	b.Shape = Enum.PartType.Ball
	b.Size = Vector3.new(1.4, 1.4, 1.4)
	b.Material = Enum.Material.Neon
	b.Color = Color3.fromHex("#B89CFF")
	b.Transparency = 0.3
	b.Position = pos + Vector3.new(0, 3, 0)
	b.Parent = Workspace
	task.delay(4, function()
		b:Destroy()
	end)
end

function Atlas.Init(ctx: any)
	ctxSalvo = ctx
	ev = Remotos.evento("Misterio")
	local tela = Instance.new("ScreenGui")
	tela.Name = "GuardioesAtlas"
	tela.ResetOnSpawn = false
	tela.Parent = jogador:WaitForChild("PlayerGui")
	aba = Instance.new("TextButton")
	aba.Size, aba.Position = UDim2.fromOffset(120, 32), UDim2.new(0, 994, 0.5, -200)
	aba.BackgroundColor3 = Color3.fromRGB(56, 40, 92)
	aba.TextColor3 = Color3.new(1, 1, 1)
	aba.Font = Enum.Font.GothamBold
	aba.TextSize = 14
	aba.Text = "Atlas (L)"
	aba.Parent = tela
	aba.Activated:Connect(alternar)
	janela = Instance.new("Frame")
	-- celular: ocupa quase a tela toda (largura relativa com teto); computador: painel lateral
	janela.AnchorPoint = Vector2.new(0.5, 0.5)
	janela.Size, janela.Position = UDim2.new(0.92, 0, 0.8, 0), UDim2.fromScale(0.5, 0.5)
	local teto = Instance.new("UISizeConstraint")
	teto.MaxSize = Vector2.new(400, 520)
	teto.Parent = janela
	janela.BackgroundColor3 = Color3.fromRGB(18, 14, 30)
	janela.BackgroundTransparency = 0.06
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

function Atlas.Start()
	hud = ctxSalvo.obter("HudDeCombate")
	ev.OnClientEvent:Connect(function(tipo: number, a: any, b: any, c: any, d: any)
		if tipo == EM.DIARIO and typeof(a) == "table" then
			dados = a
			if janela.Visible then
				desenhar()
			end
		elseif tipo == EM.AVISO and typeof(a) == "string" then
			hud.aviso(a)
		elseif tipo == EM.DESCOBERTA and typeof(a) == "string" then
			hud.aviso("Anotado no Atlas: " .. a .. " (L)")
		elseif tipo == EM.ENIGMA then
			if typeof(d) == "string" and (b == "certo" or b == "semEfeito") then
				hud.aviso(d) -- texto curto do servidor ("o cristal agora aponta para…", "as torres estão sem energia…")
			elseif b == "certo" then
				hud.aviso("O marco responde com um zumbido baixo.")
			elseif b == "errado" then
				hud.aviso(if c == "gravacao" then Mensagens.texto("gravacao") or "" else "Os marcos se apagam.")
			elseif b == "completo" then
				hud.aviso("Conseguiu! O Atlas anotou o que aconteceu (L).")
			elseif b == "semEfeito" and c == "nadaAcontece" then
				hud.aviso("Nada acontece. Falta entender alguma coisa.")
			end
		elseif tipo == EM.REACAO and typeof(a) == "Vector3" then
			hud.aviso("Sua criatura reage a algo escondido aqui perto!")
			brilho(a)
		elseif tipo == EM.REJEITADO then
			if typeof(b) == "table" and #b > 0 then
				local partes = {}
				for _, f in b do
					if f.tipo == "material" then
						table.insert(partes, string.format("%s %d/%d", nomeMat(f.id), f.tem, f.precisa))
					elseif f.tipo == "estacao" then
						table.insert(partes, string.format("%s nível %d", tostring(f.id), f.precisa))
					end
				end
				hud.aviso("Falta: " .. table.concat(partes, " · "))
			else
				hud.aviso(Mensagens.texto(a))
			end
		end
	end)
	ContextActionService:BindAction("GuardioesAtlas", function(_n, s, _o)
		if s == Enum.UserInputState.Begin then
			alternar()
		end
		return Enum.ContextActionResult.Sink
	end, false, Enum.KeyCode.L)
end

return Atlas
