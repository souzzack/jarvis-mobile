--!strict
-- NÃO EXECUTADO NO STUDIO. FlightController + GliderController (cliente): entrada, física local e rede.
-- O cliente integra FisicaDeVoo com o perfil EFETIVO enviado pelo servidor e move o personagem com
-- LinearVelocity + AlignOrientation (resposta imediata). O servidor decide estado/energia e confere a posição.
--
-- Controles (contextuais: cada tecla só faz algo de voo quando faz sentido; senão passa adiante):
--   PC:      Espaço no ar = voar (ou planar se não souber voar) · Espaço 2× no chão = decolar
--            no voo: Espaço subir · Ctrl/C descer (perto do chão = pousar) · Shift impulso · X pousar
--            G abre/fecha o planador · a câmera inclinada para cima/baixo também sobe/desce ao avançar
--   Controle: A = Espaço · B (no voo) = descer · L3 = impulso · Y (no voo) = pousar
--   Celular: botões que aparecem só no estado certo (Voar/Planar no ar; Subir, Descer, Impulso, Pousar no voo)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local G = ReplicatedStorage:WaitForChild("Guardioes")
local Fisica = require(G.Locomocao.FisicaDeVoo)
local Perfis = require(G.Config.Locomocao.Perfis)
local Regras = require(G.Config.Locomocao.Regras)
local Remotos = require(G.Rede.Remotos)
local Sinal = require(G.Util.Sinal)
local Mensagens = require(G.Util.Mensagens)

local L = Remotos.Locomocao
local EL = Remotos.EventoLocomocao
local jogador = Players.LocalPlayer

local ControleDeLocomocao = { Nome = "ControleDeLocomocao" }
ControleDeLocomocao.mudouEstado = Sinal.novo() -- (estado, modo)

local NO_AR: { [string]: boolean } = { Decolagem = true, Pairar = true, Voo = true, Impulso = true, Descida = true, Pouso = true, Interrompido = true, Planando = true }
local VOANDO: { [string]: boolean } = { Pairar = true, Voo = true, Impulso = true }

local evento: RemoteEvent
local hud: any
local ctxSalvo: any = nil

local estado = "Solo"
local modo: string? = nil
local perfil: any = nil
local perfisRecebidos: { [string]: any } = {}
local habilidades: { [string]: boolean } = {}
local fis = Fisica.novo()
local subir, descer, impulsoSegurado = false, false, false
local ultimoEspaco = 0
local alturaAtual = 0

local at: Attachment? = nil
local lv: LinearVelocity? = nil
local ao: AlignOrientation? = nil

local raycast = RaycastParams.new()
raycast.FilterType = Enum.RaycastFilterType.Exclude

local function corpo(): (BasePart?, Humanoid?)
	local ch = jogador.Character
	if not ch then
		return nil, nil
	end
	return ch:FindFirstChild("HumanoidRootPart") :: BasePart?, ch:FindFirstChildOfClass("Humanoid")
end

local function medirAltura(hrp: BasePart, hum: Humanoid): number
	raycast.FilterDescendantsInstances = { jogador.Character :: Instance }
	local r = Workspace:Raycast(hrp.Position, Vector3.new(0, -300, 0), raycast)
	if not r then
		return 300
	end
	return math.max(0, hrp.Position.Y - r.Position.Y - (hum.HipHeight + hrp.Size.Y / 2))
end

-- ------------------------------------------------------------------ física local
local function ligarFisica(hrp: BasePart, hum: Humanoid)
	if lv then
		return
	end
	local a = Instance.new("Attachment")
	a.Name = "GuardioesVoo"
	a.Parent = hrp
	local v = Instance.new("LinearVelocity")
	v.Attachment0 = a
	v.MaxForce = math.huge
	v.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	v.RelativeTo = Enum.ActuatorRelativeTo.World
	v.VectorVelocity = hrp.AssemblyLinearVelocity
	v.Parent = hrp
	local o = Instance.new("AlignOrientation")
	o.Mode = Enum.OrientationAlignmentMode.OneAttachment
	o.Attachment0 = a
	o.MaxTorque = math.huge
	o.Responsiveness = 18
	o.CFrame = hrp.CFrame.Rotation
	o.Parent = hrp
	at, lv, ao = a, v, o
	hum.AutoRotate = false
	-- começa com a velocidade atual (sem tranco) e virado para onde o corpo olha
	local vel = hrp.AssemblyLinearVelocity
	local look = hrp.CFrame.LookVector
	fis = Fisica.novo(math.atan2(look.X, look.Z))
	fis.vx, fis.vy, fis.vz = vel.X, vel.Y, vel.Z
end

