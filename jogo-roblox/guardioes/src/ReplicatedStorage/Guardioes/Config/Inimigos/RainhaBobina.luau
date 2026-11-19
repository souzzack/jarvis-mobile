--!strict
-- NÃO EXECUTADO. Miniboss RAINHA-BOBINA (Câmara da Caverna do Trovão, GDD 6.3). Só dados (T).
-- A IA básica (perseguir, telegrafar, atacar) é a mesma das criaturas; as fases de carga e os pilares são do
-- BossSystem (Chefes/CargaDaRainha). Sem 'retornoSeg': quem traz de volta é o BossSystem.

return {
	id = "RainhaBobina",
	nome = "Rainha-Bobina",
	categoria = "Miniboss",
	vida = 2400,
	postura = 300,
	defesa = 15,
	raio = 3.5,
	altura = 7,
	cor = "#B88CFF",
	ataques = {
		{ nome = "Ferrao", peso = 3, telegrafia = 0.70, impacto = 0.20, recuperacao = 1.0, alcance = 10, arcoGraus = 60, dano = 22, postura = 18, avanco = 4 },
		{ nome = "Pulso", peso = 2, telegrafia = 0.90, impacto = 0.20, recuperacao = 1.2, alcance = 8, arcoGraus = 360, dano = 18, postura = 20, avanco = 0 },
		{ nome = "Investida", peso = 1, telegrafia = 0.80, impacto = 0.25, recuperacao = 1.4, alcance = 14, arcoGraus = 40, dano = 26, postura = 24, avanco = 12 },
	},
	ia = { percepcao = 45, perseguir = true, velocidade = 12, distanciaAtaque = 9, desistir = 70, intervaloMin = 1.4 },
	retornoSeg = nil,
	recompensas = {},
}
