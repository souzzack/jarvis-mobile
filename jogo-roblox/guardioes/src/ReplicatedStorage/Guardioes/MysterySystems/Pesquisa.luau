--!strict
-- NÃO EXECUTADO. PESQUISA E FABRICAÇÃO SECRETA (ArtifactResearchService, seção 11) — LÓGICA PURA.
-- Uma pesquisa tem as 7 etapas do complemento: pista → origem (capítulo) → enigmas → receita → componentes →
-- fabricação → novas formas. Cada etapa tem UMA condição verificável pelo servidor. A receita ??? nunca é
-- fabricada sem estar no perfil (misterios.receitas), mesmo com todos os materiais na bolsa.

local P = {}

-- prog: { pistas, capitulos (["inv#n"]=true), enigmas, receitas, fabricados, materiais, evolucoes }
local function cumpre(cond: any, prog: any): boolean
	if cond.pista then
		return (prog.pistas or {})[cond.pista] == true
	elseif cond.capitulo then
		return (prog.capitulos or {})[cond.capitulo] == true
	elseif cond.enigma then
		return (prog.enigmas or {})[cond.enigma] == true
	elseif cond.receita then
		return (prog.receitas or {})[cond.receita] == true
	elseif cond.materiais then
		for id, q in cond.materiais do
			if ((prog.materiais or {})[id] or 0) < q then
				return false
			end
		end
		return true
	elseif cond.fabricado then
		return ((prog.fabricados or {})[cond.fabricado] or 0) > 0
	elseif cond.evolucao then
		return (prog.evolucoes or {})[cond.evolucao] == true
	end
	return false
end

-- índice da primeira etapa NÃO cumprida (#etapas + 1 = pesquisa completa)
function P.etapaAtual(cfg: any, prog: any): number
	for i, e in cfg.etapas do
		if not cumpre(e.condicao, prog) then
			return i
		end
	end
	return #cfg.etapas + 1
end

-- (pode, faltando). ctx: { conhecida, estacoes = { [id] = nivel }, contar = function(id) → qtd, nivelJogador }
function P.podeFabricar(receita: any, ctx: any): (boolean, { any })
	local faltando = {}
	if not ctx.conhecida then
		table.insert(faltando, { tipo = "receita", id = receita.id })
		return false, faltando -- sem receita nem olha o resto
	end
	local nivel = (ctx.estacoes or {})[receita.estacao] or 0
	if nivel < (receita.estacaoNivel or 1) then
		table.insert(faltando, { tipo = "estacao", id = receita.estacao, tem = nivel, precisa = receita.estacaoNivel or 1 })
	end
	if receita.nivelJogador and (ctx.nivelJogador or 0) < receita.nivelJogador then
		table.insert(faltando, { tipo = "nivel", id = "nivel", tem = ctx.nivelJogador or 0, precisa = receita.nivelJogador })
	end
	for id, q in receita.materiais do
		local tem = ctx.contar(id)
		if tem < q then
			table.insert(faltando, { tipo = "material", id = id, tem = tem, precisa = q })
		end
	end
	return #faltando == 0, faltando
end

return P
