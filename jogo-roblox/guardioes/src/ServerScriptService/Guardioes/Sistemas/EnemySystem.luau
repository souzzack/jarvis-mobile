--!strict
-- NÃO EXECUTADO NO STUDIO. EnemySystem (protótipo da Etapa C): criaturas definidas em Config/Inimigos.
-- Vida e postura são do SERVIDOR (atributos replicam para as barras do cliente; o Humanoid só move o corpo).
-- IA: um único laço a 10 Hz para todas as criaturas; quem está longe de todos os jogadores dorme.
-- Estados: Ocioso → Perseguir → Telegrafar → Impacto → Recuperar → Perseguir … · Atordoado · Retornar · Morto

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local G = ReplicatedStorage:WaitForChild("Guardioes")
local CfgCombate = require(G.Config.Combate)
local Dano = require(G.Combate.Dano)
local Postura = require(G.Combate.Postura)
local Alcance = require(G.Combate.Alcance)
local Sinal = require(G.Util.Sinal)
local Remotos = require(G.Rede.Remotos)
local ConfigServidor = require(script.Parent.Parent.ConfigServidor)

type Ataque = { nome: string, peso: number, telegrafia: number, impacto: number, recuperacao: number, alcance: number, arcoGraus: number, dano: number, postura: number, avanco: number }

type Inimigo = {
	id: string,
	cfg: any,
	modelo: Model,
	raiz: BasePart,
	humanoid: Humanoid?,
	vida: number,
	postura: Postura.Postura,
	estado: string,
	desde: number,
	ataque: Ataque?,
	alvo: Player?,
	surgimento: CFrame,
	proximoAtaque: number,
	atordoadoAte: number,
	atingidos: { [Player]: boolean },
	contribuicao: { [Player]: number },
	invulneravel: boolean?, -- fases de chefe (BossSystem)
}

local EnemySystem = { Nome = "EnemySystem" }
EnemySystem.morreu = Sinal.novo() -- (inimigo, contribuicao): o LootSystem (Etapa E) escuta aqui
EnemySystem.aparado = Sinal.novo() -- (inimigoId, jogador): um golpe desta criatura foi APARADO (mecânicas de chefe)

local configs: { [string]: any } = {}
local ativos: { [string]: Inimigo } = {}
local pasta: Folder
local evento: RemoteEvent
local combate: any
local contador = 0
local ctxSalvo: any = nil
local E = Remotos.EventoCombate

local function carregarConfigs()
	for _, mod in G.Config.Inimigos:GetChildren() do
		if mod:IsA("ModuleScript") then
			local c = require(mod) :: any
			configs[c.id] = c
		end
	end
end

