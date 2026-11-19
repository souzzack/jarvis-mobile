--!strict
-- NÃO EXECUTADO NO STUDIO. BossSystem (Etapa E): minibosses com fases, cada um com a sua MECÂNICA:
--   "Carga"   → RAINHA-BOBINA (abaixo)
--   "Matilha" → CÃO-TROVÃO ALFA: chama 2 cães em 70% e 40%; a cada ~14 s corre carregado por 4 s (imune);
--               só um APARO de um golpe dele quebra a corrida e o derruba (EnemySystem.aparado).
--   "Tormenta"→ GUARDIÃO DA TORMENTA (Chefes/Tormenta): arena = topo da Torre restaurada; fase 2 com
--               para-raios (ativar o carregado derruba o Guardião); fase 3 com chão eletrificado em padrões.
--   "Nucleo"  → COLOSSO DAS RUÍNAS (Chefes/Colosso): couraça imune; 3 aparos abrem o núcleo por 8 s; pisoteio
--               com onda telegrafada em volta dele.
--   "Lentes"  → ESPECTRO DO OBSERVATÓRIO (Chefes/Espectro): só à noite; teleporta entre 4 lentes; imune,
--               exceto ao reflexo do telescópio (exige o Observatório restaurado).
-- Toda vitória: troféu no Expositor da base de cada participante (PersonalBaseSystem.darTrofeu).
--  * A Rainha usa a IA comum do EnemySystem (perseguir, telegrafar, ferrão/pulso/investida).
--  * Fases de carga (Chefes/CargaDaRainha): em 75%, 50% e 25% de vida ela fica IMUNE e 3 pilares de cristal
--    surgem na arena. Quebrar todos a tempo = Rainha atordoada (dano +30%). Tempo esgotado = DESCARGA em todos
--    na arena (resolvida pelo CombatSystem: dá para esquivar com i-frames ou aparar).
--  * Recompensas: saque e XP pelo LootSystem; missão pelo QuestSystem; ESBOÇO DRUIDA na primeira vitória de
--    cada jogador que contribuiu (CraftingSystem.aprenderReceita).
--  * Retorno: o próprio BossSystem traz a Rainha de volta depois de 'retornoSeg'. Se todos saírem da arena,
--    ela reseta (vida cheia, pilares somem).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local G = ReplicatedStorage:WaitForChild("Guardioes")
local Carga = require(G.Chefes.CargaDaRainha)
local Matilha = require(G.Chefes.MatilhaDoAlfa)
local Tormenta = require(G.Chefes.Tormenta)
local Colosso = require(G.Chefes.Colosso)
local Espectro = require(G.Chefes.Espectro)
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Saque = require(G.Loot.Saque)
local Loot = require(G.Config.Loot)
local Remotos = require(G.Rede.Remotos)
local ConfigServidor = require(script.Parent.Parent.ConfigServidor)

local EC = Remotos.EventoChefe
-- conhecimento aprendido na PRIMEIRA vitória (esboço Druida de miniboss; Códice Arcano do Guardião)
local ESBOCO: { [string]: { receita: string, texto: string } } = {
	RainhaBobina = { receita = "EsbocoDruida_RainhaBobina", texto = "Esboço Druida aprendido!" },
	CaoTrovaoAlfa = { receita = "EsbocoDruida_CaoAlfa", texto = "Esboço Druida aprendido: Elmo da Matilha!" },
	ColossoDasRuinas = { receita = "EsbocoDruida_Colosso", texto = "Esboço Druida aprendido: Couraça das Ruínas!" },
	EspectroDoObservatorio = { receita = "EsbocoDruida_Espectro", texto = "Esboço Druida aprendido: Amuleto Espectral!" },
	GuardiaoDaTormenta = { receita = "CodiceArcano_EspadaDoHorizonte", texto = "Códice Arcano aprendido! E nas páginas do diário dele… um nome riscado." },
}

