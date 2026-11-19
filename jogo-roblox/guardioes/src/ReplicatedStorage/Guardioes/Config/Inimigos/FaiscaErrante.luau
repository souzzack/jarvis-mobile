--!strict
-- NÃO EXECUTADO. Faísca Errante — criatura comum da Ilha das Tempestades (GDD 6.2), usada como inimigo de teste.
-- Padrão: persegue, telegrafa (brilho), investe em linha; às vezes faz uma descarga curta em volta de si.
-- Cada ataque: telegrafia (s), janela de impacto (s), recuperação (s), alcance, arco, dano, postura no jogador.

local Faisca = {
	id = "FaiscaErrante",
	nome = "Faísca Errante",
	categoria = "Comum",
	vida = 120,
	postura = 60,
	defesa = 5,
	raio = 1.4,
	altura = 3,
	cor = "#56D6FF",
	ataques = {
		{ nome = "Investida", peso = 3, telegrafia = 0.55, impacto = 0.20, recuperacao = 0.9, alcance = 9, arcoGraus = 50, dano = 14, postura = 12, avanco = 8 },
		{ nome = "Descarga", peso = 1, telegrafia = 0.80, impacto = 0.15, recuperacao = 1.1, alcance = 6, arcoGraus = 360, dano = 18, postura = 20, avanco = 0 },
	},
	ia = { percepcao = 38, perseguir = true, velocidade = 14, distanciaAtaque = 7, desistir = 60, intervaloMin = 1.2 },
	retornoSeg = 60,
	recompensas = {},
}

return Faisca
