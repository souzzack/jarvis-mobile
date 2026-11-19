--!strict
-- NÃO EXECUTADO NO STUDIO. CompanionSystem + CompanionAI (servidor) + ligação do crescimento (Etapas 6 e 7).
-- (Companheiros = criaturas individuais. Companhias = guildas: outro sistema.)
--
--  * Uma criatura ATIVA por jogador, no mundo; as outras ficam guardadas no perfil.
--  * IA a 10 Hz (Companheiros/IADoCompanheiro decide; aqui vira movimento). Personalidade vem da espécie.
--  * Movimento: AlignPosition/AlignOrientation numa peça-raiz (física do servidor). As criaturas de solo
--    acompanham a altura do chão; as que flutuam/planam ficam no ar. (Sem desvio de obstáculos ainda:
--    PathfindingService entra quando houver mapa real para testar.)
--  * XP compartilhada: inimigo derrotado com contribuição do dono e a criatura por perto.
--  * Vínculo: afagar (com recarga) e batalhas, com teto diário por atividade (DadosDaCriatura).
--  * Evoluir: só o servidor confere (Crescimento). Permanente e salvo. Modelo troca pelo do estágio.
--  * Persistência: perfil.companheiros[guid] via PlayerData.atualizar (transação). Criaturas de TESTE nunca
--    são salvas.
--  * Modelo PROVISÓRIO procedural (blocos com a cor e o porte da espécie); os modelos reais vêm do Blender.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")

local G = ReplicatedStorage:WaitForChild("Guardioes")
local Dados = require(G.Companheiros.DadosDaCriatura)
local Crescimento = require(G.Companheiros.Crescimento)
local Vinculo = require(G.Companheiros.VinculoDimensional)
local IA = require(G.Companheiros.IADoCompanheiro)
local Afinidades = require(G.Config.AfinidadesDimensionais)
local LimiteDeTaxa = require(G.Util.LimiteDeTaxa)
local Sinal = require(G.Util.Sinal)
local Remotos = require(G.Rede.Remotos)
local ConfigServidor = require(script.Parent.Parent.ConfigServidor)

local C = Remotos.Companheiro
local EC = Remotos.EventoCompanheiro

local especies: { [string]: any } = {}
for _, m in G.Config.Especies:GetChildren() do
	if m:IsA("ModuleScript") then
		local e = require(m) :: any
		especies[e.id] = e
	end
end

-- (T) valores provisórios
local VEL_POR_ESTILO: { [string]: number } = { Flutua = 14, Saltita = 18, Trota = 20, Plana = 22 }
local DANO_POR_ESTAGIO: { [string]: number } = { Filhote = 3, Juvenil = 6, Adulto = 10 }
local XP_POR_VITORIA = 20
local VINCULO_BATALHA = 10
local VINCULO_AFAGO = 15
local RECARGA_AFAGO = 10
local RAIO_XP = 40
-- aparência provisória: tamanho do corpo adulto e cor por espécie
local VISUAL: { [string]: { corpo: Vector3, cor: string } } = {
	AxoloteNebular = { corpo = Vector3.new(1.6, 1.1, 2.6), cor = "#C8A8FF" },
	LebreDeFaisca = { corpo = Vector3.new(1.3, 1.5, 2.0), cor = "#FFD36B" },
	CaoTrovao = { corpo = Vector3.new(2.6, 3.0, 5.0), cor = "#5E7CFF" },
	RaiaDasNuvens = { corpo = Vector3.new(8.0, 0.8, 5.0), cor = "#7FD8FF" },
}

type Ativa = {
	guid: string,
	modelo: Model,
	raiz: BasePart,
	ap: AlignPosition,
	ao: AlignOrientation,
	comando: string,
	ancora: Vector3?,
	proximoAtaque: number,
	montada: boolean,
}
type Jogador = {
	criaturas: { [string]: any },
	teste: { [string]: boolean },
	ativa: Ativa?,
	balde: LimiteDeTaxa.Balde,
	ultimoAfago: number,
	listaPendente: boolean,
}

local CompanionSystem = { Nome = "CompanionSystem" }
CompanionSystem.mudouAtiva = Sinal.novo() -- (p, guid?)

local jogadores: { [Player]: Jogador } = {}
local evento: RemoteEvent
local playerData: any
local inimigos: any
local inventario: any
local ctxSistemas: any = nil
local pasta: Folder

