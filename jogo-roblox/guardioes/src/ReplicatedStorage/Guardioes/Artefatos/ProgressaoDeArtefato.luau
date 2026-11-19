--!strict
-- NÃO EXECUTADO. Evolução de artefato por estágios (ArtifactProgressionSystem, parte pura).
-- Requisitos só de JOGO: missões, desafios, materiais. Nenhum caminho por compra.
-- Esta função só AVALIA e devolve o que consumir; o consumo de materiais é uma transação atômica do
-- InventorySystem (Etapa D), feita junto com a troca de estágio — ou tudo acontece, ou nada.

export type Progresso = { missoes: { [string]: boolean }, desafios: { [string]: boolean }, materiais: { [string]: number } }
export type Falta = { tipo: string, id: string, tem: number, precisa: number }

local P = {}

function P.proximo(cfg: any, estagioAtual: number): any?
	for _, e in cfg.estagios do
		if e.n == estagioAtual + 1 then
			return e
		end
	end
	return nil
end

-- (pode, faltando, materiaisAConsumir)
function P.avaliar(cfg: any, estagioAtual: number, prog: Progresso): (boolean, { Falta }, { [string]: number })
	local e = P.proximo(cfg, estagioAtual)
	local faltando: { Falta } = {}
	local consumir: { [string]: number } = {}
	if not e then
		table.insert(faltando, { tipo = "maximo", id = cfg.id, tem = estagioAtual, precisa = estagioAtual })
		return false, faltando, consumir
	end
	local r = e.requisitos or {}
	for _, id in r.missoes or {} do
		if not prog.missoes[id] then
			table.insert(faltando, { tipo = "missao", id = id, tem = 0, precisa = 1 })
		end
	end
	for _, id in r.desafios or {} do
		if not prog.desafios[id] then
			table.insert(faltando, { tipo = "desafio", id = id, tem = 0, precisa = 1 })
		end
	end
	for id, qtd in r.materiais or {} do
		local tem = prog.materiais[id] or 0
		consumir[id] = qtd
		if tem < qtd then
			table.insert(faltando, { tipo = "material", id = id, tem = tem, precisa = qtd })
		end
	end
	table.sort(faltando, function(a, b)
		return a.tipo .. a.id < b.tipo .. b.id
	end)
	return #faltando == 0, faltando, consumir
end

-- fontes de mods para PerfilEfetivo vindas dos estágios já alcançados
function P.fontesDeBonus(cfg: any, estagio: number): { any }
	local fontes = {}
	for _, e in cfg.estagios do
		if e.n <= estagio and e.bonus and e.bonus.mods then
			table.insert(fontes, { perfis = { e.bonus.perfil }, mods = e.bonus.mods })
		end
	end
	return fontes
end

return P
