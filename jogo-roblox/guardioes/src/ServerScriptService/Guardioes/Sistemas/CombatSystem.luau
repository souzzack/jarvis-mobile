--!strict
-- NÃO EXECUTADO NO STUDIO. CombatSystem (protótipo da Etapa C): Espadachim com combo, pesado, esquiva, defesa e aparar.
-- O cliente só manda intenções. O servidor:
--   * roda a máquina de combo OFICIAL com o próprio relógio (os.clock);
--   * cobra estamina;
--   * testa o acerto com a POSIÇÃO DO SERVIDOR (distância + arco + altura), sem .Touched;
--   * resolve esquiva/aparar/defesa quando uma criatura ataca o jogador;
--   * limita a taxa de pedidos por jogador.
-- Ainda não integra atributos/equipamento (Etapa D): o multiplicador de dano é 1.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local G = ReplicatedStorage:WaitForChild("Guardioes")
local Cfg = require(G.Config.Combate)
local Espada = require(G.Config.Armas.Espada)
local MaquinaDeCombo = require(G.Combate.MaquinaDeCombo)
local Dano = require(G.Combate.Dano)
local Estamina = require(G.Combate.Estamina)
local Alcance = require(G.Combate.Alcance)
local LimiteDeTaxa = require(G.Util.LimiteDeTaxa)
local Remotos = require(G.Rede.Remotos)
local Sinal = require(G.Util.Sinal)

local C = Remotos.Combate
local E = Remotos.EventoCombate

type EstadoJogador = {
	maquina: MaquinaDeCombo.Maquina,
	estamina: Estamina.Recurso,
	balde: LimiteDeTaxa.Balde,
	arma: any,
	alvoPedido: string?,
	ultimoEnvioEstamina: number,
	ultimaEstaminaEnviada: number,
	ultimoEstadoEnviado: string,
}

local CombatSystem = { Nome = "CombatSystem" }

-- Integração (docs/08): outros sistemas não mexem no estado interno do combate; usam estes pontos.
-- Guardas: funções (p) -> (permitido, motivo). Ex.: locomoção bloqueia ataque em voo; artefato bloqueia
-- ataque durante a troca de forma ou na forma de prancha.
type Guarda = (Player) -> (boolean, string?)
local guardas: { Guarda } = {}
-- disparado quando um jogador recebe dano > 0 de uma criatura: (p, dano, tipo)
CombatSystem.jogadorAtingido = Sinal.novo()
-- arma escolhida por jogador (sobrevive ao renascer); nil = Espada padrão
local armas: { [Player]: any } = {}

local estados: { [Player]: EstadoJogador } = {}
local evento: RemoteEvent
local inimigos: any
local ctxSalvo: any = nil

local function novoEstado(): EstadoJogador
	local agora = os.clock()
	return {
		maquina = MaquinaDeCombo.nova(agora),
		estamina = Estamina.nova(Cfg.estamina.max, agora),
		balde = LimiteDeTaxa.novo(Cfg.rede.capacidadeBalde, Cfg.rede.recargaPorSeg, agora),
		arma = Espada, -- trocada por CombatSystem.definirArma (artefatos); Etapa D: equipamento
		alvoPedido = nil,
		ultimoEnvioEstamina = 0,
		ultimaEstaminaEnviada = -1,
		ultimoEstadoEnviado = "Ocioso",
	}
end

local function raizDe(p: Player): (BasePart?, Humanoid?)
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

local function rejeitar(p: Player, acao: number, motivo: string)
	evento:FireClient(p, E.REJEITADO, acao, motivo)
end

