-- NÃO EXECUTADO. Fabricação (receitas reais), restauração por etapas com ajuda, e a carga da Rainha-Bobina.

return function(T, M)
	local R = M.Receita
	local Rc = M.Receitas.porId
	local Re = M.Restauracao
	local oficina = M.Restauracoes.porId.OficinaDosInventores -- etapa 1: Fragmento 4 · etapa 2: Fragmento 6 + Núcleo 1
	local Q = M.CargaDaRainha

	local function ctx(extra: { [string]: any }?)
		local c: { [string]: any } = {
			conhecidas = {}, estacoesPerto = { OficinaDosInventores = true }, requisitosOk = true, faltasDeRequisito = {},
			materiais = { FragmentoDeFaisca = 6, NucleoDeTempestade = 1 },
		}
		for k, v in extra or {} do
			c[k] = v
		end
		return c
	end

	T.caso("Liga Arcana: tudo certo → consome 6 fragmentos e 1 núcleo", function()
		local ok, _, consumir = R.avaliar(Rc.LigaArcana, ctx())
		T.verdade(ok)
		T.igual(consumir.FragmentoDeFaisca, 6)
		T.igual(consumir.NucleoDeTempestade, 1)
	end)

	T.caso("longe da estação e com pouco material: lista as duas faltas", function()
		local ok, falta = R.avaliar(Rc.LigaArcana, ctx({ estacoesPerto = {}, materiais = { FragmentoDeFaisca = 3, NucleoDeTempestade = 1 } }))
		T.falso(ok)
		T.igual(#falta, 2)
		T.igual(falta[1].tipo, "estacao")
		T.igual(falta[2].tem, 3)
	end)

	T.caso("receita Druida: só depois do esboço (primeira vitória contra a Rainha)", function()
		local mats = { GlandulaDeBobinaViva = 4, SementeFlutuante = 3, CascaAntiga = 2 }
		local ok, falta = R.avaliar(Rc.EsbocoDruida_RainhaBobina, ctx({ materiais = mats }))
		T.falso(ok)
		T.igual(#falta, 1)
		T.igual(falta[1].tipo, "receita")
		T.verdade((R.avaliar(Rc.EsbocoDruida_RainhaBobina, ctx({ materiais = mats, conhecidas = { EsbocoDruida_RainhaBobina = true } }))))
	end)

	T.caso("requisito de mundo faltando aparece na lista", function()
		local ok, falta = R.avaliar(Rc.LigaArcana, ctx({ requisitosOk = false, faltasDeRequisito = { { tipo = "restauracao", id = "OficinaDosInventores" } } }))
		T.falso(ok)
		T.igual(falta[1].tipo, "restauracao")
	end)

	T.caso("restauração: entrega parcial, etapa concluída, estrutura restaurada", function()
		local p = Re.novo()
		T.igual(Re.estado(p, oficina), "Abandonada")
		local plano = Re.planejarEntrega(p, oficina, { FragmentoDeFaisca = 3 })
		T.igual(plano.FragmentoDeFaisca, 3)
		T.falso((Re.aplicarEntrega(p, oficina, plano)))
		T.igual(Re.estado(p, oficina), "EmRestauracao")
		T.perto(Re.fracaoEntregue(p, oficina), 0.75)
		local concluiu, restaurada = Re.aplicarEntrega(p, oficina, { FragmentoDeFaisca = 1 })
		T.verdade(concluiu)
		T.falso(restaurada)
		T.igual(p.etapa, 1)
		local plano2 = Re.planejarEntrega(p, oficina, { FragmentoDeFaisca = 10, NucleoDeTempestade = 0 })
		T.igual(plano2.FragmentoDeFaisca, 6)
		T.igual(plano2.NucleoDeTempestade, nil)
		Re.aplicarEntrega(p, oficina, plano2)
		T.perto(Re.fracaoEntregue(p, oficina), 6 / 7)
		local c3, r3 = Re.aplicarEntrega(p, oficina, { NucleoDeTempestade = 1 })
		T.verdade(c3)
		T.verdade(r3)
		T.igual(Re.estado(p, oficina), "Restaurada")
		T.igual(next(Re.planejarEntrega(p, oficina, { FragmentoDeFaisca = 99 })), nil)
	end)

	T.caso("ajuda cooperativa: só quem contribuiu o mínimo e está na mesma etapa", function()
		local ajudante = { etapa = 0, entregue = { FragmentoDeFaisca = 1 } }
		T.verdade(Re.concluirPorAjuda(ajudante, oficina, 1, 0.25))
		T.igual(ajudante.etapa, 1)
		local parado = Re.novo()
		T.falso(Re.concluirPorAjuda(parado, oficina, 1, 0.25))
		T.falso(Re.concluirPorAjuda(ajudante, oficina, 1, 0.25), "já passou dessa etapa")
	end)

	T.caso("Rainha-Bobina: cargas em 75/50/25%, sucesso quebrando os pilares, descarga se o tempo acabar", function()
		local e = Q.novo()
		T.falso(Q.deveCarregar(e, 0.8))
		T.verdade(Q.deveCarregar(e, 0.75))
		Q.iniciar(e, 10, 12, 3)
		T.falso(Q.deveCarregar(e, 0.5), "nunca duas cargas juntas")
		for _ = 1, 3 do
			Q.pilarQuebrado(e)
		end
		T.igual(Q.atualizar(e, 15), "Sucesso")
		T.falso(Q.deveCarregar(e, 0.6))
		T.verdade(Q.deveCarregar(e, 0.5))
		Q.iniciar(e, 20, 12, 3)
		Q.pilarQuebrado(e)
		T.igual(Q.atualizar(e, 31), nil)
		T.igual(Q.atualizar(e, 32), "Descarga")
		Q.iniciar(e, 40, 12, 3)
		Q.atualizar(e, 60)
		T.falso(Q.deveCarregar(e, 0.01), "só três cargas")
	end)
end
