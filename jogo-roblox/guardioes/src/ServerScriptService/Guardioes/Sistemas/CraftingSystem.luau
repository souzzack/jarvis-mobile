--!strict
-- NÃO EXECUTADO NO STUDIO. CraftingSystem (Etapa F): fabricar nas estações.
--  * Estação = Part com o atributo "GuardioesEstacao" = id, em workspace.GuardioesEstacoes (no mapa real, um
--    marcador ao lado do modelo; o modelo aprovado não é tocado). Prompt "Fabricar" abre a lista.
--  * FABRICAR(receitaId): o servidor confere receita conhecida, estação por perto (≤ 12 studs), requisitos
--    (restauração…) e materiais; consome e entrega NUMA transação do inventário (tudo ou nada).
--  * aprenderReceita(p, id): só servidor (primeira vitória contra miniboss, missões, segredos). Salva no perfil.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local G = ReplicatedStorage:WaitForChild("Guardioes")
local Receitas = require(G.Config.Receitas)
local Receita = require(G.Fabricacao.Receita)
local Requisitos = require(G.Util.Requisitos)
local LimiteDeTaxa = require(G.Util.LimiteDeTaxa)
local Sinal = require(G.Util.Sinal)
local Remotos = require(G.Rede.Remotos)
local ConfigServidor = require(script.Parent.Parent.ConfigServidor)

local F = Remotos.Fabricacao
local EF = Remotos.EventoFabricacao
local DISTANCIA_ESTACAO = 12

local CraftingSystem = { Nome = "CraftingSystem" }
CraftingSystem.fabricou = Sinal.novo() -- (p, receitaId)

local evento: RemoteEvent
local playerData: any
local inventario: any
local ctxSistemas: any = nil
local pasta: Folder
local baldes: { [Player]: LimiteDeTaxa.Balde } = {}

-- estações por perto: id → maior nível. Estação com atributo "Dono" só vale para o dono (Forja da base).
local function estacoesPerto(p: Player): { [string]: number }
	local perto: { [string]: number } = {}
	local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not hrp then
		return perto
	end
	for _, d in pasta:GetDescendants() do
		if d:IsA("BasePart") then
			local id = d:GetAttribute("GuardioesEstacao")
			local dono = d:GetAttribute("Dono")
			if typeof(id) == "string" and (dono == nil or dono == p.UserId) and (d.Position - (hrp :: BasePart).Position).Magnitude <= DISTANCIA_ESTACAO then
				local nivel = (d:GetAttribute("Nivel") :: number?) or 1
				perto[id] = math.max(perto[id] or 0, nivel)
			end
		end
	end
	return perto
end

local function contexto(p: Player, receita: any, perfil: any): Receita.Contexto
	local okReq, faltas = Requisitos.avaliar(receita.requisitos or {}, Requisitos.unir({ restauracoes = perfil.restauracoes, missoes = perfil.missoes }))
	local materiais = {}
	for id in receita.materiais do
		materiais[id] = inventario.contar(p, id)
	end
	return { conhecidas = perfil.receitas, estacoesPerto = estacoesPerto(p), requisitosOk = okReq, faltasDeRequisito = faltas, materiais = materiais }
end

local function enviarLista(p: Player, estacaoId: string?)
	local perfil = playerData.obter(p)
	if not perfil then
		return
	end
	local lista = {}
	for _, r in Receitas.lista do
		-- receitas desconhecidas não aparecem (nada de spoiler); conhecidas aparecem com o que falta
		if Receita.conhecida(r, perfil.receitas) and (estacaoId == nil or r.estacao == estacaoId) then
			local pode, faltando = Receita.avaliar(r, contexto(p, r, perfil))
			table.insert(lista, { id = r.id, nome = r.nome, pode = pode, faltando = faltando, materiais = r.materiais, resultado = r.resultado })
		end
	end
	evento:FireClient(p, EF.LISTA, estacaoId, lista)
end

