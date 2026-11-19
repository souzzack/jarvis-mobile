--!strict
-- NÃO EXECUTADO NO STUDIO. MovementSystem: autoridade da locomoção (MovementStateMachine no servidor).
-- Cobre, sobre UM núcleo de física e UMA máquina de estados, o que o documento chama de FlightSystem,
-- GliderSystem e a parte de servidor do TransportSystem (veja docs/08: um núcleo, vários perfis — sem módulos
-- duplicados). Montarias e artefatos entram por API (entrarModoDeArtefato, registrarPerfil, fontes de mods).
--
-- Divisão de autoridade:
--   * o CLIENTE é dono da física do próprio personagem (resposta imediata) e integra FisicaDeVoo com o perfil
--     que ESTE sistema calculou e enviou;
--   * o SERVIDOR decide estado/modo, cobra e recupera energia, mede o mundo (chão, zonas, espaço livre),
--     e confere o deslocamento a 10 Hz (ValidadorDeDeslocamento), corrigindo quem passar dos limites.
-- O cliente nunca envia posição, velocidade ou perfil: só intenções (Remotos.Locomocao).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local G = ReplicatedStorage:WaitForChild("Guardioes")
local Perfis = require(G.Config.Locomocao.Perfis)
local Regras = require(G.Config.Locomocao.Regras)
local MaqLoc = require(G.Locomocao.MaquinaDeLocomocao)
local Fisica = require(G.Locomocao.FisicaDeVoo)
local PerfilEfetivo = require(G.Locomocao.PerfilEfetivo)
local Validador = require(G.Locomocao.ValidadorDeDeslocamento)
local Estamina = require(G.Combate.Estamina)
local LimiteDeTaxa = require(G.Util.LimiteDeTaxa)
local Sinal = require(G.Util.Sinal)
local Remotos = require(G.Rede.Remotos)
local ConfigServidor = require(script.Parent.Parent.ConfigServidor)
local Secreto = require(script.Parent.Parent.ConfigSecreta.ArcoDasAsasPerdidas)

local L = Remotos.Locomocao
local EL = Remotos.EventoLocomocao

-- registro de perfis: públicos + só-servidor (???) + os que montarias registrarem
local perfis: { [string]: any } = {}
for id, p in Perfis.porId do
	perfis[id] = p
end
perfis[Secreto.perfil.id] = Secreto.perfil

-- perfis que o jogador ativa direto por intenção (os outros só via artefato/montaria, chamados pelo servidor)
local ACESSO_DIRETO: { [string]: string } = { VooMagico = "VooMagico", AsasNaturais = "AsasNaturais", Planador = "Planador" }

-- a pé o servidor não confere deslocamento por padrão: o tycoon e outros sistemas antigos teleportam jogadores
-- e mudam WalkSpeed. Ligar quando a auditoria do tycoon (docs/04, seção 6) confirmar que é seguro.
local VALIDAR_A_PE = false

type Estado = {
	maq: MaqLoc.Maquina,
	energia: Estamina.Recurso,
	cfgEnergia: Estamina.ConfigRecurso,
	perfil: any?,
	registro: Validador.Registro,
	balde: LimiteDeTaxa.Balde,
	limiteAnterior: Validador.Limites?,
	ultimaPos: Vector3?,
	ultimoT: number,
	velHorizontalMedida: number,
	ultimoEstadoEnviado: string,
	ultimoModoEnviado: string?,
	ultimaEnergiaEnviada: number,
	ultimoEnvioEnergia: number,
	modoArtefato: string?,
	perfilMontaria: string?, -- perfil de voo da montaria atual (nil = montaria terrestre)
	velMontaria: number, -- velocidade no chão da montaria (para a conferência)
}

local MovementSystem = { Nome = "MovementSystem" }
MovementSystem.mudouEstado = Sinal.novo() -- (p, estado, modo)

local estados: { [Player]: Estado } = {}
local evento: RemoteEvent
local habilidades: any
local combate: any
local ctxSistemas: any = nil
local fontesExtras: { (Player, string) -> { any } } = {}
local zonas: { BasePart } = {}