type Chefe = {
	cfg: any,
	centro: Vector3,
	id: string?,
	carga: Carga.Estado,
	matilha: Matilha.Estado?,
	tormenta: Tormenta.Estado?,
	paraRaios: { BasePart }, -- Guardião: os para-raios da arena (fixos)
	vulneravelAte: number, -- Guardião na fase 2: janela depois do raio
	telegrafia: { Instance }, -- áreas do chão eletrificado sendo avisadas (e a onda do Colosso)
	colosso: Colosso.Estado?,
	colossoExposto: boolean,
	espectro: Espectro.Estado?,
	espectroVulneravel: boolean,
	lentes: { BasePart },
	voltaEm: number?, -- chefes que só voltam numa condição (Espectro: à noite)
	pilares: { [string]: boolean }, -- pilares (Carga) ou cães chamados (Matilha): somem no reset/derrota
	vazioDesde: number?,
}

local BossSystem = { Nome = "BossSystem" }

local chefes: { Chefe } = {}
local evento: RemoteEvent
local inimigos: any
local combate: any
local fabricacao: any
local base: any
local equipamento: any
-- relíquias de Guardião (GDD 7.4: "vem de Guardiões e segredos")
local RELIQUIA_DO_CHEFE: { [string]: string } = { GuardiaoDaTormenta = "OlhoDaTormenta" }
local restauracao: any
local playerData: any
local ctxSistemas: any = nil

local function naArena(c: Chefe): { Player }
	local l = {}
	for _, p in Players:GetPlayers() do
		local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
		local hum = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
		if hrp and hum and hum.Health > 0 and ((hrp :: BasePart).Position - c.centro).Magnitude <= c.cfg.raioArena then
			table.insert(l, p)
		end
	end
	return l
end

local function avisar(c: Chefe, ...: any)
	for _, p in naArena(c) do
		evento:FireClient(p, ...)
	end
end

local function limparPilares(c: Chefe)
	for id in c.pilares do
		inimigos.remover(id)
	end
	c.pilares = {}
end

local CORES_PARA_RAIO = { normal = Color3.fromHex("#5B6B7A"), carregado = Color3.fromHex("#FFE45C") }

local function limparTelegrafia(c: Chefe)
	for _, i in c.telegrafia do
		i:Destroy()
	end
	c.telegrafia = {}
end

local function criarParaRaios(c: Chefe)
	if #c.paraRaios > 0 then
		return
	end
	local t = c.cfg.tormenta
	for i = 1, t.paraRaios do
		local ang = (i / t.paraRaios) * math.pi * 2
		local pr = Instance.new("Part")
		pr.Name = "ParaRaios" .. i
		pr.Anchored = true
		pr.Size = Vector3.new(1.2, 10, 1.2)
		pr.Material = Enum.Material.Metal
		pr.Color = CORES_PARA_RAIO.normal
		pr.CFrame = CFrame.new(c.centro + Vector3.new(math.cos(ang) * t.raioParaRaios, 1, math.sin(ang) * t.raioParaRaios))
		pr.Parent = Workspace
		local pp = Instance.new("ProximityPrompt")
		pp.ActionText = "Ativar para-raios"
		pp.ObjectText = "Para-raios " .. i
		pp.KeyboardKeyCode = Enum.KeyCode.B
		pp.GamepadKeyCode = Enum.KeyCode.DPadUp
		pp.HoldDuration = 0.3
		pp.MaxActivationDistance = 8
		pp.Parent = pr
		local idx = i
		pp.Triggered:Connect(function(p: Player)
			BossSystem.ativarParaRaio(c, idx, p)
		end)
		table.insert(c.paraRaios, pr)
	end
end

