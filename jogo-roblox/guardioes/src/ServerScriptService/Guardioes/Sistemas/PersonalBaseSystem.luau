--!strict
-- NÃO EXECUTADO NO STUDIO. PersonalBaseSystem (Etapa H, GDD 9 — fase 1).
--  * Cada jogador recebe uma PARCELA livre do servidor (Parts com "GuardioesParcela" em workspace.GuardioesParcelas;
--    no place real, os terrenos do tycoon recebem esse atributo — docs/04). Os NÍVEIS da base ficam no perfil
--    (perfil.base), então a base volta igual em qualquer parcela/servidor.
--  * Espaços: Forja e Bancada (estações com Dono e Nível → CraftingSystem), Jardim (colheita com teto),
--    Expositor (troféus de chefes) e Depósito (capacidade de equipamentos, conferida no InventorySystem). Prompts: "Melhorar" (N) em cada placa; "Colher" no Jardim; "Fabricar" na Forja.
--  * Melhorar = transação atômica do inventário (consome e sobe o nível juntos).
--  * Visual PROVISÓRIO (blocos que crescem com o nível); modelos reais (e o galpão/funcionários migrados do
--    tycoon) entram com o Studio. Nenhum modelo existente é tocado.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local G = ReplicatedStorage:WaitForChild("Guardioes")
local BaseLogica = require(G.Base.Base)
local Eq = require(G.Equipamento.Equipamento)
local CfgBase = require(G.Config.Base)
local Sinal = require(G.Util.Sinal)
local Remotos = require(G.Rede.Remotos)
local ConfigServidor = require(script.Parent.Parent.ConfigServidor)

local EB = Remotos.EventoBase

local PersonalBaseSystem = { Nome = "PersonalBaseSystem" }
PersonalBaseSystem.melhorou = Sinal.novo() -- (p, espacoId, nivel)

local evento: RemoteEvent
local playerData: any
local inventario: any
local progressao: any
local ctxSistemas: any = nil
local pastaParcelas: Folder
local pastaEstacoes: Folder
local parcelaDe: { [Player]: BasePart } = {}
local modeloDe: { [Player]: Model } = {}
local ultimoUso: { [Player]: number } = {}

local CORES: { [string]: string } = { Forja = "#B4553A", Jardim = "#5DBB63", Expositor = "#C9B26B", Bancada = "#8A6A4A", Deposito = "#5A6478" }
-- espaços que são ESTAÇÕES de fabricação da base (só o dono usa; CraftingSystem lê Dono e Nível)
local ESTACOES: { [string]: boolean } = { Forja = true, Bancada = true }
local rotuloDeposito: { [Player]: TextLabel } = {}

local function textoDeposito(perfil: any): string
	local n = Eq.contarNoDeposito(perfil.equipamentos)
	return string.format("Equipamentos %d/%d", n, BaseLogica.capacidadeDoDeposito(perfil.base, CfgBase.espacos.Deposito))
end

local function textoBase(p: Player, perfil: any): any
	local espacos = {}
	for id, cfg in CfgBase.espacos do
		local n = BaseLogica.nivel(perfil.base, id, cfg)
		table.insert(espacos, { id = id, nome = cfg.nome, nivel = n, max = cfg.max, funcao = cfg.funcao })
	end
	local trofeus = {}
	for id in perfil.base.trofeus do
		table.insert(trofeus, id)
	end
	return { espacos = espacos, trofeus = trofeus, temParcela = parcelaDe[p] ~= nil }
end

local function enviar(p: Player)
	local perfil = playerData.obter(p)
	if perfil then
		evento:FireClient(p, EB.ESTADO, textoBase(p, perfil))
	end
end

local function cooldown(p: Player): boolean
	local agora = os.clock()
	if agora - (ultimoUso[p] or -math.huge) < 0.8 then
		return false
	end
	ultimoUso[p] = agora
	return true
end

-- ------------------------------------------------------------------ visual provisório
local construir: (Player) -> ()

local function prompt(pai: BasePart, nome: string, texto: string, objeto: string, tecla: Enum.KeyCode, fn: (Player) -> ())
	local pp = Instance.new("ProximityPrompt")
	pp.Name = nome
	pp.ActionText = texto
	pp.ObjectText = objeto
	pp.KeyboardKeyCode = tecla
	pp.GamepadKeyCode = if tecla == Enum.KeyCode.N then Enum.KeyCode.ButtonSelect else Enum.KeyCode.DPadUp
	pp.MaxActivationDistance = 9
	pp.HoldDuration = 0.3
	pp.Parent = pai
	pp.Triggered:Connect(function(quem: Player)
		fn(quem)
	end)
