-- NÃO EXECUTADO. Avaliador de requisitos e os requisitos REAIS dos livros (ConfigSecreta/Livros).

return function(T, M)
	local R = M.Requisitos
	local L = M.LivrosSecretos

	T.caso("tudo cumprido passa", function()
		T.verdade((R.avaliar({ missoes = { "A" }, enigma = "E" }, { missoes = { A = true }, enigmas = { E = true } })))
	end)

	T.caso("lista o que falta, em ordem estável", function()
		local ok, falta = R.avaliar({ missoes = { "A", "B" }, habilidades = { "VooMagico" }, enigma = "E" }, { missoes = { A = true } })
		T.falso(ok)
		T.igual(#falta, 3)
		T.igual(falta[1].tipo, "enigma")
		T.igual(falta[2].id, "VooMagico")
		T.igual(falta[3].id, "B")
	end)

	T.caso("unir aceita listas e conjuntos sem mexer nos originais", function()
		local a = { missoes = { X = true } }
		local u = R.unir(a, { missoes = { "Y" }, enigmas = { "E" } })
		T.verdade(u.missoes.X and u.missoes.Y)
		T.verdade(u.enigmas.E)
		T.igual(a.missoes.Y, nil, "original intacto")
	end)

	T.caso("livros: com o progresso de teste, Grimório e Tomo abrem; o Códice não (Campo das Bolhas)", function()
		local teste = { missoes = { "AsAnotacoesDoAstronomo", "OsVentosDaTorre" }, restauracoes = { "Observatorio", "TorreMeteorologica" }, enigmas = { "LentesNaOrdem" } }
		local prog = R.unir({ habilidades = { VooMagico = true } }, teste)
		T.verdade((R.avaliar(L.GrimorioDosCeus.requisitos, prog)))
		T.verdade((R.avaliar(L.TomoDasCorrentesAstrais.requisitos, prog)))
		local ok, falta = R.avaliar(L.CodiceDaLeveza.requisitos, prog)
		T.falso(ok)
		T.igual(falta[1].tipo, "dimensao")
	end)

	T.caso("Tomo exige saber voar antes", function()
		local ok, falta = R.avaliar(L.TomoDasCorrentesAstrais.requisitos, R.unir({ restauracoes = { "TorreMeteorologica" }, missoes = { "OsVentosDaTorre" } }))
		T.falso(ok)
		T.igual(falta[1].id, "VooMagico")
	end)

	T.caso("Manuscrito Sem Nome exige os três livros e os segredos", function()
		local ok, falta = R.avaliar(L.ManuscritoSemNome.requisitos, R.unir({ livros = { GrimorioDosCeus = true } }))
		T.falso(ok)
		T.igual(#falta, 4)
	end)
end