local function fabricar(p: Player, receitaId: string)
	local r = Receitas.porId[receitaId]
	local perfil = playerData.obter(p)
	if not r or not perfil then
		return
	end
	local pode, _, consumir = Receita.avaliar(r, contexto(p, r, perfil))
	if not pode then
		evento:FireClient(p, EF.REJEITADO, receitaId, "faltaRequisito")
		enviarLista(p, r.estacao)
		return
	end
	local t: any = { consumir = consumir }
	if r.resultado.tipo == "material" then
		t.darMateriais = { [r.resultado.id] = r.resultado.qtd }
	elseif r.resultado.tipo == "equipamento" then
		t.darEquipamento = r.resultado.id
	elseif r.resultado.tipo == "artefato" then
		t.darArtefato = { id = r.resultado.id, estagio = r.resultado.estagio }
	end
	local ok = inventario.transacao(p, t)
	if not ok then
		evento:FireClient(p, EF.REJEITADO, receitaId, "faltaRequisito")
		return
	end
	evento:FireClient(p, EF.FEITO, r.nome)
	CraftingSystem.fabricou.disparar(p, receitaId)
	enviarLista(p, r.estacao)
end

function CraftingSystem.aprenderReceita(p: Player, receitaId: string): boolean
	if not Receitas.porId[receitaId] then
		return false
	end
	local novo = false
	local ok = playerData.atualizar(p, function(perfil)
		if perfil.receitas[receitaId] then
			return false
		end
		perfil.receitas[receitaId] = true
		novo = true
		return true
	end)
	return ok and novo
end

local function prepararEstacao(parte: BasePart)
	local id = parte:GetAttribute("GuardioesEstacao")
	if typeof(id) ~= "string" or parte:FindFirstChild("GuardioesFabricar") then
		return
	end
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "GuardioesFabricar"
	prompt.ActionText = "Fabricar"
	prompt.ObjectText = "Estação"
	prompt.KeyboardKeyCode = Enum.KeyCode.B
	prompt.GamepadKeyCode = Enum.KeyCode.DPadUp
	prompt.MaxActivationDistance = 10
	prompt.Parent = parte
	prompt.Triggered:Connect(function(p: Player)
		local dono = parte:GetAttribute("Dono")
		if dono ~= nil and dono ~= p.UserId then
			evento:FireClient(p, EF.REJEITADO, "", "naoEhSua")
			return
		end
		enviarLista(p, id)
	end)
end

function CraftingSystem.Init(ctx: any)
	ctxSistemas = ctx
	evento = Remotos.evento("Fabricacao")
end

function CraftingSystem.Start()
	playerData = ctxSistemas.obter("PlayerDataSystem")
	inventario = ctxSistemas.obter("InventorySystem")
	local existente = Workspace:FindFirstChild("GuardioesEstacoes") :: Folder?
	if existente then
		pasta = existente
	else
		pasta = Instance.new("Folder")
		pasta.Name = "GuardioesEstacoes"
		pasta.Parent = Workspace
	end
	local m = ConfigServidor.marcadoresDeTeste
	if m and m.ativa and ConfigServidor.arenaDeTeste.ativa then
		for _, e in m.estacoes do
			local b = Instance.new("Part")
			b.Name = "Bancada_" .. e.id
			b.Anchored = true
			b.Size = Vector3.new(5, 3, 3)
			b.Color = Color3.fromHex("#8A6A4A")
			b.CFrame = CFrame.new(ConfigServidor.arenaDeTeste.centro + e.deslocamento)
			b:SetAttribute("GuardioesEstacao", e.id)
			b.Parent = pasta
		end
	end
	for _, d in pasta:GetDescendants() do
		if d:IsA("BasePart") then
			prepararEstacao(d)
		end
	end
	pasta.DescendantAdded:Connect(function(d)
		if d:IsA("BasePart") then
			task.defer(prepararEstacao, d)
		end
	end)
	evento.OnServerEvent:Connect(function(p: Player, tipo: any, receitaId: any)
		local b = baldes[p]
		if not b then
			b = LimiteDeTaxa.novo(5, 2, os.clock())
			baldes[p] = b
		end
		if tipo == F.FABRICAR and typeof(receitaId) == "string" and #receitaId <= 64 and LimiteDeTaxa.consumir(b, os.clock()) then
			fabricar(p, receitaId)
		end
	end)
	Players.PlayerRemoving:Connect(function(p)
		baldes[p] = nil
	end)
end

return CraftingSystem