local raycast = RaycastParams.new()
raycast.FilterType = Enum.RaycastFilterType.Exclude
local sobreposicao = OverlapParams.new()
sobreposicao.FilterType = Enum.RaycastFilterType.Exclude
sobreposicao.RespectCanCollide = true

-- ------------------------------------------------------------------ medições do mundo (servidor)
local function corpo(p: Player): (BasePart?, Humanoid?)
	local ch = p.Character
	if not ch then
		return nil, nil
	end
	local hrp = ch:FindFirstChild("HumanoidRootPart") :: BasePart?
	local hum = ch:FindFirstChildOfClass("Humanoid")
	if hrp and hum and hum.Health > 0 then
		return hrp, hum
	end
	return nil, nil
end

local function dentroDeZona(pos: Vector3): boolean
	for _, z in zonas do
		if z.Parent then
			local rel = z.CFrame:PointToObjectSpace(pos)
			local s = z.Size / 2
			if math.abs(rel.X) <= s.X and math.abs(rel.Y) <= s.Y and math.abs(rel.Z) <= s.Z then
				return true
			end
		end
	end
	return false
end

local function medir(p: Player, st: Estado, hrp: BasePart, hum: Humanoid): MaqLoc.Contexto
	local ignorar = { p.Character :: Instance }
	local pastaInimigos = Workspace:FindFirstChild("GuardioesInimigos")
	if pastaInimigos then
		table.insert(ignorar, pastaInimigos)
	end
	raycast.FilterDescendantsInstances = ignorar
	local r = Workspace:Raycast(hrp.Position, Vector3.new(0, -300, 0), raycast)
	local pe = hum.HipHeight + hrp.Size.Y / 2
	local altura = if r then math.max(0, hrp.Position.Y - r.Position.Y - pe) else 300
	local noSolo = altura <= 0.6
	if st.maq.estado == "Solo" or st.maq.estado == "Montado" then
		noSolo = noSolo or hum.FloorMaterial ~= Enum.Material.Air
	end
	sobreposicao.FilterDescendantsInstances = ignorar
	local livre = #Workspace:GetPartBoundsInBox(hrp.CFrame * CFrame.new(0, 3, 0), Vector3.new(3, 4, 3), sobreposicao) == 0
	-- (a energia é atualizada só em passoJogador: aqui medir não pode recuperar energia no ar)
	return {
		noSolo = noSolo,
		altura = altura,
		zonaProibida = dentroDeZona(hrp.Position),
		espacoLivre = livre,
		atordoado = combate.atordoado(p),
		energia = st.energia.valor,
		movendo = st.velHorizontalMedida > 2,
	}
end

-- ------------------------------------------------------------------ perfis
local function perfilEfetivo(p: Player, id: string): any?
	local base = perfis[id]
	if not base then
		return nil
	end
	local fontes = habilidades.fontes(p)
	for _, fn in fontesExtras do
		for _, f in fn(p, id) do
			table.insert(fontes, f)
		end
	end
	return PerfilEfetivo.calcular(base, fontes)
end

local function limitesDe(st: Estado): Validador.Limites
	local e = st.maq.estado
	local alturaMax = Regras.alturaMaxAbsoluta
	if e == "Solo" or e == "Montado" or not st.perfil then
		local s = Regras.solo
		local h = if e == "Montado" then math.max(s.velHorizontal, st.velMontaria * 1.1) else s.velHorizontal
		return { velHorizontal = h, velSubida = s.velSubida, velQueda = s.velQueda, alturaMax = alturaMax }
	end
	local l = Fisica.limites(st.perfil)
	if e == "Interrompido" or e == "Descida" or e == "Pouso" then
		l.velQueda = math.max(l.velQueda, Regras.interrupcao.velQuedaAmortecida)
	end
	return { velHorizontal = l.velHorizontal, velSubida = l.velSubida, velQueda = l.velQueda, alturaMax = alturaMax }
end

local function maxLimites(a: Validador.Limites, b: Validador.Limites?): Validador.Limites
	if not b then
		return a
	end
	return {
		velHorizontal = math.max(a.velHorizontal, b.velHorizontal),
		velSubida = math.max(a.velSubida, b.velSubida),
		velQueda = math.max(a.velQueda, b.velQueda),
		alturaMax = math.max(a.alturaMax, b.alturaMax),
	}