local raycast = RaycastParams.new()
raycast.FilterType = Enum.RaycastFilterType.Exclude

-- cópia profunda: o registro em memória nunca compartilha tabelas com o perfil salvo
local function copiar(v: any): any
	if type(v) ~= "table" then
		return v
	end
	local c = {}
	for k, x in v do
		c[k] = copiar(x)
	end
	return c
end

local function hoje(): number
	return os.time() // 86400
end

-- ------------------------------------------------------------------ persistência
local function gravar(p: Player, j: Jogador, guid: string)
	if j.teste[guid] then
		return
	end
	local c = j.criaturas[guid]
	playerData.atualizar(p, function(perfil)
		perfil.companheiros[guid] = copiar(c)
		return true
	end)
end

local function gravarAtiva(p: Player, j: Jogador)
	local guid = if j.ativa then j.ativa.guid else nil
	playerData.atualizar(p, function(perfil)
		perfil.criaturaAtiva = if guid and not j.teste[guid] then guid else nil
		return true
	end)
end

-- ------------------------------------------------------------------ interface (cartões)
local function cartao(j: Jogador, c: any): any
	local esp = especies[c.especie]
	local pode, faltando = Crescimento.avaliar(c, esp)
	local montavel = Crescimento.podeMontar(c, esp)
	local ativa = j.ativa and j.ativa.guid == c.guid
	return {
		guid = c.guid, nome = c.nome, especie = c.especie, especieNome = esp.nome, estagio = c.estagio,
		xp = c.xp, nivelVinculo = Dados.nivelVinculo(c), vinculo = c.vinculo,
		ativa = ativa, comando = if ativa then (j.ativa :: Ativa).comando else nil,
		podeEvoluir = pode, faltando = faltando,
		podeMontar = montavel, montariaTipo = if esp.montaria then esp.montaria.tipo else nil,
		especializacao = c.especializacao, afinidades = c.afinidades, habilidades = Vinculo.habilidadesEfetivas(c, Afinidades),
		teste = j.teste[c.guid] == true,
	}
end

local function enviarLista(p: Player)
	local j = jogadores[p]
	if not j then
		return
	end
	j.listaPendente = false
	local lista = {}
	for _, c in j.criaturas do
		table.insert(lista, cartao(j, c))
	end
	table.sort(lista, function(a, b)
		return a.nome < b.nome
	end)
	evento:FireClient(p, EC.LISTA, lista)
end

local function rejeitar(p: Player, acao: number, motivo: string)
	evento:FireClient(p, EC.REJEITADO, acao, motivo)
end