local function surgirChefe(c: Chefe)
	c.carga = Carga.novo()
	c.tormenta = if c.cfg.mecanica == "Tormenta" then Tormenta.novo(os.clock()) else nil
	c.colosso = if c.cfg.mecanica == "Nucleo" then Colosso.novo(os.clock(), c.cfg.nucleo) else nil
	c.colossoExposto = false
	c.espectro = if c.cfg.mecanica == "Lentes" then Espectro.novo(os.clock(), c.cfg.lentes) else nil
	c.espectroVulneravel = false
	c.voltaEm = nil
	c.vulneravelAte = 0
	limparTelegrafia(c)
	if c.cfg.mecanica == "Tormenta" then
		criarParaRaios(c)
		for _, pr in c.paraRaios do
			pr.Color = CORES_PARA_RAIO.normal
			pr.Material = Enum.Material.Metal
		end
	end
	c.matilha = if c.cfg.mecanica == "Matilha" then Matilha.novo(os.clock(), c.cfg.corrida.intervalo) else nil
	c.vazioDesde = nil
	c.id = inimigos.surgirEm(c.cfg.id, CFrame.new(c.centro + Vector3.new(0, 4, 0)))
	if c.id and (c.cfg.mecanica == "Nucleo" or c.cfg.mecanica == "Lentes") then
		inimigos.definirInvulneravel(c.id, true) -- couraça / forma espectral
	end
end

local function iniciarCarga(c: Chefe, agora: number)
	Carga.iniciar(c.carga, agora, c.cfg.duracaoCarga, c.cfg.pilares)
	inimigos.definirInvulneravel(c.id, true)
	for i = 1, c.cfg.pilares do
		local ang = (i / c.cfg.pilares) * math.pi * 2
		local onde = c.centro + Vector3.new(math.cos(ang) * 14, 4, math.sin(ang) * 14)
		local pid = inimigos.surgirEm("PilarDeCristal", CFrame.new(onde))
		if pid then
			c.pilares[pid] = true
		else
			Carga.pilarQuebrado(c.carga) -- sem vaga para o pilar: conta como quebrado (nunca fica impossível)
		end
	end
	avisar(c, EC.CARGA, c.cfg.duracaoCarga, c.cfg.pilares)
end

local function terminarCarga(c: Chefe, resultado: string)
	limparPilares(c)
	inimigos.definirInvulneravel(c.id, false)
	local info = inimigos.info(c.id)
	if resultado == "Sucesso" then
		inimigos.atordoarPor(c.id, 4)
	elseif info then
		-- descarga: cada um na arena recebe o golpe (esquiva/aparar/defesa valem, como qualquer ataque)
		for _, p in naArena(c) do
			combate.danoAoJogador(p, info.posicao, c.cfg.descarga, c.id)
		end
	end
	avisar(c, EC.FIM_CARGA, resultado)
end

-- mecânica "Matilha" (Alfa)
local function passoMatilha(c: Chefe, info: any, agora: number)
	local m = c.matilha :: Matilha.Estado
	if Matilha.deveChamar(m, info.vida / info.vidaMax) then
		Matilha.registrarChamada(m)
		for i = 1, c.cfg.matilhaPorChamada do
			local ang = math.random() * math.pi * 2
			local onde = info.posicao + Vector3.new(math.cos(ang) * 10, 2, math.sin(ang) * 10)
			local id = inimigos.surgirEm("CaoDaMatilha", CFrame.new(onde))
			if id then
				c.pilares[id] = true
			end
			local _ = i
		end
		avisar(c, EC.MATILHA, c.cfg.matilhaPorChamada)
	end
	local r = Matilha.atualizar(m, agora, c.cfg.corrida.intervalo, c.cfg.corrida.duracao)
	if r == "IniciaCorrida" then
		inimigos.definirInvulneravel(c.id, true)
		avisar(c, EC.CORRIDA, c.cfg.corrida.duracao)
	elseif r == "FimCorrida" then
		inimigos.definirInvulneravel(c.id, false)
	end
end

