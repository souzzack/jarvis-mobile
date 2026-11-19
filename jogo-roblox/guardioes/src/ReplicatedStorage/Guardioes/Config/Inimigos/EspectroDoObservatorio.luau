--!strict
-- NÃO EXECUTADO. Miniboss ESPECTRO DO OBSERVATÓRIO (só à noite, GDD 6.3). Só dados (T).
-- Teleporta entre as lentes; só o reflexo do telescópio restaurado o torna ferível (Chefes/Espectro).

return {
	id = "EspectroDoObservatorio",
	nome = "Espectro do Observatório",
	categoria = "Miniboss",
	vida = 1800,
	postura = 220,
	defesa = 8,
	raio = 2.2,
	altura = 6,
	cor = "#C8D6FF",
	ataques = {
		{ nome = "Lamento", peso = 2, telegrafia = 0.80, impacto = 0.20, recuperacao = 1.0, alcance = 10, arcoGraus = 360, dano = 18, postura = 16, avanco = 0 },
		{ nome = "Garra", peso = 3, telegrafia = 0.55, impacto = 0.15, recuperacao = 0.8, alcance = 7, arcoGraus = 70, dano = 20, postura = 14, avanco = 5 },
	},
	ia = { percepcao = 45, perseguir = true, velocidade = 15, distanciaAtaque = 7, desistir = 70, intervaloMin = 1.1 },
	retornoSeg = nil,
	recompensas = {},
}
