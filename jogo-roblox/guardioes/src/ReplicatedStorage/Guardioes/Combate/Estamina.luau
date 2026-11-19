--!strict
-- NÃO EXECUTADO. Estamina do personagem. LÓGICA PURA: o tempo vem de fora.
-- Recupera 'recuperacaoPorSeg' depois de 'atrasoRecuperacao' segundos sem gasto.

export type ConfigRecurso = { max: number, recuperacaoPorSeg: number, atrasoRecuperacao: number }
export type Recurso = { valor: number, max: number, ultimoGasto: number, ultimaAtualizacao: number }

local Estamina = {}

function Estamina.nova(max: number, agora: number): Recurso
	return { valor = max, max = max, ultimoGasto = -math.huge, ultimaAtualizacao = agora }
end

function Estamina.atualizar(r: Recurso, cfg: ConfigRecurso, agora: number)
	local inicioRecuperacao = r.ultimoGasto + cfg.atrasoRecuperacao
	local desde = math.max(r.ultimaAtualizacao, inicioRecuperacao)
	if agora > desde then
		r.valor = math.min(r.max, r.valor + cfg.recuperacaoPorSeg * (agora - desde))
	end
	r.ultimaAtualizacao = math.max(r.ultimaAtualizacao, agora)
end

-- gasto normal: só acontece se houver o suficiente
function Estamina.gastar(r: Recurso, cfg: ConfigRecurso, quanto: number, agora: number): boolean
	Estamina.atualizar(r, cfg, agora)
	if r.valor + 1e-9 < quanto then
		return false
	end
	r.valor -= quanto
	r.ultimoGasto = agora
	return true
end

-- dreno forçado (defesa recebendo golpe): pode zerar; devolve true se zerou ("quebrou")
function Estamina.drenar(r: Recurso, cfg: ConfigRecurso, quanto: number, agora: number): boolean
	Estamina.atualizar(r, cfg, agora)
	r.valor -= quanto
	r.ultimoGasto = agora
	if r.valor <= 0 then
		r.valor = 0
		return true
	end
	return false
end

-- recuperação instantânea (consumível): não reinicia o atraso de recuperação; nunca passa do máximo
function Estamina.recuperar(r: Recurso, cfg: ConfigRecurso, quanto: number, agora: number)
	Estamina.atualizar(r, cfg, agora)
	r.valor = math.min(r.max, r.valor + math.max(0, quanto))
end

return Estamina
