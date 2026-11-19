--!strict
-- NÃO EXECUTADO NO STUDIO. MetamorphicArtifactSystem: troca de forma dos artefatos (servidor).
-- Inclui a parte de servidor do ArtifactProgressionSystem (avaliação por ProgressaoDeArtefato; o consumo de
-- materiais espera o InventorySystem da Etapa D).
--
-- Regras garantidas aqui (Sistema 12 do documento):
--   * só transforma artefato que o jogador POSSUI (pelo GUID) e forma já DESPERTADA (estágio);
--   * um artefato equipado por vez: a troca não cria nem apaga item (mesmo GUID, só muda a forma);
--   * durante a troca nenhuma forma está ativa: sem dano de arma, sem voo;
--   * forma de locomoção só entra se o MovementSystem aceitar (zona, espaço, energia, nenhum outro modo ativo);
--   * forma de prancha/asas nunca causa dano de arma (guarda no CombatSystem);
--   * golpe forte durante a troca cancela e volta à forma anterior.
--
-- Inventário: ainda não existe InventorySystem. Contrato (docs/08): possui(p, guid), artefatos(p).
-- Até lá, com ConfigServidor.concessoesDeTeste.ativa, cada jogador recebe artefatos de TESTE (não salvos).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local G = ReplicatedStorage:WaitForChild("Guardioes")
local MaqArt = require(G.Artefatos.MaquinaDeArtefato)
local Progressao = require(G.Artefatos.ProgressaoDeArtefato)
local LimiteDeTaxa = require(G.Util.LimiteDeTaxa)
local Remotos = require(G.Rede.Remotos)
local Espada = require(G.Config.Armas.Espada)
local ConfigServidor = require(script.Parent.Parent.ConfigServidor)
local Secreto = require(script.Parent.Parent.ConfigSecreta.ArcoDasAsasPerdidas)

local A = Remotos.Artefato
local EA = Remotos.EventoArtefato

-- configurações conhecidas: públicas + secretas (só servidor)
local configs: { [string]: any } = {}
for _, m in G.Config.Artefatos:GetChildren() do
	if m:IsA("ModuleScript") then
		local c = require(m) :: any
		configs[c.id] = c
	end
end
configs[Secreto.artefato.id] = Secreto.artefato

local armas: { [string]: any } = {}
for _, m in G.Config.Armas:GetChildren() do
	if m:IsA("ModuleScript") then
		local a = require(m) :: any
		armas[a.id] = a
	end
end

type Jogador = {
	artefatos: { [string]: MaqArt.Instancia }, -- guid → instância (o "inventário" de teste)
	equipado: string?,
	anterior: string?, -- forma antes da troca em andamento (para desfazer se o movimento recusar)
	balde: LimiteDeTaxa.Balde,
}

local MetamorphicArtifactSystem = { Nome = "MetamorphicArtifactSystem" }

local jogadores: { [Player]: Jogador } = {}
local evento: RemoteEvent
local movimento: any
local combate: any
local ctxSistemas: any = nil

local function cfgDe(inst: MaqArt.Instancia): any
	return configs[inst.id]
end

local function equipada(p: Player): (MaqArt.Instancia?, any?)
	local j = jogadores[p]
	if not j or not j.equipado then
		return nil, nil
	end
	local inst = j.artefatos[j.equipado :: string]
	return inst, if inst then cfgDe(inst) else nil
end

local function publicar(p: Player, inst: MaqArt.Instancia)
	local ch = p.Character
	if ch then -- os outros clientes desenham a forma a partir destes atributos
		ch:SetAttribute("ArtefatoId", inst.id)
		ch:SetAttribute("ArtefatoForma", inst.forma)
		ch:SetAttribute("ArtefatoAlvo", inst.alvo)
	end
	evento:FireClient(p, EA.FORMA, inst.guid, inst.forma, inst.alvo ~= nil)
end

local function enviarInventario(p: Player)
	local j = jogadores[p]
	if not j then
		return
	end
	local lista = {}
	for guid, inst in j.artefatos do
		local cfg = cfgDe(inst)
		local formas = {}
		for nome, f in cfg.formas do
			table.insert(formas, { nome = nome, tipo = f.tipo, liberada = inst.estagio >= f.estagioMin })
		end
		table.insert(lista, { guid = guid, id = inst.id, nome = cfg.nome, raridade = cfg.raridade, estagio = inst.estagio, forma = inst.forma, formas = formas, equipado = j.equipado == guid })
	end
	evento:FireClient(p, EA.INVENTARIO, lista)