-- ------------------------------------------------------------------ modelo no mundo
local function construir(c: any, dono: Player, onde: CFrame): (Model, BasePart, AlignPosition, AlignOrientation)
	local esp = especies[c.especie]
	local v = VISUAL[c.especie] or { corpo = Vector3.new(2, 2, 2), cor = "#FFFFFF" }
	local escala = esp.estagios[c.estagio].escala or 1
	local cor = Color3.fromHex(v.cor)
	local modelo = Instance.new("Model")
	modelo.Name = "Companheiro_" .. c.nome
	local raiz = Instance.new("Part")
	raiz.Name = "Corpo"
	raiz.Size = v.corpo * escala
	raiz.Color = cor
	raiz.Material = Enum.Material.SmoothPlastic
	raiz.CanCollide = false
	raiz.CanTouch = false
	raiz.CFrame = onde
	raiz.Parent = modelo
	-- cabeça e olhos: leitura de "para onde olha" (provisório)
	local cabeca = Instance.new("Part")
	cabeca.Name = "Cabeca"
	local t = math.min(raiz.Size.X, raiz.Size.Y) * 0.8
	cabeca.Size = Vector3.new(t, t, t)
	cabeca.Color = cor:Lerp(Color3.new(1, 1, 1), 0.2)
	cabeca.CanCollide, cabeca.CanTouch, cabeca.Massless = false, false, true
	cabeca.CFrame = raiz.CFrame * CFrame.new(0, raiz.Size.Y * 0.3, -raiz.Size.Z / 2 - t * 0.35)
	cabeca.Parent = modelo
	local solda = Instance.new("WeldConstraint")
	solda.Part0, solda.Part1 = raiz, cabeca
	solda.Parent = cabeca
	for _, lado in { -1, 1 } do
		local olho = Instance.new("Part")
		olho.Shape = Enum.PartType.Ball
		olho.Size = Vector3.one * t * 0.22
		olho.Material = Enum.Material.Neon
		olho.Color = Color3.fromHex("#FFFFFF")
		olho.CanCollide, olho.CanTouch, olho.Massless = false, false, true
		olho.CFrame = cabeca.CFrame * CFrame.new(lado * t * 0.25, t * 0.1, -t / 2)
		olho.Parent = modelo
		local s = Instance.new("WeldConstraint")
		s.Part0, s.Part1 = cabeca, olho
		s.Parent = olho
	end
	modelo.PrimaryPart = raiz
	local at = Instance.new("Attachment")
	at.Parent = raiz
	local ap = Instance.new("AlignPosition")
	ap.Mode = Enum.PositionAlignmentMode.OneAttachment
	ap.Attachment0 = at
	ap.MaxForce = 1e6
	ap.Responsiveness = 18
	ap.MaxVelocity = VEL_POR_ESTILO[esp.comportamento.estilo] or 16
	ap.Position = onde.Position
	ap.Parent = raiz
	local ao = Instance.new("AlignOrientation")
	ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
	ao.Attachment0 = at
	ao.MaxTorque = 1e6
	ao.Responsiveness = 12
	ao.CFrame = onde.Rotation
	ao.Parent = raiz
	modelo:SetAttribute("GuardioesCompanheiro", c.guid)
	modelo:SetAttribute("DonoId", dono.UserId)
	modelo:SetAttribute("Especie", esp.nome)
	modelo:SetAttribute("Estagio", c.estagio)
	modelo:SetAttribute("Nome", c.nome)
	modelo:SetAttribute("Acao", "Parado")
	modelo.Parent = pasta
	pcall(function()
		raiz:SetNetworkOwner(nil) -- a criatura é do servidor (a IA decide aqui)
	end)
	return modelo, raiz, ap, ao
end

local function desativar(j: Jogador)
	if j.ativa then
		j.ativa.modelo:Destroy()
		j.ativa = nil
	end
end

local function ativar(p: Player, j: Jogador, guid: string): boolean
	local c = j.criaturas[guid]
	local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not c or not hrp then
		return false
	end
	desativar(j)
	local onde = (hrp :: BasePart).CFrame * CFrame.new(3, 1, 3)
	local modelo, raiz, ap, ao = construir(c, p, onde)
	j.ativa = { guid = guid, modelo = modelo, raiz = raiz, ap = ap, ao = ao, comando = "Acompanhar", ancora = nil, proximoAtaque = 0, montada = false }
	CompanionSystem.mudouAtiva.disparar(p, guid)
	return true
end

-- ------------------------------------------------------------------ IA (10 Hz)
local function alturaDoChao(x: number, z: number, yRef: number, ignorar: { Instance }): number?
	raycast.FilterDescendantsInstances = ignorar
	local r = Workspace:Raycast(Vector3.new(x, yRef + 20, z), Vector3.new(0, -80, 0), raycast)
	return if r then r.Position.Y else nil
end