local function desligarFisica()
	if lv then
		(lv :: LinearVelocity):Destroy()
	end
	if ao then
		(ao :: AlignOrientation):Destroy()
	end
	if at then
		(at :: Attachment):Destroy()
	end
	at, lv, ao = nil, nil, nil
	local _, hum = corpo()
	if hum then
		hum.AutoRotate = true
	end
end

local function perfilVoo(): string?
	if habilidades["AsasNaturais"] then
		return "AsasNaturais"
	elseif habilidades["VooMagico"] then
		return "VooMagico"
	end
	return nil
end

local function mudar(novo: string, novoModo: string?)
	if novo ~= estado or novoModo ~= modo then
		estado, modo = novo, novoModo
		ControleDeLocomocao.mudouEstado.disparar(estado, modo)
	end
end

-- ------------------------------------------------------------------ intenções (com previsão)
local function tentarVoar(): boolean
	local id = perfilVoo()
	if not id then
		return false
	end
	evento:FireServer(L.DECOLAR, id)
	if estado == "Solo" or estado == "Planando" then
		perfil = perfisRecebidos[id] or Perfis.porId[id]
		mudar("Decolagem", id) -- previsão; o servidor confirma (ESTADO) ou recusa (REJEITADO)
	end
	return true
end

local function tentarPlanar(): boolean
	if not habilidades["Planador"] then
		return false
	end
	evento:FireServer(L.PLANADOR_ABRIR)
	return true
end

local function pousar()
	evento:FireServer(L.POUSAR)
end

-- ------------------------------------------------------------------ entrada
local function acaoEspaco(_n: string, s: Enum.UserInputState, _o: InputObject): Enum.ContextActionResult
	local _, hum = corpo()
	if s == Enum.UserInputState.End or s == Enum.UserInputState.Cancel then
		subir = false
		return Enum.ContextActionResult.Pass
	end
	if s ~= Enum.UserInputState.Begin or not hum then
		return Enum.ContextActionResult.Pass
	end
	if VOANDO[estado] or estado == "Decolagem" then
		subir = true
		return Enum.ContextActionResult.Sink
	end
	if estado == "Planando" then
		return if tentarVoar() then Enum.ContextActionResult.Sink else Enum.ContextActionResult.Pass
	end
	if estado == "Solo" then
		local agora = os.clock()
		if hum.FloorMaterial == Enum.Material.Air then
			if tentarVoar() or tentarPlanar() then
				return Enum.ContextActionResult.Sink
			end
		elseif agora - ultimoEspaco < 0.3 then
			tentarVoar()
		end
		ultimoEspaco = agora
	end
	return Enum.ContextActionResult.Pass -- deixa o pulo normal acontecer
end

local function acaoDescer(_n: string, s: Enum.UserInputState, _o: InputObject): Enum.ContextActionResult
	if not NO_AR[estado] then
		descer = false
		return Enum.ContextActionResult.Pass
	end
	descer = s == Enum.UserInputState.Begin
	return Enum.ContextActionResult.Sink
end

local function acaoImpulso(_n: string, s: Enum.UserInputState, _o: InputObject): Enum.ContextActionResult
	if not (VOANDO[estado] or impulsoSegurado) then
		return Enum.ContextActionResult.Pass -- no chão o Shift continua sendo a esquiva do combate
	end
	local ligar = s == Enum.UserInputState.Begin
	if ligar ~= impulsoSegurado then
		impulsoSegurado = ligar
		evento:FireServer(L.IMPULSO, ligar)
	end
	return Enum.ContextActionResult.Sink
end

local function acaoPousar(_n: string, s: Enum.UserInputState, _o: InputObject): Enum.ContextActionResult
	if s ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end
	if VOANDO[estado] then
		pousar()
		return Enum.ContextActionResult.Sink
	elseif estado == "Planando" then
		evento:FireServer(L.PLANADOR_FECHAR)
		return Enum.ContextActionResult.Sink
	end
	return Enum.ContextActionResult.Pass
end

local function acaoPlanador(_n: string, s: Enum.UserInputState, _o: InputObject): Enum.ContextActionResult
	if s ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end
	if estado == "Planando" then
		evento:FireServer(L.PLANADOR_FECHAR)
	elseif not tentarPlanar() then
		return Enum.ContextActionResult.Pass
	end
	return Enum.ContextActionResult.Sink
end

-- botões de toque CONTEXTUAIS: só os do estado atual existem na tela
local toqueAtivos: { [string]: boolean } = {}
local function botaoToque(nome: string, titulo: string, pos: UDim2, fn: (Enum.UserInputState) -> ())
	if toqueAtivos[nome] then
		return
	end
	toqueAtivos[nome] = true
	ContextActionService:BindAction(nome, function(_n, s, _o)
		fn(s)
		return Enum.ContextActionResult.Sink
	end, true)
	ContextActionService:SetTitle(nome, titulo)
	ContextActionService:SetPosition(nome, pos)