end

-- aplica os efeitos da forma ATIVA: arma no combate (forma de combate) ou nada (locomoção/defesa)
local function aplicarForma(p: Player, inst: MaqArt.Instancia, cfg: any)
	local f = cfg.formas[inst.forma]
	if f and f.tipo == "Combate" then
		combate.definirArma(p, armas[f.arma] or Espada)
	elseif f and f.tipo == "Defesa" then
		combate.definirArma(p, Espada) -- (Etapa D) escudo + arma da outra mão
	end
end

-- ------------------------------------------------------------------ intenções
local function aoReceber(p: Player, tipo: any, guid: any, forma: any)
	local j = jogadores[p]
	if not j or tipo ~= A.TRANSFORMAR or typeof(guid) ~= "string" or typeof(forma) ~= "string" or #forma > 24 then
		return
	end
	local agora = os.clock()
	if not LimiteDeTaxa.consumir(j.balde, agora) then
		return
	end
	local inst = j.artefatos[guid]
	if not inst then
		evento:FireClient(p, EA.REJEITADO, guid, "naoPossui")
		return
	end
	if j.equipado and j.equipado ~= guid then
		local atual = j.artefatos[j.equipado :: string]
		if atual and atual.alvo then
			evento:FireClient(p, EA.REJEITADO, guid, "transformando")
			return
		end
	end
	local cfg = cfgDe(inst)
	local destino = cfg.formas[forma]
	if not destino then
		evento:FireClient(p, EA.REJEITADO, guid, "formaInexistente")
		return
	end
	local origem = cfg.formas[inst.forma]
	local saindoDeLocomocao = origem and origem.tipo == "Locomocao"
	-- já na forma de locomoção, parado no chão (pousou antes): pedir a mesma forma = decolar de novo, sem troca
	if forma == inst.forma and destino.tipo == "Locomocao" and not inst.alvo and j.equipado == guid then
		local ok, motivo = movimento.podeEntrarModo(p, destino.perfil)
		if ok then
			ok, motivo = movimento.entrarModoDeArtefato(p, destino.perfil)
		end
		if not ok then
			evento:FireClient(p, EA.REJEITADO, guid, motivo)
		end
		return
	end
	-- checagens de locomoção ANTES de começar (não deixa começar uma troca que vai falhar)
	if destino.tipo == "Locomocao" then
		local ok, motivo = movimento.podeEntrarModo(p, destino.perfil)
		if not ok then
			evento:FireClient(p, EA.REJEITADO, guid, motivo)
			return
		end
		if movimento.energia(p) < cfg.transformacao.custoEnergia then
			evento:FireClient(p, EA.REJEITADO, guid, "energia")
			return
		end
	end
	local ok, motivo = MaqArt.transformar(inst, cfg, forma, agora)
	if not ok then
		evento:FireClient(p, EA.REJEITADO, guid, motivo)
		return
	end
	if destino.tipo == "Locomocao" then
		movimento.gastarEnergia(p, cfg.transformacao.custoEnergia)
	end
	j.equipado = guid
	j.anterior = inst.forma
	if saindoDeLocomocao then
		-- retorno ao combate: sai da prancha JÁ (queda amortecida durante a montagem da espada)
		movimento.sairModoDeArtefato(p, cfg.retornoAoCombate.duracaoMax)
	end
	publicar(p, inst)
end

local function passo()
	local agora = os.clock()
	for p, j in jogadores do
		local inst, cfg = equipada(p)
		if inst and cfg then
			local ev = MaqArt.atualizar(inst, cfg, agora)
			if ev then
				local f = cfg.formas[ev.forma]
				if f.tipo == "Locomocao" then
					local ok = movimento.entrarModoDeArtefato(p, f.perfil)
					if not ok then
						-- o mundo mudou durante a troca (zona, golpe, outra montaria): desfaz para a forma anterior
						inst.forma = j.anterior or cfg.formaInicial
						evento:FireClient(p, EA.REJEITADO, inst.guid, "locomocaoRecusada")
					end
				end
				aplicarForma(p, inst, cfg)
				publicar(p, inst)
			end
		end
	end
