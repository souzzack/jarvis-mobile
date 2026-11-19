--!strict
-- NÃO EXECUTADO. Miniboss COLOSSO DAS RUÍNAS (Ruínas tecnológicas, GDD 6.3). Só dados (T).
-- Couraça imune; 3 aparos abrem o núcleo nas costas; pisoteio com onda (BossSystem: Chefes/Colosso).
-- Golpes lentos e pesados: dá tempo de ler a telegrafia e aparar.

return {
	id = "ColossoDasRuinas",
	nome = "Colosso das Ruínas",
	categoria = "Miniboss",
	vida = 2600,
	postura = 400,
	defesa = 30,
	raio = 4,
	altura = 10,
	cor = "#8C7A5B",
	ataques = {
		{ nome = "Soco", peso = 3, telegrafia = 0.90, impacto = 0.25, recuperacao = 1.2, alcance = 11, arcoGraus = 60, dano = 26, postura = 24, avanco = 2 },
		{ nome = "Varredura", peso = 2, telegrafia = 1.10, impacto = 0.30, recuperacao = 1.4, alcance = 12, arcoGraus = 140, dano = 22, postura = 28, avanco = 0 },
	},
	ia = { percepcao = 40, perseguir = true, velocidade = 8, distanciaAtaque = 10, desistir = 60, intervaloMin = 1.6 },
	retornoSeg = nil,
	recompensas = {},
}
