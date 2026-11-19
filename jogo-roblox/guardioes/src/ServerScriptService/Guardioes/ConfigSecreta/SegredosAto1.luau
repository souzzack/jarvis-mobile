--!strict
-- NÃO EXECUTADO. SEGREDO ??? DO ATO 1 (SÓ SERVIDOR; o cliente nunca recebe este arquivo).
-- Cadeia (GDD, "Segredo ??? do Ato 1" e 7.3), resolvida pelo SecretDiscoverySystem:
--   LentesNaOrdem ............ alinhar as 3 lentes do Observatório restaurado na ordem da anotação do astrônomo
--   MargensDosLivros ......... examinar as margens dos 3 livros lidos (o Códice exige o Campo das Bolhas)
--   SeteEstrelasSobChuva ..... contemplar o céu no Santuário, sob chuva, com o Axolote Nebular ativo (Juvenil+)
--   PilaresDasSeteEstrelas ... ativar os 6 pilares na ordem da constelação, a partir da estrela que brilhou
--   ArtefatoDesconhecido1 .... a câmara sob o altar se abre
--   ReceitaArcoDasAsas_Parte1  ler o Manuscrito Sem Nome (MagicBookSystem)
--   OrvalhoEntreMundos ....... componente ENTRE DIMENSÕES (Campo das Bolhas: ainda não implementado; bloqueado)
--   ArcoForjado .............. ritual no altar: o Arco das Asas Perdidas (estágio 1)
-- As ordens variam por jogador (semente + sal abaixo). Nada aqui é vendido nem depende de sorte.

return {
	-- sal secreto da semente: sem ele, quem conhece o algoritmo não calcula a ordem de outro jogador
	sal = "Fratura-7*Coracao-partido-por-dentro",

	-- ordem da constelação (dados de luau-rascunho/SeteEstrelas.lua): anel de 6 estrelas em volta da Sétima
	estrelas = {
		{ id = "tempestades", mundo = "Ilha das Tempestades", cor = "Azul", hex = "#3B82F6" },
		{ id = "bolhas", mundo = "Campo das Bolhas", cor = "Turquesa", hex = "#2DD4BF" },
		{ id = "vulcoes", mundo = "Ilha dos Vulcões", cor = "Vermelha", hex = "#EF4444" },
		{ id = "congelada", mundo = "Cidade Congelada", cor = "Gelo", hex = "#BAE6FD" },
		{ id = "gigante", mundo = "Costas do Gigante", cor = "Dourada", hex = "#F5C76B" },
		{ id = "achados", mundo = "Achados e Perdidos", cor = "Violeta", hex = "#A855F7" },
	},

	-- lentes do Observatório: cada uma tem a cor de uma estrela; a anotação cita os MUNDOS, não as cores
	-- (o jogador liga mundo → cor pela constelação). A ordem é uma permutação por jogador.
	lentes = { 1, 3, 5 }, -- índices em 'estrelas': Azul, Vermelha, Dourada
	anotacao = "Anotação do astrônomo, a lápis: \"A luz de %s entra primeiro; depois a de %s; por último a de %s. Só assim o vidro lembra do céu.\"",

	contemplacao = { paradoSeg = 11, raio = 12, tolerancia = 0.6, estagioMin = "Juvenil" },
	clima = { cicloSeg = 1200, chuvaSeg = 240 }, -- se nenhum sistema de clima marcar Workspace.GuardioesChuva

	-- etapas na ordem do diário (dicas públicas vagas; nomes e textos só depois de feitas)
	etapas = {
		{
			id = "LentesNaOrdem", conjunto = "enigmas", requer = {},
			nome = "O vidro que lembra do céu", texto = "As lentes do Observatório voltaram a apontar para as Sete Estrelas.",
			dica = "O telescópio do Observatório parece desalinhado.",
		},
		{
			id = "MargensDosLivros", conjunto = "segredos", requer = {},
			nome = "Anotações nas margens", texto = "Três livros, uma mesma letra miúda: alguém leu tudo isso antes de você.",
			dica = "Alguns livros têm algo escrito a lápis nas margens.",
		},
		{
			id = "SeteEstrelasSobChuva", conjunto = "segredos", requer = {},
			nome = "Sete estrelas sob a chuva", texto = "Sob a chuva, o Axolote olhou para cima e o céu desenhou um símbolo: seis estrelas em volta de uma sétima.",
			dica = "Dizem que o céu do Santuário só fala com quem ouve a chuva, e com quem tem olhos de nebulosa por perto.",
		},
		{
			id = "PilaresDasSeteEstrelas", conjunto = "enigmas", requer = { "SeteEstrelasSobChuva" },
			nome = "Os seis pilares", texto = "Os pilares acenderam em volta do altar, um depois do outro, como o símbolo no céu.",
			dica = "Seis pilares apagados cercam o altar.",
		},
		{
			id = "ArtefatoDesconhecido1", conjunto = "segredos", requer = { "PilaresDasSeteEstrelas" },
			nome = "Artefato Desconhecido nº 1", texto = "A câmara sob o altar guardava algo partido ao meio.",
			dica = "Algo se mexeu sob o altar.",
		},
		{
			id = "ReceitaArcoDasAsas_Parte1", conjunto = "segredos", requer = { "MargensDosLivros", "SeteEstrelasSobChuva" },
			nome = "O Manuscrito Sem Nome", texto = "As margens e o céu completam um ao outro: metade de uma receita sem nome.",
			dica = "Um livro sem nome só se deixa ler por quem já leu as margens dos outros.",
		},
		{
			id = "OrvalhoEntreMundos", conjunto = "segredos", requer = { "ArtefatoDesconhecido1" }, dimensao = "CampoDasBolhas",
			nome = "Orvalho entre mundos", texto = "Uma gota que não pertence a nenhum dos dois mundos.",
			dica = "O que falta não existe nesta ilha.",
		},
		{
			id = "ArcoForjado", conjunto = "segredos", requer = { "ArtefatoDesconhecido1", "ReceitaArcoDasAsas_Parte1", "OrvalhoEntreMundos" },
			nome = "Arco das Asas Perdidas", texto = "O arco partido se fechou. Quando ele se abre, vira asas de luz.",
			dica = "O altar espera as peças.",
		},
	},

	-- descrição do Artefato Desconhecido, revelada aos poucos conforme a cadeia avança
	artefatoDesconhecido = "Um arco partido ao meio cuja corda ainda vibra. As penas da empunhadura brilham quando alguém olha para as Sete Estrelas. Falta algo que só existe entre um mundo e outro.",

	-- ritual final no altar (os componentes de segredo são etapas acima, não materiais)
	ritual = { materiais = { CoracaoDaTormenta = 1, PenaDoRelampagoAntigo = 3, LenteEspectral = 2 } },

	livrosComMargem = { "GrimorioDosCeus", "TomoDasCorrentesAstrais", "CodiceDaLeveza" },
	margens = {
		GrimorioDosCeus = "Na margem: \"o céu não está desenhado aqui; está guardado\".",
		TomoDasCorrentesAstrais = "Na margem: \"as correntes giram em volta de algo que ninguém vê\".",
		CodiceDaLeveza = "Na margem: \"leve o bastante para atravessar, pesado o bastante para voltar\".",
	},
}
