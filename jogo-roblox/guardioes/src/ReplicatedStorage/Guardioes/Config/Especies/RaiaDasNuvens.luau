--!strict
-- NÃO EXECUTADO. Espécie companheira (PROPOSTA ORIGINAL): RAIA-DAS-NUVENS — vive nas correntes acima da
-- Ilha das Tempestades. Filhote cabe nos braços; adulta tem envergadura de 9 studs e plana nas tempestades:
-- MONTARIA VOADORA. Exploração aérea; fraca em combate.

return {
	id = "RaiaDasNuvens",
	nome = "Raia-das-Nuvens",
	papel = "Exploracao",
	comportamento = {
		estilo = "Plana", distanciaSeguir = 9, ladoPreferido = "Acima",
		curiosidade = 0.6, coragem = 0.3,
		reacoes = { Chuva = "SobeNasCorrentes", Noite = "Bioluminesce", Combate = "CirculaAlto" },
	},
	estagios = {
		Filhote = { escala = 0.35, modelo = "RaiaFilhote", animacoes = "RaiaFilhote", habilidades = { "SentirCorrente" } },
		Juvenil = {
			escala = 0.65, modelo = "RaiaJuvenil", animacoes = "RaiaJuvenil",
			habilidades = { "SentirCorrente", "Sopro" }, -- mostra correntes ascendentes para o planador
			requisitos = { xp = 900, vinculo = 4, marcos = { "RaiaPrimeiroVooJunto", "RaiaCorrenteAlta" } },
		},
		Adulto = {
			escala = 1.0, modelo = "RaiaAdulta", animacoes = "RaiaAdulta",
			habilidades = { "SentirCorrente", "Sopro", "CarregarCavaleiro" },
			requisitos = { xp = 3200, vinculo = 7, marcos = { "RaiaOlhoDaTormenta" }, desafio = "RaiaAtravessarATormenta" },
		},
	},
	montaria = {
		tipo = "Voadora", estagioMin = "Adulto",
		velMax = 22, aceleracao = 22, desaceleracao = 28, giroGrausPorSeg = 120, salto = 0, -- no chão anda devagar
		espacoNecessario = { 10, 6, 10 },
		animacoes = "RaiaMontaria",
		perfilVoo = {
			id = "MontariaRaia", nome = "Raia-das-Nuvens", tipo = "Motorizado",
			velMax = 36, velImpulso = 52, aceleracao = 30, desaceleracao = 24, velVerticalMax = 16, acelVertical = 22,
			inclinacaoMax = 40, fatorInclinacao = 0.45, custoPorSeg = 3, custoPairarPorSeg = 6, custoImpulsoPorSeg = 12,
			decolagem = 0.8, pouso = 0.7, efeito = "Raia",
		},
	},
	afinidadesPossiveis = { "Tempestade", "Bolhas", "Gelo" },
}
