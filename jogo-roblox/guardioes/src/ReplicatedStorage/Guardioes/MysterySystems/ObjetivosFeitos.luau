--!strict
-- Objetivos de investigação já cumpridos, num texto curto ("a,b,c") para um atributo do jogador. O servidor
-- escreve (MysterySystem) e o cliente lê (EstantesDaBiblioteca) para mudar o mapa só para quem cumpriu.

local O = {}

-- investigacoes: perfil.misterios.investigacoes ({ [invId] = { objetivos = { [id] = true } } })
function O.codificar(investigacoes: any): string
	local ids = {}
	local vistos = {}
	for _, prog in investigacoes or {} do
		for id, feito in (type(prog) == "table" and prog.objetivos) or {} do
			if feito == true and type(id) == "string" and not vistos[id] and not string.find(id, ",", 1, true) then
				vistos[id] = true
				table.insert(ids, id)
			end
		end
	end
	table.sort(ids)
	return table.concat(ids, ",")
end

function O.ler(texto: any): { [string]: boolean }
	local l = {}
	if type(texto) == "string" then
		for id in string.gmatch(texto, "[^,]+") do
			l[id] = true
		end
	end
	return l
end

return O