end

-- ------------------------------------------------------------------ API (servidor)
-- avalia o próximo estágio de um artefato (a troca de estágio virá junto com a transação do InventorySystem)
function MetamorphicArtifactSystem.avaliarEvolucao(p: Player, guid: string, progresso: any): (boolean, { any }, { [string]: number })
	local j = jogadores[p]
	local inst = j and j.artefatos[guid]
	if not inst then
		return false, { { tipo = "naoPossui", id = guid, tem = 0, precisa = 1 } }, {}
	end
	return Progressao.avaliar(cfgDe(inst), inst.estagio, progresso)
end

function MetamorphicArtifactSystem.formaAtiva(p: Player): (string?, string?)
	local inst, cfg = equipada(p)
	if not inst or not cfg then
		return nil, nil
	end
	return MaqArt.formaAtiva(inst), MaqArt.tipoAtivo(inst, cfg)
end

-- ------------------------------------------------------------------ ciclo de vida
function MetamorphicArtifactSystem.Init(ctx: any)
	ctxSistemas = ctx
	evento = Remotos.evento("Artefato")
end

function MetamorphicArtifactSystem.Start()
	movimento = ctxSistemas.obter("MovementSystem")
	combate = ctxSistemas.obter("CombatSystem")

	-- sem ataque durante a troca nem em forma de locomoção (a prancha não corta)
	combate.registrarGuarda(function(p: Player)
		local inst, cfg = equipada(p)
		if inst and cfg then
			if inst.alvo then
				return false, "transformando"
			end
			if MaqArt.tipoAtivo(inst, cfg) == "Locomocao" then
				return false, "formaDeLocomocao"
			end
		end
		return true, nil
	end)
	-- golpe forte durante a troca: cancela (volta à forma anterior, meia recarga)
	combate.jogadorAtingido.conectar(function(p: Player, dano: number)
		local inst, cfg = equipada(p)
		if inst and cfg and inst.alvo and dano >= cfg.transformacao.golpeCancelaAcima then
			MaqArt.cancelar(inst, cfg, os.clock())
			publicar(p, inst)
		end
	end)
	-- bônus de estágio do artefato equipado entram no perfil efetivo de locomoção
	movimento.registrarFonteDeMods(function(p: Player, perfilId: string)
		local inst, cfg = equipada(p)
		if not inst or not cfg then
			return {}
		end
		local fontes = {}
		for _, f in Progressao.fontesDeBonus(cfg, inst.estagio) do
			if f.perfis[1] == perfilId then
				table.insert(fontes, f)
			end
		end
		return fontes
	end)
	-- energia/estado: se o voo do artefato acabar por conta própria (pousou, energia), a forma continua de
	-- locomoção no chão; o jogador volta à arma com a tecla de forma (sem troca automática surpresa).

	local teste = ConfigServidor.concessoesDeTeste
	local function entrar(p: Player)
		local j: Jogador = { artefatos = {}, equipado = nil, anterior = nil, balde = LimiteDeTaxa.novo(6, 3, os.clock()) }
		if teste and teste.ativa then
			for _, a in teste.artefatos do
				local cfg = configs[a.id]
				if cfg then
					local guid = HttpService:GenerateGUID(false)
					j.artefatos[guid] = MaqArt.nova(guid, cfg, a.estagio)
					j.equipado = j.equipado or guid
				end
			end
		end
		jogadores[p] = j
		local function aoPersonagem()
			-- renascer: o artefato volta à forma inicial (nunca se renasce em cima da prancha)
			local inst, cfg = equipada(p)
			if inst and cfg then
				inst.forma, inst.alvo = cfg.formaInicial, nil
				aplicarForma(p, inst, cfg)
				task.defer(publicar, p, inst)
			end
			task.defer(enviarInventario, p)
		end
		p.CharacterAdded:Connect(aoPersonagem)
		if p.Character then
			aoPersonagem()
		end
	end
	for _, p in Players:GetPlayers() do
		entrar(p)
	end
	Players.PlayerAdded:Connect(entrar)
	Players.PlayerRemoving:Connect(function(p)
		jogadores[p] = nil
	end)
	evento.OnServerEvent:Connect(aoReceber)
	RunService.Heartbeat:Connect(passo)
end

return MetamorphicArtifactSystem