-- ----------------------------------------------------------------- execução do golpe (servidor)
local function executarGolpe(p: Player, st: EstadoJogador, golpe: number)
	local hrp = raizDe(p)
	if not hrp then
		return
	end
	local g = MaquinaDeCombo.golpeDe(st.arma, golpe)
	local pos = hrp.Position
	local f = hrp.CFrame.LookVector
	local alcance = g.alcance + Cfg.toleranciaAlcance
	local candidatos = inimigos.proximos(pos, math.max(alcance, Cfg.mira.alcanceMax) + 4)
	local acertos = {}
	for _, c in candidatos do
		if math.abs(c.posicao.Y - pos.Y) <= 6 then
			local dentro = Alcance.noArco(pos.X, pos.Z, f.X, f.Z, c.posicao.X, c.posicao.Z, alcance, g.arcoGraus, c.raio)
			-- mira suave: o alvo escolhido pelo cliente vale com arco um pouco maior, mas nunca com alcance maior
			if not dentro and c.id == st.alvoPedido then
				dentro = Alcance.noArco(pos.X, pos.Z, f.X, f.Z, c.posicao.X, c.posicao.Z, alcance, g.arcoGraus + Cfg.mira.arcoExtraGraus, c.raio)
			end
			if dentro then
				table.insert(acertos, { c = c, d = (c.posicao - pos).Magnitude })
			end
		end
	end
	table.sort(acertos, function(a, b)
		return a.d < b.d
	end)
	local perfeito = MaquinaDeCombo.comboPerfeito(st.maquina, st.arma, golpe)
	local bonusPostura = if perfeito then st.arma.bonusPosturaComboPerfeito else 0
	local acertou = false
	for i = 1, math.min(#acertos, Cfg.maxAlvosPorGolpe) do
		local c = acertos[i].c
		local r = inimigos.receberGolpe(c.id, { dano = g.dano, postura = g.postura, bonusPostura = bonusPostura, multiplicador = 1, atacante = p })
		if r then
			acertou = true
			evento:FireAllClients(E.RESULTADO_GOLPE, c.id, r.tipo, r.dano)
		end
	end
	MaquinaDeCombo.registrarResultado(st.maquina, acertou)
end

-- avança a máquina oficial e TRATA os eventos (nunca chamar MaquinaDeCombo.atualizar direto: perderia o golpe)
local function avancar(p: Player, st: EstadoJogador, agora: number)
	local eventos = MaquinaDeCombo.atualizar(st.maquina, st.arma, Cfg, agora)
	for _, ev in eventos do
		if ev.tipo == "Golpe" then
			executarGolpe(p, st, ev.golpe)
		elseif ev.tipo == "FimGolpe" and st.maquina.estado == "Preparo" then
			-- golpe guardado começou sozinho: cobra a estamina dele agora
			local g = MaquinaDeCombo.golpeDe(st.arma, st.maquina.golpe)
			if not Estamina.gastar(st.estamina, Cfg.estamina, g.custoEstamina, agora) then
				st.maquina.estado = "Ocioso"
				st.maquina.golpe = 0
				rejeitar(p, C.ATACAR, "estamina")
			end
		end
	end
end

-- ----------------------------------------------------------------- criaturas atacando jogadores
export type AtaqueRecebido = { dano: number, postura: number }

function CombatSystem.danoAoJogador(p: Player, origem: Vector3, a: AtaqueRecebido, origemId: string): any?
	local st = estados[p]
	local hrp, hum = raizDe(p)
	if not st or not hrp or not hum then
		return nil
	end
	local agora = os.clock()
	avancar(p, st, agora)
	local f = hrp.CFrame.LookVector
	local frontal = Alcance.frontal(hrp.Position.X, hrp.Position.Z, f.X, f.Z, origem.X, origem.Z, Cfg.defesa.arcoGraus)
	local r = Dano.resolver({
		danoBase = a.dano, multiplicador = 1, defesaAlvo = 0,
		postura = a.postura,
		alvoInvulneravel = MaquinaDeCombo.invulneravel(st.maquina, Cfg, agora),
		alvoAparando = MaquinaDeCombo.aparando(st.maquina, Cfg, agora),
		alvoDefendendo = MaquinaDeCombo.defendendo(st.maquina),
		frontal = frontal,
		reducaoDefesa = Cfg.defesa.reducao,
		custoEstaminaPorDano = Cfg.defesa.custoPorDano,
		posturaAparar = Cfg.aparar.posturaNoAtacante,
	})
	if r.tipo == "Defendido" then
		if Estamina.drenar(st.estamina, Cfg.estamina, r.estaminaDoAlvo, agora) then
			MaquinaDeCombo.atordoar(st.maquina, Cfg.defesa.atordoamentoQuebra, agora) -- guarda quebrada
		end
	end
	if r.dano > 0 then
		hum:TakeDamage(r.dano)
	end
	evento:FireClient(p, E.RECEBEU_GOLPE, r.tipo, r.dano, origemId)
	if r.dano > 0 then
		CombatSystem.jogadorAtingido.disparar(p, r.dano, r.tipo)
	end
	return r
end

function CombatSystem.registrarGuarda(fn: Guarda)
	table.insert(guardas, fn)
end

local function guardasPermitem(p: Player): (boolean, string?)
	for _, g in guardas do
		local ok, motivo = g(p)
		if not ok then
			return false, motivo
		end
	end
	return true, nil
end

function CombatSystem.atordoado(p: Player): boolean
	local st = estados[p]
	return st ~= nil and st.maquina.estado == "Atordoado"
end

-- troca a arma do jogador (só entre golpes: volta a máquina a Ocioso para não misturar tempos de armas)
function CombatSystem.definirArma(p: Player, arma: any)
	armas[p] = arma
	local st = estados[p]
	if st and st.arma ~= arma then
		st.arma = arma
		if st.maquina.estado ~= "Atordoado" then
			st.maquina = MaquinaDeCombo.nova(os.clock())
		end
	end
end

-- ----------------------------------------------------------------- intenções do cliente
local function aoReceber(p: Player, tipo: any, a: any, b: any)
	local st = estados[p]
	if not st or typeof(tipo) ~= "number" then
		return
	end
	local agora = os.clock()
	if not LimiteDeTaxa.consumir(st.balde, agora) then
		return -- excesso silencioso (o contador 'excedidos' fica para o registro anti-abuso)
	end
	if not raizDe(p) then
		return
	end
	avancar(p, st, agora)
	local m = st.maquina
	if tipo ~= C.DEFESA_FIM then
		local ok, motivo = guardasPermitem(p)
		if not ok then
			rejeitar(p, tipo, motivo or "bloqueado")
			return
		end
	end
	if tipo == C.ATACAR or tipo == C.PESADO then
		st.alvoPedido = if typeof(a) == "string" and #a <= 12 then a else nil
		local estavaOcioso = m.estado == "Ocioso"
		local ok, motivo = MaquinaDeCombo.pedirAtaque(m, st.arma, Cfg, agora, tipo == C.PESADO)
		if not ok then
			rejeitar(p, tipo, motivo)
			return
		end
		if estavaOcioso then -- começou agora: cobra a estamina do golpe que iniciou
			local g = MaquinaDeCombo.golpeDe(st.arma, m.golpe)
			if not Estamina.gastar(st.estamina, Cfg.estamina, g.custoEstamina, agora) then
				m.estado = "Ocioso"
				m.golpe = 0
				rejeitar(p, tipo, "estamina")
			end
		end
	elseif tipo == C.ESQUIVAR then
		Estamina.atualizar(st.estamina, Cfg.estamina, agora)
		if st.estamina.valor < Cfg.esquiva.custo then
			rejeitar(p, tipo, "estamina")
			return
		end
		local ok, motivo = MaquinaDeCombo.pedirEsquiva(m, Cfg, agora)
		if ok then
			Estamina.gastar(st.estamina, Cfg.estamina, Cfg.esquiva.custo, agora)
		else
			rejeitar(p, tipo, motivo)
		end
	elseif tipo == C.DEFESA_INICIO then
		local ok, motivo = MaquinaDeCombo.iniciarDefesa(m, agora)
		if not ok then
			rejeitar(p, tipo, motivo)
		end
	elseif tipo == C.DEFESA_FIM then
		MaquinaDeCombo.soltarDefesa(m, agora)
	end
end

-- ----------------------------------------------------------------- laço do servidor
local function passo()
	local agora = os.clock()
	for p, st in estados do
		avancar(p, st, agora)
		Estamina.atualizar(st.estamina, Cfg.estamina, agora)
		local v = math.floor(st.estamina.valor)
		if v ~= st.ultimaEstaminaEnviada and agora - st.ultimoEnvioEstamina >= 0.2 then
			st.ultimaEstaminaEnviada = v
			st.ultimoEnvioEstamina = agora
			evento:FireClient(p, E.ESTAMINA, v, st.estamina.max)
		end
		if st.maquina.estado ~= st.ultimoEstadoEnviado then
			st.ultimoEstadoEnviado = st.maquina.estado
			evento:FireClient(p, E.ESTADO, st.maquina.estado)
		end
	end
end

function CombatSystem.Init(ctx: any)
	ctxSalvo = ctx
	evento = Remotos.evento("Combate")
end

function CombatSystem.Start()
	inimigos = ctxSalvo.obter("EnemySystem")
	local function entrar(p: Player)
		estados[p] = novoEstado()
		p.CharacterAdded:Connect(function()
			local st = novoEstado() -- renascer zera o combate (mas mantém a arma escolhida)
			st.arma = armas[p] or Espada
			estados[p] = st
		end)
	end
	for _, p in Players:GetPlayers() do
		entrar(p)
	end
	Players.PlayerAdded:Connect(entrar)
	Players.PlayerRemoving:Connect(function(p)
		estados[p] = nil
		armas[p] = nil
	end)
	evento.OnServerEvent:Connect(aoReceber)
	RunService.Heartbeat:Connect(passo)
end

return CombatSystem
