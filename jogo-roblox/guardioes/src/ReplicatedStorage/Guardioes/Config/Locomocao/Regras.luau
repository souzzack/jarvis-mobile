--!strict
-- NÃO EXECUTADO. Regras globais de locomoção (valores (T) = ponto de partida, a balancear em teste). Só dados.

export type Regras = {
	energia: { max: number, recuperacaoPorSeg: number, atrasoRecuperacao: number, minDecolar: number },
	alturaMaxAbsoluta: number,
	planador: { alturaMinAbrir: number },
	interrupcao: { duracao: number, velQuedaAmortecida: number },
	solo: { velHorizontal: number, velSubida: number, velQueda: number },
	validacao: { frequenciaHz: number, folgaStuds: number, fatorVelocidade: number, violacoesParaCorrigir: number },
	rede: { capacidadeBalde: number, recargaPorSeg: number },
	atingidoInterrompeVoo: number,
}

local Regras: Regras = {
	-- energia de voo (separada da estamina de combate); só recupera no chão ou montado parado
	energia = { max = 100, recuperacaoPorSeg = 14, atrasoRecuperacao = 1.2, minDecolar = 15 },
	-- teto de voo do place (Y absoluto); cada dimensão pode baixar com a sua própria config
	alturaMaxAbsoluta = 600,
	planador = { alturaMinAbrir = 8 },
	-- interrupção (energia zerou, zona proibida, golpe forte): queda amortecida até o chão
	interrupcao = { duracao = 0.6, velQuedaAmortecida = 18 },
	-- limites usados pelo servidor quando o jogador está a pé (andar 16 + folga de pulo e empurrões)
	solo = { velHorizontal = 30, velSubida = 60, velQueda = 260 },
	-- conferência no servidor: amostras a 10 Hz, folga para latência, 2 violações seguidas = correção
	validacao = { frequenciaHz = 10, folgaStuds = 4, fatorVelocidade = 1.25, violacoesParaCorrigir = 2 },
	rede = { capacidadeBalde = 10, recargaPorSeg = 6 },
	-- dano recebido igual ou maior que isto derruba do voo (golpes pequenos não)
	atingidoInterrompeVoo = 12,
}

return Regras