local function pensar(p: Player, j: Jogador, agora: number)
	local a = j.ativa
	if not a or a.montada or not a.modelo.Parent then
		return
	end
	local c = j.criaturas[a.guid]
	local esp = especies[c.especie]
	local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	local pos = a.raiz.Position
	local dono, olha = nil, nil
	if hrp then
		dono = { x = hrp.Position.X, y = hrp.Position.Y, z = hrp.Position.Z }
		olha = { x = hrp.CFrame.LookVector.X, z = hrp.CFrame.LookVector.Z }
	end
	-- inimigo mais próximo do dono (ou da âncora)
	local centro = if a.comando == "Permanecer" and a.ancora then a.ancora else (if hrp then hrp.Position else pos)
	local inimigo = nil
	local melhor = math.huge
	for _, e in inimigos.proximos(centro, IA.ALCANCE_ATAQUE) do
		local d = (e.posicao - centro).Magnitude
		if d < melhor then
			melhor = d
			inimigo = { x = e.posicao.X, y = e.posicao.Y, z = e.posicao.Z, id = e.id, raio = e.raio }
		end
	end
	local dec = IA.decidir({
		comando = a.comando,
		dono = dono,
		donoOlha = olha,
		criatura = { x = pos.X, y = pos.Y, z = pos.Z },
		ancora = if a.ancora then { x = a.ancora.X, y = a.ancora.Y, z = a.ancora.Z } else nil,
		inimigo = inimigo,
		interesse = nil, -- (Etapa 14) pontos de interesse marcados no mapa real
		comportamento = esp.comportamento,
		aleatorio = math.random(),
	})
	a.modelo:SetAttribute("Acao", dec.acao)
	if a.comando == "Retornar" and dono and (pos - (hrp :: BasePart).Position).Magnitude < 6 then
		a.comando = "Acompanhar"
		j.listaPendente = true
	end
	local alvo = dec.alvo
	if not alvo then
		a.ap.Position = pos
		return
	end
	local destino = Vector3.new(alvo.x, alvo.y, alvo.z)
	local estilo = esp.comportamento.estilo
	if estilo == "Trota" or estilo == "Saltita" then
		local chao = alturaDoChao(destino.X, destino.Z, destino.Y, { a.modelo, p.Character :: Instance })
		if chao then
			local pulo = if estilo == "Saltita" and dec.acao ~= "Parado" then math.abs(math.sin(agora * 9)) * 0.9 else 0
			destino = Vector3.new(destino.X, chao + a.raiz.Size.Y / 2 + pulo, destino.Z)
		end
	end
	if dec.acao == "Teleportar" then
		a.modelo:PivotTo(CFrame.new(destino))
		a.ap.Position = destino
		return
	end
	if dec.acao == "Atacar" and inimigo then
		local alvoPos = Vector3.new(inimigo.x, destino.Y, inimigo.z)
		local dir = (pos - alvoPos)
		dir = if dir.Magnitude > 0.1 then dir.Unit else Vector3.xAxis
		destino = alvoPos + dir * ((inimigo.raio or 1.5) + a.raiz.Size.Z / 2 + 0.5)
		if (pos - alvoPos).Magnitude <= (inimigo.raio or 1.5) + a.raiz.Size.Z / 2 + 3 and agora >= a.proximoAtaque then
			a.proximoAtaque = agora + 1.2
			local fator = if esp.papel == "Combate" then 1 else 0.5
			inimigos.receberGolpe(inimigo.id, {
				dano = math.floor((DANO_POR_ESTAGIO[c.estagio] or 3) * fator + 0.5),
				postura = 6, bonusPostura = 0, multiplicador = 1, atacante = p,
			})
		end
	end
	a.ap.MaxVelocity = (VEL_POR_ESTILO[estilo] or 16) * math.max(0.3, dec.velocidade)
	a.ap.Position = destino
	local olharPara = Vector3.new(destino.X, pos.Y, destino.Z) - pos
	if olharPara.Magnitude > 0.5 then
		a.ao.CFrame = CFrame.lookAt(Vector3.zero, olharPara.Unit)
	end
end

