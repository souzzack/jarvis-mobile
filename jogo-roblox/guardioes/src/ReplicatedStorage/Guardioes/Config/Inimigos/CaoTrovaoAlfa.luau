--!strict
-- NÃO EXECUTADO. Miniboss CÃO-TROVÃO ALFA (Floresta das árvores retorcidas, GDD 6.3). Só dados (T).
-- Matilha e corrida carregada (imune; só aparar quebra) ficam no BossSystem (Chefes/MatilhaDoAlfa).
-- Ataques rápidos e frequentes: o aparo é a habilidade que esta luta ensina.

return {
	id = "CaoTrovaoAlfa",
	nome = "Cão-Trovão Alfa",
	categoria = "Miniboss",
	vida = 2000,
	postura = 260,
	defesa = 12,
	raio = 2.6,
	altura = 5,
	cor = "#3E5BFF",
	ataques = {
		{ nome = "Mordida", peso = 4, telegrafia = 0.45, impacto = 0.15, recuperacao = 0.7, alcance = 7, arcoGraus = 70, dano = 16, postura = 14, avanco = 3 },
		{ nome = "BoteCarregado", peso = 2, telegrafia = 0.60, impacto = 0.20, recuperacao = 1.0, alcance = 12, arcoGraus = 40, dano = 24, postura = 22, avanco = 10 },
	},
	ia = { percepcao = 50, perseguir = true, velocidade = 20, distanciaAtaque = 7, desistir = 75, intervaloMin = 0.9 },
	retornoSeg = nil,
	recompensas = {},
}