end

local function melhorar(dono: Player, quem: Player, espacoId: string)
	if quem ~= dono then
		evento:FireClient(quem, EB.REJEITADO, "naoEhSua", {})
		return
	end
	if not cooldown(quem) then
		return
	end
	local perfil = playerData.obter(quem)
	local cfg = CfgBase.espacos[espacoId]
	if not perfil or not cfg then
		return
	end
	local atual = BaseLogica.nivel(perfil.base, espacoId, cfg)
	local proximo = cfg.niveis and cfg.niveis[atual + 1]
	local materiais = {}
	for id in (proximo and proximo.materiais) or {} do
		materiais[id] = inventario.contar(quem, id)
	end
	local pode, faltando, consumir = BaseLogica.avaliarMelhoria(cfg, atual, progressao.nivel(quem), materiais)
	if not pode then
		evento:FireClient(quem, EB.REJEITADO, espacoId, faltando)
		return
	end
	local ok = inventario.transacao(quem, {
		consumir = consumir,
		alterarPerfil = function(pf)
			if BaseLogica.nivel(pf.base, espacoId, cfg) ~= atual then
				return false -- outra mudança chegou antes: não paga duas vezes
			end
			pf.base.espacos[espacoId] = atual + 1
			return true
		end,
	})
	if ok then
		evento:FireClient(quem, EB.MELHOROU, cfg.nome, atual + 1)
		PersonalBaseSystem.melhorou.disparar(quem, espacoId, atual + 1)
		construir(quem)
		enviar(quem)
	end
end

local function colher(dono: Player, quem: Player)
	if quem ~= dono or not cooldown(quem) then
		return
	end
	local perfil = playerData.obter(quem)
	if not perfil then
		return
	end
	local cfg = CfgBase.espacos.Jardim
	local nivel = BaseLogica.nivel(perfil.base, "Jardim", cfg)
	local agora = os.time()
	local qtd, novoRelogio = BaseLogica.colheita(nivel, perfil.base.jardimColhidoEm, agora, cfg.producao.porNivelPorHora, cfg.producao.teto)
	if qtd <= 0 then
		evento:FireClient(quem, EB.COLHEU, {}, cfg.producao.teto)
		return
	end
	local itens = BaseLogica.repartir(qtd, cfg.producao.materiais)
	local antes = perfil.base.jardimColhidoEm
	local ok = inventario.transacao(quem, {
		darMateriais = itens,
		alterarPerfil = function(pf)
			if pf.base.jardimColhidoEm ~= antes then
				return false -- colheita dupla (dois toques ao mesmo tempo): só a primeira vale
			end
			pf.base.jardimColhidoEm = novoRelogio
			return true
		end,
	})
	if ok then
		evento:FireClient(quem, EB.COLHEU, itens, cfg.producao.teto)
	end
end