-- mecânica "Tormenta" (Guardião)
local function telegrafar(c: Chefe, padrao: string, duracao: number)
	limparTelegrafia(c)
	local function area(tam: Vector3, cf: CFrame, forma: Enum.PartType?)
		local a = Instance.new("Part")
		a.Anchored, a.CanCollide, a.CanQuery, a.CanTouch, a.CastShadow = true, false, false, false, false
		a.Material = Enum.Material.Neon
		a.Color = Color3.fromHex("#FF5A5A")
		a.Transparency = 0.6
		if forma then
			a.Shape = forma
		end
		a.Size = tam
		a.CFrame = cf
		a.Parent = Workspace
		table.insert(c.telegrafia, a)
	end
	local chao = CFrame.new(c.centro + Vector3.new(0, 0.2, 0))
	if padrao == "Centro" then
		area(Vector3.new(0.3, 16, 16), chao * CFrame.Angles(0, 0, math.rad(90)), Enum.PartType.Cylinder)
	elseif padrao == "Cruz" then
		area(Vector3.new(6, 0.3, c.cfg.raioArena * 2), chao)
		area(Vector3.new(c.cfg.raioArena * 2, 0.3, 6), chao)
	else -- Anel: 16 segmentos entre os raios 10 e 18
		for i = 1, 16 do
			local ang = (i / 16) * math.pi * 2
			area(Vector3.new(8, 0.3, 4.2), chao * CFrame.Angles(0, -ang, 0) * CFrame.new(14, 0, 0))
		end
	end
	local _ = duracao
end

function BossSystem.ativarParaRaio(c: Chefe, idx: number, p: Player)
	local t = c.tormenta
	if not t or not c.id then
		return
	end
	local agora = os.clock()
	local r = Tormenta.ativar(t, idx, agora, c.cfg.tormenta)
	local pr = c.paraRaios[idx]
	if r == "Acerto" then
		pr.Color = CORES_PARA_RAIO.normal
		pr.Material = Enum.Material.Metal
		-- o raio desce no Guardião: dano grande e atordoado (janela para os golpes de todos)
		inimigos.definirInvulneravel(c.id, false)
		local dr = c.cfg.raioDoParaRaio
		inimigos.receberGolpe(c.id, { dano = dr.danoNoGuardiao, postura = 0, bonusPostura = 0, multiplicador = 1, atacante = p })
		if c.id then
			inimigos.atordoarPor(c.id, dr.atordoamento)
			c.vulneravelAte = agora + dr.atordoamento
		end
		avisar(c, EC.PARA_RAIO, idx, "Acerto")
	elseif r == "Errado" then
		local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
		if hrp then
			combate.danoAoJogador(p, pr.Position, c.cfg.raioDoParaRaio.errado, c.id :: string)
		end
		evento:FireClient(p, EC.PARA_RAIO, idx, "Errado")
	end
end

