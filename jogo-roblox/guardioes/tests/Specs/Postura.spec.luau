-- NÃO EXECUTADO. Postura do inimigo: enche com golpes, quebra ao encher, baixa 15/s depois de 2 s sem golpe.

return function(T, M)
	local P = M.Postura
	local cfg = { recuperacaoPorSeg = 15, atrasoRecuperacao = 2.0 }

	T.caso("acumula e só recupera depois do atraso", function()
		local p = P.nova(60, 0)
		T.falso(P.receber(p, cfg, 20, 0))
		P.atualizar(p, cfg, 1.0)
		T.perto(p.acumulada, 20)
		P.atualizar(p, cfg, 3.0)
		T.perto(p.acumulada, 5)
	end)

	T.caso("encher quebra e zera a barra", function()
		local p = P.nova(60, 0)
		P.receber(p, cfg, 40, 0)
		T.verdade(P.receber(p, cfg, 25, 0.5))
		T.perto(p.acumulada, 0)
	end)

	T.caso("valor negativo não reduz a postura", function()
		local p = P.nova(60, 0)
		P.receber(p, cfg, 20, 0)
		P.receber(p, cfg, -50, 0.1)
		T.perto(p.acumulada, 20)
	end)
end
