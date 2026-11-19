--!strict
-- NÃO EXECUTADO. Perfis de locomoção aérea PÚBLICOS. Só dados (T = a balancear).
-- Um perfil descreve COMO o corpo se move; quem dá acesso a ele é uma habilidade, raça, artefato ou montaria.
-- Perfis de itens ??? ficam no servidor (ConfigSecreta) e só chegam ao dono quando estão ativos.
--
-- tipo: "Motorizado" (voo completo) | "Plataforma" (baixa altura, curta) | "Planador" (sem motor: perde altura)
-- Velocidades em studs/s (andar = 16). Acelerações em studs/s². Custos em energia/s.
-- Princípio de equilíbrio: nenhum transporte é melhor em tudo (veja docs/07, seção 8).

export type Perfil = {
	id: string,
	nome: string,
	tipo: string,
	velMax: number,
	velImpulso: number, -- 0 = sem impulso (liberado por habilidade/estágio)
	velMin: number?, -- planador: velocidade mínima para frente
	aceleracao: number,
	desaceleracao: number,
	velVerticalMax: number,
	acelVertical: number,
	afundamento: number?, -- planador: queda por segundo sem corrente
	taxaGiro: number?, -- planador: graus/s de curva
	alturaMaxSobreSolo: number?, -- plataforma: não sobe mais que isto acima do chão
	inclinacaoMax: number, -- graus de rolagem nas curvas (visual)
	fatorInclinacao: number,
	custoPorSeg: number,
	custoPairarPorSeg: number,
	custoImpulsoPorSeg: number,
	decolagem: number, -- duração (s) do estado Takeoff
	pouso: number, -- duração (s) do estado Landing
	efeito: string, -- nome do conjunto de efeitos (FlightEffects)
}

local lista: { Perfil } = {
	{
		id = "VooMagico", nome = "Voo mágico", tipo = "Motorizado",
		velMax = 32, velImpulso = 0, aceleracao = 36, desaceleracao = 30, velVerticalMax = 16, acelVertical = 30,
		inclinacaoMax = 30, fatorInclinacao = 0.35, custoPorSeg = 6, custoPairarPorSeg = 4, custoImpulsoPorSeg = 16,
		decolagem = 0.45, pouso = 0.35, efeito = "Arcano",
	},
	{
		id = "AsasNaturais", nome = "Asas (raça Alada)", tipo = "Motorizado",
		velMax = 30, velImpulso = 0, aceleracao = 40, desaceleracao = 34, velVerticalMax = 18, acelVertical = 36,
		inclinacaoMax = 38, fatorInclinacao = 0.4, custoPorSeg = 4.5, custoPairarPorSeg = 5, custoImpulsoPorSeg = 15,
		decolagem = 0.5, pouso = 0.4, efeito = "Penas",
	},
	{
		id = "PranchaHorizonte", nome = "Prancha do Horizonte", tipo = "Motorizado",
		velMax = 42, velImpulso = 0, aceleracao = 34, desaceleracao = 26, velVerticalMax = 14, acelVertical = 24,
		inclinacaoMax = 34, fatorInclinacao = 0.45, custoPorSeg = 7, custoPairarPorSeg = 3, custoImpulsoPorSeg = 18,
		decolagem = 0.3, pouso = 0.3, efeito = "Raio",
	},
	{
		id = "PlataformaFirmamento", nome = "Plataforma do Firmamento", tipo = "Plataforma",
		velMax = 14, velImpulso = 0, aceleracao = 20, desaceleracao = 24, velVerticalMax = 4, acelVertical = 10,
		alturaMaxSobreSolo = 8,
		inclinacaoMax = 8, fatorInclinacao = 0.15, custoPorSeg = 14, custoPairarPorSeg = 10, custoImpulsoPorSeg = 0,
		decolagem = 0.35, pouso = 0.25, efeito = "Folhas",
	},
	{
		id = "VassouraVentos", nome = "Cajado dos Ventos (forma de voo)", tipo = "Motorizado",
		velMax = 38, velImpulso = 0, aceleracao = 44, desaceleracao = 36, velVerticalMax = 20, acelVertical = 40,
		inclinacaoMax = 42, fatorInclinacao = 0.5, custoPorSeg = 6.5, custoPairarPorSeg = 6, custoImpulsoPorSeg = 17,
		decolagem = 0.35, pouso = 0.3, efeito = "Vento",
	},
	{
		id = "Planador", nome = "Planador", tipo = "Planador",
		velMax = 30, velImpulso = 0, velMin = 14, aceleracao = 10, desaceleracao = 8, velVerticalMax = 24, acelVertical = 14,
		afundamento = 6, taxaGiro = 90,
		inclinacaoMax = 25, fatorInclinacao = 0.3, custoPorSeg = 0, custoPairarPorSeg = 0, custoImpulsoPorSeg = 0,
		decolagem = 0.35, pouso = 0.3, efeito = "Tecido",
	},
}

local porId: { [string]: Perfil } = {}
for _, p in lista do
	porId[p.id] = p
end

return { lista = lista, porId = porId }
