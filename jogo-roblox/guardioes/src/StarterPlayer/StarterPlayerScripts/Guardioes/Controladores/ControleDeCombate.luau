--!strict
-- NÃO EXECUTADO NO STUDIO. Entrada de combate (PC, controle e toque) e previsão local.
-- O cliente roda uma CÓPIA da máquina de combo só para responder na hora (animação, efeito do arco);
-- quem decide é o servidor. Quando o servidor rejeita, a cópia volta ao estado oficial.
--
-- Mapeamento (GDD 5.1; no protótipo o pesado tem botão próprio, para o ataque leve não esperar o "segurar"):
--   Atacar: botão esquerdo do mouse · R2 · botão de toque   | Pesado: R · Y · botão de toque
--   Defender (segurar): botão direito · F · L2 · toque      | Esquivar: Q · Shift esquerdo · B · toque

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local G = ReplicatedStorage:WaitForChild("Guardioes")
local Cfg = require(G.Config.Combate)
local Espada = require(G.Config.Armas.Espada)
local MaquinaDeCombo = require(G.Combate.MaquinaDeCombo)
local Remotos = require(G.Rede.Remotos)
local Mensagens = require(G.Util.Mensagens)

local C = Remotos.Combate
local E = Remotos.EventoCombate
local jogador = Players.LocalPlayer

local ControleDeCombate = { Nome = "ControleDeCombate" }

local evento: RemoteEvent
local hud: any
local ctxSalvo: any = nil
local maquina = MaquinaDeCombo.nova(os.clock())
local arma = Espada
local alvoAtual: Model? = nil

-- IDs de animação: preencher só com assets enviados e conferidos no Studio (nunca inventar IDs)
local Animacoes: { [string]: string } = {}
local avisouAnimacoes = false
local function tocarAnimacao(nome: string)
	local id = Animacoes[nome]
	if not id then
		if not avisouAnimacoes then
			avisouAnimacoes = true
			warn("[Guardioes] animações de combate ainda sem IDs; usando só o efeito do arco")
		end
		return
	end
	-- (Etapa J) carregar no Animator do personagem e tocar
end

local function raiz(): BasePart?
	local ch = jogador.Character
	return if ch then ch:FindFirstChild("HumanoidRootPart") :: BasePart? else nil
end

-- efeito provisório: mostra o arco do golpe na frente do personagem (só no cliente)
local function mostrarArco(g: any)
	local r = raiz()
	if not r then
		return
	end
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.Material = Enum.Material.Neon
	p.Color = Color3.fromHex("#9FE8FF")
	p.Transparency = 0.6
	p.Size = Vector3.new(g.alcance * 1.4, 0.15, g.alcance * 0.5)
	p.CFrame = r.CFrame * CFrame.new(0, 0.5, -g.alcance * 0.5)
	p.Parent = Workspace
	task.delay(0.12, function()
		p:Destroy()
	end)
end

-- mira suave: inimigo mais perto do centro da tela, a até 'alcanceMax' studs
local function escolherAlvo(): Model?
	local cam = Workspace.CurrentCamera
	local r = raiz()
	local pasta = Workspace:FindFirstChild("GuardioesInimigos")
	if not cam or not r or not pasta then
		return nil
	end
	local vp = cam.ViewportSize
	local melhor: Model? = nil
	local nota = math.huge
	for _, m in pasta:GetChildren() do
		if m:IsA("Model") and m.PrimaryPart and m:GetAttribute("Estado") ~= "Morto" then
			local pos = (m.PrimaryPart :: BasePart).Position
			local d = (pos - r.Position).Magnitude
			if d <= Cfg.mira.alcanceMax then
				local tela, visivel = cam:WorldToViewportPoint(pos)
				if visivel then
					local centro = (Vector2.new(tela.X, tela.Y) - vp / 2).Magnitude
					local n = centro + d * 4
					if n < nota then
						melhor, nota = m, n
					end
				end
			end
		end
	end
	return melhor
end

local function idDoAlvo(): string?
	return if alvoAtual then alvoAtual:GetAttribute("GuardioesId") :: string? else nil
end

local function atacar(pesado: boolean)
	local agora = os.clock()
	MaquinaDeCombo.atualizar(maquina, arma, Cfg, agora)
	local ok = MaquinaDeCombo.pedirAtaque(maquina, arma, Cfg, agora, pesado)
	if ok then
		evento:FireServer(if pesado then C.PESADO else C.ATACAR, idDoAlvo())
	end
end

local function esquivar()
	local r = raiz()
	local ch = jogador.Character
	local hum = ch and ch:FindFirstChildOfClass("Humanoid")
	if not r or not hum then
		return
	end
	local agora = os.clock()
	MaquinaDeCombo.atualizar(maquina, arma, Cfg, agora)
	if not MaquinaDeCombo.pedirEsquiva(maquina, Cfg, agora) then
		return
	end
	local dir = hum.MoveDirection
	if dir.Magnitude < 0.1 then
		dir = -r.CFrame.LookVector -- parado: esquiva para trás
	end
	dir = Vector3.new(dir.X, 0, dir.Z).Unit
	evento:FireServer(C.ESQUIVAR, dir.X, dir.Z)
	-- impulso local (o cliente é dono da física do próprio personagem)
	local at = Instance.new("Attachment")
	at.Parent = r
	local lv = Instance.new("LinearVelocity")
	lv.Attachment0 = at
	lv.MaxForce = 1e5
	lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
	lv.PrimaryTangentAxis = Vector3.xAxis
	lv.SecondaryTangentAxis = Vector3.zAxis
	lv.PlaneVelocity = Vector2.new(dir.X, dir.Z) * (Cfg.esquiva.distancia / Cfg.esquiva.duracao)
	lv.RelativeTo = Enum.ActuatorRelativeTo.World
	lv.Parent = r
	task.delay(Cfg.esquiva.duracao * 0.8, function()
		lv:Destroy()
		at:Destroy()
	end)
	tocarAnimacao("Esquiva")
