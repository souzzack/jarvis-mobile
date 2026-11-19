--!strict
-- NÃO EXECUTADO. Resolução de um golpe contra um alvo. LÓGICA PURA.
-- Ordem: esquivado (invulnerável) → aparado (defesa recém-iniciada, de frente) → defendido (de frente) → acerto.

export type Entrada = {
	danoBase: number,
	multiplicador: number?, -- bônus de atributos/maestria/raridade (1 = nenhum)
	defesaAlvo: number?,
	alvoAtordoado: boolean?,
	bonusAtordoado: number?, -- +30% se o alvo estiver atordoado
	postura: number,
	bonusPostura: number?, -- ex.: combo perfeito +25%
	alvoInvulneravel: boolean,
	alvoAparando: boolean,
	alvoDefendendo: boolean,
	frontal: boolean,
	reducaoDefesa: number,
	custoEstaminaPorDano: number,
	posturaAparar: number,
}

export type Resultado = {
	tipo: string, -- "Acerto" | "Defendido" | "Aparado" | "Esquivado"
	dano: number,
	posturaNoAlvo: number,
	estaminaDoAlvo: number,
	posturaNoAtacante: number,
}

local Dano = {}

local function arred(x: number): number
	return math.floor(x + 0.5)
end

-- mitigação por defesa: 100 de defesa = metade do dano; nunca negativa, nunca zera
function Dano.mitigacao(defesa: number?): number
	local d = math.max(0, defesa or 0)
	return 100 / (100 + d)
end

function Dano.bruto(e: Entrada): number
	local m = (e.multiplicador or 1) * Dano.mitigacao(e.defesaAlvo)
	if e.alvoAtordoado then
		m *= 1 + (e.bonusAtordoado or 0)
	end
	return math.max(0, e.danoBase * m)
end

function Dano.resolver(e: Entrada): Resultado
	if e.alvoInvulneravel then
		return { tipo = "Esquivado", dano = 0, posturaNoAlvo = 0, estaminaDoAlvo = 0, posturaNoAtacante = 0 }
	end
	if e.alvoAparando and e.frontal then
		return { tipo = "Aparado", dano = 0, posturaNoAlvo = 0, estaminaDoAlvo = 0, posturaNoAtacante = e.posturaAparar }
	end
	local bruto = Dano.bruto(e)
	local postura = e.postura * (1 + (e.bonusPostura or 0))
	if e.alvoDefendendo and e.frontal then
		return {
			tipo = "Defendido",
			dano = arred(bruto * (1 - e.reducaoDefesa)),
			posturaNoAlvo = arred(postura * 0.5),
			estaminaDoAlvo = bruto * e.custoEstaminaPorDano,
			posturaNoAtacante = 0,
		}
	end
	local dano = arred(bruto)
	if bruto > 0 and dano < 1 then
		dano = 1
	end
	return { tipo = "Acerto", dano = dano, posturaNoAlvo = arred(postura), estaminaDoAlvo = 0, posturaNoAtacante = 0 }
end

return Dano
