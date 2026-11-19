-- NÃO EXECUTADO. Base pessoal (melhorias e jardim com teto), viagem rápida e a mecânica do Cão-Trovão Alfa.

return function(T, M)
	local B = M.Base
	local cfg = M.CfgBase.espacos
	local V = M.Viagem
	local A = M.MatilhaDoAlfa

	T.caso("Forja: nível inicial 1; subir exige nível do jogador e materiais", function()
		local base = { espacos = {}, jardimColhidoEm = 0, trofeus = {} }
		T.igual(B.nivel(base, "Forja", cfg.Forja), 1)
		local ok, falta = B.avaliarMelhoria(cfg.Forja, 1, 2, { FragmentoDeFaisca = 10 })
		T.falso(ok)
		T.igual(#falta, 1)
		T.igual(falta[1].tipo, "nivelJogador")
		local ok2, _, consumir = B.avaliarMelhoria(cfg.Forja, 1, 3, { FragmentoDeFaisca = 10 })
		T.verdade(ok2)
		T.igual(consumir.FragmentoDeFaisca, 10)
	end)

	T.caso("Forja 3 pede a Juba do Alfa; nível máximo não sobe", function()
		local ok, falta = B.avaliarMelhoria(cfg.Forja, 2, 6, { JubaEstatica = 1, NucleoDeTempestade = 2 })
		T.falso(ok)
		T.igual(#falta, 1)
		T.igual(falta[1].id, "JubaEstatica")
		T.igual(falta[1].tem, 1)
		local _, fMax = B.avaliarMelhoria(cfg.Forja, 5, 60, {})
		T.igual(fMax[1].tipo, "maximo")
		local _, fExp = B.avaliarMelhoria(cfg.Expositor, 1, 60, {})
		T.igual(fExp[1].tipo, "maximo")
	end)

	T.caso("jardim: produz com o tempo, guarda a sobra e para no teto", function()
		local q, rel = B.colheita(1, 0, 3600, 3, 12)
		T.igual(q, 3)
		T.igual(rel, 3600)
		local q2, rel2 = B.colheita(1, 0, 3000, 3, 12)
		T.igual(q2, 2)
		T.igual(rel2, 2400, "a sobra de 600 s continua contando")
		local q3, rel3 = B.colheita(2, 0, 36000, 3, 12)
		T.igual(q3, 12)
		T.igual(rel3, 36000)
		T.igual((B.colheita(1, 100, 50, 3, 12)), 0)
	end)

	T.caso("colheita repartida entre os materiais do jardim", function()
		local r = B.repartir(5, { "S", "C" })
		T.igual(r.S, 3)
		T.igual(r.C, 2)
		T.igual(next(B.repartir(0, { "S" })), nil)
	end)

	T.caso("viagem: descoberto, a pé, fora de combate e sem recarga", function()
		local function ctx(extra: { [string]: any }?)
			local c: { [string]: any } = { descoberto = true, estado = "Solo", montado = false, agora = 100, ultimoDano = 0, ultimaViagem = 0, semCombateSeg = 8, recargaSeg = 30 }
			for k, v in extra or {} do
				c[k] = v
			end
			return c
		end
		T.verdade((V.pode(ctx())))
		T.igual(select(2, V.pode(ctx({ descoberto = false }))), "naoDescoberto")
		T.igual(select(2, V.pode(ctx({ estado = "Voo" }))), "locomocao")
		T.igual(select(2, V.pode(ctx({ montado = true }))), "locomocao")
		T.igual(select(2, V.pode(ctx({ ultimoDano = 95 }))), "emCombate")
		T.igual(select(2, V.pode(ctx({ ultimaViagem = 80 }))), "recarga")
		T.verdade(V.descobre(10, 15))
		T.falso(V.descobre(16, 15))
	end)

	T.caso("Alfa: chama a matilha em 70% e 40%, só uma vez cada", function()
		local e = A.novo(0, 14)
		T.falso(A.deveChamar(e, 0.8))
		T.verdade(A.deveChamar(e, 0.7))
		A.registrarChamada(e)
		T.falso(A.deveChamar(e, 0.5))
		T.verdade(A.deveChamar(e, 0.4))
		A.registrarChamada(e)
		T.falso(A.deveChamar(e, 0.1))
	end)

	T.caso("Alfa: corrida carregada; aparar quebra, sem aparo ela acaba sozinha", function()
		local e = A.novo(0, 14)
		T.igual(A.atualizar(e, 10, 14, 4), nil)
		T.igual(A.atualizar(e, 14, 14, 4), "IniciaCorrida")
		T.verdade(A.aparado(e, 15, 14))
		T.falso(e.emCorrida)
		T.falso(A.aparado(e, 16, 14), "fora da corrida aparar não derruba")
		T.igual(A.atualizar(e, 28, 14, 4), nil)
		T.igual(A.atualizar(e, 29, 14, 4), "IniciaCorrida")
		T.igual(A.atualizar(e, 33, 14, 4), "FimCorrida")
		T.igual(e.proximaCorrida, 47)
	end)
end