-- modelo sem asset externo: raiz + corpo visível + Humanoid (se anda). Arte final entra no lugar sem mudar a lógica.
local function criarModelo(cfg: any, onde: CFrame, id: string): (Model, BasePart, Humanoid?)
	local m = Instance.new("Model")
	m.Name = cfg.id
	local raiz = Instance.new("Part")
	raiz.Name = "HumanoidRootPart"
	raiz.Size = Vector3.new(cfg.raiz2 or 2, cfg.altura * 0.6, cfg.raiz2 or 2)
	raiz.Transparency = 1
	raiz.CanCollide = false
	raiz.CFrame = onde
	raiz.Parent = m
	local corpo = Instance.new("Part")
	corpo.Name = "Corpo"
	corpo.Shape = if cfg.categoria == "Teste" then Enum.PartType.Cylinder else Enum.PartType.Ball
	corpo.Size = if cfg.categoria == "Teste" then Vector3.new(cfg.altura, cfg.raio * 2, cfg.raio * 2) else Vector3.new(cfg.raio * 2, cfg.raio * 2, cfg.raio * 2)
	corpo.CFrame = if cfg.categoria == "Teste" then onde * CFrame.Angles(0, 0, math.rad(90)) else onde
	corpo.Color = Color3.fromHex(cfg.cor)
	corpo.Material = if cfg.categoria == "Teste" then Enum.Material.Wood else Enum.Material.Glass
	corpo.CanCollide = true
	corpo.Parent = m
	local solda = Instance.new("WeldConstraint")
	solda.Part0 = raiz
	solda.Part1 = corpo
	solda.Parent = raiz
	m.PrimaryPart = raiz
	local hum: Humanoid? = nil
	if cfg.ia.velocidade > 0 then
		local h = Instance.new("Humanoid")
		h.WalkSpeed = cfg.ia.velocidade
		h.HipHeight = cfg.altura * 0.5
		h.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		h.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
		h.BreakJointsOnDeath = false
		h.Parent = m
		hum = h
	else
		raiz.Anchored = true
		corpo.Anchored = true
	end
	m:SetAttribute("GuardioesId", id)
	m:SetAttribute("Nome", cfg.nome)
	m:SetAttribute("VidaMax", cfg.vida)
	m:SetAttribute("Vida", cfg.vida)
	m:SetAttribute("PosturaMax", cfg.postura)
	m:SetAttribute("Postura", 0)
	m.Parent = pasta
	if hum then
		raiz:SetNetworkOwner(nil) -- física da criatura é do servidor
	end
	return m, raiz, hum
end

local function surgir(cfgId: string, onde: CFrame): Inimigo?
	local cfg = configs[cfgId]
	if not cfg then
		warn("[Guardioes] inimigo sem configuração: " .. cfgId)
		return nil
	end
	local n = 0
	for _ in ativos do
		n += 1
	end
	if n >= ConfigServidor.maxInimigosAtivos then
		return nil
	end
	contador += 1
	local id = "e" .. contador
	local modelo, raiz, hum = criarModelo(cfg, onde, id)
	local agora = os.clock()
	local ini: Inimigo = {
		id = id, cfg = cfg, modelo = modelo, raiz = raiz, humanoid = hum, vida = cfg.vida,
		postura = Postura.nova(cfg.postura, agora), estado = "Ocioso", desde = agora, ataque = nil, alvo = nil,
		surgimento = onde, proximoAtaque = agora, atordoadoAte = -math.huge, atingidos = {}, contribuicao = {},
	}
	ativos[id] = ini
	return ini
end

local function jogadorVivo(p: Player): (BasePart?, Humanoid?)
	local ch = p.Character
	if not ch then
		return nil, nil
	end
	local hrp = ch:FindFirstChild("HumanoidRootPart") :: BasePart?
	local h = ch:FindFirstChildOfClass("Humanoid")
	if hrp and h and h.Health > 0 then
		return hrp, h
	end
	return nil, nil
end

local function maisProximo(pos: Vector3, raio: number): (Player?, number)
	local melhor: Player? = nil
	local dMin = raio
	for _, p in Players:GetPlayers() do
		local hrp = jogadorVivo(p)
		if hrp then
			local d = (hrp.Position - pos).Magnitude
			if d < dMin then
				melhor, dMin = p, d
			end
		end
	end
	return melhor, dMin
end

