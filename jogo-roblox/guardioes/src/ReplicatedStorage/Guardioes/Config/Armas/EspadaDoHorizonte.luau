--!strict
-- NÃO EXECUTADO. Espada do Horizonte (artefato Arcano) — forma de COMBATE. Só dados, mesmo formato de Armas/Espada.
-- Mais rápida que a espada comum e com energia elétrica. O poder extra da raridade Arcana (1,50×) entra pelo
-- multiplicador de equipamento (Etapa D), não aqui: estes são os valores base da arma.

local EspadaDoHorizonte = {
	id = "EspadaDoHorizonte",
	estilo = "Espadachim",
	combo = {
		{ nome = "Relampago1", preparo = 0.10, golpe = 0.10, recuperacao = 0.20, alcance = 7.5, arcoGraus = 115, dano = 10, postura = 8, custoEstamina = 8, animacao = "HorizonteCorte1" },
		{ nome = "Relampago2", preparo = 0.12, golpe = 0.10, recuperacao = 0.22, alcance = 7.5, arcoGraus = 115, dano = 12, postura = 10, custoEstamina = 9, animacao = "HorizonteCorte2" },
		{ nome = "LinhaDoHorizonte", preparo = 0.20, golpe = 0.12, recuperacao = 0.36, alcance = 10, arcoGraus = 40, dano = 18, postura = 18, custoEstamina = 12, animacao = "HorizonteEstocada" },
	},
	pesado = { nome = "DescargaDoHorizonte", preparo = 0.50, golpe = 0.14, recuperacao = 0.55, alcance = 9, arcoGraus = 160, dano = 28, postura = 36, custoEstamina = 22, animacao = "HorizontePesado" },
	bonusPosturaComboPerfeito = 0.25,
}

return EspadaDoHorizonte