end

-- ------------------------------------------------------------------ rede
local function sincronizar(p: Player, st: Estado, motivo: string?)
	local m = st.maq
	if m.modo ~= st.ultimoModoEnviado and st.perfil then
		evento:FireClient(p, EL.PERFIL, st.perfil)
	end
	if m.estado ~= st.ultimoEstadoEnviado or m.modo ~= st.ultimoModoEnviado or motivo then
		st.ultimoEstadoEnviado = m.estado
		st.ultimoModoEnviado = m.modo
		evento:FireClient(p, EL.ESTADO, m.estado, m.modo, motivo or m.motivo)
		local ch = p.Character
		if ch then -- atributos replicados: os outros clientes desenham efeitos a partir deles
			ch:SetAttribute("LocEstado", m.estado)
			ch:SetAttribute("LocModo", m.modo)
			ch:SetAttribute("LocEfeito", if st.perfil then st.perfil.efeito else nil)
		end
		MovementSystem.mudouEstado.disparar(p, m.estado, m.modo)
	end
end

local function rejeitar(p: Player, acao: number, motivo: string)
	evento:FireClient(p, EL.REJEITADO, acao, motivo)
end

local function novoEstado(p: Player): Estado
	local agora = os.clock()
	local raca = habilidades.raca(p)
	local mult = 1
	if raca then
		for _, mod in raca.mods do
			if mod.campo == "energiaMax" and mod.multiplicar then
				mult *= mod.multiplicar
			end
		end
	end
	local cfgEnergia = { max = Regras.energia.max * mult, recuperacaoPorSeg = Regras.energia.recuperacaoPorSeg, atrasoRecuperacao = Regras.energia.atrasoRecuperacao }
	return {
		maq = MaqLoc.nova(agora),
		energia = Estamina.nova(cfgEnergia.max, agora),
		cfgEnergia = cfgEnergia,
		perfil = nil,
		registro = Validador.novoRegistro(),
		balde = LimiteDeTaxa.novo(Regras.rede.capacidadeBalde, Regras.rede.recargaPorSeg, agora),
		limiteAnterior = nil,
		ultimaPos = nil,
		ultimoT = agora,
		velHorizontalMedida = 0,
		ultimoEstadoEnviado = "",
		ultimoModoEnviado = nil,
		ultimaEnergiaEnviada = -1,
		ultimoEnvioEnergia = 0,
		modoArtefato = nil,
		perfilMontaria = nil,
		velMontaria = 0,
	}
end

-- ------------------------------------------------------------------ intenções do cliente
local function aoReceber(p: Player, tipo: any, a: any)
	local st = estados[p]
	if not st or typeof(tipo) ~= "number" then
		return
	end
	local agora = os.clock()
	if not LimiteDeTaxa.consumir(st.balde, agora) then
		return
	end
	local hrp, hum = corpo(p)
	if not hrp or not hum then
		return
	end
	local ctx = medir(p, st, hrp, hum)
	if tipo == L.DECOLAR and a == "Montaria" then
		-- voo da montaria: só montado numa espécie voadora (o perfil foi registrado pelo MountSystem)
		local perfil = if st.perfilMontaria then perfilEfetivo(p, st.perfilMontaria) else nil
		if not perfil then
			rejeitar(p, tipo, if st.maq.estado == "Montado" then "montariaNaoVoa" else "semMontaria")
			return
		end
		local ok, motivo = MaqLoc.decolar(st.maq, perfil, ctx, Regras.energia.minDecolar, agora)
		if ok then
			st.perfil = perfil
			sincronizar(p, st)
		else
			rejeitar(p, tipo, motivo)
		end
	elseif tipo == L.DECOLAR then
		if typeof(a) ~= "string" or ACESSO_DIRETO[a] == nil or a == "Planador" then
			rejeitar(p, tipo, "perfilInvalido")
			return
		end
		if not habilidades.tem(p, ACESSO_DIRETO[a]) then
			rejeitar(p, tipo, "naoAprendido")
			return
		end
		local perfil = perfilEfetivo(p, a)
		if not perfil then
			return
		end
		local ok, motivo = MaqLoc.decolar(st.maq, perfil, ctx, Regras.energia.minDecolar, agora)
		if ok then
			st.perfil = perfil
			sincronizar(p, st)
		else
			rejeitar(p, tipo, motivo)
		end
	elseif tipo == L.POUSAR then
		local ok, motivo = MaqLoc.pousar(st.maq, agora)
		if ok then
			sincronizar(p, st)
		else
			rejeitar(p, tipo, motivo)
		end
	elseif tipo == L.IMPULSO then
		if st.perfil then
			local ok, motivo = MaqLoc.impulso(st.maq, st.perfil, a == true, agora)
			if not ok and a == true then
				rejeitar(p, tipo, motivo)
			end
			sincronizar(p, st)
		end
	elseif tipo == L.PLANADOR_ABRIR then
		if not habilidades.tem(p, "Planador") then
			rejeitar(p, tipo, "naoAprendido")
			return
		end
		if ctx.zonaProibida then
			rejeitar(p, tipo, "zonaProibida")
			return
		end
		local perfil = perfilEfetivo(p, "Planador")
		local ok, motivo = MaqLoc.abrirPlanador(st.maq, perfil, ctx, Regras.planador.alturaMinAbrir, agora)
		if ok then
			st.perfil = perfil
			sincronizar(p, st)
		else
			rejeitar(p, tipo, motivo)
		end
	elseif tipo == L.PLANADOR_FECHAR then
		if MaqLoc.fecharPlanador(st.maq, agora) then
			st.perfil = nil
			sincronizar(p, st)
		end
	end