local function passoTormenta(c: Chefe, info: any, agora: number)
	local t = c.tormenta :: Tormenta.Estado
	local cfg = c.cfg
	for _, ev in Tormenta.atualizar(t, agora, info.vida / info.vidaMax, cfg.tormenta, math.random) do
		if ev.tipo == "Fase" then
			avisar(c, EC.FASE, ev.fase)
			inimigos.definirInvulneravel(c.id, ev.fase == 2) -- fase 2: só o raio fere; fase 3: volta a ser ferível
		elseif ev.tipo == "Carga" then
			local pr = c.paraRaios[ev.idx :: number]
			pr.Color = CORES_PARA_RAIO.carregado
			pr.Material = Enum.Material.Neon
			avisar(c, EC.PARA_RAIO, ev.idx, "Carregado")
		elseif ev.tipo == "RaioFalhou" then
			local pr = c.paraRaios[ev.idx :: number]
			pr.Color = CORES_PARA_RAIO.normal
			pr.Material = Enum.Material.Metal
			local f = cfg.raioDoParaRaio.falhou
			for _, p in naArena(c) do
				local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
				if hrp and ((hrp :: BasePart).Position - pr.Position).Magnitude <= f.raio then
					combate.danoAoJogador(p, pr.Position, f, c.id :: string)
				end
			end
			avisar(c, EC.PARA_RAIO, ev.idx, "Falhou")
		elseif ev.tipo == "Telegrafa" then
			telegrafar(c, ev.padrao :: string, cfg.tormenta.telegrafia)
			avisar(c, EC.PADRAO, ev.padrao, cfg.tormenta.telegrafia)
		elseif ev.tipo == "Descarrega" then
			for _, p in naArena(c) do
				local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
				if hrp then
					local d = (hrp :: BasePart).Position - c.centro
					if Tormenta.noPadrao(ev.padrao :: string, d.X, d.Z) then
						combate.danoAoJogador(p, c.centro, cfg.chao, c.id :: string)
					end
				end
			end
			for _, a in c.telegrafia do
				(a :: BasePart).Transparency = 0.1
			end
			task.delay(0.25, function()
				limparTelegrafia(c)
			end)
		end
	end
	-- fim da janela do raio na fase 2: volta a ficar imune
	if t.fase == 2 and c.vulneravelAte > 0 and agora >= c.vulneravelAte then
		c.vulneravelAte = 0
		inimigos.definirInvulneravel(c.id, true)
	end
end

-- mecânica "Nucleo" (Colosso)
local function passoColosso(c: Chefe, info: any, agora: number)
	local e = c.colosso :: Colosso.Estado
	local r = Colosso.atualizar(e, agora, c.cfg.nucleo, c.colossoExposto)
	if r == "Fechou" then
		c.colossoExposto = false
		inimigos.definirInvulneravel(c.id, true)
		avisar(c, EC.NUCLEO, "Fechou")
	elseif r == "TelegrafaOnda" then
		limparTelegrafia(c)
		local anel = Instance.new("Part")
		anel.Anchored, anel.CanCollide, anel.CanQuery, anel.CanTouch, anel.CastShadow = true, false, false, false, false
		anel.Shape = Enum.PartType.Cylinder
		anel.Material = Enum.Material.Neon
		anel.Color = Color3.fromHex("#FF9A3C")
		anel.Transparency = 0.6
		anel.Size = Vector3.new(0.3, c.cfg.onda.raio * 2, c.cfg.onda.raio * 2)
		anel.CFrame = CFrame.new(info.posicao.X, c.centro.Y - 3.5, info.posicao.Z) * CFrame.Angles(0, 0, math.rad(90))
		anel.Parent = Workspace
		table.insert(c.telegrafia, anel)
		avisar(c, EC.ONDA, c.cfg.nucleo.telegrafiaOnda)
	elseif r == "Onda" then
		for _, p in naArena(c) do
			local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
			if hrp and (((hrp :: BasePart).Position - info.posicao) * Vector3.new(1, 0, 1)).Magnitude <= c.cfg.onda.raio then
				combate.danoAoJogador(p, info.posicao, c.cfg.onda, c.id :: string)
			end
		end
		for _, a in c.telegrafia do
			(a :: BasePart).Transparency = 0.1
		end
		task.delay(0.25, function()
			limparTelegrafia(c)
		end)
	end
end

