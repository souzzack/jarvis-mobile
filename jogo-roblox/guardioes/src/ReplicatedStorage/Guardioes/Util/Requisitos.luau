--!strict
-- NÃO EXECUTADO. Avaliador genérico de requisitos — LÓGICA PURA. Usado por livros (e reaproveitável por
-- portais, receitas e missões). 'progresso' traz conjuntos { [id] = true } por categoria.
-- Categorias: missoes, restauracoes, habilidades, livros, segredos, dimensoes, enigmas.

export type Falta = { tipo: string, id: string }

local CATEGORIAS: { [string]: string } = {
	missoes = "missao", restauracoes = "restauracao", habilidades = "habilidade", livros = "livro",
	segredos = "segredo", dimensoes = "dimensao",
}

local R = {}

function R.avaliar(req: any, progresso: any): (boolean, { Falta })
	local faltando: { Falta } = {}
	for cat, tipo in CATEGORIAS do
		local lista = req[cat]
		if lista then
			local tem = progresso[cat] or {}
			for _, id in lista do
				if not tem[id] then
					table.insert(faltando, { tipo = tipo, id = id })
				end
			end
		end
	end
	if req.enigma and not (progresso.enigmas or {})[req.enigma] then
		table.insert(faltando, { tipo = "enigma", id = req.enigma })
	end
	table.sort(faltando, function(a, b)
		return a.tipo .. a.id < b.tipo .. b.id
	end)
	return #faltando == 0, faltando
end

-- junta vários conjuntos de progresso (perfil salvo + memória de teste) sem alterar os originais
function R.unir(...: any): any
	local u = {}
	for _, fonte in { ... } do
		for cat, conj in fonte do
			if type(conj) == "table" then
				u[cat] = u[cat] or {}
				for k, v in conj do
					if type(k) == "number" then
						u[cat][v] = true -- lista { "id", … }
					elseif v then
						u[cat][k] = true -- conjunto { id = true }
					end
				end
			end
		end
	end
	return u
end

return R
