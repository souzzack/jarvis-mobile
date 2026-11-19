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
	perfil = {
		id = "AsasPerdidas", nome = "Asas Perdidas", tipo = "Motorizado",
		velMax = 46, velImpulso = 70, aceleracao = 55, desaceleracao = 40, velVerticalMax = 24, acelVertical = 48,
		inclinacaoMax = 45, fatorInclinacao = 0.5, custoPorSeg = 6, custoPairarPorSeg = 5, custoImpulsoPorSeg = 16,
		decolagem = 0.3, pouso = 0.3, efeito = "AsasDeLuz",
	},
}