end

-- ------------------------------------------------------------------ laço (10 Hz)
local function custoPorSeg(st: Estado): number
	local p = st.perfil
	if not p or st.maq.tipoModo == "Planador" then
		return 0
	end
	local e = st.maq.estado
	if e == "Impulso" then
		return p.custoImpulsoPorSeg
	elseif e == "Voo" then
		return p.custoPorSeg
	elseif e == "Pairar" or e == "Decolagem" then
		return p.custoPairarPorSeg
	end
	return 0
end

local function passoJogador(p: Player, st: Estado, agora: number)
	local hrp, hum = corpo(p)
	if not hrp or not hum then
		return
	end
	-- velocidade horizontal MEDIDA pelo servidor (não a que o cliente diz)
	local pos = hrp.Position
	local dt = agora - st.ultimoT
	if st.ultimaPos and dt > 0 then
		local d = pos - (st.ultimaPos :: Vector3)
		st.velHorizontalMedida = Vector3.new(d.X, 0, d.Z).Magnitude / dt
	end
	st.ultimaPos, st.ultimoT = pos, agora

	-- energia: gasta no voo motorizado; recupera só no chão; no ar sem custo (planador/queda) fica parada
	local custo = custoPorSeg(st)
	if custo > 0 then
		Estamina.drenar(st.energia, st.cfgEnergia, custo * dt, agora)
	elseif MaqLoc.recuperaEnergia(st.maq) then
		Estamina.atualizar(st.energia, st.cfgEnergia, agora)
	else
		st.energia.ultimaAtualizacao = agora
	end

	local ctx = medir(p, st, hrp, hum)
	local eventos = MaqLoc.atualizar(st.maq, st.perfil, ctx, Regras.interrupcao.duracao, agora)
	local motivo: string? = nil
	for _, ev in eventos do
		if ev.tipo == "Interrompido" then
			motivo = ev.motivo
		end
	end
	if st.maq.modo == nil then
		st.perfil = nil
		st.modoArtefato = nil
	end
	if st.maq.montariaId == nil then
		st.perfilMontaria = nil
		st.velMontaria = 0
	end
	sincronizar(p, st, motivo)

	-- conferência de deslocamento
	if MaqLoc.noAr(st.maq) or VALIDAR_A_PE then
		local lim = maxLimites(limitesDe(st), st.limiteAnterior)
		local v = Regras.validacao
		local amostra = { x = pos.X, y = pos.Y, z = pos.Z, t = agora }
		local corrigir, volta = Validador.registrar(st.registro, amostra, lim, v.fatorVelocidade, v.folgaStuds, v.violacoesParaCorrigir)
		if corrigir and volta then
			local ch = p.Character :: Model
			local giro = hrp.CFrame - hrp.CFrame.Position
			ch:PivotTo(CFrame.new(volta.x, volta.y, volta.z) * giro)
			hrp.AssemblyLinearVelocity = Vector3.zero
			evento:FireClient(p, EL.CORRECAO, volta.x, volta.y, volta.z)
		end
	else
		Validador.reancorar(st.registro, { x = pos.X, y = pos.Y, z = pos.Z, t = agora })
	end
	st.limiteAnterior = limitesDe(st)

	local e = math.floor(st.energia.valor)
	if e ~= st.ultimaEnergiaEnviada and agora - st.ultimoEnvioEnergia >= 0.2 then
		st.ultimaEnergiaEnviada = e
		st.ultimoEnvioEnergia = agora
		evento:FireClient(p, EL.ENERGIA, e, st.energia.max)
	end
