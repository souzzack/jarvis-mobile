--!strict
-- NÃO EXECUTADO NO STUDIO. BossSystem (Etapa E): minibosses com fases. Primeiro: RAINHA-BOBINA.
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
	pilares: { [string]: boolean },
	vazioDesde: number?,
}

local BossSystem = { Nome = "BossSystem" }

local chefes: { Chefe } = {}
local evento: RemoteEvent
local inimigos: any
local combate: any
local fabricacao: any
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
				Carga.pilarQuebrado(c.carga)
			elseif c.id == ini.id then
				c.id = nil
				limparPilares(c)
				avisar(c, EC.DERROTADO, ini.cfg.nome)
				local esboco = ESBOCO[ini.cfg.id]
				if esboco then
					for _, p in Saque.elegiveis(contribuicao, Loot.minimoDeContribuicao) do
						if fabricacao.aprenderReceita(p, esboco) then
							evento:FireClient(p, EC.DERROTADO, ini.cfg.nome .. " — Esboço Druida aprendido!")
						end
					end
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
		local vistos: { [Player]: boolean } = {}
		while true do
			task.wait(1)
			for _, c in chefes do
				if c.id then
					for _, p in naArena(c) do
						if not vistos[p] then
							vistos[p] = true
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