end
local function tirarToque(nome: string)
	if toqueAtivos[nome] then
		ContextActionService:UnbindAction(nome)
		toqueAtivos[nome] = nil
	end
end

local function atualizarToque()
	if not UserInputService.TouchEnabled then
		return
	end
	local _, hum = corpo()
	local noArAPe = estado == "Solo" and hum ~= nil and hum.FloorMaterial == Enum.Material.Air
	local voando = VOANDO[estado] == true
	if estado == "Solo" and perfilVoo() then
		botaoToque("GuardioesToqueVoar", "Voar", UDim2.new(1, -310, 1, -150), function(s)
			if s == Enum.UserInputState.Begin then
				tentarVoar()
			end
		end)
	else
		tirarToque("GuardioesToqueVoar")
	end
	if (noArAPe or estado == "Descida" or estado == "Interrompido") and habilidades["Planador"] then
		botaoToque("GuardioesToquePlanar", "Planar", UDim2.new(1, -310, 1, -230), function(s)
			if s == Enum.UserInputState.Begin then
				tentarPlanar()
			end
		end)
	elseif estado == "Planando" then
		botaoToque("GuardioesToquePlanar", "Fechar", UDim2.new(1, -310, 1, -230), function(s)
			if s == Enum.UserInputState.Begin then
				evento:FireServer(L.PLANADOR_FECHAR)
			end
		end)
	else
		tirarToque("GuardioesToquePlanar")
	end
	if voando then
		botaoToque("GuardioesToqueSubir", "Subir", UDim2.new(1, -150, 1, -230), function(s)
			subir = s == Enum.UserInputState.Begin
		end)
		botaoToque("GuardioesToqueDescer", "Descer", UDim2.new(1, -150, 1, -150), function(s)
			descer = s == Enum.UserInputState.Begin
		end)
		botaoToque("GuardioesToquePousar", "Pousar", UDim2.new(1, -310, 1, -150), function(s)
			if s == Enum.UserInputState.Begin then
				pousar()
			end
		end)
		if perfil and perfil.velImpulso > 0 then
			botaoToque("GuardioesToqueImpulso", "Impulso", UDim2.new(1, -230, 1, -120), function(s)
				local ligar = s == Enum.UserInputState.Begin
				if ligar ~= impulsoSegurado then
					impulsoSegurado = ligar
					evento:FireServer(L.IMPULSO, ligar)
				end
			end)
		end
	else
		for _, n in { "GuardioesToqueSubir", "GuardioesToqueDescer", "GuardioesToquePousar", "GuardioesToqueImpulso" } do
			tirarToque(n)
		end
	end
end

-- ------------------------------------------------------------------ passo por quadro
local function passo(dt: number)
	local hrp, hum = corpo()
	if not hrp or not hum then
		return
	end
	if not NO_AR[estado] then
		if lv then
			desligarFisica()
		end
		return
	end
	ligarFisica(hrp, hum)
	alturaAtual = medirAltura(hrp, hum)
	local cam = Workspace.CurrentCamera
	local md = hum.MoveDirection
	local vertical = (if subir then 1 else 0) - (if descer then 1 else 0)
	-- voar para onde a câmera aponta: avançando com a câmera inclinada, o corpo sobe/desce junto
	if vertical == 0 and md.Magnitude > 0.1 and cam then
		local lk = cam.CFrame.LookVector
		local plano = Vector3.new(lk.X, 0, lk.Z)
		if plano.Magnitude > 0.05 then
			local alinhado = md:Dot(plano.Unit)
			if alinhado > 0.5 then
				vertical = math.clamp(lk.Y * 1.6, -1, 1) * alinhado
			end
		end
	end

	if (estado == "Interrompido" or modo == "Queda" or not perfil) and estado ~= "Planando" then
		-- queda amortecida e segura (sem controle de voo); um pouco de controle horizontal
		local alvoVy = -Regras.interrupcao.velQuedaAmortecida
		fis.vy += (alvoVy - fis.vy) * math.min(1, dt * 4)
		fis.vx += (md.X * 10 - fis.vx) * math.min(1, dt * 2)
		fis.vz += (md.Z * 10 - fis.vz) * math.min(1, dt * 2)
	else
		local ent = { dx = md.X, dz = md.Z, vertical = vertical, impulso = impulsoSegurado }
		if estado == "Decolagem" then
			ent = { dx = 0, dz = 0, vertical = 1, impulso = false }
		elseif estado == "Descida" then
			ent = { dx = md.X * 0.6, dz = md.Z * 0.6, vertical = -1, impulso = false }
		elseif estado == "Pouso" then
			ent = { dx = 0, dz = 0, vertical = -0.5, impulso = false }
		elseif VOANDO[estado] and alturaAtual < 2 then
			if descer then
				pousar() -- descer rente ao chão = pousar
				descer = false
			elseif ent.vertical <= 0 then
				ent.vertical = 0.5 -- prancha/voo rente ao chão: não raspa
			end
		end
		-- pairando parado: o corpo vira para onde a câmera olha
		if estado == "Pairar" and cam and Fisica.velocidadeHorizontal(fis) < 2 then
			local lk = cam.CFrame.LookVector
			fis.rumo = math.atan2(lk.X, lk.Z)
		end
		Fisica.passo(fis, perfil, ent, dt, { alturaSobreSolo = alturaAtual, correnteAscendente = 0 })
	end
	if lv and ao then
		lv.VectorVelocity = Vector3.new(fis.vx, fis.vy, fis.vz)
		ao.CFrame = CFrame.Angles(0, fis.rumo + math.pi, 0) * CFrame.Angles(fis.arfagem, 0, 0) * CFrame.Angles(0, 0, fis.inclinacao)
	end
