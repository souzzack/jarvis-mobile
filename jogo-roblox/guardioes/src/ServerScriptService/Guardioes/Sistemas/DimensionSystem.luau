--!strict
-- NÃO EXECUTADO NO STUDIO. DimensionSystem — parte 1: VIAGEM RÁPIDA dentro da dimensão.
--  * Pontos de viagem = Parts com "GuardioesPontoDeViagem" (= id) e "Nome" em workspace.GuardioesViagem.
--    Descobertos por proximidade (o servidor mede, 1×/s) e salvos em perfil.pontosDescobertos.
--  * "Minha base" é sempre um destino (se o jogador tem parcela).
--  * VIAJAR(id): só descoberto, a pé, sem dano recente (8 s), com recarga (30 s). O servidor teleporta e
--    reancora a conferência de movimento (MovementSystem.reancorar). A criatura ativa se teleporta sozinha.
--  * PORTAIS entre DIMENSÕES (outros places, Config/Dimensoes, Viagem/Portal):
--      - Parts com o atributo "GuardioesPortal" na mesma pasta; prompt "Atravessar" (B) abre a lista de destinos;
--      - ATRAVESSAR(id): perto de um portal, a pé, fora de combate, dimensão liberada e place publicado;
--      - antes do teleporte o perfil é GRAVADO e a trava LIBERADA (PlayerDataSystem.liberarParaPortal): o servidor
--        de destino carrega sem esperar. Se o teleporte falhar, a trava volta (retomarAposPortal);
--      - na chegada: a dimensão fica marcada como visitada (perfil.dimensoes) e o jogador aparece no portal
--        (TeleportData só decide ONDE aparecer e é lido com desconfiança).
--    Sem placeId (0), o portal mostra "em construção". O Campo das Bolhas não é tocado.

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local G = ReplicatedStorage:WaitForChild("Guardioes")
local Viagem = require(G.Viagem.Viagem)
local Portal = require(G.Viagem.Portal)
local Dimensoes = require(G.Config.Dimensoes)
local Requisitos = require(G.Util.Requisitos)
local LimiteDeTaxa = require(G.Util.LimiteDeTaxa)
local Remotos = require(G.Rede.Remotos)
local ConfigServidor = require(script.Parent.Parent.ConfigServidor)

local VI = Remotos.Viagem
local EV = Remotos.EventoViagem
local CFG = ConfigServidor.viagem
local BASE = "MinhaBase"
local ATUAL = Portal.dimensaoAtual(game.PlaceId, Dimensoes.lista)
local atravessando: { [Player]: boolean } = {}

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

-- dimensões no MESMO place: Parts de chegada (GuardioesChegadaDimensao = id; RaioDimensao = tamanho da área)
local function chegadasLocais(): { [string]: BasePart }
	local l: { [string]: BasePart } = {}
	for _, d in pasta:GetDescendants() do
		local id = d:GetAttribute("GuardioesChegadaDimensao")
		if d:IsA("BasePart") and typeof(id) == "string" then
			l[id] = d
		end
	end
	return l
end

-- em qual dimensão o jogador está: pela área (dimensões locais) ou, fora delas, a do place
local function dimensaoDe(p: Player): string
	local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not hrp then
		return ATUAL
	end
	local areas = {}
	for id, parte in chegadasLocais() do
		local raio = parte:GetAttribute("RaioDimensao")
		if typeof(raio) == "number" and raio > 0 then
			table.insert(areas, { id = id, x = parte.Position.X, z = parte.Position.Z, raio = raio })
		end
	end
	return Portal.dimensaoPorPosicao((hrp :: BasePart).Position.X, (hrp :: BasePart).Position.Z, areas, ATUAL)
end
DimensionSystem.dimensaoDe = dimensaoDe

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

-- já VISITOU a dimensão (o hub conta sempre). Usado por livros e segredos ("esteve no Campo das Bolhas").
function DimensionSystem.liberada(p: Player, dimensaoId: string): boolean
	local d = Portal.porId(Dimensoes.lista, dimensaoId)
	if d and d.hub then
		return true
	end
	local perfil = playerData.obter(p)
	return perfil ~= nil and perfil.dimensoes[dimensaoId] == true
end

-- pode IR para a dimensão (requisitos cumpridos), mesmo sem ter visitado ainda
local function podeIr(p: Player, perfil: any, d: any): boolean
	if d.hub or perfil.dimensoes[d.id] then
		return true
	end
	local ok = Requisitos.avaliar(d.requisitos or {}, {
		missoes = perfil.missoes, restauracoes = perfil.restauracoes, segredos = perfil.segredos, dimensoes = perfil.dimensoes,
		enigmas = perfil.enigmas, livros = perfil.livrosLidos, habilidades = perfil.habilidades,
	})
	return ok
