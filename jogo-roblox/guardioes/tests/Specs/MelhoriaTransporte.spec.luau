-- NÃO EXECUTADO. Melhorias +1 a +10 (teto pela raridade, onde fazer, custo crescente) e a prancha de viagem.

return function(T, M)
	local Me = M.Melhoria
	local R = M.Raridades
	local Eq = M.Equipamento

	T.caso("multiplicador vai em linha até o teto do +10 (metade do salto)", function()
		local teto = R.tetoMelhoria("Druida")
		T.perto(teto, 1.46, 1e-9)
		T.perto(Me.multiplicador(1.42, teto, 0), 1.42, 1e-9)
		T.perto(Me.multiplicador(1.42, teto, 5), 1.44, 1e-9)
		T.perto(Me.multiplicador(1.42, teto, 10), 1.46, 1e-9)
		T.perto(Me.multiplicador(1.42, teto, 99), 1.46, 1e-9, "nunca passa do +10")
		T.verdade(teto < R.porId.Arcano.multiplicador, "+10 Druida não alcança o Arcano")
	end)

	T.caso("onde melhorar: até +5 na Oficina restaurada; +6 a +10 na Forja 4", function()
		local a = Me.onde(5)
		T.igual(a.estacao, "OficinaDosInventores")
		T.igual(a.restauracao, "OficinaDosInventores")
		local b = Me.onde(6)
		T.igual(b.estacao, "Forja")
		T.igual(b.nivelEstacao, 4)
	end)

	T.caso("custo crescente (e o material de origem nos itens Druida)", function()
		local c3 = Me.custo(3, "JubaEstatica")
		T.igual(c3.FragmentoDeFaisca, 6)
		T.igual(c3.JubaEstatica, 1)
		T.igual(c3.NucleoDeTempestade, nil)
		T.igual(Me.custo(4, nil).NucleoDeTempestade, 1)
		local c8 = Me.custo(8, "X")
		T.igual(c8.NucleoDeTempestade, 2)
		T.igual(c8.X, 3)
		T.igual(Me.custo(10, "X").X, 4)
	end)

	T.caso("totais usam a melhoria do item", function()
		local itens = { g = { id = "ElmoDaMatilha", melhoria = 10 } }
		local sem = Eq.totais({ Cabeca = "g" }, itens, M.Equipamentos.porId, R.porId)
		local com = Eq.totais({ Cabeca = "g" }, itens, M.Equipamentos.porId, R.porId, R.tetoMelhoria)
		T.igual(sem.defesa, 14, "10 × 1,42 = 14,2 (sem contar melhoria)")
		T.igual(com.defesa, 15, "10 × 1,46 = 14,6")
	end)

	T.caso("perfil recusa melhoria fora de 0 a 10", function()
		local p = M.Perfil.novo(1)
		p.equipamentos.g = { id = "ElmoDaMatilha", melhoria = 11 }
		T.igual(select(2, M.Perfil.validar(p)), "melhoria")
	end)

	T.caso("prancha de viagem: baixa, lenta, barata e sem impulso (não anula os outros transportes)", function()
		local pc = M.Perfis.porId.PranchaComum
		T.igual(pc.tipo, "Plataforma")
		T.igual(pc.velImpulso, 0)
		T.verdade(pc.velMax < M.Perfis.porId.VooMagico.velMax)
		T.verdade(pc.custoPorSeg < M.Perfis.porId.VooMagico.custoPorSeg)
		T.igual(pc.alturaMaxSobreSolo, 6)
	end)
end
