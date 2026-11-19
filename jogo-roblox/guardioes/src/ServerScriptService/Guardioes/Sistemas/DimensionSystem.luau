--!strict
-- NÃO EXECUTADO NO STUDIO. DimensionSystem — parte 1: VIAGEM RÁPIDA dentro da dimensão.
--  * Pontos de viagem = Parts com "GuardioesPontoDeViagem" (= id) e "Nome" em workspace.GuardioesViagem.
--    Descobertos por proximidade (o servidor mede, 1×/s) e salvos em perfil.pontosDescobertos.
--  * "Minha base" é sempre um destino (se o jogador tem parcela).
--  * VIAJAR(id): só descoberto, a pé, sem dano recente (8 s), com recarga (30 s). O servidor teleporta e
--    reancora a conferência de movimento (MovementSystem.reancorar). A criatura ativa se teleporta sozinha.
--  * Entre DIMENSÕES (outros places): TeleportService + DimensionSystem.liberada — fica para quando houver
--    um segundo place; o Campo das Bolhas continua congelado.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local G = ReplicatedStorage:WaitForChild("Guardioes")
local Viagem = require(G.Viagem.Viagem)
local LimiteDeTaxa = require(G.Util.LimiteDeTaxa)
local Remotos = require(G.Rede.Remotos)
local ConfigServidor = require(script.Parent.Parent.ConfigServidor)

local VI = Remotos.Viagem
local EV = Remotos.EventoViagem
local CFG = ConfigServidor.viagem
local BASE = "MinhaBase"

local DimensionSystem = { Nome = "DimensionSystem" }

local evento: RemoteEvent
local playerData: any
local movimento: any
local montarias: any
local base: any
local ctxSistemas: any = nil
local pasta: Folder
local ultimoDano: { [Player]: number } = {}
local ultimaViagem: { [Player]: number } = {}
local baldes: { [Player]: LimiteDeTaxa.Balde } = {}

local function pontos(): { [string]: BasePart }
	local l: { [string]: BasePart } = {}
	for _, d in pasta:GetDescendants() do
		local id = d:GetAttribute("GuardioesPontoDeViagem")
		if d:IsA("BasePart") and typeof(id) == "string" then
			l[id] = d
		end
	end
	return l
end

local function enviar(p: Player)
	local perfil = playerData.obter(p)
	if not perfil then
		return
	end
	local lista = {}
	for id, parte in pontos() do
		if perfil.pontosDescobertos[id] then
			table.insert(lista, { id = id, nome = tostring(parte:GetAttribute("Nome") or id) })
		end
	end
	table.sort(lista, function(a, b)
		return a.nome < b.nome
	end)
	if base.parcela(p) then
		table.insert(lista, 1, { id = BASE, nome = "Minha base" })
	end
	evento:FireClient(p, EV.LISTA, lista)
end

local function viajar(p: Player, id: string)
	local perfil = playerData.obter(p)
	local ch = p.Character
	if not perfil or not ch then
		return
	end
	local destino: CFrame? = nil
	local descoberto = false
	if id == BASE then
		local par = base.parcela(p)
		if par then
			descoberto = true
			destino = par.CFrame * CFrame.new(0, par.Size.Y / 2 + 4, 14)
		end
	else
		local parte = pontos()[id]
		if parte and perfil.pontosDescobertos[id] then
			descoberto = true
			destino = parte.CFrame * CFrame.new(0, 4, 0)
		end
	end
	local agora = os.clock()
	local ok, motivo = Viagem.pode({
		descoberto = descoberto and destino ~= nil,
		estado = movimento.estado(p) or "Solo",
		montado = montarias.montado(p),
		agora = agora,
		ultimoDano = ultimoDano[p] or -math.huge,
		ultimaViagem = ultimaViagem[p] or -math.huge,
		semCombateSeg = CFG.semCombateSeg,
		recargaSeg = CFG.recargaSeg,
	})
	if not ok then
		evento:FireClient(p, EV.REJEITADO, motivo)
		return
	end
	ultimaViagem[p] = agora
	ch:PivotTo(destino :: CFrame)
	movimento.reancorar(p)
	evento:FireClient(p, EV.CHEGOU, id)
