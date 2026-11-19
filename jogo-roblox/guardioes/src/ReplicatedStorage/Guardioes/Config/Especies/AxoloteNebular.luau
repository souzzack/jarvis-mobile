--!strict
-- NÃO EXECUTADO. Espécie companheira: AXOLOTE NEBULAR (modelo aprovado V12 — não alterar sem autorização).
-- Suporte e descoberta. Pequeno demais para montaria em qualquer estágio (sem justificativa fantástica coerente).
-- Estágios: modelos/animacoes são CHAVES de assets a produzir (os do adulto partem do V12 aprovado).

return {
	id = "AxoloteNebular",
	nome = "Axolote Nebular",
	papel = "Suporte",
	comportamento = {
		estilo = "Flutua", -- flutua na altura do ombro, ondulando a cauda
		distanciaSeguir = 5, ladoPreferido = "Esquerda",
		curiosidade = 0.7, -- chance de investigar pontos de interesse (cristais, água, constelações)
		coragem = 0.2, -- foge de combate e cura de longe
		reacoes = { Chuva = "BrilhaMais", Noite = "OlhaOCeu", Combate = "EscondeAtras" },
	},
	estagios = {
		Filhote = {
			escala = 0.55, modelo = "AxoloteFilhote", animacoes = "AxoloteFilhote",
			habilidades = { "FaroDeCristal" }, -- identifica recursos próximos
		},
		Juvenil = {
			escala = 0.8, modelo = "AxoloteJuvenil", animacoes = "AxoloteJuvenil",
			habilidades = { "FaroDeCristal", "BolhaDeCura" },
			requisitos = { xp = 600, vinculo = 3, marcos = { "AxoPrimeiraConstelacao", "AxoExplorarCaverna" } },
		},
		Adulto = {
			escala = 1.0, modelo = "AxoloteNebularV12", animacoes = "AxoloteAdulto",
			habilidades = { "FaroDeCristal", "BolhaDeCura", "ContemplacaoCeleste" },
			requisitos = { xp = 2400, vinculo = 6, marcos = { "AxoSeteEstrelas" }, desafio = "AxoNoiteDeTormenta" },
		},
	},
	montaria = nil,
	afinidadesPossiveis = { "Tempestade", "Bolhas", "Gelo" },
}