-- mecânica "Lentes" (Espectro)
local function criarLentes(c: Chefe)
	if #c.lentes > 0 then
		return
	end
	local L = c.cfg.lentes
	for i = 1, L.lentes do
		local ang = (i / L.lentes) * math.pi * 2
		local lente = Instance.new("Part")
		lente.Name = "Lente" .. i
		lente.Anchored = true
		lente.CanCollide = false
		lente.Shape = Enum.PartType.Cylinder
		lente.Size = Vector3.new(0.4, 6, 6)
		lente.Material = Enum.Material.Glass
		lente.Color = Color3.fromHex("#BFD8FF")
		lente.Transparency = 0.4
		lente.CFrame = CFrame.new(c.centro + Vector3.new(math.cos(ang) * L.raioLentes, 3, math.sin(ang) * L.raioLentes)) * CFrame.Angles(0, -ang, 0)
		lente.Parent = Workspace
		table.insert(c.lentes, lente)
	end
	-- telescópio no centro: o reflexo torna o Espectro ferível
	local tel = Instance.new("Part")
	tel.Name = "Telescopio"
	tel.Anchored = true
	tel.Size = Vector3.new(2, 3, 5)
	tel.Color = Color3.fromHex("#B08D57")
	tel.Material = Enum.Material.Metal
	tel.CFrame = CFrame.new(c.centro + Vector3.new(0, -2.5, 0)) * CFrame.Angles(math.rad(-25), 0, 0)
	tel.Parent = Workspace
	local pp = Instance.new("ProximityPrompt")
	pp.ActionText = "Usar telescópio"
	pp.ObjectText = "Telescópio"
	pp.KeyboardKeyCode = Enum.KeyCode.B
	pp.GamepadKeyCode = Enum.KeyCode.DPadUp
	pp.HoldDuration = 0.5
	pp.MaxActivationDistance = 8
	pp.Parent = tel
	pp.Triggered:Connect(function(p: Player)
		local e = c.espectro
		if not e or not c.id then
			return
		end
		local teste = ConfigServidor.concessoesDeTeste
		local restaurado = (teste and teste.ativa and teste.ignorarTravasDeChefe) or restauracao.restaurada(p, c.cfg.exigeRestauracaoTelescopio)
		local ok, motivo = Espectro.refletir(e, os.clock(), c.cfg.lentes, restaurado == true)
		if ok then
			c.espectroVulneravel = true
			inimigos.definirInvulneravel(c.id, false)
			inimigos.atordoarPor(c.id, c.cfg.lentes.atordoamento)
			avisar(c, EC.REFLEXO, "ok")
		else
			evento:FireClient(p, EC.REFLEXO, motivo)
		end
	end)
end

local function noiteAgora(c: Chefe): boolean
	local teste = ConfigServidor.concessoesDeTeste
	if teste and teste.ativa and teste.ignorarNoite then
		return true
	end
	return Espectro.noite(Lighting.ClockTime, c.cfg.noite.inicio, c.cfg.noite.fim)
end

local function passoEspectro(c: Chefe, info: any, agora: number)
	local e = c.espectro :: Espectro.Estado
	if c.espectroVulneravel and not Espectro.vulneravel(e, agora) then
		c.espectroVulneravel = false
		inimigos.definirInvulneravel(c.id, true)
	end
	local nova = Espectro.atualizar(e, agora, c.cfg.lentes, math.random)
	if nova then
		local lente = c.lentes[nova]
		if lente then
			inimigos.teleportar(c.id, CFrame.new(lente.Position + Vector3.new(0, 2, 0)))
			avisar(c, EC.TELEPORTE, nova)
		end
	end
	-- amanheceu e ninguém está lutando: some até a próxima noite
	if not noiteAgora(c) and info.vida >= info.vidaMax then
		inimigos.remover(c.id)
		c.id = nil
		c.voltaEm = agora
	end
end

-- arena do Guardião: só entra quem restaurou a Torre (ou em teste, com a trava desligada)
local function travaDaArena(c: Chefe)
	local req = c.cfg.exigeRestauracao
	local teste = ConfigServidor.concessoesDeTeste
	if not req or (teste and teste.ativa and teste.ignorarTravasDeChefe) then
		return
	end
	for _, p in naArena(c) do
		if not restauracao.restaurada(p, req) then
			local ch = p.Character :: Model
			local hrp = ch:FindFirstChild("HumanoidRootPart") :: BasePart
			local fora = (hrp.Position - c.centro) * Vector3.new(1, 0, 1)
			fora = if fora.Magnitude > 0.1 then fora.Unit else Vector3.xAxis
			ch:PivotTo(CFrame.new(c.centro + fora * (c.cfg.raioArena + 8) + Vector3.new(0, 4, 0)))
			evento:FireClient(p, EC.BLOQUEADO, "torreSemEnergia")
		end
	end
