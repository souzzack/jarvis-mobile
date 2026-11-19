--!strict
-- NÃO EXECUTADO. Mecânica do ESPECTRO DO OBSERVATÓRIO (GDD 6.3) — LÓGICA PURA.
--  * Só aparece à NOITE (horário do jogo, medido pelo servidor).
--  * Teleporta entre as LENTES do observatório de tempos em tempos.
--  * Imune, exceto ao REFLEXO do telescópio: com o Observatório restaurado, ativar o telescópio deixa o Espectro
--    ferível (e atordoado no início) por alguns segundos. O telescópio tem recarga.

export type Estado = { lente: number, proximoTeleporte: number, vulneravelAte: number, telescopioPronto: number }
export type Config = { lentes: number, intervaloTeleporte: number, janelaReflexo: number, recargaTelescopio: number }

local Es = {}

function Es.noite(horaDoDia: number, inicio: number, fim: number): boolean
	-- janela que atravessa a meia-noite (ex.: 18h às 6h)
	if inicio > fim then
		return horaDoDia >= inicio or horaDoDia < fim
	end
	return horaDoDia >= inicio and horaDoDia < fim
end

function Es.novo(agora: number, cfg: Config): Estado
	return { lente = 1, proximoTeleporte = agora + cfg.intervaloTeleporte, vulneravelAte = 0, telescopioPronto = agora }
end

function Es.vulneravel(e: Estado, agora: number): boolean
	return agora < e.vulneravelAte
end

-- devolve a NOVA lente quando teleporta (nunca a mesma), ou nil. Não teleporta durante o reflexo.
function Es.atualizar(e: Estado, agora: number, cfg: Config, sortear: () -> number): number?
	if Es.vulneravel(e, agora) or agora < e.proximoTeleporte then
		return nil
	end
	local outra = 1 + math.min(cfg.lentes - 2, math.floor(sortear() * (cfg.lentes - 1)))
	if outra >= e.lente then
		outra += 1 -- pula a lente atual
	end
	e.lente = outra
	e.proximoTeleporte = agora + cfg.intervaloTeleporte
	return outra
end

-- ativar o telescópio: (ok, motivo)
function Es.refletir(e: Estado, agora: number, cfg: Config, observatorioRestaurado: boolean): (boolean, string)
	if not observatorioRestaurado then
		return false, "telescopioQuebrado"
	end
	if agora < e.telescopioPronto then
		return false, "recarga"
	end
	e.vulneravelAte = agora + cfg.janelaReflexo
	e.telescopioPronto = agora + cfg.recargaTelescopio
	e.proximoTeleporte = math.max(e.proximoTeleporte, e.vulneravelAte)
	return true, "ok"
end

return Es
