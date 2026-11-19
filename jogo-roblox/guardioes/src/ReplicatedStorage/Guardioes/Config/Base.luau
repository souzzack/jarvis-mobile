--!strict
-- NÃO EXECUTADO. Base pessoal, fase 1: espaços predefinidos com níveis (GDD 9). Só dados (T).
-- Nesta etapa: Forja (1–5), Jardim (1–3) e Expositor de troféus. Bancada e Depósito entram quando existirem
-- consumíveis e limite de inventário por espaço.

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
		Expositor = {
			nome = "Expositor de troféus",
			funcao = "Mostra os minibosses e Guardiões vencidos",
			nivelInicial = 1,
			max = 1,
			niveis = {},
		},
	},
	-- posição de cada espaço dentro da parcela (studs, relativo ao centro da parcela)
	layout = {
		Forja = Vector3.new(-10, 0, 0),
		Jardim = Vector3.new(10, 0, 0),
		Expositor = Vector3.new(0, 0, -10),
	},
}
