--!strict
-- NÃO EXECUTADO. Base pessoal, fase 1: espaços predefinidos com níveis (GDD 9). Só dados (T).
-- Forja (1–5), Jardim (1–3), Expositor de troféus, Bancada (1–3: consumíveis e acessórios) e Depósito (1–4:
-- quantos equipamentos o jogador guarda).

return {
	espacos = {
		Forja = {
			nome = "Forja",
			funcao = "Fabricação de armas e equipamentos; nível 3 libera as receitas Druida",
			nivelInicial = 1,
			max = 5,
			niveis = {
				[2] = { nivelJogador = 3, materiais = { FragmentoDeFaisca = 10 } },
				[3] = { nivelJogador = 6, materiais = { JubaEstatica = 3, NucleoDeTempestade = 2 } },
				[4] = { nivelJogador = 10, materiais = { JubaEstatica = 5, LigaArcana = 2 } },
				[5] = { nivelJogador = 15, materiais = { GlandulaDeBobinaViva = 6, LigaArcana = 4 } },
			},
		},
		Jardim = {
			nome = "Jardim mágico",
			funcao = "Produz Sementes Flutuantes e Cascas Antigas com o tempo (com teto)",
			nivelInicial = 1,
			max = 3,
			niveis = {
				[2] = { nivelJogador = 2, materiais = { SementeFlutuante = 2 } },
				[3] = { nivelJogador = 5, materiais = { CascaAntiga = 3, PenaDeRaia = 2 } },
			},
			producao = { porNivelPorHora = 3, teto = 12, materiais = { "SementeFlutuante", "CascaAntiga" } },
		},
		Bancada = {
			nome = "Bancada",
			funcao = "Consumíveis (bálsamo, tônico, infusão) e acessórios simples",
			nivelInicial = 1,
			max = 3,
			niveis = {
				[2] = { nivelJogador = 4, materiais = { CascaAntiga = 4, FragmentoDeFaisca = 6 } },
				[3] = { nivelJogador = 8, materiais = { EssenciaDeVento = 2, LigaArcana = 1 } },
			},
		},
		Deposito = {
			nome = "Depósito",
			funcao = "Guarda equipamentos: cada nível aumenta quantos você pode ter",
			nivelInicial = 1,
			max = 4,
			capacidade = { 30, 45, 60, 80 }, -- equipamentos (armaduras e acessórios) por nível
			niveis = {
				[2] = { nivelJogador = 3, materiais = { CascaAntiga = 4, FragmentoDeFaisca = 8 } },
				[3] = { nivelJogador = 7, materiais = { NucleoEnferrujado = 2, CascaAntiga = 6 } },
				[4] = { nivelJogador = 12, materiais = { LigaArcana = 2, NucleoEnferrujado = 3 } },
			},
		},
		Expositor = {
			nome = "Expositor de troféus",
			funcao = "Mostra os minibosses e Guardiões vencidos",
			nivelInicial = 1,
			max = 1,
			niveis = {},
		},
	},
	-- posição de cada espaço dentro da parcela { x, y, z } em studs, relativo ao centro da parcela
	-- (números, não Vector3: este módulo também roda fora do Roblox, nos testes do Lune)
	layout = {
		Forja = { -10, 0, 0 },
		Jardim = { 10, 0, 0 },
		Expositor = { 0, 0, -10 },
		Bancada = { -10, 0, 10 },
		Deposito = { 10, 0, 10 },
	},
}
