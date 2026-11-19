--!strict
-- NÃO EXECUTADO NO STUDIO. Janela da Companhia (guilda de jogadores), tecla U ou aba.
-- Sem companhia: criar (nome + emblema de peças pré-aprovadas) e convites recebidos.
-- Com companhia: membros e cargos, cofre (depositar/retirar, livre/travado para o líder), registro,
-- transferência de liderança e dissolução. O cliente só PEDE; o servidor confere o cargo em tudo.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")

local G = ReplicatedStorage:WaitForChild("Guardioes")
local Remotos = require(G.Rede.Remotos)
local Mensagens = require(G.Util.Mensagens)
local Companhia = require(G.Companhias.Companhia)
local Materiais = require(G.Config.Materiais)

local CO = Remotos.Companhia
local EV = Remotos.EventoCompanhia
local EI = Remotos.EventoInventario
local jogador = Players.LocalPlayer

local JanelaDaCompanhia = { Nome = "JanelaDaCompanhia" }

local ctxSalvo: any = nil
local hud: any
local ev: RemoteEvent
local janela: Frame
local lista: ScrollingFrame
local aba: TextButton
local estado: any = nil
local convites: { any } = {}
local materiais: { any } = {}
local nomeDigitado = ""
local escolha = { forma = 1, cor = 1, simbolo = 1 }
local nomes: { [number]: string } = {}
local y = 0

local function nomeDe(uid: number): string
	if nomes[uid] then
		return nomes[uid]
	end
	nomes[uid] = "…"
	task.spawn(function()
		local ok, n = pcall(function()
			return Players:GetNameFromUserIdAsync(uid)
		end)
		nomes[uid] = if ok then n else tostring(uid)
	end)
	return nomes[uid]
end

local function texto(t: string, altura: number, negrito: boolean?)
	local l = Instance.new("TextLabel")
	l.Position, l.Size = UDim2.fromOffset(6, y), UDim2.new(1, -12, 0, altura)
	l.BackgroundTransparency = 1
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextWrapped = true
	l.Font = if negrito then Enum.Font.GothamBold else Enum.Font.Gotham
	l.TextSize = if negrito then 14 else 12
	l.TextColor3 = Color3.new(1, 1, 1)
	l.Text = t
	l.Parent = lista
	y += altura + 2
end

