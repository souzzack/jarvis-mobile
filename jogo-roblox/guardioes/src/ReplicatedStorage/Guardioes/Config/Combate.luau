--!strict
-- NÃO EXECUTADO (sem Studio e sem runtime Luau nesta sessão). Valores (T) = ponto de partida de balanceamento.
-- Regras globais de combate, iguais para todas as armas. Só dados.

export type ConfigCombate = {
	estamina: { max: number, recuperacaoPorSeg: number, atrasoRecuperacao: number },
	esquiva: { duracao: number, invulInicio: number, invulFim: number, custo: number, recarga: number, distancia: number },
	defesa: { reducao: number, arcoGraus: number, custoPorDano: number, atordoamentoQuebra: number },
	aparar: { janela: number, posturaNoAtacante: number },
	combo: { janelaContinuar: number, bufferAntecipado: number },
	postura: { atordoamento: number, bonusDanoAtordoado: number, recuperacaoPorSeg: number, atrasoRecuperacao: number },
	rede: { capacidadeBalde: number, recargaPorSeg: number },
	mira: { alcanceMax: number, arcoExtraGraus: number },
	maxAlvosPorGolpe: number,
	toleranciaAlcance: number,
}

local Combate: ConfigCombate = {
	estamina = { max = 100, recuperacaoPorSeg = 22, atrasoRecuperacao = 0.8 },
	-- invulnerável entre 0,05 s e 0,30 s depois do início da esquiva
	esquiva = { duracao = 0.45, invulInicio = 0.05, invulFim = 0.30, custo = 25, recarga = 0.35, distancia = 12 },
	-- defesa frontal: reduz 70%; cada golpe defendido gasta estamina = 60% do dano bruto; estamina zerada = guarda quebrada
	defesa = { reducao = 0.70, arcoGraus = 120, custoPorDano = 0.60, atordoamentoQuebra = 1.2 },
	-- aparar: defesa iniciada até 0,18 s antes do impacto
	aparar = { janela = 0.18, posturaNoAtacante = 40 },
	-- depois da recuperação de um golpe, o próximo pedido continua o combo se vier em até 0,6 s;
	-- pedidos durante o golpe/recuperação ficam guardados (buffer) se faltar até 0,35 s para o fim
	combo = { janelaContinuar = 0.6, bufferAntecipado = 0.35 },
	postura = { atordoamento = 2.5, bonusDanoAtordoado = 0.30, recuperacaoPorSeg = 15, atrasoRecuperacao = 2.0 },
	rede = { capacidadeBalde = 12, recargaPorSeg = 8 },
	mira = { alcanceMax = 40, arcoExtraGraus = 30 },
	maxAlvosPorGolpe = 3,
	-- folga (studs) entre a posição vista pelo servidor e a do cliente (latência)
	toleranciaAlcance = 1.5,
}

return Combate
