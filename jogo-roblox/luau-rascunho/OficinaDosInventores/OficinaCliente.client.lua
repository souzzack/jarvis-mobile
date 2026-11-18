--!strict
-- RASCUNHO, NÃO TESTADO NO STUDIO (o Studio não estava acessível quando isto foi escrito).
-- Lugar sugerido: StarterPlayer.StarterPlayerScripts.Magnata.OficinaCliente (LocalScript).
-- Só visual e só no cliente: animações do Condensador e do laboratório, nível de detalhe do interior,
-- intensidade da luz interna pela distância e faíscas (Beam) quando a tempestade está ativa.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage:WaitForChild("Magnata"):WaitForChild("Oficina"):WaitForChild("OficinaConfig"))

local function acharModelo(): Model?
	local atual: Instance = workspace
	for _, nome in Config.CAMINHO do
		local filho = atual:WaitForChild(nome, 30)
		if not filho then
			return nil
		end
		atual = filho
	end
	return if atual:IsA("Model") then atual else nil
end

local modelo = acharModelo()
if not modelo then
	warn("[Oficina] modelo não encontrado no cliente")
	return
end
while not modelo:GetAttribute("OficinaPreparada") do
	modelo:GetAttributeChangedSignal("OficinaPreparada"):Wait()
end

local camera = workspace.CurrentCamera
local pivo = modelo:GetPivot()
local interior = modelo:FindFirstChild(Config.INTERIOR_NOME, true)
local ancora = modelo:FindFirstChild("PontosDeEfeito") :: BasePart?
local luz: PointLight? = nil
if ancora then
	local aLuz = ancora:FindFirstChild("LuzInterna")
	if aLuz then
		luz = aLuz:FindFirstChildOfClass("PointLight")
	end
end

-- grupos animados: guarda o pivô inicial de cada um
type Animado = { cfg: Config.Animacao, alvo: PVInstance, cf0: CFrame, ang: number }
local animados: { Animado } = {}
for _, cfg in Config.ANIMACOES do
	local alvo = modelo:FindFirstChild(cfg.nome, true)
	if alvo and alvo:IsA("PVInstance") then
		table.insert(animados, { cfg = cfg, alvo = alvo, cf0 = alvo:GetPivot(), ang = 0 })
	else
		warn(`[Oficina] grupo animado "{cfg.nome}" não encontrado (o importador pode ter renomeado o nó)`)
	end
end

-- peças do interior (para esconder de longe sem destruir)
local pecasInterior: { BasePart } = {}
if interior then
	for _, d in interior:GetDescendants() do
		if d:IsA("BasePart") then
			table.insert(pecasInterior, d)
		end
	end
end
local interiorVisivel = true
local function mostrarInterior(v: boolean)
	if v == interiorVisivel then
		return
	end
	interiorVisivel = v
	for _, p in pecasInterior do
		p.LocalTransparencyModifier = if v then 0 else 1
	end
end

-- faíscas: um Beam reaproveitado, ligado a pares de Attachments sorteados
local beam: Beam? = nil
if ancora then
	local b = Instance.new("Beam")
	b.Color = ColorSequence.new(Color3.fromRGB(190, 235, 255))
	b.LightEmission = 1
	b.Width0, b.Width1 = 0.12, 0.05
	b.Segments = 8
	b.CurveSize0, b.CurveSize1 = 0.6, -0.6
	b.FaceCamera = true
	b.Enabled = false
	b.Parent = ancora
	beam = b
end
local pares: { { Attachment } } = {}
if ancora then
	local function a(n: string): Attachment?
		return ancora:FindFirstChild(n) :: Attachment?
	end
	local fa, fb, cf = a("FaiscadorA"), a("FaiscadorB"), a("CondutorFim")
	if fa and cf then table.insert(pares, { fa, cf }) end
	if fb and cf then table.insert(pares, { fb, cf }) end
end
local proximaFaisca = 0

local t = 0
RunService.RenderStepped:Connect(function(dt: number)
	t += dt
	local tempestade = workspace:GetAttribute(Config.ATRIBUTO_TEMPESTADE) == true
	local dist = (camera.CFrame.Position - pivo.Position).Magnitude

	-- nível de detalhe do interior com histerese
	if interiorVisivel and dist > Config.INTERIOR_SUMIR then
		mostrarInterior(false)
	elseif not interiorVisivel and dist < Config.INTERIOR_VOLTAR then
		mostrarInterior(true)
	end
	if luz then
		luz.Enabled = dist < Config.LUZ_DISTANCIA_MAX
	end
	if not interiorVisivel then
		if beam then beam.Enabled = false end
		return -- longe: nada de animação nem faísca
	end

	for _, a in animados do
		local c = a.cfg
		if c.tipo == "girar" then
			local w = if tempestade then (c.velTempestade or 0) else (c.vel or 0)
			a.ang += w * dt
			local eixo = c.eixo or Vector3.yAxis
			a.alvo:PivotTo(a.cf0 * CFrame.fromAxisAngle(eixo, a.ang))
		elseif c.tipo == "pistao" then
			local y = math.max(0, math.sin(t * 2.2)) * (c.amplitude or 0.35)
			a.alvo:PivotTo(a.cf0 * CFrame.new(0, y, 0))
		elseif c.tipo == "ponteiro" then
			local ang = -0.8 + math.sin(t * 0.9) * (c.amplitude or 0.4) + (if tempestade then 0.6 else 0)
			a.alvo:PivotTo(a.cf0 * CFrame.fromAxisAngle(Vector3.zAxis, ang))
		end
	end

	-- faíscas só com tempestade, ~12 vezes por segundo, piscando
	if beam then
		if tempestade and #pares > 0 and t >= proximaFaisca then
			proximaFaisca = t + 0.08
			local p = pares[math.random(1, #pares)]
			beam.Attachment0, beam.Attachment1 = p[1], p[2]
			beam.Enabled = math.random() < 0.6
		elseif not tempestade then
			beam.Enabled = false
		end
	end
end)
