--!strict
-- NÃO EXECUTADO. Restauração por estrutura e por jogador (GDD 8) — LÓGICA PURA.
-- Estados: Abandonada (etapa 0, nada entregue) → Em restauração (etapas) → Restaurada (todas as etapas).
-- Progresso = { etapa = etapas concluídas, entregue = { material → qtd } da etapa atual }.
-- Entregas parciais valem. Ajuda cooperativa: quem já entregou ao menos 'minimo' (fração) da etapa atual
-- conclui a etapa junto quando um jogador por perto conclui a mesma etapa (sem pular a experiência).

export type Progresso = { etapa: number, entregue: { [string]: number } }

local Re = {}

function Re.novo(): Progresso
	return { etapa = 0, entregue = {} }
end

function Re.estado(p: Progresso, cfg: any): string
	if p.etapa >= #cfg.etapas then
		return "Restaurada"
	elseif p.etapa == 0 and next(p.entregue) == nil then
		return "Abandonada"
	end
	return "EmRestauracao"
end

-- o que ainda falta na etapa atual: { material → qtd }
function Re.faltaNaEtapa(p: Progresso, cfg: any): { [string]: number }
	local e = cfg.etapas[p.etapa + 1]
	local falta: { [string]: number } = {}
	if not e then
		return falta
	end
	for id, qtd in e.materiais do
		local r = qtd - (p.entregue[id] or 0)
		if r > 0 then
			falta[id] = r
		end
	end
	return falta
end

-- quanto entregar agora, dado o que o jogador tem: { material → qtd } (pode ser parcial)
function Re.planejarEntrega(p: Progresso, cfg: any, disponivel: { [string]: number }): { [string]: number }
	local plano: { [string]: number } = {}
	for id, r in Re.faltaNaEtapa(p, cfg) do
		local d = math.min(r, disponivel[id] or 0)
		if d > 0 then
			plano[id] = d
		end
	end
	return plano
end

-- aplica uma entrega já paga; devolve (concluiuEtapa, restaurada)
function Re.aplicarEntrega(p: Progresso, cfg: any, entrega: { [string]: number }): (boolean, boolean)
	for id, q in entrega do
		p.entregue[id] = (p.entregue[id] or 0) + q
	end
	if p.etapa < #cfg.etapas and next(Re.faltaNaEtapa(p, cfg)) == nil then
		p.etapa += 1
		p.entregue = {}
		return true, p.etapa >= #cfg.etapas
	end
	return false, p.etapa >= #cfg.etapas
end

-- fração entregue da etapa atual (0 a 1)
function Re.fracaoEntregue(p: Progresso, cfg: any): number
	local e = cfg.etapas[p.etapa + 1]
	if not e then
		return 1
	end
	local total, feito = 0, 0
	for id, qtd in e.materiais do
		total += qtd
		feito += math.min(qtd, p.entregue[id] or 0)
	end
	return if total > 0 then feito / total else 1
end

-- ajuda: um vizinho concluiu a etapa 'etapaConcluida'; se eu estava nela e contribuí o mínimo, concluo também
function Re.concluirPorAjuda(p: Progresso, cfg: any, etapaConcluida: number, minimo: number): boolean
	if p.etapa + 1 ~= etapaConcluida or Re.fracaoEntregue(p, cfg) < minimo then
		return false
	end
	p.etapa += 1
	p.entregue = {}
	return true
end

return Re