-- ------------------------------------------------------------------ intenções do cliente
local function aoReceber(p: Player, tipo: any, guid: any, arg: any)
	local j = jogadores[p]
	if not j or typeof(tipo) ~= "number" or typeof(guid) ~= "string" then
		return
	end
	if not LimiteDeTaxa.consumir(j.balde, os.clock()) then
		return
	end
	local c = j.criaturas[guid]
	if not c then
		rejeitar(p, tipo, "naoPossui")
		return
	end
	local esp = especies[c.especie]
	local a = j.ativa
	if tipo == C.ATIVAR then
		if a and a.montada then
			rejeitar(p, tipo, "montado")
			return
		end
		if ativar(p, j, guid) then
			gravarAtiva(p, j)
		end
	elseif tipo == C.COMANDO then
		if not a or a.guid ~= guid or a.montada then
			rejeitar(p, tipo, "semCriatura")
			return
		end
		if arg == "Acompanhar" or arg == "Retornar" then
			a.comando, a.ancora = arg, nil
		elseif arg == "Permanecer" then
			a.comando, a.ancora = arg, a.raiz.Position
		else
			return
		end
	elseif tipo == C.AFAGAR then
		local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
		if not a or a.guid ~= guid or not hrp or (a.raiz.Position - (hrp :: BasePart).Position).Magnitude > 10 then
			rejeitar(p, tipo, "longe")
			return
		end
		local agora = os.clock()
		if agora - j.ultimoAfago < RECARGA_AFAGO then
			rejeitar(p, tipo, "cedoDemais")
			return
		end
		j.ultimoAfago = agora
		Dados.ganharVinculo(c, "Carinho", VINCULO_AFAGO, hoje())
		gravar(p, j, guid)
		-- a Raia adulta solta penas ao ser afagada (material da Espada do Horizonte, estágio 3)
		if c.especie == "RaiaDasNuvens" and c.estagio == "Adulto" and math.random() < 0.35 then
			inventario.darMateriais(p, { PenaDeRaia = 1 }, "afago")
		end
	elseif tipo == C.RENOMEAR then
		if not Dados.nomeValido(arg) then
			rejeitar(p, tipo, "nomeInvalido")
			return
		end
		local ok, filtrado = pcall(function()
			return TextService:FilterStringAsync(arg, p.UserId):GetNonChatStringForBroadcastAsync()
		end)
		if not ok or filtrado ~= arg then
			rejeitar(p, tipo, "nomeFiltrado")
			return
		end
		c.nome = arg
		if a and a.guid == guid then
			a.modelo:SetAttribute("Nome", arg)
		end
		gravar(p, j, guid)
	elseif tipo == C.EVOLUIR then
		local ok = Crescimento.evoluir(c, esp)
		if not ok then
			rejeitar(p, tipo, "faltaRequisito")
			enviarLista(p)
			return
		end
		gravar(p, j, guid)
		if a and a.guid == guid and not a.montada then
			ativar(p, j, guid) -- novo porte/modelo do estágio
		end
		evento:FireClient(p, EC.EVOLUIU, guid, c.estagio)
	elseif tipo == C.ESPECIALIZAR then
		if typeof(arg) ~= "string" then
			return
		end
		local ok, motivo = Vinculo.especializar(c, esp, Afinidades, arg, false)
		if not ok then
			rejeitar(p, tipo, motivo)
			return
		end
		gravar(p, j, guid)
	end
	enviarLista(p)
end

-- ------------------------------------------------------------------ API (servidor)
-- criatura ativa: (registro, espécie, raiz no mundo)
function CompanionSystem.ativa(p: Player): (any?, any?, BasePart?)
	local j = jogadores[p]
	if not j or not j.ativa then
		return nil, nil, nil
	end
	local c = j.criaturas[j.ativa.guid]
	return c, especies[c.especie], j.ativa.raiz
end

-- usada pelo MountSystem: liga/desliga a IA e devolve as peças da criatura ativa
function CompanionSystem.definirMontada(p: Player, montada: boolean): (Model?, AlignPosition?, AlignOrientation?)
	local j = jogadores[p]
	local a = j and j.ativa
	if not a then
		return nil, nil, nil
	end
	a.montada = montada
	a.comando = if montada then "Montada" else "Acompanhar"
	a.ap.Enabled = not montada
	a.ao.Enabled = not montada
	if not montada then
		a.ap.Position = a.raiz.Position
		pcall(function()
			a.raiz:SetNetworkOwner(nil)
		end)
	end
	j.listaPendente = true
	return a.modelo, a.ap, a.ao
end

-- ganchos para missões/eventos (QuestSystem, Etapa G): marco e desafio da criatura ativa, objetivo dimensional
function CompanionSystem.registrarMarco(p: Player, marcoId: string): boolean
	local c = CompanionSystem.ativa(p)
	local j = jogadores[p]
	if c and j and Dados.registrarMarco(c, marcoId) then
		gravar(p, j, c.guid)
		j.listaPendente = true
		return true
	end
	return false
end

function CompanionSystem.registrarDesafio(p: Player, desafioId: string): boolean
	local c = CompanionSystem.ativa(p)
	local j = jogadores[p]
	if c and j and Dados.registrarDesafio(c, desafioId) then
		gravar(p, j, c.guid)
		j.listaPendente = true
		return true
	end
	return false
end

function CompanionSystem.registrarObjetivoDimensional(p: Player, objetivoId: string): boolean
	local c = CompanionSystem.ativa(p)
	local j = jogadores[p]
	if c and j and Vinculo.registrarObjetivo(c, Afinidades, objetivoId) then
		gravar(p, j, c.guid)
		j.listaPendente = true
		return true
	end
	return false
