-- NÃO EXECUTADO. Hierarquia de raridades e teto de melhoria.

return function(T, M)
	local R = M.Raridades

	T.caso("8 raridades em ordem, com poder crescente", function()
		T.igual(#R.lista, 8)
		for i, r in R.lista do
			T.igual(r.ordem, i, "ordem de " .. r.id)
			if i > 1 then
				T.verdade(r.multiplicador > R.lista[i - 1].multiplicador, "poder cresce em " .. r.id)
			end
		end
	end)

	T.caso("??? é oculta e é a mais alta", function()
		local o = R.porId.Oculta
		T.verdade(o.oculta)
		T.igual(o.nome, "???")
		T.igual(o.ordem, 8)
	end)

	T.caso("teto do +10 fica entre a própria raridade e a seguinte", function()
		for i, r in R.lista do
			local teto = R.tetoMelhoria(r.id)
			T.verdade(teto >= r.multiplicador, "teto não fica abaixo de " .. r.id)
			local seg = R.lista[i + 1]
			if seg then
				T.verdade(teto < seg.multiplicador, "teto de " .. r.id .. " abaixo da seguinte")
			end
		end
		T.perto(R.tetoMelhoria("Raro"), 1.205)
		T.perto(R.tetoMelhoria("Oculta"), 1.56)
	end)
end
