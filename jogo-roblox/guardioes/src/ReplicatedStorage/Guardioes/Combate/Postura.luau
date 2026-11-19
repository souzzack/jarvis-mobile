--!strict
-- NÃO EXECUTADO. Postura de um inimigo (ou chefe). LÓGICA PURA.
-- Golpes acumulam postura; ao encher, o alvo é derrubado (atordoado) e a barra zera.
-- Sem receber golpes por 'atrasoRecuperacao' s, a postura acumulada baixa 'recuperacaoPorSeg' por segundo.

export type ConfigPostura = { recuperacaoPorSeg: number, atrasoRecuperacao: number }
export type Postura = { acumulada: number, max: number, ultimoGolpe: number, ultimaAtualizacao: number }

local Postura = {}

function Postura.nova(max: number, agora: number): Postura
	return { acumulada = 0, max = max, ultimoGolpe = -math.huge, ultimaAtualizacao = agora }
end

function Postura.atualizar(p: Postura, cfg: ConfigPostura, agora: number)
	local desde = math.max(p.ultimaAtualizacao, p.ultimoGolpe + cfg.atrasoRecuperacao)
	if agora > desde then
		p.acumulada = math.max(0, p.acumulada - cfg.recuperacaoPorSeg * (agora - desde))
	end
	p.ultimaAtualizacao = math.max(p.ultimaAtualizacao, agora)
end

-- devolve true se a postura encheu (o alvo cai) — a barra volta a zero
function Postura.receber(p: Postura, cfg: ConfigPostura, quanto: number, agora: number): boolean
	Postura.atualizar(p, cfg, agora)
	p.acumulada += math.max(0, quanto)
	p.ultimoGolpe = agora
	if p.acumulada >= p.max then
		p.acumulada = 0
		return true
	end
	return false
end

return Postura