-- linha com rótulo à esquerda e botões à direita
local function linha(rotulo: string, botoes: { { texto: string, fn: () -> () } }, cor: Color3?)
	local c = Instance.new("Frame")
	c.Position, c.Size = UDim2.fromOffset(4, y), UDim2.new(1, -8, 0, 30)
	c.BackgroundColor3 = cor or Color3.fromRGB(32, 38, 60)
	c.BorderSizePixel = 0
	c.Parent = lista
	local l = Instance.new("TextLabel")
	l.Position, l.Size = UDim2.fromOffset(6, 0), UDim2.new(1, -12 - 70 * #botoes, 1, 0)
	l.BackgroundTransparency = 1
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextTruncate = Enum.TextTruncate.AtEnd
	l.Font = Enum.Font.Gotham
	l.TextSize = 12
	l.TextColor3 = Color3.new(1, 1, 1)
	l.Text = rotulo
	l.Parent = c
	for i, b in botoes do
		local bt = Instance.new("TextButton")
		bt.Position, bt.Size = UDim2.new(1, -70 * (#botoes - i + 1), 0, 3), UDim2.fromOffset(66, 24)
		bt.BackgroundColor3 = Color3.fromRGB(52, 60, 92)
		bt.TextColor3 = Color3.new(1, 1, 1)
		bt.Font = Enum.Font.GothamBold
		bt.TextSize = 11
		bt.Text = b.texto
		bt.Parent = c
		bt.Activated:Connect(b.fn)
	end
	y += 32
end

local desenhar: () -> ()

local function proximo(t: { string }, i: number): number
	return (i % #t) + 1
end

local function desenharSemCompanhia()
	texto("Você não está em uma companhia.", 18, true)
	for _, cv in convites do
		linha("Convite: " .. cv.nome .. " (de " .. cv.de .. ")", {
			{ texto = "Aceitar", fn = function()
				ev:FireServer(CO.ACEITAR, cv.id)
				table.clear(convites)
			end },
			{ texto = "Recusar", fn = function()
				ev:FireServer(CO.RECUSAR, cv.id)
				for i, x in convites do
					if x == cv then
						table.remove(convites, i)
						break
					end
				end
				desenhar()
			end },
		}, Color3.fromRGB(40, 70, 56))
	end
	texto("Criar companhia", 18, true)
	local caixa = Instance.new("TextBox")
	caixa.Position, caixa.Size = UDim2.fromOffset(6, y), UDim2.new(1, -12, 0, 28)
	caixa.BackgroundColor3 = Color3.fromRGB(26, 28, 38)
	caixa.TextColor3 = Color3.new(1, 1, 1)
	caixa.PlaceholderText = "Nome (3 a 20 letras)"
	caixa.Font = Enum.Font.Gotham
	caixa.TextSize = 13
	caixa.ClearTextOnFocus = false
	caixa.Text = nomeDigitado
	caixa.Parent = lista
	caixa:GetPropertyChangedSignal("Text"):Connect(function()
		nomeDigitado = caixa.Text
	end)
	y += 32
	local E = Companhia.EMBLEMA
	for _, campo in { "forma", "cor", "simbolo" } do
		local opcoes = (E :: any)[campo]
		linha(campo .. ": " .. opcoes[(escolha :: any)[campo]], { { texto = "Trocar", fn = function()
			(escolha :: any)[campo] = proximo(opcoes, (escolha :: any)[campo])
			desenhar()
		end } })
	end
	linha("", { { texto = "Criar", fn = function()
		ev:FireServer(CO.CRIAR, nomeDigitado, { forma = E.forma[escolha.forma], cor = E.cor[escolha.cor], simbolo = E.simbolo[escolha.simbolo] })
	end } })
end

local CARGOS = { "Recruta", "Membro", "Oficial" }

local function desenharComCompanhia(s: any)
	local meu = s.meuCargo
	local lider = meu == "Lider"
	local rk = Companhia.RANK[meu] or 0
	texto(string.format("%s  · %s %s %s", s.nome, s.emblema.forma, s.emblema.simbolo, s.emblema.cor), 20, true)
	local limite = if s.limiteDiario then string.format(" · retirado hoje %d/%d", s.retiradoHoje, s.limiteDiario) else ""
	texto(string.format("Nível %d (%d/%d XP) · seu cargo: %s%s", s.nivel, s.xp, s.xpProximo, meu, limite), 16)
	if s.transferencia then
		texto(string.format("Liderança passa para %s em %.0f h", nomeDe(s.transferencia.para), math.max(0, s.transferencia.ate - os.time()) / 3600), 16)
	end
	if s.dissolucao then
		local quando = if s.dissolucao.ate then string.format("Dissolução em %.0f h (os depósitos voltam a quem depositou)", math.max(0, s.dissolucao.ate - os.time()) / 3600) else "Dissolução pedida: confirme ou cancele"
		texto(quando, 16)
	end
	-- objetivos da semana (cooperativos: precisam de pelo menos 2 pessoas contribuindo)
	if s.semanal then
		local sem = s.semanal
		texto(string.format("Objetivos da semana (termina em %dd %dh)", sem.terminaEm // 86400, (sem.terminaEm % 86400) // 3600), 18, true)
		for _, o in sem.objetivos do
			local premio = {}
			for mat, q in o.recompensa do
				local m = Materiais.porId[mat]
				table.insert(premio, string.format("%s ×%d", if m then m.nome else mat, q))
			end
			local situacao = if o.concluido then "✔ concluído"
				else string.format("%d/%d · você: %d · %d pessoa(s)", o.feito, o.alvo, o.minha, o.pessoas)
			texto(string.format("%s — %s", o.nome, situacao), 14)
			texto(string.format("   Prêmio: +%d XP da companhia; para quem ajudou: %s", o.xp, table.concat(premio, ", ")), 28)
		end
		texto(string.format("Precisa de pelo menos %d pessoas ajudando. O progresso aparece em até 30 s.", sem.minContribuintes), 28)
	end
	-- membros
	texto("Membros", 18, true)
	for _, m in s.membros do
		local botoes = {}
		local outro = m.uid ~= jogador.UserId
		if lider and outro then
			local i = table.find(CARGOS, m.cargo) or 1
			table.insert(botoes, { texto = "Cargo", fn = function()
				ev:FireServer(CO.CARGO, m.uid, CARGOS[proximo(CARGOS, i)])
			end })
			table.insert(botoes, { texto = "Líder", fn = function()
				ev:FireServer(CO.TRANSFERIR, m.uid)
			end })
		end
		if outro and (meu == "Lider" or meu == "Oficial") and (Companhia.RANK[m.cargo] or 9) < rk then
			table.insert(botoes, { texto = "Expulsar", fn = function()
				ev:FireServer(CO.EXPULSAR, m.uid)
			end })
		end
		linha(nomeDe(m.uid) .. " · " .. m.cargo, botoes)
	end
	-- cofre
	texto("Cofre", 18, true)
	if #s.cofre == 0 then
		texto("Vazio", 14)
	end
	for _, item in s.cofre do
		local botoes = {}
		if meu ~= "Recruta" then
			table.insert(botoes, { texto = "Retirar 1", fn = function()
				ev:FireServer(CO.RETIRAR, item.id, 1)
			end })
			table.insert(botoes, { texto = "Retirar 10", fn = function()
				ev:FireServer(CO.RETIRAR, item.id, 10)
			end })
		end
		if lider then
			local prox = if item.livre == item.qtd then "travado" elseif item.travado == item.qtd then "normal" else "livre"
			table.insert(botoes, { texto = "→ " .. prox, fn = function()
				ev:FireServer(CO.MARCAR, item.id, prox)
			end })
		end
		local marca = if item.travado > 0 then " 🔒" .. item.travado elseif item.livre > 0 then " livre " .. item.livre else ""
		linha(string.format("%s ×%d%s", item.nome, item.qtd, marca), botoes)
	end
	texto("Depositar (materiais de teste não entram no cofre)", 16, true)
	for _, m in materiais do
		linha(string.format("%s ×%d", m.nome, m.qtd), {
			{ texto = "Dep. 1", fn = function()
				ev:FireServer(CO.DEPOSITAR, m.id, 1)
			end },
			{ texto = "Dep. 10", fn = function()
				ev:FireServer(CO.DEPOSITAR, m.id, math.min(10, m.qtd))
			end },
		})
	end
	-- registro
	texto("Registro", 18, true)
	for _, r in s.log do
		texto(string.format("%s · %s %s", if r.quem == 0 then "sistema" else nomeDe(r.quem), r.acao, r.detalhe or ""), 14)
	end
	-- ações finais
	local finais = {}
	if lider then
		if s.transferencia then
			table.insert(finais, { texto = "Cancelar T.", fn = function()
				ev:FireServer(CO.CANCELAR_TRANSFERENCIA)
			end })
		end
		if s.dissolucao and s.dissolucao.ate then
			table.insert(finais, { texto = "Cancelar D.", fn = function()
				ev:FireServer(CO.CANCELAR_DISSOLUCAO)
			end })
		else
			table.insert(finais, { texto = if s.dissolucao then "Confirmar" else "Dissolver", fn = function()
				ev:FireServer(CO.DISSOLVER)
			end })
		end
	else
		table.insert(finais, { texto = "Sair", fn = function()
			ev:FireServer(CO.SAIR)
		end })
	end
	linha("", finais, Color3.fromRGB(70, 36, 40))
end

desenhar = function()
	for _, f in lista:GetChildren() do
		f:Destroy()
	end
	y = 0
	if estado then
		desenharComCompanhia(estado)
	else
		desenharSemCompanhia()
	end
	lista.CanvasSize = UDim2.fromOffset(0, y + 8)
end

local function alternar()
	janela.Visible = not janela.Visible
	aba.Text = if janela.Visible then "Fechar (U)" else "Companhia (U)"
	if janela.Visible then
		ev:FireServer(CO.VER)
		desenhar()
	end
end

function JanelaDaCompanhia.Init(ctx: any)
	ctxSalvo = ctx
	ev = Remotos.evento("Companhia")
	local tela = Instance.new("ScreenGui")
	tela.Name = "GuardioesCompanhia"
	tela.ResetOnSpawn = false
	tela.Parent = jogador:WaitForChild("PlayerGui")
	aba = Instance.new("TextButton")
	aba.Size, aba.Position = UDim2.fromOffset(140, 32), UDim2.new(0, 702, 0.5, -200)
	aba.BackgroundColor3 = Color3.fromRGB(38, 46, 74)
	aba.TextColor3 = Color3.new(1, 1, 1)
	aba.Font = Enum.Font.GothamBold
	aba.TextSize = 14
	aba.Text = "Companhia (U)"
	aba.Parent = tela
	aba.Activated:Connect(alternar)
	janela = Instance.new("Frame")
	janela.Size, janela.Position = UDim2.fromOffset(400, 440), UDim2.new(0, 702, 0.5, -160)
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

function JanelaDaCompanhia.Start()
	hud = ctxSalvo.obter("HudDeCombate")
	ev.OnClientEvent:Connect(function(tipo: number, a: any, b: any, c: any, d: any)
		if tipo == EV.ESTADO then
			estado = if typeof(a) == "table" then a else nil
		elseif tipo == EV.CONVITE and typeof(a) == "string" then
			table.insert(convites, { id = a, nome = tostring(b), emblema = c, de = tostring(d) })
			hud.aviso("Convite para a companhia " .. tostring(b) .. " (U)")
		elseif tipo == EV.REJEITADO then
			hud.aviso(Mensagens.texto(a))
		elseif tipo == EV.AVISO and typeof(a) == "string" then
			hud.aviso(a)
		end
		if janela.Visible then
			desenhar()
		end
	end)
	-- materiais da bolsa (para depositar): o mesmo evento que o HudDeProgresso escuta
	Remotos.evento("Inventario").OnClientEvent:Connect(function(tipo: number, a: any)
		if tipo == EI.MATERIAIS and typeof(a) == "table" then
			materiais = a
			if janela.Visible and estado then
				desenhar()
			end
		end
	end)
	ContextActionService:BindAction("GuardioesCompanhia", function(_n, s, _o)
		if s == Enum.UserInputState.Begin then
			alternar()
		end
		return Enum.ContextActionResult.Sink
	end, false, Enum.KeyCode.U)
end

return JanelaDaCompanhia
