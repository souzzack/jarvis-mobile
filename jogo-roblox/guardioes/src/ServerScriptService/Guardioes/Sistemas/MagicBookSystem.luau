--!strict
-- NÃO EXECUTADO NO STUDIO. MagicBookSystem (Etapa 9): ler livros no mundo e aprender para sempre.
--  * Livros = Parts com o atributo "GuardioesLivro" = id, em workspace.GuardioesLivros. Cada um ganha um
--    ProximityPrompt ("Ler"). Os mapas reais NÃO são tocados: na arena de teste o sistema cria pedestais
--    provisórios (ConfigServidor.concessoesDeTeste.livrosNaArena).
--  * Requisitos ficam só no servidor (ConfigSecreta/Livros) e são avaliados por Util/Requisitos contra o
--    progresso do perfil (+ progresso de TESTE em memória, se ativo).
--  * Ao ler: perfil.livrosLidos e segredos revelados são gravados numa transação; as habilidades vão por
--    MovementAbilitySystem.conceder (também salvas). Quem já leu nunca precisa achar o livro de novo.
--  * Recusa mostra só o texto público do livro (o Manuscrito Sem Nome não revela nada).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local G = ReplicatedStorage:WaitForChild("Guardioes")
local Livros = require(G.Config.LivrosMagicos)
local Habilidades = require(G.Config.Locomocao.Habilidades)
local Requisitos = require(G.Util.Requisitos)
local Remotos = require(G.Rede.Remotos)
local Secretos = require(script.Parent.Parent.ConfigSecreta.Livros)
local ConfigServidor = require(script.Parent.Parent.ConfigServidor)

local EL = Remotos.EventoLivro
local DISTANCIA_MAX = 12
local RECARGA = 1.0

local Sinal = require(G.Util.Sinal)

local MagicBookSystem = { Nome = "MagicBookSystem" }
MagicBookSystem.lido = Sinal.novo() -- (p, livroId): missões escutam

local evento: RemoteEvent
local playerData: any
local habilidades: any
local ctxSistemas: any = nil
local ultimaLeitura: { [Player]: number } = {}

local function progressoDe(p: Player, perfil: any): any
	local hab = {}
	for _, id in habilidades.lista(p) do
		hab[id] = true
	end
	local base = {
		missoes = perfil.missoes, restauracoes = perfil.restauracoes, segredos = perfil.segredos,
		dimensoes = perfil.dimensoes, enigmas = perfil.enigmas, livros = perfil.livrosLidos, habilidades = hab,
	}
	local teste = ConfigServidor.concessoesDeTeste
	if teste and teste.ativa and teste.progressoLivros then
		return Requisitos.unir(base, teste.progressoLivros)
	end
	return Requisitos.unir(base)
end

-- lista do "grimório pessoal": públicos com o requisito em texto; ocultos só viram nome depois de lidos
local function enviarLista(p: Player)
	local perfil = playerData.obter(p)
	if not perfil then
		return
	end
	local l = {}
	for _, livro in Livros.lista do
		local lido = perfil.livrosLidos[livro.id] == true
		local esconder = livro.oculto and not lido
		table.insert(l, {
			id = livro.id, nome = if esconder then "???" else livro.nome, lido = lido,
			ensina = if esconder then nil else (Habilidades.porId[livro.ensina] and Habilidades.porId[livro.ensina].nome),
			requisito = if lido then nil else livro.requisitoPublico,
		})
	end
	evento:FireClient(p, EL.LISTA, l)
end