end

local function portaisPerto(p: Player): boolean
	local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not hrp then
		return false
	end
	for _, d in pasta:GetDescendants() do
		if d:IsA("BasePart") and d:GetAttribute("GuardioesPortal") and ((hrp :: BasePart).Position - d.Position).Magnitude <= CFG.raioPortal then
			return true
		end
	end
	return false
end

local function listaDoPortal(p: Player)
	local perfil = playerData.obter(p)
	if not perfil then
		return
	end
	local lista = {}
	local aqui = dimensaoDe(p)
	for _, d in Dimensoes.lista do
		local estado = Portal.estado(d, aqui, podeIr(p, perfil, d))
		table.insert(lista, { id = d.id, nome = d.nome, estado = estado, requisito = if estado == "bloqueada" then d.requisitoPublico else nil })
	end
	evento:FireClient(p, EV.PORTAL, lista)
end

local teleportar: (Player, any) -> (boolean, string)

-- dimensão no mesmo place: as mesmas regras da viagem (a pé, fora de combate), sem gravar/liberar o perfil
-- (o jogador não sai do servidor). Marca a dimensão como visitada.
local function viajarLocal(p: Player, d: any): (boolean, string)
	local chegada = chegadasLocais()[d.id]
	local ch = p.Character
	if not chegada or not ch then
		return false, "emConstrucao"
	end
	local okRegra, motivo = Viagem.pode({
		descoberto = true, estado = movimento.estado(p) or "Solo", montado = montarias.montado(p), agora = os.clock(),
		ultimoDano = ultimoDano[p] or -math.huge, ultimaViagem = -math.huge, semCombateSeg = CFG.semCombateSeg, recargaSeg = 0,
	})
	if not okRegra then
		evento:FireClient(p, EV.REJEITADO, motivo)
		return false, motivo
	end
	atravessando[p] = true
	evento:FireClient(p, EV.ATRAVESSANDO, d.nome)
	ch:PivotTo(chegada.CFrame * CFrame.new(0, 4, 0))
	movimento.reancorar(p)
	if not d.hub then
		playerData.atualizar(p, function(pf)
			if pf.dimensoes[d.id] then
				return false
			end
			pf.dimensoes[d.id] = true
			return true
		end)
	end
	evento:FireClient(p, EV.CHEGOU, d.id)
	task.delay(1.5, function()
		atravessando[p] = nil
	end)
	return true, "ok"
end

local function atravessar(p: Player, id: string)
	local perfil = playerData.obter(p)
	local d = Portal.porId(Dimensoes.lista, id)
	if not perfil or not d or atravessando[p] then
		return
	end
	if not portaisPerto(p) then
		evento:FireClient(p, EV.REJEITADO, "longe")
		return
	end
	local estado = Portal.estado(d, dimensaoDe(p), podeIr(p, perfil, d))
	if estado ~= "ok" then
		evento:FireClient(p, EV.REJEITADO, if estado == "aqui" then "jaEstaAqui" elseif estado == "emConstrucao" then "emConstrucao" else "dimensaoBloqueada")
		return
	end
	teleportar(p, d)
end

-- regras da viagem + gravação segura + TeleportAsync. Usado pelo portal comum e pelas passagens secretas
-- (SecretDimensionService), para existir UM caminho de viagem entre places só. (ok, motivo)
teleportar = function(p: Player, d: any): (boolean, string)
	if atravessando[p] then
		return false, "ocupado"
	end
	if d.noPlace then
		return viajarLocal(p, d)
	end
	if type(d.placeId) ~= "number" or d.placeId <= 0 then
		return false, "emConstrucao" -- nunca teleporta para um lugar que não existe
	end
	local okRegra, motivo = Viagem.pode({
		descoberto = true, estado = movimento.estado(p) or "Solo", montado = montarias.montado(p), agora = os.clock(),
		ultimoDano = ultimoDano[p] or -math.huge, ultimaViagem = -math.huge, semCombateSeg = CFG.semCombateSeg, recargaSeg = 0,
	})
	if not okRegra then
		evento:FireClient(p, EV.REJEITADO, motivo)
		return false, motivo
	end
	atravessando[p] = true
	if not playerData.liberarParaPortal(p) then
		atravessando[p] = nil
		evento:FireClient(p, EV.REJEITADO, "gravacao")
		return false, "gravacao"
	end
	evento:FireClient(p, EV.ATRAVESSANDO, d.nome)
	local opcoes = Instance.new("TeleportOptions")
	opcoes:SetTeleportData(Portal.dadosDeChegada(ATUAL))
	local ok, erro = pcall(function()
		TeleportService:TeleportAsync(d.placeId, { p }, opcoes)
	end)
	if not ok then
		warn("[Guardioes] portal: " .. tostring(erro))
		playerData.retomarAposPortal(p)
		atravessando[p] = nil
		evento:FireClient(p, EV.REJEITADO, "teleporteFalhou")
		return false, "teleporteFalhou"
	end
	return true, "ok"
