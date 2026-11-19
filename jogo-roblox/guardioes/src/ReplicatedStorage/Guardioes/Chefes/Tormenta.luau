--!strict
-- NÃO EXECUTADO. Mecânica do GUARDIÃO DA TORMENTA (GDD 6.3) — LÓGICA PURA (tempo e sorteio vêm de fora).
--   Fase 1 (100–65%): luta comum (lança, investida aérea, trovão).
--   Fase 2 (65–30%): o Guardião fica IMUNE a golpes; os para-raios carregam UM POR VEZ. Ativar o carregado
--     joga o raio nele (dano grande + atordoado, janela de golpes). Ninguém ativa a tempo = o raio cai em volta
--     daquele para-raio. Ativar o errado dá um choque em quem ativou.
--   Fase 3 (30–0%): o olho da tempestade fecha; o chão eletrifica em PADRÕES telegrafados (centro, anel, cruz)
--     que pedem esquiva (i-frames valem).

export type Estado = {
	fase: number,
	carregado: number?, carregadoAte: number, proximaCarga: number,
	padrao: string?, telegrafiaAte: number, proximoPadrao: number,
}
export type Config = {
	paraRaios: number, janelaCarga: number, intervaloCarga: number,
	telegrafia: number, intervaloPadrao: number,
}
export type Evento = { tipo: string, idx: number?, padrao: string?, fase: number? }

local T = {}
T.LIMIARES = { 0.65, 0.30 }
T.PADROES = { "Centro", "Anel", "Cruz" }

function T.novo(agora: number): Estado
	return { fase = 1, carregado = nil, carregadoAte = 0, proximaCarga = agora, padrao = nil, telegrafiaAte = 0, proximoPadrao = agora }
end

function T.faseDe(fracaoVida: number): number
	if fracaoVida <= T.LIMIARES[2] then
		return 3
	elseif fracaoVida <= T.LIMIARES[1] then
		return 2
	end
	return 1
end

-- avança o tempo; 'sortear' devolve [0,1). Nunca volta de fase.
function T.atualizar(e: Estado, agora: number, fracaoVida: number, cfg: Config, sortear: () -> number): { Evento }
	local ev: { Evento } = {}
	local f = T.faseDe(fracaoVida)
	if f > e.fase then
		e.fase = f
		table.insert(ev, { tipo = "Fase", fase = f })
		e.carregado = nil
		if f == 2 then
			e.proximaCarga = agora + 1.5
		elseif f == 3 then
			e.proximoPadrao = agora + 2
		end
	end
	if e.fase == 2 then
		if e.carregado and agora >= e.carregadoAte then
			table.insert(ev, { tipo = "RaioFalhou", idx = e.carregado })
			e.carregado = nil
			e.proximaCarga = agora + cfg.intervaloCarga
		elseif not e.carregado and agora >= e.proximaCarga then
			e.carregado = 1 + math.min(cfg.paraRaios - 1, math.floor(sortear() * cfg.paraRaios))
			e.carregadoAte = agora + cfg.janelaCarga
			table.insert(ev, { tipo = "Carga", idx = e.carregado })
		end
	elseif e.fase == 3 then
		if e.padrao and agora >= e.telegrafiaAte then
			table.insert(ev, { tipo = "Descarrega", padrao = e.padrao })
			e.padrao = nil
			e.proximoPadrao = agora + cfg.intervaloPadrao
		elseif not e.padrao and agora >= e.proximoPadrao then
			e.padrao = T.PADROES[1 + math.min(#T.PADROES - 1, math.floor(sortear() * #T.PADROES))]
			e.telegrafiaAte = agora + cfg.telegrafia
			table.insert(ev, { tipo = "Telegrafa", padrao = e.padrao })
		end
	end
	return ev
end

-- um jogador ativou o para-raios 'idx': "Acerto" | "Errado" | nil (fora da fase 2)
function T.ativar(e: Estado, idx: number, agora: number, cfg: Config): string?
	if e.fase ~= 2 then
		return nil
	end
	if e.carregado == idx then
		e.carregado = nil
		e.proximaCarga = agora + cfg.intervaloCarga
		return "Acerto"
	end
	return "Errado"
end

-- o ponto (dx, dz relativo ao centro da arena) está na área do padrão?
function T.noPadrao(padrao: string, dx: number, dz: number): boolean
	local r = math.sqrt(dx * dx + dz * dz)
	if padrao == "Centro" then
		return r <= 8
	elseif padrao == "Anel" then
		return r >= 10 and r <= 18
	elseif padrao == "Cruz" then
		return math.abs(dx) <= 3 or math.abs(dz) <= 3
	end
	return false
end

return T
