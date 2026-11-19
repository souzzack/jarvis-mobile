--!strict
-- NÃO EXECUTADO. Configuração só do servidor (o cliente não lê).
-- A arena de teste cria um Boneco de Treino e duas Faíscas Errantes perto de 'centro' quando não há pontos de
-- surgimento no mapa. Desligue no place de produção.

local ConfigServidor = {
	arenaDeTeste = {
		ativa = true,
		centro = Vector3.new(0, 4, 40),
		inimigos = {
			{ id = "BonecoDeTreino", deslocamento = Vector3.new(0, 0, 0) },
			{ id = "FaiscaErrante", deslocamento = Vector3.new(18, 0, 14) },
			{ id = "FaiscaErrante", deslocamento = Vector3.new(-18, 0, 16) },
		},
	},
	-- SÓ TESTE (não persiste; some ao sair): o que cada jogador recebe ao entrar enquanto não existem
	-- PlayerDataSystem/InventorySystem. Desligar junto com a arena no place de produção.
	concessoesDeTeste = {
		ativa = true,
		raca = "Humano",
		habilidades = { "VooMagico", "CorrentesAstrais", "Planador" },
		artefatos = { { id = "EspadaDoHorizonte", estagio = 2 }, { id = "EscudoDoFirmamento", estagio = 2 }, { id = "CajadoDosVentosAntigos", estagio = 2 } },
		-- materiais de teste (em memória): o bastante para levar a Espada do Horizonte ao estágio 3
		materiais = { NucleoDeTempestade = 2, PenaDeRaia = 6, LigaArcana = 2, SementeFlutuante = 5, CascaAntiga = 4 },
		-- criaturas de teste (marcadas 'teste': nunca vão para o perfil salvo)
		criaturas = {
			{ especie = "CaoTrovao", estagio = "Adulto", nome = "Trovisco" },
			{ especie = "RaiaDasNuvens", estagio = "Adulto", nome = "Brisa" },
			{ especie = "AxoloteNebular", estagio = "Filhote", nome = "Nebu", xp = 590, vinculo = 290 },
			{ especie = "LebreDeFaisca", estagio = "Adulto", nome = "Pipoca" },
		},
		-- progresso fingido SÓ para ler os livros de teste (Grimório e Tomo). O Códice continua bloqueado
		-- (exige o Campo das Bolhas) para mostrar a mensagem de requisito.
		progressoLivros = {
			missoes = { "AsAnotacoesDoAstronomo", "OsVentosDaTorre" },
			restauracoes = { "Observatorio", "TorreMeteorologica" },
			enigmas = { "LentesNaOrdem" },
		},
		-- pedestais de livros perto da arena (marcadores de teste; os mapas reais não são tocados)
		livrosNaArena = { "GrimorioDosCeus", "TomoDasCorrentesAstrais", "CodiceDaLeveza" },
		-- SÓ TESTE: deixa entrar na arena do Guardião sem a Torre restaurada (desligue para testar a trava)
		ignorarTravasDeChefe = true,
	},
	-- persistência (PlayerDataSystem). DataStore NOVA: o save do tycoon nunca é escrito.
	-- Sem acesso a DataStore (Studio sem "Enable Studio Access to API Services"), roda só em memória e avisa.
	dados = {
		nomeStore = "Guardioes_Perfis_v2",
		salvar = true,
		autosaveSeg = 120,
		travaSeg = 300, -- trava de sessão: outro servidor só assume depois disso (ou quando esta for liberada)
		tentativasCarregar = 5,
	},
	-- marcadores de TESTE perto da arena (os mapas reais não são tocados; no mapa real, Parts com os mesmos
	-- atributos nas pastas GuardioesEstacoes / GuardioesEstruturas / GuardioesChefes)
	marcadoresDeTeste = {
		ativa = true,
		estacoes = { { id = "OficinaDosInventores", deslocamento = Vector3.new(30, 0, -10) } },
		-- escondidos: só aparecem para o dono quando a criatura ativa sabe a habilidade (e está perto)
		ocultos = {
			{ revela = "TrilhaEscondida", deslocamento = Vector3.new(-30, 2, 40), tamanho = Vector3.new(4, 1, 18) },
			-- corrente ascendente (funciona para o planador mesmo sem ver; a Raia a mostra)
			{ revela = "SentirCorrente", deslocamento = Vector3.new(30, 20, 60), tamanho = Vector3.new(14, 60, 14), corrente = 14 },
		},
		estruturas = {
			{ id = "OficinaDosInventores", deslocamento = Vector3.new(30, 0, -4) },
			{ id = "Observatorio", deslocamento = Vector3.new(38, 0, -4) },
			{ id = "TorreMeteorologica", deslocamento = Vector3.new(46, 0, -4) },
		},
	},
	-- chefes: arena = centro + raio; quem está dentro participa das fases (descarga, pilares)
	chefes = {
		{ id = "RainhaBobina", mecanica = "Carga", deslocamento = Vector3.new(0, 0, -90), raioArena = 40, retornoSeg = 300, duracaoCarga = 12, pilares = 3, descarga = { dano = 45, postura = 30 } },
		{
			id = "GuardiaoDaTormenta", mecanica = "Tormenta", deslocamento = Vector3.new(110, 0, -90), raioArena = 32, retornoSeg = 600,
			exigeRestauracao = "TorreMeteorologica", -- arena = topo da Torre religada
			tormenta = { paraRaios = 4, raioParaRaios = 20, janelaCarga = 5, intervaloCarga = 6, telegrafia = 1.2, intervaloPadrao = 2.8 },
			raioDoParaRaio = { danoNoGuardiao = 480, atordoamento = 3, falhou = { dano = 30, postura = 20, raio = 10 }, errado = { dano = 10, postura = 5 } },
			chao = { dano = 35, postura = 25 },
		},
		{ id = "CaoTrovaoAlfa", mecanica = "Matilha", deslocamento = Vector3.new(-90, 0, -60), raioArena = 45, retornoSeg = 300, matilhaPorChamada = 2, corrida = { intervalo = 14, duracao = 4 }, atordoamento = 4 },
	},
	-- base pessoal: Parts com o atributo "GuardioesParcela" (= número) na pasta GuardioesParcelas. No place
	-- real, os terrenos do tycoon recebem esse atributo (docs/04). Sem parcelas, a arena cria 2 de TESTE.
	parcelasDeTeste = { Vector3.new(-70, 0, 40), Vector3.new(-70, 0, 90) },
	-- viagem rápida: Parts com "GuardioesPontoDeViagem" (= id) e "Nome" na pasta GuardioesViagem
	pontosDeViagemDeTeste = {
		{ id = "Arena", nome = "Arena de teste", deslocamento = Vector3.new(0, 0, 12) },
		{ id = "Oficina", nome = "Oficina (marcadores)", deslocamento = Vector3.new(36, 0, 8) },
		{ id = "Caverna", nome = "Câmara da Rainha", deslocamento = Vector3.new(0, 0, -60) },
		{ id = "Floresta", nome = "Floresta do Alfa", deslocamento = Vector3.new(-60, 0, -30) },
	},
	viagem = { raioDescoberta = 15, semCombateSeg = 8, recargaSeg = 30 },
	-- zonas sem voo: Parts (caixas) dentro desta pasta do workspace. Dentro delas: sem decolar/planar/montar.
	pastaZonasSemVoo = "GuardioesZonasSemVoo",
	-- pontos de surgimento no mapa: Parts com o atributo "GuardioesSurgimento" = id do inimigo, dentro desta pasta
	pastaSurgimentos = "GuardioesSurgimentos",
	ia = {
		frequenciaHz = 10,
		distanciaSono = 250, -- sem jogador a menos disso, a criatura dorme
	},
	maxInimigosAtivos = 60,
}

return ConfigServidor
