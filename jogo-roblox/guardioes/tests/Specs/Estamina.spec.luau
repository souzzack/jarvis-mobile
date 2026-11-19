-- NÃO EXECUTADO. Estamina: 100, recupera 22/s depois de 0,8 s sem gasto.

return function(T, M)
	local Est = M.Estamina
	local cfg = { max = 100, recuperacaoPorSeg = 22, atrasoRecuperacao = 0.8 }

	T.caso("gasto e espera antes de recuperar", function()
		local r = Est.nova(100, 0)
		T.verdade(Est.gastar(r, cfg, 30, 0))
		T.perto(r.valor, 70)
		Est.atualizar(r, cfg, 0.5)
		T.perto(r.valor, 70, 1e-6, "ainda no atraso")
		Est.atualizar(r, cfg, 1.8)
		T.perto(r.valor, 92, 1e-6, "1 s de recuperação")
		Est.atualizar(r, cfg, 5)
		T.perto(r.valor, 100, 1e-6, "teto")
	end)

	T.caso("gasto maior que o disponível é recusado e não altera nada", function()
		local r = Est.nova(100, 0)
		T.falso(Est.gastar(r, cfg, 200, 0))
		T.perto(r.valor, 100)
	end)

	T.caso("dreno pode zerar e avisa a quebra", function()
		local r = Est.nova(100, 0)
		T.falso(Est.drenar(r, cfg, 40, 0))
		T.verdade(Est.drenar(r, cfg, 150, 0.1))
		T.perto(r.valor, 0)
	end)
end
