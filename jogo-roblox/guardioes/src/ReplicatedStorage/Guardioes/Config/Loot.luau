--!strict
-- NÃO EXECUTADO. Tabelas de saque por inimigo (T). Saque PESSOAL: cada jogador elegível rola o seu.
-- garantiaEm = proteção contra azar (depois de N derrotas sem o item, ele cai com certeza).

return {
	minimoDeContribuicao = 0.10, -- precisa ter causado ao menos 10% do dano
	porInimigo = {
		FaiscaErrante = {
			xp = 15,
			entradas = {
				{ id = "FragmentoDeFaisca", chance = 0.75, min = 1, max = 2 },
				{ id = "NucleoDeTempestade", chance = 0.08, min = 1, max = 1, garantiaEm = 15 },
			},
		},
		BonecoDeTreino = { xp = 0, entradas = {} },
		PilarDeCristal = { xp = 0, entradas = {} },
		RainhaBobina = {
			xp = 300,
			entradas = {
				{ id = "GlandulaDeBobinaViva", chance = 1, min = 3, max = 5 },
				{ id = "NucleoDeTempestade", chance = 0.5, min = 1, max = 2 },
			},
		},
	},
}
