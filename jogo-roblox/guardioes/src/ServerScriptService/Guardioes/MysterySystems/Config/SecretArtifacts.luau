--!strict
-- NÃO EXECUTADO. ARTEFATOS ??? DOS ARQUIVISTAS (SÓ SERVIDOR). Seção 10.
-- Usam a MESMA arquitetura dos Artefatos Metamórficos (formas, estágios, transformação; ver
-- Config/Artefatos/EspadaDoHorizonte e ConfigSecreta/ArcoDasAsasPerdidas): não há segundo sistema de
-- transformação. Conteúdo ADICIONAL: não substituem Espada do Horizonte, Escudo do Firmamento, Cajado dos Ventos
-- Antigos nem o Arco das Asas Perdidas.
-- Raridade "Oculta" (???, multiplicador 1,56 — Config/Raridades): o maior poder do jogo, com MECÂNICA EXCLUSIVA.
-- Obtenção SÓ por investigação (pesquisa com 7 etapas); nunca por miniboss, Guardião, sorte ou compra.
-- ESTADO: definidos e validados (spec), mas NÃO registrados no MetamorphicArtifactSystem ainda: a etapa de
-- FABRICAÇÃO depende de capítulos não lançados, então ninguém consegue obtê-los nesta versão (de propósito).
-- A PESQUISA aparece no diário assim que a etapa 1 é cumprida, com o nome escondido ("???") até a etapa
-- 'revelaNomeNaEtapa' (o nome só aparece quando a receita é descoberta).

