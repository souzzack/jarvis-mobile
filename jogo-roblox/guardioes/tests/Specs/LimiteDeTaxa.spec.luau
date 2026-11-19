-- NÃO EXECUTADO. Balde de fichas da rede.

return function(T, M)
	local L = M.LimiteDeTaxa

	T.caso("esvazia, recusa e conta o excesso; recarrega com o tempo", function()
		local b = L.novo(3, 1, 0)
		T.verdade(L.consumir(b, 0))
		T.verdade(L.consumir(b, 0))
		T.verdade(L.consumir(b, 0))
		T.falso(L.consumir(b, 0))
		T.igual(b.excedidos, 1)
		T.verdade(L.consumir(b, 1.0))
	end)

	T.caso("nunca passa da capacidade", function()
		local b = L.novo(3, 1, 0)
		L.consumir(b, 100)
		T.perto(b.fichas, 2)
	end)
end