construir = function(p: Player)
	local parcela = parcelaDe[p]
	local perfil = playerData.obter(p)
	if not parcela or not perfil then
		return
	end
	if modeloDe[p] then
		modeloDe[p]:Destroy()
	end
	for _, d in pastaEstacoes:GetChildren() do
		if d:GetAttribute("Dono") == p.UserId then
			d:Destroy()
		end
	end
	local m = Instance.new("Model")
	m.Name = "Base_" .. p.UserId
	local centro = parcela.CFrame * CFrame.new(0, parcela.Size.Y / 2, 0)
	-- parcela ligada a um terreno do tycoon: usa o pátio da frente (o galpão continua do tycoon)
	local layout = if parcela:GetAttribute("LayoutDaBase") == "Frente" then CfgBase.layoutFrente else CfgBase.layout
	for id, cfg in CfgBase.espacos do
		local n = BaseLogica.nivel(perfil.base, id, cfg)
		local pos = layout[id] or { 0, 0, 0 }
		local onde = centro * CFrame.new(pos[1], pos[2], pos[3])
		local bloco = Instance.new("Part")
		bloco.Name = id
		bloco.Anchored = true
		bloco.Size = Vector3.new(4 + n, 2 + n * 0.6, 4 + n)
		bloco.CFrame = onde * CFrame.new(0, bloco.Size.Y / 2, 0)
		bloco.Color = Color3.fromHex(CORES[id] or "#888888")
		bloco.Parent = if ESTACOES[id] then pastaEstacoes else m
		if ESTACOES[id] then
			-- estação da base: só o dono usa (CraftingSystem lê Dono e Nível)
			bloco:SetAttribute("GuardioesEstacao", id)
			bloco:SetAttribute("Dono", p.UserId)
			bloco:SetAttribute("Nivel", n)
		elseif id == "Jardim" then
			prompt(bloco, "GuardioesColher", "Colher", cfg.nome, Enum.KeyCode.B, function(quem)
				colher(p, quem)
			end)
		elseif id == "Deposito" then
			local g = Instance.new("BillboardGui")
			g.Size = UDim2.fromOffset(140, 24)
			g.StudsOffset = Vector3.new(0, bloco.Size.Y / 2 + 1.5, 0)
			g.MaxDistance = 40
			local t = Instance.new("TextLabel")
			t.Size = UDim2.fromScale(1, 1)
			t.BackgroundTransparency = 1
			t.TextScaled = true
			t.Font = Enum.Font.GothamBold
			t.TextColor3 = Color3.new(1, 1, 1)
			t.Text = textoDeposito(perfil)
			t.Parent = g
			rotuloDeposito[p] = t
			g.Parent = bloco
		elseif id == "Expositor" then
			local i = 0
			for trofeu in perfil.base.trofeus do
				i += 1
				local t = Instance.new("Part")
				t.Name = "Trofeu_" .. trofeu
				t.Anchored = true
				t.Size = Vector3.new(1, 1.6, 1)
				t.Material = Enum.Material.Neon
				t.Color = Color3.fromHex(if trofeu == "RainhaBobina" then "#B88CFF" else "#3E5BFF")
				t.CFrame = bloco.CFrame * CFrame.new(-1.5 + (i - 1) * 1.5, bloco.Size.Y / 2 + 0.8, 0)
				t.Parent = m
			end
		end
		-- placa com "Melhorar" (separada do bloco para não disputar a mesma tecla)
		local placa = Instance.new("Part")
		placa.Name = "Placa_" .. id
		placa.Anchored = true
		placa.Size = Vector3.new(2, 2.5, 0.3)
		placa.Color = Color3.fromHex("#4A3B2C")
		placa.CFrame = onde * CFrame.new(0, 1.25, bloco.Size.Z / 2 + 1.5)
		placa.Parent = m
		prompt(placa, "GuardioesMelhorar", string.format("Melhorar (nv %d/%d)", n, cfg.max), cfg.nome, Enum.KeyCode.N, function(quem)
			melhorar(p, quem, id)
		end)
	end
	local letreiro = Instance.new("BillboardGui")
	letreiro.Size = UDim2.fromOffset(200, 30)
	letreiro.StudsOffset = Vector3.new(0, 8, 0)
	letreiro.Adornee = parcela
	letreiro.MaxDistance = 120
	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundTransparency = 1
	t.TextScaled = true
	t.Font = Enum.Font.GothamBold
	t.TextColor3 = Color3.new(1, 1, 1)
	t.TextStrokeTransparency = 0.4
	t.Text = "Base de " .. p.DisplayName
	t.Parent = letreiro
	letreiro.Parent = m
	m.Parent = Workspace
	modeloDe[p] = m
end

-- ------------------------------------------------------------------ API
function PersonalBaseSystem.parcela(p: Player): BasePart?
	return parcelaDe[p]
end

-- troféu de chefe (BossSystem): uma vez por chefe, salvo
function PersonalBaseSystem.darTrofeu(p: Player, chefeId: string): boolean
	local novo = false
	playerData.atualizar(p, function(pf)
		if pf.base.trofeus[chefeId] then
			return false
		end
		pf.base.trofeus[chefeId] = true
		novo = true
		return true
	end)
	if novo then
		construir(p)
		enviar(p)
	end
	return novo
end

function PersonalBaseSystem.nivelDe(p: Player, espacoId: string): number
	local perfil = playerData.obter(p)
	local cfg = CfgBase.espacos[espacoId]
	return if perfil and cfg then BaseLogica.nivel(perfil.base, espacoId, cfg) else 0
end

function PersonalBaseSystem.Init(ctx: any)
	ctxSistemas = ctx
	evento = Remotos.evento("Base")
end

