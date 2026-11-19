--!strict
-- NÃO EXECUTADO. Cão da matilha, chamado pelo Alfa. Fraco, rápido; não renasce sozinho.

return {
	id = "CaoDaMatilha",
	nome = "Cão da Matilha",
	categoria = "Comum",
	vida = 90,
	postura = 40,
	defesa = 4,
	raio = 1.5,
	altura = 2.6,
	cor = "#6F86FF",
	ataques = {
		{ nome = "Mordida", peso = 1, telegrafia = 0.50, impacto = 0.15, recuperacao = 0.8, alcance = 6, arcoGraus = 60, dano = 9, postura = 8, avanco = 4 },
	},
	ia = { percepcao = 40, perseguir = true, velocidade = 18, distanciaAtaque = 5, desistir = 60, intervaloMin = 1.3 },
	retornoSeg = nil,
	recompensas = {},
}
