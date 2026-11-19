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
		artefatos = { { id = "EspadaDoHorizonte", estagio = 2 }, { id = "EscudoDoFirmamento", estagio = 2 } },
		-- criaturas de teste (marcadas 'teste': nunca vão para o perfil salvo)
		criaturas = {
			{ especie = "CaoTrovao", estagio = "Adulto", nome = "Trovisco" },
			{ especie = "RaiaDasNuvens", estagio = "Adulto", nome = "Brisa" },
			{ especie = "AxoloteNebular", estagio = "Filhote", nome = "Nebu", xp = 590, vinculo = 290 },
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