end

-- passagem secreta (SecretDimensionService): quem chama já conferiu descoberta, condições e distância
function DimensionSystem.atravessarPara(p: Player, destino: any): (boolean, string)
	return teleportar(p, destino)
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
		elseif tipo == VI.ATRAVESSAR and typeof(id) == "string" and #id <= 64 then
			task.spawn(atravessar, p, id)
		end
	end)
	playerData.carregado.conectar(function(p: Player)
		task.defer(enviar, p)
		-- chegou nesta dimensão: marca como visitada (o hub não precisa)
		local d = Portal.porId(Dimensoes.lista, ATUAL)
		if d and not d.hub then
			playerData.atualizar(p, function(pf)
				if pf.dimensoes[ATUAL] then
					return false
				end
				pf.dimensoes[ATUAL] = true
				return true
			end)
		end
	end)
	-- chegada por portal: aparecer ao lado do portal desta dimensão (só posição; nada de progresso vem daqui)
	local function aoChegar(p: Player)
		local ok, dados = pcall(function()
			return p:GetJoinData().TeleportData
		end)
		if not ok or not Portal.lerChegada(dados, Dimensoes.lista) then
			return
		end
		p.CharacterAdded:Once(function(ch)
			task.wait(0.2)
			for _, d in pasta:GetDescendants() do
				if d:IsA("BasePart") and d:GetAttribute("GuardioesPortal") then
					ch:PivotTo((d :: BasePart).CFrame * CFrame.new(0, 3, -6))
					movimento.reancorar(p)
					break
				end
			end
		end)
	end
	Players.PlayerAdded:Connect(aoChegar)
	for _, p in Players:GetPlayers() do
		aoChegar(p)
	end
	TeleportService.TeleportInitFailed:Connect(function(p: Player, resultado, mensagem)
		if atravessando[p] then
			warn("[Guardioes] portal falhou: " .. tostring(resultado) .. " " .. tostring(mensagem))
			playerData.retomarAposPortal(p)
			atravessando[p] = nil
			evento:FireClient(p, EV.REJEITADO, "teleporteFalhou")
		end
	end)
	-- portal de TESTE perto da arena (no mapa real: Part com o atributo GuardioesPortal na pasta GuardioesViagem)
	local mp = ConfigServidor.marcadoresDeTeste
	if ConfigServidor.arenaDeTeste.ativa and mp and mp.ativa and mp.portal then
		local temPortal = false
		for _, d in pasta:GetDescendants() do
			if d:GetAttribute("GuardioesPortal") then
				temPortal = true
			end
		end
		if not temPortal then
			local arco = Instance.new("Part")
			arco.Name = "Portal_Teste"
			arco.Anchored = true
			arco.Size = Vector3.new(8, 10, 1)
			arco.Material = Enum.Material.Neon
			arco.Color = Color3.fromHex("#7A5CFF")
			arco.Transparency = 0.35
			arco.CanCollide = false
			arco.CFrame = CFrame.new(ConfigServidor.arenaDeTeste.centro + mp.portal)
			arco:SetAttribute("GuardioesPortal", true)
			arco.Parent = pasta
		end
	end
	for _, d in pasta:GetDescendants() do
		if d:IsA("BasePart") and d:GetAttribute("GuardioesPortal") and not d:FindFirstChild("GuardioesAtravessar") then
			local pr = Instance.new("ProximityPrompt")
			pr.Name = "GuardioesAtravessar"
			pr.ActionText = "Atravessar"
			pr.ObjectText = "Portal"
			pr.KeyboardKeyCode = Enum.KeyCode.B
			pr.GamepadKeyCode = Enum.KeyCode.DPadUp
			pr.MaxActivationDistance = 10
			pr.Parent = d
			pr.Triggered:Connect(function(p: Player)
				listaDoPortal(p)
			end)
		end
	end
	Players.PlayerRemoving:Connect(function(p)
		ultimoDano[p], ultimaViagem[p], baldes[p], atravessando[p] = nil, nil, nil, nil
	end)
	-- descoberta por proximidade (1×/s)
	task.spawn(function()
		while true do
			task.wait(1)
			local ok, erro = pcall(function()
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
			end)
			if not ok then
				warn("[Guardioes] viagem (descoberta): " .. tostring(erro))
			end
		end
	end)
end

return DimensionSystem
