--!strict
-- NÃO EXECUTADO. Espécie companheira: CÃO-TROVÃO (filhote órfão da matilha do Alfa, GDD 6.3). Combate e
-- MONTARIA TERRESTRE quando adulto (porte de cavalo, musculatura que justifica carregar um jogador).

return {
	id = "CaoTrovao",
	nome = "Cão-Trovão",
	papel = "Combate",
	comportamento = {
		estilo = "Trota", distanciaSeguir = 7, ladoPreferido = "Direita",
		curiosidade = 0.4, coragem = 0.9,
		reacoes = { Chuva = "Uiva", Noite = "Vigia", Combate = "AtacaAlvoDoDono" },
	},
	estagios = {
		Filhote = { escala = 0.4, modelo = "CaoFilhote", animacoes = "CaoFilhote", habilidades = { "Mordiscar" } },
		Juvenil = {
			escala = 0.7, modelo = "CaoJuvenil", animacoes = "CaoJuvenil",
			habilidades = { "Mordida", "Latido" }, -- latido interrompe telegrafias curtas
			requisitos = { xp = 800, vinculo = 3, marcos = { "CaoPrimeiraCaca", "CaoDefenderDono" } },
		},
		Adulto = {
			escala = 1.0, modelo = "CaoAdulto", animacoes = "CaoAdulto",
			habilidades = { "Mordida", "Latido", "InvestidaTrovao" },
			requisitos = { xp = 3000, vinculo = 7, marcos = { "CaoEncontrarAlfa" }, desafio = "CaoProvaDaMatilha" },
		},
	},
	montaria = {
		tipo = "Terrestre", estagioMin = "Adulto",
		velMax = 34, aceleracao = 26, desaceleracao = 34, giroGrausPorSeg = 150, salto = 55,
		travessia = { "AguaRasa", "Encostas" },
		espacoNecessario = { 6, 7, 9 }, -- caixa (studs) livre para montar/desmontar
		animacoes = "CaoMontaria",
	},
	afinidadesPossiveis = { "Tempestade", "Vulcao", "Gelo" },
}
