--!strict
-- NÃO EXECUTADO. SEGREDO (qualidade ???). Fica SÓ no servidor: o cliente nunca recebe este arquivo.
-- O perfil de voo chega ao dono por mensagem apenas enquanto a forma está ativa.
-- Obtenção: só por descobertas, enigmas e materiais de segredo (SecretDiscoverySystem, Etapa I). Nunca por compra.
-- Superior às formas equivalentes de raridades inferiores, mas dentro do orçamento (??? = 1,56× vs Arcano 1,50×):
-- a vantagem é a MECÂNICA (mergulho e arrancada), não só números maiores.

return {
	artefato = {
		id = "ArcoDasAsasPerdidas",
		nome = "Arco das Asas Perdidas",
		raridade = "Oculta",
		formaInicial = "Arco",
		formas = {
			Arco = { tipo = "Combate", arma = "ArcoDasAsas", estagioMin = 1, efeito = "FlechaDePena" },
			Asas = {
				tipo = "Locomocao", perfil = "AsasPerdidas", estagioMin = 1, efeito = "AsasDeLuz",
				montagem = { "PartirArco", "CordaViraEixo", "PenasDeLuzBrotam", "AsasAbrem" },
			},
		},
		transformacao = { duracao = 0.45, recarga = 1.2, custoEnergia = 6, golpeCancelaAcima = 16 },
		retornoAoCombate = { alturaLivre = 8, velQueda = 10, duracaoMax = 3.0 },
		estagios = {
			{ n = 1, descricao = "Desperto.", requisitos = {} },
			{ n = 2, descricao = "Mergulho Estelar.", requisitos = { desafios = { "ASetimaEstrela" } }, bonus = { habilidade = "MergulhoEstelar" } },
		},
	},
	-- forma de combate (estilo Patrulheiro): longo alcance, arco estreito (tiro), sem projétil físico no
	-- protótipo — o acerto é testado na hora, como os outros golpes. Chega ao dono só quando equipado.
	arma = {
		id = "ArcoDasAsas",
		estilo = "Patrulheiro",
		combo = {
			{ nome = "Flecha1", preparo = 0.18, golpe = 0.06, recuperacao = 0.22, alcance = 38, arcoGraus = 8, dano = 9, postura = 6, custoEstamina = 7, animacao = "ArcoTiro1" },
			{ nome = "Flecha2", preparo = 0.18, golpe = 0.06, recuperacao = 0.22, alcance = 38, arcoGraus = 8, dano = 10, postura = 6, custoEstamina = 7, animacao = "ArcoTiro2" },
			{ nome = "FlechaDePena", preparo = 0.32, golpe = 0.08, recuperacao = 0.40, alcance = 42, arcoGraus = 12, dano = 17, postura = 14, custoEstamina = 11, animacao = "ArcoTiroForte" },
		},
		pesado = { nome = "ChuvaDeLuz", preparo = 0.70, golpe = 0.15, recuperacao = 0.60, alcance = 30, arcoGraus = 40, dano = 26, postura = 24, custoEstamina = 22, animacao = "ArcoChuva" },
		bonusPosturaComboPerfeito = 0.25,
	},
	perfil = {
		id = "AsasPerdidas", nome = "Asas Perdidas", tipo = "Motorizado",
		velMax = 46, velImpulso = 70, aceleracao = 55, desaceleracao = 40, velVerticalMax = 24, acelVertical = 48,
		inclinacaoMax = 45, fatorInclinacao = 0.5, custoPorSeg = 6, custoPairarPorSeg = 5, custoImpulsoPorSeg = 16,
		decolagem = 0.3, pouso = 0.3, efeito = "AsasDeLuz",
	},
}