end

-- leitura para câmera/efeitos
function ControleDeLocomocao.estado(): (string, string?)
	return estado, modo
end
function ControleDeLocomocao.velocidade(): number
	return math.sqrt(fis.vx * fis.vx + fis.vy * fis.vy + fis.vz * fis.vz)
end
function ControleDeLocomocao.perfil(): any
	return perfil
end
function ControleDeLocomocao.impulso(): boolean
	return estado == "Impulso"
end

function ControleDeLocomocao.Init(ctx: any)
	ctxSalvo = ctx
	evento = Remotos.evento("Locomocao")
end

function ControleDeLocomocao.Start()
	hud = ctxSalvo.obter("HudDeCombate")
	local alta = Enum.ContextActionPriority.High.Value
	ContextActionService:BindActionAtPriority("GuardioesVooEspaco", acaoEspaco, false, alta, Enum.KeyCode.Space, Enum.KeyCode.ButtonA)
	ContextActionService:BindActionAtPriority("GuardioesVooDescer", acaoDescer, false, alta, Enum.KeyCode.LeftControl, Enum.KeyCode.C, Enum.KeyCode.ButtonB)
	ContextActionService:BindActionAtPriority("GuardioesVooImpulso", acaoImpulso, false, alta, Enum.KeyCode.LeftShift, Enum.KeyCode.ButtonL3)
	ContextActionService:BindActionAtPriority("GuardioesVooPousar", acaoPousar, false, alta, Enum.KeyCode.X, Enum.KeyCode.ButtonY)
	ContextActionService:BindActionAtPriority("GuardioesPlanador", acaoPlanador, false, alta, Enum.KeyCode.G)

	evento.OnClientEvent:Connect(function(tipo: number, a: any, b: any, c: any)
		if tipo == EL.ESTADO then
			mudar(a, b)
			if not NO_AR[a] then
				impulsoSegurado, subir, descer = false, false, false
			end
			if c and a == "Interrompido" then -- o motivo só é anunciado uma vez, na interrupção
				hud.aviso(Mensagens.texto(if c == "energia" then "energiaAcabou" else c))
			end
			atualizarToque()
		elseif tipo == EL.PERFIL then
			if typeof(a) == "table" and typeof(a.id) == "string" then
				perfil = a
				perfisRecebidos[a.id] = a
			end
		elseif tipo == EL.REJEITADO then
			if a == L.DECOLAR and estado == "Decolagem" then
				mudar("Solo", nil) -- desfaz a previsão
			end
			hud.aviso(Mensagens.texto(b))
		elseif tipo == EL.CORRECAO then
			fis.vx, fis.vy, fis.vz = 0, 0, 0
		elseif tipo == EL.HABILIDADES then
			habilidades = {}
			for _, id in a do
				habilidades[id] = true
			end
			atualizarToque()
		end
	end)

	jogador.CharacterAdded:Connect(function()
		desligarFisica()
		mudar("Solo", nil)
		impulsoSegurado, subir, descer = false, false, false
	end)

	RunService.RenderStepped:Connect(passo)
	-- botões contextuais de "no ar a pé" mudam sem evento do servidor: confere 4×/s
	task.spawn(function()
		while true do
			task.wait(0.25)
			atualizarToque()
		end
	end)
end

return ControleDeLocomocao
