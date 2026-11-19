--!strict
-- NÃO EXECUTADO. Rolagem de saque com PROTEÇÃO CONTRA AZAR — LÓGICA PURA (o sorteio vem de fora).
-- Cada entrada tem chance própria; as raras têm 'garantiaEm': depois de N tentativas sem cair, cai com certeza.
-- O contador ('azar') é por jogador e por entrada; zera quando o item cai.

export type Entrada = { id: string, chance: number, min: number, max: number, garantiaEm: number? }
export type Tabela = { entradas: { Entrada } }

local S = {}

-- 'sortear' devolve um número em [0, 1). Retorna { id → quantidade } e atualiza 'azar' (id → tentativas).
function S.rolar(t: Tabela, azar: { [string]: number }, sortear: () -> number): { [string]: number }
	local saque: { [string]: number } = {}
	for _, e in t.entradas do
		local tentativas = (azar[e.id] or 0) + 1
		local caiu = sortear() < e.chance
		if not caiu and e.garantiaEm and tentativas >= e.garantiaEm then
			caiu = true
		end
		if caiu then
			local faixa = math.max(0, e.max - e.min)
			local qtd = e.min + math.min(faixa, math.floor(sortear() * (faixa + 1)))
			saque[e.id] = (saque[e.id] or 0) + qtd
			azar[e.id] = 0
		else
			azar[e.id] = tentativas
		end
	end
	return saque
end

-- parte de cada jogador no saque: só quem causou ao menos 'minimo' do dano total ganha (saque pessoal,
-- ninguém "rouba" o do outro). Retorna a lista de jogadores elegíveis.
function S.elegiveis<J>(contribuicao: { [J]: number }, minimo: number): { J }
	local total = 0
	for _, d in contribuicao do
		total += d
	end
	local lista = {}
	if total <= 0 then
		return lista
	end
	for j, d in contribuicao do
		if d / total >= minimo then
			table.insert(lista, j)
		end
	end
	return lista
end

return S
