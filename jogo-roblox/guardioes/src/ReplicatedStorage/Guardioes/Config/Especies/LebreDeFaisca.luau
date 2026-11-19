--!strict
-- NÃO EXECUTADO. Espécie companheira: LEBRE-DE-FAÍSCA (pacífica da Ilha das Tempestades, GDD 6.2).
-- Coleta e áreas escondidas. Pequena: nunca vira montaria.

return {
	id = "LebreDeFaisca",
	nome = "Lebre-de-Faísca",
	papel = "Coleta",
	comportamento = {
		estilo = "Saltita", distanciaSeguir = 6, ladoPreferido = "Direita",
		curiosidade = 0.9, coragem = 0.4,
		reacoes = { Chuva = "OrelhasFaiscam", Noite = "Encolhe", Combate = "DistraiInimigo" },
	},
	estagios = {
		Filhote = { escala = 0.5, modelo = "LebreFilhote", animacoes = "LebreFilhote", habilidades = { "FarejarMaterial" } },
		Juvenil = {
			escala = 0.8, modelo = "LebreJuvenil", animacoes = "LebreJuvenil",
			habilidades = { "FarejarMaterial", "CavarTesouro" },
			requisitos = { xp = 500, vinculo = 3, marcos = { "LebreAcharToca" } },
		},
		Adulto = {
			escala = 1.0, modelo = "LebreAdulta", animacoes = "LebreAdulta",
			habilidades = { "FarejarMaterial", "CavarTesouro", "TrilhaEscondida" }, -- revela passagens ocultas comuns
			requisitos = { xp = 2000, vinculo = 6, marcos = { "LebreCincoTesouros" }, desafio = "LebreCorridaDasRuinas" },
		},
	},
	montaria = nil,
	afinidadesPossiveis = { "Tempestade", "Bolhas", "Vulcao" },
}
