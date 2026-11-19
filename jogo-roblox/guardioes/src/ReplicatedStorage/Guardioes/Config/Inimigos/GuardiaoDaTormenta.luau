--!strict
-- NÃO EXECUTADO. GUARDIÃO DA TORMENTA — Guardião dimensional da Ilha (fonte Arcana, GDD 6.3). Só dados (T).
-- Arena: topo da Torre Meteorológica restaurada. Fases e para-raios: BossSystem (Chefes/Tormenta).
-- História: Guardião antigo corrompido pela Fratura; o diário dele é a primeira pista de quem a causou.

return {
	id = "GuardiaoDaTormenta",
	nome = "Guardião da Tormenta",
	categoria = "Guardiao",
	vida = 6000,
	postura = 500,
	defesa = 25,
	raio = 3,
	altura = 9,
	cor = "#E8F4FF",
	ataques = {
		{ nome = "Lanca", peso = 3, telegrafia = 0.65, impacto = 0.20, recuperacao = 1.0, alcance = 12, arcoGraus = 50, dano = 28, postura = 22, avanco = 3 },
		{ nome = "InvestidaAerea", peso = 2, telegrafia = 0.85, impacto = 0.25, recuperacao = 1.3, alcance = 18, arcoGraus = 30, dano = 32, postura = 26, avanco = 16 },
		{ nome = "Trovao", peso = 1, telegrafia = 1.00, impacto = 0.20, recuperacao = 1.2, alcance = 9, arcoGraus = 360, dano = 24, postura = 24, avanco = 0 },
	},
	ia = { percepcao = 55, perseguir = true, velocidade = 14, distanciaAtaque = 10, desistir = 80, intervaloMin = 1.2 },
	retornoSeg = nil,
	recompensas = {},
}
