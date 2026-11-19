--!strict
-- NÃO EXECUTADO. Mecânica do COLOSSO DAS RUÍNAS (GDD 6.3) — LÓGICA PURA.
--  * Couraça: imune a golpes enquanto o núcleo está fechado. Cada golpe dele APARADO conta; 3 aparos
--    abrem o NÚCLEO nas costas por alguns segundos (ferível). Depois fecha e a contagem zera.
--  * Pisoteio com ONDA: de tempos em tempos, telegrafa e solta uma onda em volta (raio fixo); esquivar no
--    instante (i-frames) evita.

export type Estado = { aparos: number, expostoAte: number, proximaOnda: number, ondaAte: number, emOnda: boolean }
export type Config = { aparosParaAbrir: number, exposicao: number, intervaloOnda: number, telegrafiaOnda: number }

local Co = {}

function Co.novo(agora: number, cfg: Config): Estado
	return { aparos = 0, expostoAte = 0, proximaOnda = agora + cfg.intervaloOnda, ondaAte = 0, emOnda = false }
end

function Co.exposto(e: Estado, agora: number): boolean
	return agora < e.expostoAte
end

-- um golpe do Colosso foi aparado; devolve true quando ABRE o núcleo agora
function Co.aparado(e: Estado, agora: number, cfg: Config): boolean
	if Co.exposto(e, agora) then
		return false
	end
	e.aparos += 1
	if e.aparos >= cfg.aparosParaAbrir then
		e.aparos = 0
		e.expostoAte = agora + cfg.exposicao
		return true
	end
	return false
end

-- "TelegrafaOnda" | "Onda" | "Fechou" | nil
function Co.atualizar(e: Estado, agora: number, cfg: Config, estavaExposto: boolean): string?
	if estavaExposto and not Co.exposto(e, agora) then
		return "Fechou"
	end
	if e.emOnda then
		if agora >= e.ondaAte then
			e.emOnda = false
			e.proximaOnda = agora + cfg.intervaloOnda
			return "Onda"
		end
		return nil
	end
	if agora >= e.proximaOnda then
		e.emOnda = true
		e.ondaAte = agora + cfg.telegrafiaOnda
		return "TelegrafaOnda"
	end
	return nil
end

return Co