end

-- ------------------------------------------------------------------ ciclo de vida
function CompanionSystem.Init(ctx: any)
	ctxSistemas = ctx
	evento = Remotos.evento("Companheiro")
end

function CompanionSystem.Start()
	playerData = ctxSistemas.obter("PlayerDataSystem")
	inimigos = ctxSistemas.obter("EnemySystem")
	inventario = ctxSistemas.obter("InventorySystem")
	pasta = Instance.new("Folder")
	pasta.Name = "GuardioesCompanheiros"
	pasta.Parent = Workspace

	local teste = ConfigServidor.concessoesDeTeste
	local function entrar(p: Player)
		local j: Jogador = { criaturas = {}, teste = {}, ativa = nil, balde = LimiteDeTaxa.novo(8, 4, os.clock()), ultimoAfago = -math.huge, listaPendente = false }
		if teste and teste.ativa and teste.criaturas then
			for _, t in teste.criaturas do
				local esp = especies[t.especie]
				if esp then
					local guid = HttpService:GenerateGUID(false)
					local c = Dados.nova(guid, t.especie, t.nome)
					c.estagio = t.estagio
					c.habilidades = table.clone(esp.estagios[t.estagio].habilidades)
					c.xp = t.xp or 0
					c.vinculo = t.vinculo or 0
					j.criaturas[guid] = c
					j.teste[guid] = true
				end
			end
		end
		jogadores[p] = j
		local function aoPersonagem(ch: Model)
			local hrp = ch:WaitForChild("HumanoidRootPart", 10) :: BasePart?
			if not hrp or not jogadores[p] then
				return
			end
			local jj = jogadores[p]
			if jj.ativa then
				ativar(p, jj, jj.ativa.guid) -- renasce ao lado do dono, nunca montada
			else
				local primeira = next(jj.criaturas)
				if primeira then
					ativar(p, jj, primeira)
				end
			end
			enviarLista(p)
		end
		p.CharacterAdded:Connect(aoPersonagem)
		if p.Character then
			task.spawn(aoPersonagem, p.Character)
		end
	end
	playerData.carregado.conectar(function(p: Player, perfil: any)
		local j = jogadores[p]
		if not j then
			return
		end
		for guid, c in perfil.companheiros do
			if especies[c.especie] then
				j.criaturas[guid] = copiar(c)
			end
		end
		if perfil.criaturaAtiva and j.criaturas[perfil.criaturaAtiva] and p.Character then
			ativar(p, j, perfil.criaturaAtiva)
		end
		enviarLista(p)
	end)
	for _, p in Players:GetPlayers() do
		entrar(p)
	end
	Players.PlayerAdded:Connect(entrar)
	Players.PlayerRemoving:Connect(function(p)
		local j = jogadores[p]
		if j then
			desativar(j)
		end
		jogadores[p] = nil
	end)
	evento.OnServerEvent:Connect(aoReceber)

	-- XP e vínculo compartilhados por vitória
	inimigos.morreu.conectar(function(ini: any, contribuicao: { [Player]: number })
		local onde = ini.raiz and ini.raiz.Position
		for p in contribuicao do
			local j = jogadores[p]
			local a = j and j.ativa
			if j and a and onde and (a.raiz.Position - onde).Magnitude <= RAIO_XP then
				local c = j.criaturas[a.guid]
				Dados.ganharXp(c, XP_POR_VITORIA)
				Dados.ganharVinculo(c, "Batalha", VINCULO_BATALHA, hoje())
				gravar(p, j, a.guid)
				j.listaPendente = true
			end
		end
	end)

	local acumulado = 0
	RunService.Heartbeat:Connect(function(dt)
		acumulado += dt
		if acumulado < 0.1 then
			return
		end
		acumulado = 0
		local agora = os.clock()
		for p, j in jogadores do
			pensar(p, j, agora)
		end
	end)
	-- lista atualizada no máximo 1×/s (XP, vínculo, comando que mudou sozinho)
	task.spawn(function()
		while true do
			task.wait(1)
			for p, j in jogadores do
				if j.listaPendente then
					enviarLista(p)
				end
			end
		end
	end)
end

return CompanionSystem