local function ler(p: Player, livroId: string, parte: BasePart)
	local agora = os.clock()
	if agora - (ultimaLeitura[p] or -math.huge) < RECARGA then
		return
	end
	ultimaLeitura[p] = agora
	local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not hrp or ((hrp :: BasePart).Position - parte.Position).Magnitude > DISTANCIA_MAX then
		return
	end
	local publico = Livros.porId[livroId]
	local segredo = Secretos[livroId]
	local perfil = playerData.obter(p)
	if not publico or not segredo or not perfil then
		return
	end
	if perfil.livrosLidos[livroId] then
		evento:FireClient(p, EL.RECUSADO, livroId, "jaLido")
		return
	end
	local ok = Requisitos.avaliar(segredo.requisitos, progressoDe(p, perfil))
	if not ok then
		-- só o texto público; nunca a lista interna (protege segredos e enigmas)
		evento:FireClient(p, EL.RECUSADO, livroId, publico.requisitoPublico)
		return
	end
	local gravou = playerData.atualizar(p, function(pf)
		pf.livrosLidos[livroId] = true
		for _, s in segredo.revela or {} do
			pf.segredos[s] = true
		end
		return true
	end)
	if not gravou then
		return
	end
	local nomes = {}
	for _, h in segredo.concede do
		habilidades.conceder(p, h, "livro:" .. livroId)
		local cfg = Habilidades.porId[h]
		table.insert(nomes, if cfg then cfg.nome else h)
	end
	evento:FireClient(p, EL.LIDO, livroId, if publico.oculto then "???" else publico.nome, nomes)
	MagicBookSystem.lido.disparar(p, livroId)
	enviarLista(p)
end

local function prepararLivro(parte: BasePart)
	local id = parte:GetAttribute("GuardioesLivro")
	if typeof(id) ~= "string" or not Livros.porId[id] or parte:FindFirstChild("GuardioesLer") then
		return
	end
	local publico = Livros.porId[id]
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "GuardioesLer"
	prompt.ActionText = "Ler"
	prompt.ObjectText = if publico.oculto then "???" else publico.nome
	prompt.HoldDuration = 0.6
	prompt.MaxActivationDistance = 8
	prompt.RequiresLineOfSight = false
	-- E (teclado) e X (controle) já transformam o artefato: o livro usa B / seta para cima
	prompt.KeyboardKeyCode = Enum.KeyCode.B
	prompt.GamepadKeyCode = Enum.KeyCode.DPadUp
	prompt.Parent = parte
	prompt.Triggered:Connect(function(p: Player)
		ler(p, id, parte)
	end)
end

-- pedestais PROVISÓRIOS de teste perto da arena (não são mapas: somem quando a arena for desligada)
local function criarPedestaisDeTeste(pasta: Folder)
	local teste = ConfigServidor.concessoesDeTeste
	local arena = ConfigServidor.arenaDeTeste
	if not (teste and teste.ativa and teste.livrosNaArena and arena.ativa) then
		return
	end
	for i, id in teste.livrosNaArena do
		local base = Instance.new("Part")
		base.Name = "Pedestal_" .. id
		base.Anchored = true
		base.Size = Vector3.new(2, 3, 2)
		base.Color = Color3.fromHex("#6B5A45")
		base.CFrame = CFrame.new(arena.centro + Vector3.new(-12 + (i - 1) * 8, 1.5 - arena.centro.Y + 1, -22))
		base.Parent = pasta
		local livro = Instance.new("Part")
		livro.Name = "Livro_" .. id
		livro.Anchored = true
		livro.CanCollide = false
		livro.Size = Vector3.new(1.6, 0.35, 1.2)
		livro.Material = Enum.Material.Neon
		livro.Color = Color3.fromHex("#E8D7A8")
		livro.CFrame = base.CFrame * CFrame.new(0, 1.7, 0)
		livro:SetAttribute("GuardioesLivro", id)
		livro.Parent = pasta
	end
end

function MagicBookSystem.Init(ctx: any)
	ctxSistemas = ctx
	evento = Remotos.evento("Livro")
end

function MagicBookSystem.Start()
	playerData = ctxSistemas.obter("PlayerDataSystem")
	habilidades = ctxSistemas.obter("MovementAbilitySystem")
	local pasta = Workspace:FindFirstChild("GuardioesLivros") :: Folder?
	if not pasta then
		local nova = Instance.new("Folder")
		nova.Name = "GuardioesLivros"
		nova.Parent = Workspace
		pasta = nova
	end
	local p = pasta :: Folder
	criarPedestaisDeTeste(p)
	for _, d in p:GetDescendants() do
		if d:IsA("BasePart") then
			prepararLivro(d)
		end
	end
	p.DescendantAdded:Connect(function(d)
		if d:IsA("BasePart") then
			task.defer(prepararLivro, d)
		end
	end)
	Players.PlayerRemoving:Connect(function(pl)
		ultimaLeitura[pl] = nil
	end)
	playerData.carregado.conectar(function(pl: Player)
		enviarLista(pl)
	end)
end

return MagicBookSystem
