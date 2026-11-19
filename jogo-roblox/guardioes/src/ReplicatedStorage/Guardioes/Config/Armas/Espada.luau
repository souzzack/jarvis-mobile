--!strict
-- NÃO EXECUTADO. Espada (estilo Espadachim): combo de 3 golpes + ataque pesado. Só dados.
-- Tempos em segundos: preparo (telegrafia do próprio golpe), golpe (janela ativa: o acerto é testado no início dela),
-- recuperacao (não pode atacar de novo, mas pode esquivar). Alcance em studs, arco em graus, dano base antes da fórmula.

export type Golpe = {
	nome: string,
	preparo: number,
	golpe: number,
	recuperacao: number,
	alcance: number,
	arcoGraus: number,
	dano: number,
	postura: number,
	custoEstamina: number,
	animacao: string, -- chave em Animacoes (IDs só depois do upload no Studio: nunca inventar IDs)
}

export type Arma = {
	id: string,
	estilo: string,
	combo: { Golpe },
	pesado: Golpe,
	bonusPosturaComboPerfeito: number,
}

local Espada: Arma = {
	id = "Espada",
	estilo = "Espadachim",
	combo = {
		{ nome = "Corte1", preparo = 0.12, golpe = 0.10, recuperacao = 0.22, alcance = 7, arcoGraus = 110, dano = 10, postura = 8, custoEstamina = 8, animacao = "EspadaCorte1" },
		{ nome = "Corte2", preparo = 0.14, golpe = 0.10, recuperacao = 0.24, alcance = 7, arcoGraus = 110, dano = 12, postura = 10, custoEstamina = 9, animacao = "EspadaCorte2" },
		{ nome = "Estocada", preparo = 0.22, golpe = 0.12, recuperacao = 0.40, alcance = 9, arcoGraus = 40, dano = 18, postura = 18, custoEstamina = 12, animacao = "EspadaEstocada" },
	},
	pesado = { nome = "GolpePesado", preparo = 0.55, golpe = 0.14, recuperacao = 0.60, alcance = 8, arcoGraus = 140, dano = 28, postura = 35, custoEstamina = 22, animacao = "EspadaPesado" },
	-- 3º golpe encadeado sem errar nenhum: +25% de postura (GDD 5.4)
	bonusPosturaComboPerfeito = 0.25,
}

return Espada
