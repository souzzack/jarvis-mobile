--!strict
-- NÃO EXECUTADO. Avaliação de receita (GDD 7.3) — LÓGICA PURA.
-- Exige: conhecer a receita (ou ser conhecida desde o início), estar perto da ESTAÇÃO certa, requisitos de mundo
-- (restauração etc., via Util/Requisitos no sistema) e os materiais. Devolve o que consumir e o que entregar;
-- o InventorySystem faz as duas coisas numa transação só.

export type Falta = { tipo: string, id: string, tem: number, precisa: number }
export type Contexto = {
	conhecidas: { [string]: boolean },
	estacoesPerto: { [string]: boolean },
	requisitosOk: boolean,
	faltasDeRequisito: { { tipo: string, id: string } },
	materiais: { [string]: number }, -- quanto o jogador tem de cada material pedido
}

local R = {}

function R.conhecida(receita: any, conhecidas: { [string]: boolean }): boolean
	return receita.conhecidaDesdeInicio == true or conhecidas[receita.id] == true
end

-- (pode, faltando, consumir)
function R.avaliar(receita: any, ctx: Contexto): (boolean, { Falta }, { [string]: number })
	local faltando: { Falta } = {}
	if not R.conhecida(receita, ctx.conhecidas) then
		table.insert(faltando, { tipo = "receita", id = receita.id, tem = 0, precisa = 1 })
	end
	if receita.estacao and not ctx.estacoesPerto[receita.estacao] then
		table.insert(faltando, { tipo = "estacao", id = receita.estacao, tem = 0, precisa = 1 })
	end
	if not ctx.requisitosOk then
		for _, f in ctx.faltasDeRequisito do
			table.insert(faltando, { tipo = f.tipo, id = f.id, tem = 0, precisa = 1 })
		end
	end
	local consumir: { [string]: number } = {}
	for id, qtd in receita.materiais do
		consumir[id] = qtd
		local tem = ctx.materiais[id] or 0
		if tem < qtd then
			table.insert(faltando, { tipo = "material", id = id, tem = tem, precisa = qtd })
		end
	end
	table.sort(faltando, function(a, b)
		return a.tipo .. a.id < b.tipo .. b.id
	end)
	return #faltando == 0, faltando, consumir
end

return R