end

function DimensionSystem.liberada(p: Player, dimensaoId: string): boolean
	if dimensaoId == "IlhaDasTempestades" then
		return true
	end
	local perfil = playerData.obter(p)
	return perfil ~= nil and perfil.dimensoes[dimensaoId] == true
end

function DimensionSystem.Init(ctx: any)
	ctxSistemas = ctx
	evento = Remotos.evento("Viagem")
end

function DimensionSystem.Start()
	playerData = ctxSistemas.obter("PlayerDataSystem")
	movimento = ctxSistemas.obter("MovementSystem")
	montarias = ctxSistemas.obter("MountSystem")
	base = ctxSistemas.obter("PersonalBaseSystem")
	local combate = ctxSistemas.obter("CombatSystem")
	local existente = Workspace:FindFirstChild("GuardioesViagem") :: Folder?
	if existente then
		pasta = existente
	else
		pasta = Instance.new("Folder")
		pasta.Name = "GuardioesViagem"
		pasta.Parent = Workspace
	end
	if next(pontos()) == nil and ConfigServidor.arenaDeTeste.ativa then
		for _, pt in ConfigServidor.pontosDeViagemDeTeste do
			local m = Instance.new("Part")
			m.Name = "Ponto_" .. pt.id
			m.Anchored = true
			m.CanCollide = false
			m.Shape = Enum.PartType.Cylinder
			m.Size = Vector3.new(0.4, 5, 5)
			m.CFrame = CFrame.new(ConfigServidor.arenaDeTeste.centro + pt.deslocamento + Vector3.new(0, -3, 0)) * CFrame.Angles(0, 0, math.rad(90))
			m.Material = Enum.Material.Neon
			m.Color = Color3.fromHex("#9FE8FF")
			m.Transparency = 0.3
			m:SetAttribute("GuardioesPontoDeViagem", pt.id)
			m:SetAttribute("Nome", pt.nome)
			m.Parent = pasta
		end
	end
	combate.jogadorAtingido.conectar(function(p: Player)
		ultimoDano[p] = os.clock()
	end)
	evento.OnServerEvent:Connect(function(p: Player, tipo: any, id: any)
		local b = baldes[p]
		if not b then
			b = LimiteDeTaxa.novo(4, 1, os.clock())
			baldes[p] = b
		end
		if not LimiteDeTaxa.consumir(b, os.clock()) then
			return
		end
		if tipo == VI.VIAJAR and typeof(id) == "string" and #id <= 64 then
			viajar(p, id)
		elseif tipo == VI.LISTAR then
			enviar(p)
		end
	end)
	playerData.carregado.conectar(function(p: Player)
		task.defer(enviar, p)
	end)
	Players.PlayerRemoving:Connect(function(p)
		ultimoDano[p], ultimaViagem[p], baldes[p] = nil, nil, nil
	end)
	-- descoberta por proximidade (1×/s)
	task.spawn(function()
		while true do
			task.wait(1)
			local lista = pontos()
			for _, p in Players:GetPlayers() do
				local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
				local perfil = hrp and playerData.obter(p)
				if hrp and perfil then
					for id, parte in lista do
						if not perfil.pontosDescobertos[id] and Viagem.descobre(((hrp :: BasePart).Position - parte.Position).Magnitude, CFG.raioDescoberta) then
							local ok = playerData.atualizar(p, function(pf)
								pf.pontosDescobertos[id] = true
								return true
							end)
							if ok then
								evento:FireClient(p, EV.DESCOBERTO, tostring(parte:GetAttribute("Nome") or id))
								enviar(p)
							end
						end
					end
				end
			end
		end
	end)
end

return DimensionSystem