end

local function passo(c: Chefe, agora: number)
	if not c.id then
		-- chefes que voltam por condição (Espectro: depois do retorno E à noite)
		if c.cfg.mecanica == "Lentes" and c.voltaEm and agora >= c.voltaEm and noiteAgora(c) then
			surgirChefe(c)
		end
		return
	end
	local info = inimigos.info(c.id)
	if not info then
		return
	end
	local presentes = #naArena(c)
	-- ninguém na arena por 20 s: reseta (vida cheia, sem pilares)
	if presentes == 0 then
		c.vazioDesde = c.vazioDesde or agora
		if agora - (c.vazioDesde :: number) > 20 and (info.vida < info.vidaMax or c.carga.emCarga or (c.tormenta ~= nil and c.tormenta.fase > 1)) then
			limparPilares(c)
			limparTelegrafia(c)
			inimigos.remover(c.id)
			if c.cfg.mecanica == "Lentes" and not noiteAgora(c) then
				c.id = nil
				c.voltaEm = agora -- de dia o Espectro não volta: espera a noite
			else
				surgirChefe(c)
			end
		end
		return
	end
	c.vazioDesde = nil
	travaDaArena(c)
	if c.cfg.mecanica == "Tormenta" then
		passoTormenta(c, info, agora)
		return
	elseif c.cfg.mecanica == "Nucleo" then
		passoColosso(c, info, agora)
		return
	elseif c.cfg.mecanica == "Lentes" then
		passoEspectro(c, info, agora)
		return
	end
	if c.cfg.mecanica == "Matilha" then
		passoMatilha(c, info, agora)
		return
	end
	if Carga.deveCarregar(c.carga, info.vida / info.vidaMax) then
		iniciarCarga(c, agora)
	end
	local r = Carga.atualizar(c.carga, agora)
	if r then
		terminarCarga(c, r)
	end
end

function BossSystem.Init(ctx: any)
	ctxSistemas = ctx
	evento = Remotos.evento("Chefe")
end