end

-- ------------------------------------------------------------------ API para outros sistemas (servidor)
function MovementSystem.registrarPerfil(perfil: any)
	perfis[perfil.id] = perfil
end

-- fn(p, perfilId) -> lista de fontes de mods (ex.: bônus de estágio do artefato equipado)
function MovementSystem.registrarFonteDeMods(fn: (Player, string) -> { any })
	table.insert(fontesExtras, fn)
end

function MovementSystem.estado(p: Player): (string?, string?)
	local st = estados[p]
	if not st then
		return nil, nil
	end
	return st.maq.estado, st.maq.modo
end

function MovementSystem.energia(p: Player): number
	local st = estados[p]
	return if st then st.energia.valor else 0
end

function MovementSystem.gastarEnergia(p: Player, quanto: number): boolean
	local st = estados[p]
	return st ~= nil and Estamina.gastar(st.energia, st.cfgEnergia, quanto, os.clock())
end

-- pode começar um modo de artefato agora? (checado ANTES de iniciar a transformação)
function MovementSystem.podeEntrarModo(p: Player, perfilId: string): (boolean, string)
	local st = estados[p]
	local hrp, hum = corpo(p)
	if not st or not hrp or not hum then
		return false, "semPersonagem"
	end
	if not perfis[perfilId] then
		return false, "perfilInvalido"
	end
	if st.maq.estado ~= "Solo" then
		return false, st.maq.estado
	end
	local ctx = medir(p, st, hrp, hum)
	if ctx.zonaProibida then
		return false, "zonaProibida"
	end
	if not ctx.espacoLivre then
		return false, "semEspaco"
	end
	if ctx.energia < Regras.energia.minDecolar then
		return false, "energia"
	end
	return true, "ok"
end

function MovementSystem.entrarModoDeArtefato(p: Player, perfilId: string): (boolean, string)
	local st = estados[p]
	local hrp, hum = corpo(p)
	if not st or not hrp or not hum then
		return false, "semPersonagem"
	end
	local perfil = perfilEfetivo(p, perfilId)
	if not perfil then
		return false, "perfilInvalido"
	end
	local ok, motivo = MaqLoc.decolar(st.maq, perfil, medir(p, st, hrp, hum), Regras.energia.minDecolar, os.clock())
	if ok then
		st.perfil = perfil
		st.modoArtefato = perfilId
		sincronizar(p, st)
	end
	return ok, motivo
end

-- Retorno ao combate: sai do modo do artefato. No ar: queda amortecida (Interrompido → Descida sem perfil).
function MovementSystem.sairModoDeArtefato(p: Player, duracaoQueda: number)
	local st = estados[p]
	if not st or not st.modoArtefato or st.maq.modo ~= st.modoArtefato then
		return
	end
	local agora = os.clock()
	st.modoArtefato = nil
	if MaqLoc.noAr(st.maq) and st.maq.estado ~= "Pouso" then
		MaqLoc.interromper(st.maq, "retornoAoCombate", duracaoQueda, agora)
		st.maq.modo, st.maq.tipoModo = "Queda", "Queda"
		st.perfil = nil
	else
		MaqLoc.reiniciar(st.maq, agora)
		st.perfil = nil
	end
	sincronizar(p, st, "retornoAoCombate")
end

