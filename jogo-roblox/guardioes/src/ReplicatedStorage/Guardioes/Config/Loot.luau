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
		ColossoDasRuinas = {
			xp = 300,
			entradas = {
				{ id = "NucleoEnferrujado", chance = 1, min = 3, max = 5 },
				{ id = "EssenciaDeVento", chance = 1, min = 2, max = 3 }, -- fonte da Essência (estágio 3 do Cajado)
			},
		},
		EspectroDoObservatorio = {
			xp = 300,
			entradas = { { id = "LenteEspectral", chance = 1, min = 2, max = 3 } },
		},
		GuardiaoDaTormenta = {
			xp = 800,
			entradas = {
				{ id = "CoracaoDaTormenta", chance = 1, min = 1, max = 1 },
				{ id = "PenaDoRelampagoAntigo", chance = 1, min = 2, max = 3 },
			},
		},
		CaoDaMatilha = { xp = 8, entradas = { { id = "FragmentoDeFaisca", chance = 0.4, min = 1, max = 1 } } },
		CaoTrovaoAlfa = {
			xp = 280,
			entradas = {
				{ id = "JubaEstatica", chance = 1, min = 3, max = 5 },
				{ id = "NucleoDeTempestade", chance = 0.5, min = 1, max = 1 },
			},
		},
		RainhaBobina = {
			xp = 300,
			entradas = {
				{ id = "GlandulaDeBobinaViva", chance = 1, min = 3, max = 5 },
				{ id = "NucleoDeTempestade", chance = 0.5, min = 1, max = 2 },
			},
		},
	},
}