function BossSystem.Start()
	inimigos = ctxSistemas.obter("EnemySystem")
	combate = ctxSistemas.obter("CombatSystem")
	fabricacao = ctxSistemas.obter("CraftingSystem")
	base = ctxSistemas.obter("PersonalBaseSystem")
	equipamento = ctxSistemas.obter("EquipmentSystem")
	restauracao = ctxSistemas.obter("RestorationSystem")
	playerData = ctxSistemas.obter("PlayerDataSystem")
	-- aparo durante a corrida do Alfa: quebra a corrida e derruba
	inimigos.aparado.conectar(function(inimigoId: string)
		for _, c in chefes do
			-- Colosso: cada aparo conta; 3 abrem o núcleo
			if c.id == inimigoId and c.colosso then
				local agora = os.clock()
				if Colosso.aparado(c.colosso, agora, c.cfg.nucleo) then
					c.colossoExposto = true
					inimigos.definirInvulneravel(c.id, false)
					avisar(c, EC.NUCLEO, "Aberto")
				elseif not Colosso.exposto(c.colosso, agora) then
					avisar(c, EC.NUCLEO, c.colosso.aparos, c.cfg.nucleo.aparosParaAbrir)
				end
			end
			if c.id == inimigoId and c.matilha and Matilha.aparado(c.matilha, os.clock(), c.cfg.corrida.intervalo) then
				inimigos.definirInvulneravel(c.id, false)
				inimigos.atordoarPor(c.id, c.cfg.atordoamento)
				avisar(c, EC.FIM_CARGA, "Sucesso")
			end
		end
	end)
	if not ConfigServidor.arenaDeTeste.ativa then
		return -- (Etapa 14) no mapa real, os chefes virão de marcadores em workspace.GuardioesChefes
	end
	for _, cfg in ConfigServidor.chefes do
		local c: Chefe = {
			cfg = cfg, centro = ConfigServidor.arenaDeTeste.centro + cfg.deslocamento, id = nil, carga = Carga.novo(),
			matilha = nil, tormenta = nil, paraRaios = {}, vulneravelAte = 0, telegrafia = {}, pilares = {}, vazioDesde = nil,
			colosso = nil, colossoExposto = false, espectro = nil, espectroVulneravel = false, lentes = {}, voltaEm = nil,
		}
		table.insert(chefes, c)
		if cfg.mecanica == "Lentes" then
			criarLentes(c)
			c.voltaEm = 0 -- aparece na primeira noite (o passo cuida)
		else
			surgirChefe(c)
		end
	end
	inimigos.morreu.conectar(function(ini: any, contribuicao: { [Player]: number })
		for _, c in chefes do
			if c.pilares[ini.id] then
				c.pilares[ini.id] = nil
				if c.cfg.mecanica ~= "Matilha" then
					Carga.pilarQuebrado(c.carga)
				end
			elseif c.id == ini.id then
				c.id = nil
				limparPilares(c)
				limparTelegrafia(c)
				avisar(c, EC.DERROTADO, ini.cfg.nome)
				local esboco = ESBOCO[ini.cfg.id]
				for _, p in Saque.elegiveis(contribuicao, Loot.minimoDeContribuicao) do
					if esboco and fabricacao.aprenderReceita(p, esboco.receita) then
						evento:FireClient(p, EC.DERROTADO, ini.cfg.nome .. " — " .. esboco.texto)
						if ini.cfg.id == "GuardiaoDaTormenta" then
							-- primeira pista do Ato 1 (segredo de história, não de item)
							playerData.atualizar(p, function(pf)
								pf.segredos.DiarioDoGuardiao = true
								return true
							end)
						end
					end
					base.darTrofeu(p, ini.cfg.id)
					local rel = RELIQUIA_DO_CHEFE[ini.cfg.id]
					if rel then
						equipamento.darReliquia(p, rel) -- única: só a primeira vitória entrega
					end
				end
				if c.cfg.mecanica == "Lentes" then
					c.voltaEm = os.clock() + c.cfg.retornoSeg -- e só à noite
				else
					task.delay(c.cfg.retornoSeg, function()
						surgirChefe(c)
					end)
				end
			end
		end
	end)
	task.spawn(function()
		while true do
			task.wait(0.2)
			local agora = os.clock()
			for _, c in chefes do
				local ok, erro = pcall(passo, c, agora)
				if not ok then
					warn("[Guardioes] chefe: " .. tostring(erro))
				end
			end
		end
	end)
	-- quem entra na arena vê a barra do chefe
	task.spawn(function()
		-- por jogador E por chefe (id muda quando o chefe volta): cada arena nova mostra a sua barra
		local vistos: { [Player]: { [string]: boolean } } = {}
		while true do
			task.wait(1)
			local ok, erro = pcall(function()
				for _, c in chefes do
					if c.id then
						for _, p in naArena(c) do
							vistos[p] = vistos[p] or {}
							if not vistos[p][c.id :: string] then
								vistos[p][c.id :: string] = true
								evento:FireClient(p, EC.INICIO, c.id, c.cfg.id)
							end
						end
					end
				end
				for p in vistos do
					if not p.Parent then
						vistos[p] = nil
					end
				end
			end)
			if not ok then
				warn("[Guardioes] chefe (barra): " .. tostring(erro))
			end
		end
	end)
end

return BossSystem