-- Montaria (chamado pelo MountSystem, que já validou criatura, estágio, distância e espaço da espécie)
function MovementSystem.montar(p: Player, guid: string, perfilVooId: string?, velMax: number): (boolean, string)
	local st = estados[p]
	local hrp, hum = corpo(p)
	if not st or not hrp or not hum then
		return false, "semPersonagem"
	end
	local ok, motivo = MaqLoc.montar(st.maq, guid, medir(p, st, hrp, hum), os.clock())
	if ok then
		st.perfilMontaria = perfilVooId
		st.velMontaria = velMax
		st.perfil = nil
		sincronizar(p, st)
	end
	return ok, motivo
end

function MovementSystem.desmontar(p: Player): (boolean, string)
	local st = estados[p]
	if not st then
		return false, "semPersonagem"
	end
	local ok, motivo = MaqLoc.desmontar(st.maq, os.clock())
	if ok then
		st.perfilMontaria = nil
		st.velMontaria = 0
		st.perfil = nil
		sincronizar(p, st)
	end
	return ok, motivo
end

function MovementSystem.montado(p: Player): string?
	local st = estados[p]
	return if st then st.maq.montariaId else nil
end

-- teleporte legítimo do servidor (portal, renascer): volta ao chão e reancora a conferência
function MovementSystem.reancorar(p: Player)
	local st = estados[p]
	local hrp = corpo(p)
	if st then
		MaqLoc.reiniciar(st.maq, os.clock())
		st.perfil, st.modoArtefato, st.ultimaPos = nil, nil, nil
		if hrp then
			Validador.reancorar(st.registro, { x = hrp.Position.X, y = hrp.Position.Y, z = hrp.Position.Z, t = os.clock() })
		end
		sincronizar(p, st, "reancorado")
	end
end

-- ------------------------------------------------------------------ ciclo de vida
function MovementSystem.Init(ctx: any)
	ctxSistemas = ctx
	evento = Remotos.evento("Locomocao")
end

function MovementSystem.Start()
	habilidades = ctxSistemas.obter("MovementAbilitySystem")
	combate = ctxSistemas.obter("CombatSystem")

	-- zonas sem voo
	local pasta = Workspace:FindFirstChild(ConfigServidor.pastaZonasSemVoo)
	if pasta then
		for _, z in pasta:GetDescendants() do
			if z:IsA("BasePart") then
				table.insert(zonas, z)
			end
		end
	end

	-- integração com o combate: sem ataques fora do chão; golpe forte derruba do voo
	combate.registrarGuarda(function(p: Player)
		local st = estados[p]
		if st and not MaqLoc.podeAtacar(st.maq) then
			return false, "locomocao"
		end
		return true, nil
	end)
	combate.jogadorAtingido.conectar(function(p: Player, dano: number)
		local st = estados[p]
		if st and dano >= Regras.atingidoInterrompeVoo and (MaqLoc.motorizado(st.maq) or st.maq.estado == "Planando") then
			MaqLoc.interromper(st.maq, "golpe", Regras.interrupcao.duracao, os.clock())
			sincronizar(p, st, "golpe")
		end
	end)

	local function entrar(p: Player)
		estados[p] = novoEstado(p)
		p.CharacterAdded:Connect(function()
			local antigo = estados[p]
			local st = novoEstado(p)
			if antigo then -- renascer não devolve energia cheia de graça
				st.energia.valor = antigo.energia.valor
			end
			estados[p] = st
			task.defer(sincronizar, p, st, "renasceu")
		end)
	end
	for _, p in Players:GetPlayers() do
		entrar(p)
	end
	Players.PlayerAdded:Connect(entrar)
	Players.PlayerRemoving:Connect(function(p)
		estados[p] = nil -- nada de voo é salvo: ao voltar, o personagem começa no chão
	end)
	evento.OnServerEvent:Connect(aoReceber)

	local intervalo = 1 / Regras.validacao.frequenciaHz
	local acumulado = 0
	RunService.Heartbeat:Connect(function(dt)
		acumulado += dt
		if acumulado < intervalo then
			return
		end
		acumulado = 0
		local agora = os.clock()
		for p, st in estados do
			passoJogador(p, st, agora)
		end
	end)
end

return MovementSystem
