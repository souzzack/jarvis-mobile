--!strict
-- NÃO EXECUTADO NO STUDIO. FlightEffects: rastros de energia, partículas e vento — para TODOS os jogadores
-- que estão voando, lendo os atributos replicados LocEstado/LocEfeito do personagem (sem rede extra).
-- Desempenho: qualidade gráfica do aparelho define quantidade; quem está longe não tem efeito;
-- atualização a 5 Hz (não por quadro). Recursos: só os padrões do próprio Roblox (rbxasset), nada de terceiros.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")


local EfeitosDeVoo = { Nome = "EfeitosDeVoo" }

local NO_AR: { [string]: boolean } = { Decolagem = true, Pairar = true, Voo = true, Impulso = true, Descida = true, Pouso = true, Planando = true }
local CORES: { [string]: { Color3 } } = {
	Arcano = { Color3.fromHex("#9FA8FF"), Color3.fromHex("#E2C8FF") },
	Penas = { Color3.fromHex("#FFFFFF"), Color3.fromHex("#D8E6FF") },
	Raio = { Color3.fromHex("#7FE7FF"), Color3.fromHex("#FFF27A") },
	Folhas = { Color3.fromHex("#7EDC6A"), Color3.fromHex("#D9F7A6") },
	Vento = { Color3.fromHex("#BFF5EC"), Color3.fromHex("#FFFFFF") },
	Tecido = { Color3.fromHex("#FFD7A0"), Color3.fromHex("#FFFFFF") },
	AsasDeLuz = { Color3.fromHex("#FFE9A8"), Color3.fromHex("#FFFFFF") },
	Raia = { Color3.fromHex("#4EA8FF"), Color3.fromHex("#B8E2FF") },
}
local DISTANCIA_MAX = 180
-- placeholder de áudio: som de queda que vem com o Roblox; trocar por vento/energia próprios quando gravados
local SOM_VENTO = "rbxasset://sounds/action_falling.mp3"

type Efeito = { pasta: Folder, rastro: Trail, particulas: ParticleEmitter? }
local ativos: { [Model]: Efeito } = {}
local somVento: Sound? = nil
local loco: any

-- 1 = baixo, 2 = médio, 3 = alto (Automático conta como médio)
local function nivelQualidade(): number
	local ok, nivel = pcall(function()
		return UserSettings():GetService("UserGameSettings").SavedQualityLevel.Value
	end)
	if not ok or nivel == 0 then
		return 2
	end
	return if nivel <= 3 then 1 elseif nivel <= 7 then 2 else 3
end

local function criar(ch: Model, efeito: string): Efeito?
	local hrp = ch:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not hrp then
		return nil
	end
	local q = nivelQualidade()
	local cores = CORES[efeito] or CORES.Arcano
	local pasta = Instance.new("Folder")
	pasta.Name = "GuardioesEfeitoVoo"
	local a0 = Instance.new("Attachment")
	a0.Position = Vector3.new(-1.6, 0, 0.6)
	a0.Parent = hrp
	local a1 = Instance.new("Attachment")
	a1.Position = Vector3.new(1.6, 0, 0.6)
	a1.Parent = hrp
	local t = Instance.new("Trail")
	t.Attachment0, t.Attachment1 = a0, a1
	t.Lifetime = ({ 0.18, 0.35, 0.55 })[q]
	t.Color = ColorSequence.new(cores[1], cores[2])
	t.Transparency = NumberSequence.new(0.35, 1)
	t.LightEmission = 0.8
	t.FaceCamera = true
	t.Parent = hrp
	local pe: ParticleEmitter? = nil
	if q >= 2 then
		local e = Instance.new("ParticleEmitter")
		e.Rate = if q == 3 then 26 else 10
		e.Lifetime = NumberRange.new(0.3, 0.6)
		e.Speed = NumberRange.new(0.5, 2)
		e.Size = NumberSequence.new(0.35, 0)
		e.Color = ColorSequence.new(cores[1], cores[2])
		e.LightEmission = 1
		e.Parent = a0
		pe = e
	end
	-- tudo que foi criado fica referenciado na pasta (limpeza em um lugar só)
	for _, i in { a0, a1, t } do
		local ref = Instance.new("ObjectValue")
		ref.Value = i
		ref.Parent = pasta
	end
	pasta.Parent = ch
	return { pasta = pasta, rastro = t, particulas = pe }
end

local function remover(ch: Model)
	local e = ativos[ch]
	if not e then
		return
	end
	for _, ref in e.pasta:GetChildren() do
		local v = (ref :: ObjectValue).Value
		if v then
			v:Destroy()
		end
	end
	e.pasta:Destroy()
	ativos[ch] = nil
end

local function atualizar()
	local cam = Workspace.CurrentCamera
	local origem = if cam then cam.CFrame.Position else Vector3.zero
	local vistos: { [Model]: boolean } = {}
	for _, p in Players:GetPlayers() do
		local ch = p.Character
		local hrp = ch and ch:FindFirstChild("HumanoidRootPart") :: BasePart?
		if ch and hrp then
			local estado = ch:GetAttribute("LocEstado")
			local efeito = (ch:GetAttribute("LocEfeito") :: string?) or "Arcano"
			local perto = (hrp.Position - origem).Magnitude <= DISTANCIA_MAX
			if NO_AR[estado :: string] and perto then
				vistos[ch] = true
				if not ativos[ch] then
					ativos[ch] = criar(ch, efeito)
				end
				local e = ativos[ch]
				if e and e.particulas then
					e.particulas.Enabled = estado == "Voo" or estado == "Impulso"
				end
			end
		end
	end
	for ch in ativos do
		if not vistos[ch] then
			remover(ch)
		end
	end
end

function EfeitosDeVoo.Init(ctx: any)
	loco = ctx.obter("ControleDeLocomocao")
end

function EfeitosDeVoo.Start()
	somVento = Instance.new("Sound")
	local s = somVento :: Sound
	s.Name = "GuardioesVento"
	s.SoundId = SOM_VENTO
	s.Looped = true
	s.Volume = 0
	s.Parent = Workspace.CurrentCamera or Workspace
	s:Play()
	local acumulado = 0
	RunService.Heartbeat:Connect(function(dt)
		-- vento do próprio jogador: segue a velocidade de perto (barato: só volume e tom)
		local estado = loco.estado()
		local perfil = loco.perfil()
		local alvo = 0
		if estado ~= "Solo" and estado ~= "Montado" and perfil then
			alvo = math.clamp(loco.velocidade() / math.max(1, perfil.velMax), 0, 1.3) * 0.5
		end
		s.Volume += (alvo - s.Volume) * math.min(1, dt * 3)
		s.PlaybackSpeed = 0.8 + s.Volume * 0.6
		acumulado += dt
		if acumulado >= 0.2 then
			acumulado = 0
			atualizar()
		end
	end)
	Players.PlayerRemoving:Connect(function(p)
		if p.Character then
			remover(p.Character)
		end
	end)
end

return EfeitosDeVoo
