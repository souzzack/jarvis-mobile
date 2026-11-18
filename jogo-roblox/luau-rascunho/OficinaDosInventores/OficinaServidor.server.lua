--!strict
-- RASCUNHO, NÃO TESTADO NO STUDIO (o Studio não estava acessível quando isto foi escrito).
-- Lugar sugerido: ServerScriptService.Magnata.OficinaServidor (Script).
-- Prepara a Oficina dos Inventores importada do GLB:
--   1) ancora tudo e desliga colisão/consulta/toque das malhas visuais (a malha detalhada não deve ser colisor);
--   2) cria colisores invisíveis simples a partir de OficinaColisores (mesmas caixas do visualizador);
--   3) tira sombra do interior; 4) cria a luz interna, os pontos das faíscas e o lugar do NPC.
-- Nada é apagado nem movido: se o modelo não for encontrado, o script só avisa.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local pasta = ReplicatedStorage:WaitForChild("Magnata"):WaitForChild("Oficina")
local Config = require(pasta:WaitForChild("OficinaConfig"))
local Colisores = require(pasta:WaitForChild("OficinaColisores"))

local function acharModelo(): Model?
	local atual: Instance = workspace
	for _, nome in Config.CAMINHO do
		local filho = atual:FindFirstChild(nome)
		if not filho then
			warn(`[Oficina] não encontrei "{nome}" em {atual:GetFullName()} — importe Architecture.glb antes`)
			return nil
		end
		atual = filho
	end
	return if atual:IsA("Model") then atual else nil
end

local modelo = acharModelo()
if not modelo then
	return
end

local pivo = modelo:GetPivot()
local interior = modelo:FindFirstChild(Config.INTERIOR_NOME, true)

-- 1) malhas visuais: ancoradas, sem colisão, sem consulta, sem toque; interior sem sombra
for _, d in modelo:GetDescendants() do
	if d:IsA("BasePart") then
		d.Anchored = true
		d.CanCollide = false
		d.CanQuery = false
		d.CanTouch = false
		if d:IsA("MeshPart") then
			d.CollisionFidelity = Enum.CollisionFidelity.Box -- a forma de colisão da malha não é usada
			d.RenderFidelity = Enum.RenderFidelity.Automatic
		end
		if interior and d:IsDescendantOf(interior) then
			d.CastShadow = false
		end
	end
end

-- 2) colisores invisíveis (caixas orientadas só em Y, coordenadas locais ao pivô)
local pastaCol = Instance.new("Folder")
pastaCol.Name = "Colisores"
for i, c in Colisores.CAIXAS do
	local p = Instance.new("Part")
	p.Name = string.format("Colisor_%02d", i)
	p.Size = Vector3.new(c.s[1], c.s[2], c.s[3])
	p.CFrame = pivo * CFrame.new(c.c[1], c.c[2], c.c[3]) * CFrame.Angles(0, c.ry, 0)
	p.Anchored = true
	p.CanCollide = true
	p.CanQuery = true
	p.CanTouch = false
	p.Transparency = 1
	p.CastShadow = false
	p.Parent = pastaCol
end
pastaCol.Parent = modelo

-- 3) luz interna e pontos de efeito (Attachments numa peça âncora invisível)
local ancora = Instance.new("Part")
ancora.Name = "PontosDeEfeito"
ancora.Size = Vector3.one
ancora.Transparency = 1
ancora.Anchored = true
ancora.CanCollide = false
ancora.CanQuery = false
ancora.CanTouch = false
ancora.CFrame = pivo
ancora.Parent = modelo

local function anexo(nome: string, local_: Vector3): Attachment
	local a = Instance.new("Attachment")
	a.Name = nome
	a.Position = local_
	a.Parent = ancora
	return a
end

local aLuz = anexo("LuzInterna", Config.LUZ_LOCAL)
local luz = Instance.new("PointLight")
luz.Color = Config.LUZ_COR
luz.Brightness = Config.LUZ_BRILHO
luz.Range = Config.LUZ_ALCANCE
luz.Shadows = false
luz.Parent = aLuz

anexo("FaiscadorA", Config.FAISCADOR[1])
anexo("FaiscadorB", Config.FAISCADOR[2])
anexo("CondutorFim", Config.CONDUTOR_FIM)
anexo("BobinaLabTopo", Config.BOBINA_LAB_TOPO)
local npc = anexo("PontoNPC", Config.PONTO_NPC)
npc:SetAttribute("NPC", "STORM.NPC.02")

modelo:SetAttribute("OficinaPreparada", true)
print(`[Oficina] preparada: {#Colisores.CAIXAS} colisores, interior {if interior then "encontrado" else "AUSENTE"}`)
