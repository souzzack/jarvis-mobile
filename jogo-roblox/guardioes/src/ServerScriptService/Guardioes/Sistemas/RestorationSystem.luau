--!strict
-- NÃO EXECUTADO NO STUDIO. RestorationSystem (Etapa H, GDD 8): restaurar estruturas, por jogador.
--  * Estrutura = marcador (Part com "GuardioesEstrutura" = id) em workspace.GuardioesEstruturas, ao lado do
--    modelo aprovado — o modelo nunca é trocado. Prompt "Restaurar" entrega o que o jogador tem da etapa atual
--    (entrega parcial vale) numa transação do inventário.
--  * Etapa concluída: vizinhos (≤ 30 studs) na mesma etapa que já entregaram ≥ 25% concluem junto (ajuda).
--  * Restaurada: perfil.restauracoes[id] = true (destrava receitas, livros, missões). Sinal 'restaurou'.
--  * Melhoria GLOBAL decorativa: quando a maioria dos presentes restaurou, o atributo
--    workspace.GuardioesEstruturas:<id>Global = true (visuais futuros escutam; nenhum modelo é trocado).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local G = ReplicatedStorage:WaitForChild("Guardioes")
local Restauracoes = require(G.Config.Restauracoes)
local Restauracao = require(G.Restauracao.Restauracao)
local Sinal = require(G.Util.Sinal)
local Remotos = require(G.Rede.Remotos)
local ConfigServidor = require(script.Parent.Parent.ConfigServidor)

local ER = Remotos.EventoRestauracao
local DISTANCIA = 12

local RestorationSystem = { Nome = "RestorationSystem" }
RestorationSystem.restaurou = Sinal.novo() -- (p, estruturaId)
RestorationSystem.concluiuEtapa = Sinal.novo() -- (p, estruturaId, etapa)

local evento: RemoteEvent
local playerData: any
local inventario: any
local ctxSistemas: any = nil
local pasta: Folder
local ultimo: { [Player]: number } = {}

local function progressoDe(perfil: any, id: string): any
	local r = perfil.restauracoesProgresso[id]
	return if r then r else Restauracao.novo()
end

local function enviar(p: Player, id: string)
	local perfil = playerData.obter(p)
	local cfg = Restauracoes.porId[id]
	if not perfil or not cfg then
		return
	end
	local prog = progressoDe(perfil, id)
	local etapa = cfg.etapas[prog.etapa + 1]
	evento:FireClient(p, ER.ESTADO, id, {
		nome = cfg.nome, funcao = cfg.funcao, estado = Restauracao.estado(prog, cfg), etapa = prog.etapa, total = #cfg.etapas,
		etapaNome = if etapa then etapa.nome else nil, falta = Restauracao.faltaNaEtapa(prog, cfg),
	})
end

local function atualizarGlobal(id: string)
	local total, feitos = 0, 0
	for _, p in Players:GetPlayers() do
		local perfil = playerData.obter(p)
		if perfil then
			total += 1
			if perfil.restauracoes[id] then
				feitos += 1
			end
		end
	end
	pasta:SetAttribute(id .. "Global", total > 0 and feitos / total > 0.5)
end

-- conclui a etapa para quem ajudou (vizinhos com contribuição mínima)
local function ajudar(quem: Player, id: string, etapaConcluida: number, onde: Vector3)
	local cfg = Restauracoes.porId[id]
	for _, p in Players:GetPlayers() do
		local hrp = p ~= quem and p.Character and p.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
		if hrp and ((hrp :: BasePart).Position - onde).Magnitude <= Restauracoes.raioDeAjuda then
			local restaurada = false
			local ajudou = false
			playerData.atualizar(p, function(perfil)
				local prog = progressoDe(perfil, id)
				if not Restauracao.concluirPorAjuda(prog, cfg, etapaConcluida, Restauracoes.ajudaMinima) then
					return false
				end
				ajudou = true
				perfil.restauracoesProgresso[id] = prog
				if prog.etapa >= #cfg.etapas then
					perfil.restauracoes[id] = true
					restaurada = true
				end
				return true
			end)
			if ajudou then
				evento:FireClient(p, ER.AJUDOU, id, quem.DisplayName)
				RestorationSystem.concluiuEtapa.disparar(p, id, etapaConcluida)
				if restaurada then
					RestorationSystem.restaurou.disparar(p, id)
				end
				enviar(p, id)
			end
		end
	end
end