return {
	LaminaDoNaoExistente = {
		artefato = {
			id = "LaminaDoNaoExistente", nome = "Lâmina do Não-Existente", raridade = "Oculta", formaInicial = "Lamina",
			formas = {
				Lamina = { tipo = "Combate", arma = "LaminaDoNaoExistente", estagioMin = 1, efeito = "CorteDimensional" },
				PranchaAstral = {
					tipo = "Locomocao", perfil = "PranchaAstral", estagioMin = 2, efeito = "RastroAstral",
					montagem = { "LaminaSomeNoAr", "ContornoAstralFica", "ContornoViraPrancha" },
				},
			},
			transformacao = { duracao = 0.5, recarga = 1.4, custoEnergia = 7, golpeCancelaAcima = 14 },
			retornoAoCombate = { alturaLivre = 6, velQueda = 12, duracaoMax = 3.0 },
			estagios = {
				{ n = 1, descricao = "A lâmina aparece por um instante a cada golpe.", requisitos = {} },
				{ n = 2, descricao = "Prancha astral.", requisitos = { desafios = { "Lamina_SegundaPesquisa" } } },
				{ n = 3, descricao = "Corte que atravessa a guarda (mecânica exclusiva).", requisitos = { desafios = { "Lamina_TerceiraPesquisa" } }, bonus = { habilidade = "CorteEntreMundos" } },
			},
		},
		revelaNomeNaEtapa = 4,
		mecanicaExclusiva = "Corte Entre Mundos: o golpe pesado ignora parte da POSTURA do alvo (não o dano), uma vez a cada 12 s.",
		perfil = { id = "PranchaAstral", nome = "Prancha astral", tipo = "Motorizado", velMax = 44, velImpulso = 66, aceleracao = 52, desaceleracao = 38, velVerticalMax = 20, acelVertical = 40, inclinacaoMax = 40, fatorInclinacao = 0.5, custoPorSeg = 6, custoPairarPorSeg = 5, custoImpulsoPorSeg = 15, decolagem = 0.35, pouso = 0.35, efeito = "RastroAstral" },
		pesquisa = {
			{ nome = "Uma lâmina que não existe", condicao = { capitulo = "OSegredoDoPrimeiroArquivista#4" } },
			{ nome = "Origem", condicao = { capitulo = "OSegredoDoPrimeiroArquivista#6" } },
			{ nome = "Enigmas da Biblioteca", condicao = { enigma = "Biblioteca_EstanteSemFim" } },
			{ nome = "Receita", condicao = { receita = "Receita_LaminaDoNaoExistente" } },
			{ nome = "Componentes", condicao = { materiais = { FragmentoDoNaoExistente = 3 } } },
			{ nome = "Fabricação", condicao = { fabricado = "Receita_LaminaDoNaoExistente" } },
			{ nome = "Novas formas", condicao = { evolucao = "Lamina_SegundaPesquisa" } },
		},
	},
	EscudoDoUltimoArquivista = {
		artefato = {
			id = "EscudoDoUltimoArquivista", nome = "Escudo do Último Arquivista", raridade = "Oculta", formaInicial = "Escudo",
			formas = {
				Escudo = { tipo = "Combate", arma = "EscudoDoUltimoArquivista", estagioMin = 1, efeito = "PaginasGirando" },
				Plataforma = { tipo = "Locomocao", perfil = "PlataformaDoArquivo", estagioMin = 2, efeito = "PaginasSobOsPes", montagem = { "PaginasSoltam", "PaginasSeEncaixam" } },
			},
			transformacao = { duracao = 0.6, recarga = 1.6, custoEnergia = 6, golpeCancelaAcima = 18 },
			retornoAoCombate = { alturaLivre = 5, velQueda = 10, duracaoMax = 3.0 },
			estagios = {
				{ n = 1, descricao = "Defesa com páginas que giram.", requisitos = {} },
				{ n = 2, descricao = "Plataforma flutuante.", requisitos = { desafios = { "Escudo_SegundaPesquisa" } } },
				{ n = 3, descricao = "Barreira do Arquivo (mecânica exclusiva).", requisitos = { desafios = { "Escudo_TerceiraPesquisa" } }, bonus = { habilidade = "BarreiraDoArquivo" } },
			},
		},
		revelaNomeNaEtapa = 4,
		mecanicaExclusiva = "Barreira do Arquivo: por 3 s, protege também os aliados próximos (40% menos dano); recarga longa.",
		perfil = { id = "PlataformaDoArquivo", nome = "Plataforma do Arquivo", tipo = "Plataforma", velMax = 30, velImpulso = 0, aceleracao = 30, desaceleracao = 30, velVerticalMax = 14, acelVertical = 28, inclinacaoMax = 0, fatorInclinacao = 0, custoPorSeg = 4, custoPairarPorSeg = 2, custoImpulsoPorSeg = 0, decolagem = 0.4, pouso = 0.4, efeito = "PaginasSobOsPes" },
		pesquisa = {
			{ nome = "Um escudo assinado", condicao = { capitulo = "OSegredoDoPrimeiroArquivista#6" } },
			{ nome = "Origem", condicao = { capitulo = "OSegredoDoPrimeiroArquivista#7" } },
			{ nome = "Enigmas", condicao = { enigma = "Biblioteca_UltimaPagina" } },
			{ nome = "Receita", condicao = { receita = "Receita_EscudoDoUltimoArquivista" } },
			{ nome = "Componentes", condicao = { materiais = { PaginaDoUltimoArquivista = 3 } } },
			{ nome = "Fabricação", condicao = { fabricado = "Receita_EscudoDoUltimoArquivista" } },
			{ nome = "Novas formas", condicao = { evolucao = "Escudo_SegundaPesquisa" } },
		},
	},
	CajadoDaFratura = {
		artefato = {
			id = "CajadoDaFratura", nome = "Cajado da Fratura", raridade = "Oculta", formaInicial = "Cajado",
			formas = {
				Cajado = { tipo = "Combate", arma = "CajadoDaFratura", estagioMin = 1, efeito = "RachaduraDeLuz" },
				Passo = { tipo = "Locomocao", perfil = "PassoDaFratura", estagioMin = 2, efeito = "FendaAberta", montagem = { "CajadoRacha", "FendaSeAbre" } },
			},
			transformacao = { duracao = 0.45, recarga = 1.3, custoEnergia = 8, golpeCancelaAcima = 12 },
			retornoAoCombate = { alturaLivre = 6, velQueda = 12, duracaoMax = 3.0 },
			estagios = {
				{ n = 1, descricao = "Energia dimensional nos golpes.", requisitos = {} },
				{ n = 2, descricao = "Passo da Fratura (deslocamento curto entre fendas).", requisitos = { desafios = { "Cajado_SegundaPesquisa" } } },
				{ n = 3, descricao = "Percepção da Fratura: o cajado conta como Visão Arcana (mecânica exclusiva).", requisitos = { desafios = { "Cajado_TerceiraPesquisa" } }, bonus = { habilidade = "PercepcaoDaFratura" } },
			},
		},
		revelaNomeNaEtapa = 4,
		mecanicaExclusiva = "Percepção da Fratura: equipado, conta como fonte de Visão Arcana e Ressonância Dimensional nas investigações.",
		perfil = { id = "PassoDaFratura", nome = "Passo da Fratura", tipo = "Motorizado", velMax = 40, velImpulso = 70, aceleracao = 60, desaceleracao = 50, velVerticalMax = 22, acelVertical = 44, inclinacaoMax = 35, fatorInclinacao = 0.45, custoPorSeg = 7, custoPairarPorSeg = 6, custoImpulsoPorSeg = 18, decolagem = 0.3, pouso = 0.3, efeito = "FendaAberta" },
		pesquisa = {
			{ nome = "Uma rachadura que pensa", condicao = { capitulo = "OSegredoDoPrimeiroArquivista#7" } },
			{ nome = "Origem", condicao = { enigma = "Intervalo_RelogioPartido" } },
			{ nome = "Enigmas", condicao = { enigma = "Intervalo_TresMomentos" } },
			{ nome = "Receita", condicao = { receita = "Receita_CajadoDaFratura" } },
			{ nome = "Componentes", condicao = { materiais = { EstilhacoDaFratura = 3 } } },
			{ nome = "Fabricação", condicao = { fabricado = "Receita_CajadoDaFratura" } },
			{ nome = "Novas formas", condicao = { evolucao = "Cajado_SegundaPesquisa" } },
		},
	},
}