local function escolherAtaque(cfg: any): Ataque?
	local total = 0
	for _, a in cfg.ataques do
		total += a.peso
	end
	if total <= 0 then
		return nil
	end
	local r = math.random() * total
	for _, a in cfg.ataques do
		r -= a.peso
		if r <= 0 then
			return a
		end
	end
	return cfg.ataques[#cfg.ataques]
end

local function atualizarAtributos(ini: Inimigo)
	ini.modelo:SetAttribute("Vida", math.max(0, ini.vida))
	ini.modelo:SetAttribute("Postura", ini.postura.acumulada)
	ini.modelo:SetAttribute("Estado", ini.estado)
end

local function mudar(ini: Inimigo, estado: string, agora: number)
	ini.estado = estado
	ini.desde = agora
	atualizarAtributos(ini)
end

local function parar(ini: Inimigo)
	if ini.humanoid then
		ini.humanoid:MoveTo(ini.raiz.Position)
	end
end

local function olharPara(ini: Inimigo, alvo: Vector3)
	local p = ini.raiz.Position
	local plano = Vector3.new(alvo.X, p.Y, alvo.Z)
	if (plano - p).Magnitude > 0.05 then
		ini.raiz.CFrame = CFrame.lookAt(p, plano)
	end
end

local function morrer(ini: Inimigo, agora: number)
	mudar(ini, "Morto", agora)
	parar(ini)
	evento:FireAllClients(E.INIMIGO_MORREU, ini.id)
	EnemySystem.morreu.disparar(ini, ini.contribuicao)
	local cfgId, onde, retorno = ini.cfg.id, ini.surgimento, ini.cfg.retornoSeg
	if not retorno then -- chefes e mecanismos: quem decide se volta é o BossSystem
		task.delay(1.5, function()
			ini.modelo:Destroy()
			ativos[ini.id] = nil
		end)
		return
	end
	task.delay(1.5, function()
		ini.modelo:Destroy()
		ativos[ini.id] = nil
	end)
	task.delay(retorno, function()
		surgir(cfgId, onde)
	end)
end

local function atordoar(ini: Inimigo, agora: number)
	ini.atordoadoAte = agora + CfgCombate.postura.atordoamento
	ini.ataque = nil
	parar(ini)
	mudar(ini, "Atordoado", agora)
end

-- ----------------------------------------------------------------- golpes do jogador nas criaturas
export type GolpeRecebido = { dano: number, postura: number, bonusPostura: number, multiplicador: number, atacante: Player }

function EnemySystem.receberGolpe(id: string, g: GolpeRecebido): any?
	local ini = ativos[id]
	if not ini or ini.estado == "Morto" then
		return nil
	end
	if ini.invulneravel then
		return { tipo = "Imune", dano = 0, posturaNoAlvo = 0, estaminaDoAlvo = 0, posturaNoAtacante = 0 }
	end
	local agora = os.clock()
	local r = Dano.resolver({
		danoBase = g.dano, multiplicador = g.multiplicador, defesaAlvo = ini.cfg.defesa,
		alvoAtordoado = ini.estado == "Atordoado", bonusAtordoado = CfgCombate.postura.bonusDanoAtordoado,
		postura = g.postura, bonusPostura = g.bonusPostura,
		alvoInvulneravel = false, alvoAparando = false, alvoDefendendo = false, frontal = false,
		reducaoDefesa = 0, custoEstaminaPorDano = 0, posturaAparar = 0,
	})
	ini.vida -= r.dano
	ini.contribuicao[g.atacante] = (ini.contribuicao[g.atacante] or 0) + r.dano
	if ini.estado ~= "Atordoado" and Postura.receber(ini.postura, CfgCombate.postura, r.posturaNoAlvo, agora) then
		atordoar(ini, agora)
	end
	-- golpe provoca: a criatura passa a perseguir quem bateu
	if ini.estado == "Ocioso" or ini.estado == "Retornar" then
		ini.alvo = g.atacante
		mudar(ini, "Perseguir", agora)
	end
	atualizarAtributos(ini)
	if ini.vida <= 0 then
		morrer(ini, agora)
	end
	return r
end

export type Proximo = { id: string, posicao: Vector3, raio: number }

-- ----------------------------------------------------------------- API para chefes e mecanismos (servidor)
function EnemySystem.surgirEm(cfgId: string, onde: CFrame): string?
	local ini = surgir(cfgId, onde)
	return if ini then ini.id else nil
end

function EnemySystem.definirInvulneravel(id: string, v: boolean)
	local ini = ativos[id]
	if ini then
		ini.invulneravel = v
		ini.modelo:SetAttribute("Imune", v)
	end
end

-- derruba por um tempo (janela de dano do chefe); dano recebido atordoado já tem o bônus de +30%
function EnemySystem.atordoarPor(id: string, duracao: number)
	local ini = ativos[id]
	if ini and ini.estado ~= "Morto" then
		local agora = os.clock()
		atordoar(ini, agora)
		ini.atordoadoAte = agora + duracao
	end
end

function EnemySystem.info(id: string): { vida: number, vidaMax: number, posicao: Vector3, estado: string }?
	local ini = ativos[id]
	if not ini then
		return nil
	end
	return { vida = ini.vida, vidaMax = ini.cfg.vida, posicao = ini.raiz.Position, estado = ini.estado }
end

-- teleporte decidido pelo servidor (Espectro entre as lentes); a IA continua de onde está
function EnemySystem.teleportar(id: string, onde: CFrame)
	local ini = ativos[id]
	if ini and ini.estado ~= "Morto" then
		ini.modelo:PivotTo(onde)
	end
end

-- some sem morrer (sem saque, sem missão): pilares que sobraram, chefe resetado
function EnemySystem.remover(id: string)
	local ini = ativos[id]
	if ini then
		ativos[id] = nil
		ini.modelo:Destroy()
	end
end

function EnemySystem.proximos(pos: Vector3, raio: number): { Proximo }
	local lista: { Proximo } = {}
	for id, ini in ativos do
		if ini.estado ~= "Morto" then
			local p = ini.raiz.Position
			if (p - pos).Magnitude <= raio + ini.cfg.raio then
				table.insert(lista, { id = id, posicao = p, raio = ini.cfg.raio })
			end
		end
	end
	return lista
end

-- ----------------------------------------------------------------- IA
local function impacto(ini: Inimigo, a: Ataque)
	local p = ini.raiz.Position
	local f = ini.raiz.CFrame.LookVector
	for _, pl in Players:GetPlayers() do
		if not ini.atingidos[pl] then
			local hrp = jogadorVivo(pl)
			if hrp and math.abs(hrp.Position.Y - p.Y) <= 6 and Alcance.noArco(p.X, p.Z, f.X, f.Z, hrp.Position.X, hrp.Position.Z, a.alcance, a.arcoGraus, 1.2) then
				ini.atingidos[pl] = true
				local r = combate.danoAoJogador(pl, p, { dano = a.dano, postura = a.postura }, ini.id)
				if r and r.tipo == "Aparado" then
					EnemySystem.aparado.disparar(ini.id, pl)
				end
				if r and r.tipo == "Aparado" and r.posturaNoAtacante > 0 then
					if Postura.receber(ini.postura, CfgCombate.postura, r.posturaNoAtacante, os.clock()) then
						atordoar(ini, os.clock())
						return
					end
					atualizarAtributos(ini)
				end
			end
		end
	end
	if a.avanco > 0 then
		ini.raiz.AssemblyLinearVelocity = f * (a.avanco / math.max(0.05, a.impacto)) + Vector3.new(0, ini.raiz.AssemblyLinearVelocity.Y, 0)
	end
end

local function pensar(ini: Inimigo, agora: number)
	local cfg = ini.cfg
	if ini.estado == "Morto" or cfg.ia.velocidade <= 0 and #cfg.ataques == 0 then
		return
	end
	Postura.atualizar(ini.postura, CfgCombate.postura, agora)
	local pos = ini.raiz.Position
	if ini.estado == "Atordoado" then
		if agora >= ini.atordoadoAte then
			mudar(ini, "Perseguir", agora)
		end
		return
	end
	if ini.estado == "Ocioso" then
		local alvo = maisProximo(pos, cfg.ia.percepcao)
		if alvo then
			ini.alvo = alvo
			mudar(ini, "Perseguir", agora)
		end
		return
	end
	if ini.estado == "Retornar" then
		if (pos - ini.surgimento.Position).Magnitude < 4 then
			mudar(ini, "Ocioso", agora)
		elseif ini.humanoid then
			ini.humanoid:MoveTo(ini.surgimento.Position)
		end
		return
	end
	local alvo = ini.alvo
	local hrp = if alvo then jogadorVivo(alvo) else nil
	if ini.estado == "Perseguir" then
		if not hrp or (pos - ini.surgimento.Position).Magnitude > cfg.ia.desistir then
			ini.alvo = nil
			mudar(ini, "Retornar", agora)
			return
		end
		local d = ((hrp :: BasePart).Position - pos).Magnitude
		if d <= cfg.ia.distanciaAtaque and agora >= ini.proximoAtaque then
			local a = escolherAtaque(cfg)
			if a then
				ini.ataque = a
				ini.atingidos = {}
				parar(ini)
				olharPara(ini, (hrp :: BasePart).Position)
				mudar(ini, "Telegrafar", agora)
				ini.modelo:SetAttribute("Telegrafando", a.nome)
				evento:FireAllClients(E.TELEGRAFIA, ini.id, a.nome, a.telegrafia)
			end
		elseif ini.humanoid then
			ini.humanoid:MoveTo((hrp :: BasePart).Position)
		end
	elseif ini.estado == "Telegrafar" then
		local a = ini.ataque :: Ataque
		if hrp and agora - ini.desde < a.telegrafia * 0.6 then
			olharPara(ini, (hrp :: BasePart).Position) -- acompanha o alvo só no começo da telegrafia (dá para fugir)
		end
		if agora >= ini.desde + a.telegrafia then
			ini.modelo:SetAttribute("Telegrafando", nil)
			mudar(ini, "Impacto", agora)
			impacto(ini, a)
		end
	elseif ini.estado == "Impacto" then
		local a = ini.ataque :: Ataque
		if agora >= ini.desde + a.impacto then
			mudar(ini, "Recuperar", agora)
		end
	elseif ini.estado == "Recuperar" then
		local a = ini.ataque :: Ataque
		if agora >= ini.desde + a.recuperacao then
			ini.ataque = nil
			ini.proximoAtaque = agora + cfg.ia.intervaloMin
			mudar(ini, "Perseguir", agora)
		end
	end
end

local function acordado(ini: Inimigo): boolean
	if ini.estado ~= "Ocioso" then
		return true
	end
	local _, d = maisProximo(ini.raiz.Position, ConfigServidor.ia.distanciaSono)
	return d < ConfigServidor.ia.distanciaSono
end

function EnemySystem.Init(ctx: any)
	carregarConfigs()
	pasta = Instance.new("Folder")
	pasta.Name = "GuardioesInimigos"
	pasta.Parent = Workspace
	evento = Remotos.evento("Combate")
	ctxSalvo = ctx
end

function EnemySystem.Start()
	combate = ctxSalvo.obter("CombatSystem")
	local surg = Workspace:FindFirstChild(ConfigServidor.pastaSurgimentos)
	local criados = 0
	if surg then
		for _, p in surg:GetDescendants() do
			if p:IsA("BasePart") and p:GetAttribute("GuardioesSurgimento") then
				if surgir(tostring(p:GetAttribute("GuardioesSurgimento")), p.CFrame + Vector3.new(0, 3, 0)) then
					criados += 1
				end
			end
		end
	end
	if criados == 0 and ConfigServidor.arenaDeTeste.ativa then
		local a = ConfigServidor.arenaDeTeste
		for _, e in a.inimigos do
			surgir(e.id, CFrame.new(a.centro + e.deslocamento))
		end
		print("[Guardioes] arena de teste criada em " .. tostring(a.centro))
	end
	local passo = 1 / ConfigServidor.ia.frequenciaHz
	while true do
		local agora = os.clock()
		for _, ini in ativos do
			if acordado(ini) then
				local ok, erro = pcall(pensar, ini, agora)
				if not ok then
					warn("[Guardioes] IA de " .. ini.id .. ": " .. tostring(erro))
				end
			end
		end
		task.wait(passo)
	end
end

return EnemySystem
