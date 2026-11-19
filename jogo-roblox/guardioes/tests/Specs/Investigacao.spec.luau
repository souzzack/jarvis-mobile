-- NÃO EXECUTADO. Investigações: estados, pistas, objetivos, capítulos não lançados, validação e diário.

return function(T, M)
	local I = M.Investigacao
	local CFG = M.InvestigationChapters.OSegredoDoPrimeiroArquivista

	T.caso("começa Undiscovered; só a pista que DESCOBRE abre a investigação", function()
		local p = I.novo(CFG)
		T.igual(p.estado, "Undiscovered")
		T.igual(select(2, I.registrarPista(p, CFG, "DiarioDeCampo")), "naoDescoberta")
		T.verdade(I.registrarPista(p, CFG, "InscricaoDoObservatorio"))
		T.igual(p.estado, "Investigating")
		T.igual(select(2, I.registrarPista(p, CFG, "InscricaoDoObservatorio")), "jaRegistrada")
	end)

	T.caso("três pistas → ReadyToSolve; o objetivo do enigma só aparece depois delas", function()
		local p = I.novo(CFG)
		I.registrarPista(p, CFG, "InscricaoDoObservatorio")
		local antes = I.objetivosVisiveis(p, CFG)
		T.igual(#antes, 1, "só 'reunir pistas' visível")
		T.igual(select(2, I.registrarObjetivo(p, CFG, "OSinal")), "objetivoIndisponivel", "não marca o enigma antes das pistas")
		I.registrarPista(p, CFG, "SimboloOculto")
		I.registrarPista(p, CFG, "DiarioDeCampo")
		T.igual(p.estado, "ReadyToSolve")
		T.igual(#I.objetivosVisiveis(p, CFG), 2)
	end)

	T.caso("enigma resolvido conclui o capítulo 1; o 2 (não lançado) segura o Completed", function()
		local p = I.novo(CFG)
		for _, id in { "InscricaoDoObservatorio", "SimboloOculto", "DiarioDeCampo" } do
			I.registrarPista(p, CFG, id)
		end
		T.verdade(I.registrarObjetivo(p, CFG, "OSinal"))
		local ok, _, rec = I.concluirCapitulo(p, CFG)
		T.verdade(ok)
		T.igual(rec, "RecCap1_OSinal")
		T.igual(p.capitulo, 2)
		T.igual(p.estado, "Investigating", "esperando o capítulo 2")
		T.igual(select(2, I.concluirCapitulo(p, CFG)), "capituloIndisponivel", "capítulo futuro nunca conclui")
		T.verdade(I.validar(p, CFG))
	end)

	T.caso("validar recusa estados impossíveis (cliente ou save adulterado)", function()
		local p = I.novo(CFG)
		p.capitulosConcluidos["5"] = true
		T.igual(select(2, I.validar(p, CFG)), "capituloNaoLancado")
		local q = I.novo(CFG)
		q.estado = "Completed"
		T.igual(select(2, I.validar(q, CFG)), "completedSemCapitulos")
		local r = I.novo(CFG)
		r.pistas.Inventada = true
		T.igual(select(2, I.validar(r, CFG)), "pistaInexistente")
		local s = I.novo(CFG)
		s.capitulo = 99
		T.igual(select(2, I.validar(s, CFG)), "capitulo")
		T.igual(select(2, I.validar({ estado = "Hackeado" }, CFG)), "estado")
	end)

	T.caso("investigação com todos os capítulos lançados chega a Completed", function()
		local cfg = {
			versaoConteudo = 1, descobertaPor = "A",
			capitulos = {
				{ n = 1, lancado = true, pistas = { A = { descobre = true } }, objetivos = { { id = "P", tipo = "pistas", pistas = { "A" } } } },
			},
		}
		local p = I.novo(cfg)
		I.registrarPista(p, cfg, "A")
		T.verdade(I.concluirCapitulo(p, cfg))
		T.igual(p.estado, "Completed")
		T.verdade(I.validar(p, cfg))
	end)

	T.caso("diário mostra SÓ o descoberto e nunca o capítulo futuro pelo nome", function()
		local D = M.DiarioMisterios
		local prog = M.Perfil.misteriosNovo()
		local cfgs = { investigacoes = M.InvestigationChapters, registros = M.Secrets.registros, conhecimentos = M.Secrets.conhecimentos, receitas = M.Secrets.receitas, portais = {} }
		local texto = function(_i, _p, pc)
			return pc.texto
		end
		local v0 = D.montar(prog, cfgs, texto, I)
		T.igual(#v0.investigacoes, 0, "não descoberta = invisível")
		T.igual(#v0.receitas, 0)
		local p = I.novo(CFG)
		for _, id in { "InscricaoDoObservatorio", "SimboloOculto", "DiarioDeCampo" } do
			I.registrarPista(p, CFG, id)
		end
		I.registrarObjetivo(p, CFG, "OSinal")
		I.concluirCapitulo(p, CFG)
		prog.investigacoes.OSegredoDoPrimeiroArquivista = p
		prog.receitas.TintaDoArquivista = true
		local v = D.montar(prog, cfgs, texto, I)
		T.igual(#v.investigacoes, 1)
		local inv = v.investigacoes[1]
		T.igual(#inv.pistas, 3)
		T.igual(inv.pistas[1].nome, CFG.capitulos[1].pistas.InscricaoDoObservatorio.nome, "em ordem")
		T.falso(inv.capitulo.disponivel)
		T.igual(inv.capitulo.nome, nil, "nome do capítulo futuro não vai para o cliente")
		T.igual(inv.capitulosFuturos, 6)
		T.igual(#v.receitas, 1)
	end)
end
