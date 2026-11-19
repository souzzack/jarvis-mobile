--!strict
-- NÃO EXECUTADO NO STUDIO. BossSystem (Etapa E): minibosses com fases, cada um com a sua MECÂNICA:
--   "Carga"   → RAINHA-BOBINA (abaixo)
--   "Matilha" → CÃO-TROVÃO ALFA: chama 2 cães em 70% e 40%; a cada ~14 s corre carregado por 4 s (imune);
--               só um APARO de um golpe dele quebra a corrida e o derruba (EnemySystem.aparado).
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
local Saque = require(G.Loot.Saque)
local Loot = require(G.Config.Loot)
local Remotos = require(G.Rede.Remotos)
local ConfigServidor = require(script.Parent.Parent.ConfigServidor)

local EC = Remotos.EventoChefe
local ESBOCO: { [string]: string } = { RainhaBobina = "EsbocoDruida_RainhaBobina" }

type Chefe = {
	cfg: any,
	centro: Vector3,
	id: string?,
	carga: Carga.Estado,
	matilha: Matilha.Estado?,
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

local function surgirChefe(c: Chefe)
	c.carga = Carga.novo()
	c.matilha = if c.cfg.mecanica == "Matilha" then Matilha.novo(os.clock(), c.cfg.corrida.intervalo) else nil
	c.vazioDesde = nil
	c.id = inimigos.surgirEm(c.cfg.id, CFrame.new(c.centro + Vector3.new(0, 4, 0)))
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

local function passo(c: Chefe, agora: number)
	if not c.id then
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
		if agora - (c.vazioDesde :: number) > 20 and (info.vida < info.vidaMax or c.carga.emCarga) then
			limparPilares(c)
			inimigos.remover(c.id)
			surgirChefe(c)
		end
		return
	end
	c.vazioDesde = nil
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
	-- aparo durante a corrida do Alfa: quebra a corrida e derruba
	inimigos.aparado.conectar(function(inimigoId: string)
		for _, c in chefes do
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
		local c: Chefe = { cfg = cfg, centro = ConfigServidor.arenaDeTeste.centro + cfg.deslocamento, id = nil, carga = Carga.novo(), pilares = {}, vazioDesde = nil }
		table.insert(chefes, c)
		surgirChefe(c)
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
				avisar(c, EC.DERROTADO, ini.cfg.nome)
				local esboco = ESBOCO[ini.cfg.id]
				for _, p in Saque.elegiveis(contribuicao, Loot.minimoDeContribuicao) do
					if esboco and fabricacao.aprenderReceita(p, esboco) then
						evento:FireClient(p, EC.DERROTADO, ini.cfg.nome .. " — Esboço Druida aprendido!")
					end
					base.darTrofeu(p, ini.cfg.id)
				end
				task.delay(c.cfg.retornoSeg, function()
					surgirChefe(c)
				end)
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
		end
	end)
end

return BossSystem
