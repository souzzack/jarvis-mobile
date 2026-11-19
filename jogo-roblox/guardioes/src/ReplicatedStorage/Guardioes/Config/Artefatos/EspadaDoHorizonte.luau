--!strict
-- NÃO EXECUTADO. Artefato metamórfico: ESPADA DO HORIZONTE (Arcano). Só dados.
-- Um único item (um GUID) com várias FORMAS. Trocar de forma não cria nem destrói item: só muda 'forma'.
-- Formas: tipo "Combate" usa 'arma' (Config/Armas); tipo "Locomocao" usa 'perfil' (Config/Locomocao/Perfis).
-- Estágios: o que cada estágio exige e libera (GDD complementar, Sistema 11). Requisitos só de jogo, nunca Robux.

return {
	id = "EspadaDoHorizonte",
	nome = "Espada do Horizonte",
	raridade = "Arcano",
	formaInicial = "Espada",
	formas = {
		Espada = {
			tipo = "Combate", arma = "EspadaDoHorizonte", estagioMin = 1,
			efeito = "LaminaEletrica", animacaoEntrada = "HorizonteMontarEspada",
		},
		Prancha = {
			tipo = "Locomocao", perfil = "PranchaHorizonte", estagioMin = 2,
			efeito = "PranchaRaio", animacaoEntrada = "HorizonteMontarPrancha",
			-- montagem visual (TransformationController): a lâmina gira 90°, a guarda abre em duas aletas,
			-- o cabo recolhe para dentro e a lâmina se alarga até virar a prancha sob os pés
			montagem = { "GirarLamina", "AbrirGuarda", "RecolherCabo", "AlargarLamina", "AcenderVeios" },
		},
	},
	transformacao = {
		duracao = 0.6, -- durante a troca nenhuma forma está ativa: sem dano e sem voo
		recarga = 1.5,
		custoEnergia = 8, -- energia de voo
		golpeCancelaAcima = 12, -- dano recebido durante a troca que a cancela (volta à forma anterior)
	},
	-- "Retorno ao combate": da prancha direto para a espada, mesmo no ar, com queda amortecida e segura
	retornoAoCombate = { alturaLivre = 6, velQueda = 14, duracaoMax = 3.0 },
	estagios = {
		{ n = 1, descricao = "Desbloqueada como arma.", requisitos = {} },
		{ n = 2, descricao = "A missão do Horizonte Partido ativa a forma de prancha.", requisitos = { missoes = { "OHorizontePartido" } } },
		{
			n = 3, descricao = "Materiais especiais melhoram velocidade, autonomia e manobras da prancha.",
			requisitos = { materiais = { NucleoDeTempestade = 3, PenaDeRaia = 6, LigaArcana = 2 } },
			bonus = { perfil = "PranchaHorizonte", mods = { { campo = "velMax", somar = 4 }, { campo = "custoPorSeg", multiplicar = 0.9 }, { campo = "inclinacaoMax", somar = 4 } } },
		},
		{
			n = 4, descricao = "Desafios avançados: Corte em Voo (atacar ao desmontar da prancha).",
			requisitos = { desafios = { "AnelDosRelampagos", "GuardiaoDaTormentaSemCair" } },
			bonus = { habilidade = "CorteEmVoo" },
		},
	},
}
