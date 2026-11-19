--!strict
-- NÃO EXECUTADO NO STUDIO. ArtifactTransformationController (cliente).
--  * Entrada: E (PC) · X (controle) · botão "Forma" (toque, só aparece com artefato que tem forma de locomoção).
--    Alterna entre a forma de arma e a de locomoção; o servidor valida tudo (posse, estágio, energia, espaço).
--  * Visual PROVISÓRIO para TODOS os jogadores, lido dos atributos ArtefatoId/ArtefatoForma/ArtefatoAlvo:
--    peças simples (Parts) que encolhem/giram e se remontam na outra forma no tempo da transformação.
--    Os modelos definitivos (espada que se abre em prancha etc.) vêm do Blender (docs/09, plano de animação).
--    As peças são só visuais: sem colisão, sem massa, sem consulta de acerto.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local G = ReplicatedStorage:WaitForChild("Guardioes")
local Remotos = require(G.Rede.Remotos)
local Mensagens = require(G.Util.Mensagens)

local A = Remotos.Artefato
local EA = Remotos.EventoArtefato

local TransformacaoDeArtefato = { Nome = "TransformacaoDeArtefato" }

local evento: RemoteEvent
local hud: any
local ctxSalvo: any = nil
local inventario: { any } = {}

-- aparência provisória por forma: tamanho, cor, onde prende ("Mao" = mão direita, "Pes" = sob os pés, "Braco")
local VISUAL: { [string]: { tamanho: Vector3, cor: Color3, onde: string } } = {
	Espada = { tamanho = Vector3.new(0.35, 0.2, 4.2), cor = Color3.fromHex("#9FE8FF"), onde = "Mao" },
	Prancha = { tamanho = Vector3.new(2.4, 0.3, 6.2), cor = Color3.fromHex("#5FD0FF"), onde = "Pes" },
	Escudo = { tamanho = Vector3.new(2.6, 2.6, 0.3), cor = Color3.fromHex("#6FBF5A"), onde = "Braco" },
	Plataforma = { tamanho = Vector3.new(5, 0.35, 5), cor = Color3.fromHex("#8EE07A"), onde = "Pes" },
	Cajado = { tamanho = Vector3.new(0.3, 0.3, 5.5), cor = Color3.fromHex("#CFF7F0"), onde = "Mao" },
	Vassoura = { tamanho = Vector3.new(0.4, 0.4, 6), cor = Color3.fromHex("#CFF7F0"), onde = "Pes" },
	Arco = { tamanho = Vector3.new(0.25, 4, 0.25), cor = Color3.fromHex("#FFE9A8"), onde = "Mao" },
	Asas = { tamanho = Vector3.new(7, 2.2, 0.2), cor = Color3.fromHex("#FFF6D8"), onde = "Costas" },
}

local function pecaDe(ch: Model): BasePart?
	return ch:FindFirstChild("GuardioesArtefatoVisual") :: BasePart?
end

local function prender(ch: Model, p: BasePart, onde: string): boolean
	local hrp = ch:FindFirstChild("HumanoidRootPart") :: BasePart?
	local mao = (ch:FindFirstChild("RightHand") or ch:FindFirstChild("Right Arm")) :: BasePart?
	local braco = (ch:FindFirstChild("LeftLowerArm") or ch:FindFirstChild("Left Arm")) :: BasePart?
	local base: BasePart?, desloc: CFrame
	if onde == "Mao" then
		base, desloc = mao, CFrame.new(0, -0.3, -1.8)
	elseif onde == "Braco" then
		base, desloc = braco, CFrame.new(-0.4, 0, 0) * CFrame.Angles(0, math.rad(90), 0)
	elseif onde == "Costas" then
		base, desloc = hrp, CFrame.new(0, 0.8, 0.9)
	else -- Pés
		base, desloc = hrp, CFrame.new(0, -3.2, 0)
	end
	if not base then
		return false
	end
	p.CFrame = (base :: BasePart).CFrame * desloc
	local w = Instance.new("WeldConstraint")
	w.Part0, w.Part1 = base, p
	w.Parent = p
	return true
end

