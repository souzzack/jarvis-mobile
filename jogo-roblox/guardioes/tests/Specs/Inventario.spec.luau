-- NÃO EXECUTADO. Bolsas: consumo atômico entre a bolsa de teste e a salva, pilhas, nível, saque e missões.

return function(T, M)
	local B = M.Bolsa
	local S = M.Saque
	local Mi = M.Missao
	local N = M.Nivel

	local function sequencia(valores: { number })
		local i = 0
		return function()
			i += 1
			return valores[math.min(i, #valores)]
		end
	end

	T.caso("consumo usa primeiro a bolsa de teste e completa com a salva", function()
		local teste = { materiais = { A = 2 }, artefatos = {} }
		local salva = { materiais = { A = 3, B = 1 }, artefatos = {} }
		local ok, plano = B.planejarConsumo({ teste, salva }, { A = 4, B = 1 })
		T.verdade(ok)
		T.igual(plano[1].A, 2)
		T.igual(plano[2].A, 2)
		T.igual(plano[2].B, 1)
		B.aplicarConsumo(teste, plano[1])
		B.aplicarConsumo(salva, plano[2])
		T.igual(teste.materiais.A, nil)
		T.igual(salva.materiais.A, 1)
		T.igual(salva.materiais.B, nil)
	end)

	T.caso("faltando: nada é planejado e o que falta é informado", function()
		local ok, _, falta = B.planejarConsumo({ { materiais = { A = 2 }, artefatos = {} }, { materiais = { A = 3 }, artefatos = {} } }, { A = 6 })
		T.falso(ok)
		T.igual(falta[1].tem, 5)
		T.igual(falta[1].precisa, 6)
	end)

	T.caso("pilha máxima: o excedente é devolvido", function()
		local b = { materiais = { A = 8 }, artefatos = {} }
		local entrou, sobra = B.adicionarMaterial(b, "A", 5, 10)
		T.igual(entrou, 2)
		T.igual(sobra, 3)
		T.igual(b.materiais.A, 10)
		T.igual((B.adicionarMaterial(b, "C", 0, 10)), 0)
	end)

	T.caso("consumir mais do que há é erro (nunca fica negativo)", function()
		local ok = pcall(B.aplicarConsumo, { materiais = { A = 1 }, artefatos = {} }, { A = 2 })
		T.falso(ok)
	end)

	local tabela = {
		entradas = {
			{ id = "C", chance = 0.75, min = 1, max = 2 },
			{ id = "R", chance = 0.08, min = 1, max = 1, garantiaEm = 3 },
		},
	}

	T.caso("proteção contra azar: o raro cai garantido na 3ª tentativa e o contador zera", function()
		local azar = {}
		local azarado = sequencia({ 0.9 })
		T.igual(next(S.rolar(tabela, azar, azarado)), nil)
		T.igual(next(S.rolar(tabela, azar, azarado)), nil)
		local terceira = S.rolar(tabela, azar, azarado)
		T.igual(terceira.R, 1)
		T.igual(terceira.C, nil)
		T.igual(azar.R, 0)
		T.igual(azar.C, 3)
	end)

	T.caso("quantidade dentro da faixa", function()
		local s = S.rolar(tabela, {}, sequencia({ 0.1, 0.99, 0.5 }))
		T.igual(s.C, 2)
		T.igual(s.R, nil)
	end)

	T.caso("saque pessoal: só quem fez ao menos 10% do dano", function()
		local l = S.elegiveis({ a = 90, b = 10, c = 5 }, 0.10)
		T.igual(#l, 1)
		T.igual(l[1], "a")
	end)

	T.caso("missão: conta só eventos certos, não passa da meta, conclui no último", function()
		local m = { objetivos = { { id = "f", tipo = "derrotar", alvo = "FaiscaErrante", qtd = 2 }, { id = "l", tipo = "ler", alvo = "*", qtd = 1 } } }
		local prog = {}
		local mudou, fim = Mi.registrar(prog, m, { tipo = "derrotar", alvo = "FaiscaErrante" })
		T.verdade(mudou)
		T.falso(fim)
		T.falso((Mi.registrar(prog, m, { tipo = "derrotar", alvo = "BonecoDeTreino" })))
		Mi.registrar(prog, m, { tipo = "derrotar", alvo = "FaiscaErrante" })
		T.falso((Mi.registrar(prog, m, { tipo = "derrotar", alvo = "FaiscaErrante" })), "meta já cheia")
		T.igual(prog.f, 2)
		local _, concluiu = Mi.registrar(prog, m, { tipo = "ler", alvo = "QualquerLivro" })
		T.verdade(concluiu)
		T.igual(Mi.resumo(prog, m)[1], "f 2/2")
	end)

	T.caso("missões reais: O Horizonte Partido pede 5 Faíscas", function()
		local m = M.Missoes.porId.OHorizontePartido
		local prog = {}
		for _ = 1, 4 do
			Mi.registrar(prog, m, { tipo = "derrotar", alvo = "FaiscaErrante" })
		end
		T.falso(Mi.concluida(prog, m))
		local _, fim = Mi.registrar(prog, m, { tipo = "derrotar", alvo = "FaiscaErrante" })
		T.verdade(fim)
	end)

	T.caso("nível: curva, vários níveis de uma vez e teto 60", function()
		T.igual(N.xpParaProximo(1), 100)
		T.igual(N.xpParaProximo(4), 800)
		local n, xp, g = N.ganhar(1, 0, 250)
		T.igual(n, 2)
		T.igual(xp, 150)
		T.igual(g, 1)
		local n2, xp2 = N.ganhar(59, 0, 10000000)
		T.igual(n2, 60)
		T.igual(xp2, 0)
		local n3, _, g3 = N.ganhar(60, 5, 100)
		T.igual(n3, 60)
		T.igual(g3, 0)
	end)

	T.caso("vida máxima por nível e raça", function()
		T.igual(N.vidaMaxima(1), 100)
		T.igual(N.vidaMaxima(10), 136)
		T.igual(N.vidaMaxima(10, 0.92), 125)
	end)
end
