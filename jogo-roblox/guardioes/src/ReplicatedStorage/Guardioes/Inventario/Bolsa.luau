--!strict
-- NÃO EXECUTADO. Operações de inventário — LÓGICA PURA (o InventorySystem aplica dentro de transações).
-- Uma "bolsa" = { materiais = { id → qtd }, artefatos = { guid → { id, estagio } } }.
-- O jogador pode ter várias bolsas (a de TESTE em memória e a SALVA no perfil). Consumir é planejado sobre
-- todas e só acontece se houver o suficiente no total: ou consome tudo, ou nada.

export type Bolsa = { materiais: { [string]: number }, artefatos: { [string]: any } }
export type Falta = { id: string, tem: number, precisa: number }

local B = {}

function B.nova(): Bolsa
	return { materiais = {}, artefatos = {} }
end

function B.contar(bolsas: { Bolsa }, id: string): number
	local t = 0
	for _, b in bolsas do
		t += b.materiais[id] or 0
	end
	return t
end

-- Plano de consumo: tira da primeira bolsa da lista antes das outras (a de teste vem primeiro).
-- Retorna (ok, plano[indiceDaBolsa] = { id → qtd }, faltando).
function B.planejarConsumo(bolsas: { Bolsa }, pedido: { [string]: number }): (boolean, { { [string]: number } }, { Falta })
	local plano: { { [string]: number } } = {}
	for i = 1, #bolsas do
		plano[i] = {}
	end
	local faltando: { Falta } = {}
	for id, qtd in pedido do
		if qtd > 0 then
			local tem = B.contar(bolsas, id)
			if tem < qtd then
				table.insert(faltando, { id = id, tem = tem, precisa = qtd })
			else
				local resta = qtd
				for i, b in bolsas do
					local daqui = math.min(resta, b.materiais[id] or 0)
					if daqui > 0 then
						plano[i][id] = daqui
						resta -= daqui
					end
					if resta == 0 then
						break
					end
				end
			end
		end
	end
	table.sort(faltando, function(a, b)
		return a.id < b.id
	end)
	return #faltando == 0, plano, faltando
end

-- aplica a parte do plano numa bolsa (chamar só com um plano aprovado)
function B.aplicarConsumo(b: Bolsa, parte: { [string]: number })
	for id, qtd in parte do
		local atual = b.materiais[id] or 0
		assert(atual >= qtd, "consumo maior que o estoque: " .. id)
		local novo = atual - qtd
		b.materiais[id] = if novo > 0 then novo else nil
	end
end

-- adiciona respeitando o tamanho máximo da pilha; devolve (adicionado, excedente)
function B.adicionarMaterial(b: Bolsa, id: string, qtd: number, pilhaMax: number): (number, number)
	if qtd <= 0 then
		return 0, 0
	end
	local atual = b.materiais[id] or 0
	local cabe = math.max(0, pilhaMax - atual)
	local entra = math.min(cabe, math.floor(qtd))
	if entra > 0 then
		b.materiais[id] = atual + entra
	end
	return entra, math.floor(qtd) - entra
end

return B