local function entregar(p: Player, id: string, parte: BasePart)
	local agora = os.clock()
	if agora - (ultimo[p] or -math.huge) < 0.8 then
		return
	end
	ultimo[p] = agora
	local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	local cfg = Restauracoes.porId[id]
	local perfil = playerData.obter(p)
	if not hrp or not cfg or not perfil or ((hrp :: BasePart).Position - parte.Position).Magnitude > DISTANCIA then
		return
	end
	local prog = progressoDe(perfil, id)
	if Restauracao.estado(prog, cfg) == "Restaurada" then
		enviar(p, id)
		return
	end
	local disponivel = {}
	for mat in Restauracao.faltaNaEtapa(prog, cfg) do
		disponivel[mat] = inventario.contar(p, mat)
	end
	local plano = Restauracao.planejarEntrega(prog, cfg, disponivel)
	if next(plano) == nil then
		enviar(p, id) -- mostra o que falta
		return
	end
	-- paga e registra o progresso NA MESMA transação (nunca um sem o outro)
	local etapaAntes = prog.etapa
	local concluiu, restaurada = false, false
	local pago = inventario.transacao(p, {
		consumir = plano,
		alterarPerfil = function(pf)
			local pr = progressoDe(pf, id)
			concluiu, restaurada = Restauracao.aplicarEntrega(pr, cfg, plano)
			pf.restauracoesProgresso[id] = pr
			if restaurada then
				pf.restauracoes[id] = true
			end
			return true
		end,
	})
	if not pago then
		enviar(p, id)
		return
	end
	if concluiu then
		RestorationSystem.concluiuEtapa.disparar(p, id, etapaAntes + 1)
		ajudar(p, id, etapaAntes + 1, parte.Position)
	end
	if restaurada then
		RestorationSystem.restaurou.disparar(p, id)
		atualizarGlobal(id)
	end
	enviar(p, id)
end

local function prepararEstrutura(parte: BasePart)
	local id = parte:GetAttribute("GuardioesEstrutura")
	if typeof(id) ~= "string" or not Restauracoes.porId[id] or parte:FindFirstChild("GuardioesRestaurar") then
		return
	end
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "GuardioesRestaurar"
	prompt.ActionText = "Restaurar"
	prompt.ObjectText = Restauracoes.porId[id].nome
	prompt.KeyboardKeyCode = Enum.KeyCode.B
	prompt.GamepadKeyCode = Enum.KeyCode.DPadUp
	prompt.HoldDuration = 0.5
	prompt.MaxActivationDistance = 10
	prompt.Parent = parte
	prompt.Triggered:Connect(function(p: Player)
		entregar(p, id, parte)
	end)
end

function RestorationSystem.restaurada(p: Player, id: string): boolean
	local perfil = playerData.obter(p)
	return perfil ~= nil and perfil.restauracoes[id] == true
end

function RestorationSystem.Init(ctx: any)
	ctxSistemas = ctx
	evento = Remotos.evento("Restauracao")
end

function RestorationSystem.Start()
	playerData = ctxSistemas.obter("PlayerDataSystem")
	inventario = ctxSistemas.obter("InventorySystem")
	local existente = Workspace:FindFirstChild("GuardioesEstruturas") :: Folder?
	if existente then
		pasta = existente
	else
		pasta = Instance.new("Folder")
		pasta.Name = "GuardioesEstruturas"
		pasta.Parent = Workspace
	end
	local m = ConfigServidor.marcadoresDeTeste
	if m and m.ativa and ConfigServidor.arenaDeTeste.ativa then
		for _, e in m.estruturas do
			local b = Instance.new("Part")
			b.Name = "Marcador_" .. e.id
			b.Anchored = true
			b.Size = Vector3.new(2, 5, 2)
			b.Color = Color3.fromHex("#5B6B7A")
			b.Material = Enum.Material.Slate
			b.CFrame = CFrame.new(ConfigServidor.arenaDeTeste.centro + e.deslocamento)
			b:SetAttribute("GuardioesEstrutura", e.id)
			b.Parent = pasta
		end
	end
	for _, d in pasta:GetDescendants() do
		if d:IsA("BasePart") then
			prepararEstrutura(d)
		end
	end
	pasta.DescendantAdded:Connect(function(d)
		if d:IsA("BasePart") then
			task.defer(prepararEstrutura, d)
		end
	end)
	Players.PlayerRemoving:Connect(function(p)
		ultimo[p] = nil
		task.defer(function()
			for _, e in Restauracoes.lista do
				atualizarGlobal(e.id)
			end
		end)
	end)
end

return RestorationSystem