end

local function defender(comecar: boolean)
	local agora = os.clock()
	MaquinaDeCombo.atualizar(maquina, arma, Cfg, agora)
	if comecar then
		if MaquinaDeCombo.iniciarDefesa(maquina, agora) then
			evento:FireServer(C.DEFESA_INICIO)
			tocarAnimacao("Defesa")
		end
	else
		MaquinaDeCombo.soltarDefesa(maquina, agora)
		evento:FireServer(C.DEFESA_FIM)
	end
end

local function acao(fn: (Enum.UserInputState) -> ())
	return function(_nome: string, estado: Enum.UserInputState, _obj: InputObject)
		fn(estado)
		return Enum.ContextActionResult.Sink
	end
end

function ControleDeCombate.Init(ctx: any)
	ctxSalvo = ctx
	evento = Remotos.evento("Combate")
end

function ControleDeCombate.Start()
	hud = ctxSalvo.obter("HudDeCombate")
	ContextActionService:BindAction("GuardioesAtacar", acao(function(s)
		if s == Enum.UserInputState.Begin then
			atacar(false)
		end
	end), true, Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonR2)
	ContextActionService:BindAction("GuardioesPesado", acao(function(s)
		if s == Enum.UserInputState.Begin then
			atacar(true)
		end
	end), true, Enum.KeyCode.R, Enum.KeyCode.ButtonY)
	ContextActionService:BindAction("GuardioesDefender", acao(function(s)
		if s == Enum.UserInputState.Begin then
			defender(true)
		elseif s == Enum.UserInputState.End or s == Enum.UserInputState.Cancel then
			defender(false)
		end
	end), true, Enum.UserInputType.MouseButton2, Enum.KeyCode.F, Enum.KeyCode.ButtonL2)
	ContextActionService:BindAction("GuardioesEsquivar", acao(function(s)
		if s == Enum.UserInputState.Begin then
			esquivar()
		end
	end), true, Enum.KeyCode.Q, Enum.KeyCode.LeftShift, Enum.KeyCode.ButtonB)
	for nome, titulo in { GuardioesAtacar = "Atacar", GuardioesPesado = "Pesado", GuardioesDefender = "Defesa", GuardioesEsquivar = "Esquiva" } do
		ContextActionService:SetTitle(nome, titulo)
	end
	ContextActionService:SetPosition("GuardioesAtacar", UDim2.new(1, -150, 1, -150))
	ContextActionService:SetPosition("GuardioesPesado", UDim2.new(1, -230, 1, -120))
	ContextActionService:SetPosition("GuardioesDefender", UDim2.new(1, -150, 1, -230))
	ContextActionService:SetPosition("GuardioesEsquivar", UDim2.new(1, -230, 1, -200))
	-- no voo os botões de combate somem (menos botões na tela; o servidor recusaria de qualquer jeito)
	local loco = ctxSalvo.obter("ControleDeLocomocao")
	loco.mudouEstado.conectar(function(estado: string)
		local mostrar = estado == "Solo"
		for _, nome in { "GuardioesAtacar", "GuardioesPesado", "GuardioesDefender", "GuardioesEsquivar" } do
			local botao = ContextActionService:GetButton(nome)
			if botao then
				botao.Visible = mostrar
			end
		end
	end)

	evento.OnClientEvent:Connect(function(tipo: number, a: any, b: any, c: any)
		if tipo == E.REJEITADO then
			-- servidor discordou: volta ao estado neutro (o ESTADO oficial chega logo em seguida)
			maquina = MaquinaDeCombo.nova(os.clock())
			hud.aviso(Mensagens.texto(b))
		elseif tipo == E.ESTADO then
			if a == "Ocioso" and maquina.estado ~= "Ocioso" and maquina.estado ~= "Defesa" then
				maquina.estado = "Ocioso"
				maquina.golpe = 0
			elseif a == "Atordoado" then
				MaquinaDeCombo.atordoar(maquina, Cfg.defesa.atordoamentoQuebra, os.clock())
				hud.aviso("Guarda quebrada!")
			end
		elseif tipo == E.ESTAMINA then
			hud.estamina(a, b)
		elseif tipo == E.RESULTADO_GOLPE then
			hud.numeroDeDano(a, b, c)
		elseif tipo == E.RECEBEU_GOLPE then
			hud.recebeu(a, b)
		elseif tipo == E.ARMA then
			if typeof(a) == "table" and typeof(a.combo) == "table" and a.pesado then
				arma = a
				maquina = MaquinaDeCombo.nova(os.clock())
			end
		elseif tipo == E.TELEGRAFIA then
			hud.telegrafia(a, b, c)
		end
	end)

	local ultimaMira = 0
	RunService.RenderStepped:Connect(function()
		local agora = os.clock()
		for _, ev in MaquinaDeCombo.atualizar(maquina, arma, Cfg, agora) do
			if ev.tipo == "Golpe" then
				local g = MaquinaDeCombo.golpeDe(arma, ev.golpe)
				mostrarArco(g)
				tocarAnimacao(g.animacao)
			end
		end
		if agora - ultimaMira > 0.2 then
			ultimaMira = agora
			alvoAtual = escolherAlvo()
			hud.marcarAlvo(alvoAtual)
		end
	end)
end

return ControleDeCombate