local function mostrarForma(ch: Model, forma: string?, animar: boolean)
	local antiga = pecaDe(ch)
	if antiga then
		if animar then
			antiga.Name = "GuardioesArtefatoSaindo"
			TweenService:Create(antiga, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), { Size = antiga.Size * 0.2, Transparency = 1 }):Play()
			task.delay(0.3, function()
				antiga:Destroy()
			end)
		else
			antiga:Destroy()
		end
	end
	local v = forma and VISUAL[forma]
	if not v then
		return
	end
	local p = Instance.new("Part")
	p.Name = "GuardioesArtefatoVisual"
	p.Material = Enum.Material.Neon
	p.Color = v.cor
	p.CanCollide, p.CanQuery, p.CanTouch, p.Massless, p.CastShadow = false, false, false, true, false
	p.Size = if animar then v.tamanho * 0.2 else v.tamanho
	p.Transparency = if animar then 1 else 0.15
	if not prender(ch, p, v.onde) then
		p:Destroy()
		return
	end
	p.Parent = ch
	if animar then
		TweenService:Create(p, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = v.tamanho, Transparency = 0.15 }):Play()
	end
end

-- "carregando" a transformação: a peça atual gira e pulsa até a nova forma chegar
local function mostrarTransformando(ch: Model)
	local p = pecaDe(ch)
	if p then
		TweenService:Create(p, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Transparency = 0.6 }):Play()
	end
end

local function observar(ch: Model)
	local function aplicar(animar: boolean)
		if ch:GetAttribute("ArtefatoAlvo") then
			mostrarTransformando(ch)
		else
			mostrarForma(ch, ch:GetAttribute("ArtefatoForma") :: string?, animar)
		end
	end
	ch:GetAttributeChangedSignal("ArtefatoForma"):Connect(function()
		aplicar(true)
	end)
	ch:GetAttributeChangedSignal("ArtefatoAlvo"):Connect(function()
		aplicar(true)
	end)
	task.defer(aplicar, false)
end

-- ------------------------------------------------------------------ entrada
local function equipado(): any?
	for _, a in inventario do
		if a.equipado then
			return a
		end
	end
	return inventario[1]
end

local function formaDoTipo(a: any, tipo: string): string?
	for _, f in a.formas do
		if f.tipo == tipo and f.liberada then
			return f.nome
		end
	end
	return nil
end

local function alternar()
	local a = equipado()
	if not a then
		return
	end
	local atual
	for _, f in a.formas do
		if f.nome == a.forma then
			atual = f
		end
	end
	local destino: string?
	if atual and atual.tipo == "Locomocao" then
		destino = formaDoTipo(a, "Combate") or formaDoTipo(a, "Defesa")
		-- (pedir a mesma forma de locomoção estando no chão = decolar de novo; ver servidor)
	else
		destino = formaDoTipo(a, "Locomocao")
		if not destino then
			hud.aviso(Mensagens.texto("bloqueada"))
			return
		end
	end
	if destino then
		evento:FireServer(A.TRANSFORMAR, a.guid, destino)
	end
end

local function atualizarToque()
	if not UserInputService.TouchEnabled then
		return
	end
	local a = equipado()
	if a and formaDoTipo(a, "Locomocao") then
		ContextActionService:BindAction("GuardioesToqueForma", function(_n, s, _o)
			if s == Enum.UserInputState.Begin then
				alternar()
			end
			return Enum.ContextActionResult.Sink
		end, true)
		ContextActionService:SetTitle("GuardioesToqueForma", "Forma")
		ContextActionService:SetPosition("GuardioesToqueForma", UDim2.new(1, -390, 1, -150))
	else
		ContextActionService:UnbindAction("GuardioesToqueForma")
	end
end

function TransformacaoDeArtefato.Init(ctx: any)
	ctxSalvo = ctx
	evento = Remotos.evento("Artefato")
end

function TransformacaoDeArtefato.Start()
	hud = ctxSalvo.obter("HudDeCombate")
	ContextActionService:BindAction("GuardioesForma", function(_n, s, _o)
		if s == Enum.UserInputState.Begin then
			alternar()
		end
		return Enum.ContextActionResult.Sink
	end, false, Enum.KeyCode.E, Enum.KeyCode.ButtonX)

	evento.OnClientEvent:Connect(function(tipo: number, a: any, b: any)
		if tipo == EA.INVENTARIO then
			inventario = if typeof(a) == "table" then a else {}
			atualizarToque()
		elseif tipo == EA.FORMA then
			for _, item in inventario do
				if item.guid == a then
					item.forma = b
					item.equipado = true
				else
					item.equipado = false
				end
			end
		elseif tipo == EA.REJEITADO then
			hud.aviso(Mensagens.texto(b))
		end
	end)

	local function aoJogador(p: Player)
		if p.Character then
			observar(p.Character)
		end
		p.CharacterAdded:Connect(observar)
	end
	for _, p in Players:GetPlayers() do
		aoJogador(p)
	end
	Players.PlayerAdded:Connect(aoJogador)
end

return TransformacaoDeArtefato