function PersonalBaseSystem.Start()
	playerData = ctxSistemas.obter("PlayerDataSystem")
	inventario = ctxSistemas.obter("InventorySystem")
	progressao = ctxSistemas.obter("ProgressionSystem")
	pastaEstacoes = (Workspace:FindFirstChild("GuardioesEstacoes") or Workspace:WaitForChild("GuardioesEstacoes", 10)) :: Folder
	local existente = Workspace:FindFirstChild("GuardioesParcelas") :: Folder?
	if existente then
		pastaParcelas = existente
	else
		pastaParcelas = Instance.new("Folder")
		pastaParcelas.Name = "GuardioesParcelas"
		pastaParcelas.Parent = Workspace
	end
	local temParcela = false
	for _, d in pastaParcelas:GetDescendants() do
		if d:IsA("BasePart") and d:GetAttribute("GuardioesParcela") then
			temParcela = true
		end
	end
	if not temParcela and ConfigServidor.arenaDeTeste.ativa then
		for i, desloc in ConfigServidor.parcelasDeTeste do
			local par = Instance.new("Part")
			par.Name = "ParcelaDeTeste" .. i
			par.Anchored = true
			par.Size = Vector3.new(36, 1, 36)
			par.Color = Color3.fromHex("#6E7F5A")
			par.Material = Enum.Material.Grass
			par.CFrame = CFrame.new(ConfigServidor.arenaDeTeste.centro + desloc + Vector3.new(0, -3.5, 0))
			par:SetAttribute("GuardioesParcela", i)
			par.Parent = pastaParcelas
		end
	end
	-- Parcelas ligadas ao tycoon têm o atributo TerrenoTycoon (= nome do terreno). O jogador recebe a parcela do
	-- MESMO terreno que o tycoon deu a ele (atributo "Terreno" do jogador), para os dois nunca ficarem em terrenos
	-- diferentes. Sem tycoon (ou sem resposta dele em alguns segundos), vale a menor parcela livre.
	local function livre(p: Player): BasePart?
		local ocupadas: { [BasePart]: boolean } = {}
		for _, b in parcelaDe do
			ocupadas[b] = true
		end
		local ligadas = false
		for _, d in pastaParcelas:GetDescendants() do
			if d:IsA("BasePart") and d:GetAttribute("TerrenoTycoon") then
				ligadas = true
				break
			end
		end
		if ligadas then
			local terreno = p:GetAttribute("Terreno")
			local t0 = os.clock()
			while terreno == nil and p.Parent and os.clock() - t0 < 8 do
				task.wait(0.25)
				terreno = p:GetAttribute("Terreno")
			end
			if terreno ~= nil then
				for _, d in pastaParcelas:GetDescendants() do
					if d:IsA("BasePart") and not ocupadas[d] and d:GetAttribute("TerrenoTycoon") == terreno then
						return d
					end
				end
			end
		end
		local melhor: BasePart? = nil
		local menor = math.huge
		for _, d in pastaParcelas:GetDescendants() do
			if d:IsA("BasePart") and not ocupadas[d] then
				local n = d:GetAttribute("GuardioesParcela")
				if typeof(n) == "number" and n < menor then
					melhor, menor = d, n
				end
			end
		end
		return melhor
	end
	playerData.carregado.conectar(function(p: Player)
		-- em tarefa própria: livre() pode esperar alguns segundos pelo terreno do tycoon, e os ouvintes do
		-- 'carregado' rodam em sequência (os outros sistemas não podem ficar esperando)
		task.spawn(function()
		local par = livre(p)
		if not p.Parent then
			return
		end
		-- enquanto esperava, outro jogador pode ter ficado com esta parcela: escolhe de novo (já sem espera)
		for _, outra in parcelaDe do
			if outra == par then
				par = livre(p)
				break
			end
		end
		if par then
			parcelaDe[p] = par
			construir(p)
		else
			evento:FireClient(p, EB.REJEITADO, "semBase", {})
		end
		enviar(p)
		end)
	end)
	-- o contador do Depósito acompanha a bolsa (fabricou, desmontou)
	inventario.mudou.conectar(function(p: Player)
		local t = rotuloDeposito[p]
		local perfil = playerData.obter(p)
		if t and t.Parent and perfil then
			t.Text = textoDeposito(perfil)
		end
	end)
	Players.PlayerRemoving:Connect(function(p)
		rotuloDeposito[p] = nil
		if modeloDe[p] then
			modeloDe[p]:Destroy()
		end
		for _, d in pastaEstacoes:GetChildren() do
			if d:GetAttribute("Dono") == p.UserId then
				d:Destroy()
			end
		end
		modeloDe[p], parcelaDe[p], ultimoUso[p] = nil, nil, nil
	end)
end

return PersonalBaseSystem
