-- NÃO EXECUTADO. IA do companheiro: escolta por espécie, seguir/alcançar, teleporte, combate pela coragem,
-- curiosidade, permanecer, retornar e montada.
-- Dono na origem olhando para −Z (direita = +X, atrás = +Z).

return function(T, M)
	local IA = M.IADoCompanheiro
	local cao = M.Especies.CaoTrovao.comportamento -- Trota, 7, Direita, coragem 0,9
	local axo = M.Especies.AxoloteNebular.comportamento -- Flutua, 5, Esquerda, coragem 0,2
	local raia = M.Especies.RaiaDasNuvens.comportamento -- Plana, 9, Acima
	local lebre = M.Especies.LebreDeFaisca.comportamento -- Saltita, curiosidade 0,9, coragem 0,4
	local ORIGEM = { x = 0, y = 0, z = 0 }
	local OLHA = { x = 0, z = -1 }

	local function entrada(comp: any, criatura: any, extra: { [string]: any }?)
		local e: { [string]: any } = { comando = "Acompanhar", dono = ORIGEM, donoOlha = OLHA, criatura = criatura, comportamento = comp, aleatorio = 0.99 }
		for k, v in extra or {} do
			e[k] = v
		end
		return e
	end

	T.caso("escolta: cada espécie tem seu lado, distância e altura", function()
		local c = IA.posicaoDeEscolta(ORIGEM, OLHA, cao)
		T.perto(c.x, 5.6)
		T.perto(c.z, 3.5)
		T.perto(c.y, 0)
		local a = IA.posicaoDeEscolta(ORIGEM, OLHA, axo)
		T.perto(a.x, -4)
		T.perto(a.y, 1.5)
		local r = IA.posicaoDeEscolta(ORIGEM, OLHA, raia)
		T.perto(r.x, 0)
		T.perto(r.y, 10)
		T.perto(r.z, 8.1)
	end)

	T.caso("segue no ritmo normal; longe, acelera; perto, para", function()
		local d1 = IA.decidir(entrada(cao, { x = 20, y = 0, z = 0 }))
		T.igual(d1.acao, "Seguir")
		T.igual(d1.velocidade, 1)
		local d2 = IA.decidir(entrada(cao, { x = 40, y = 0, z = 0 }))
		T.igual(d2.velocidade, 1.6)
		local d3 = IA.decidir(entrada(cao, { x = 5.6, y = 0, z = 3.5 }))
		T.igual(d3.acao, "Parado")
	end)

	T.caso("muito longe do dono: teleporta para a escolta", function()
		local d = IA.decidir(entrada(cao, { x = 100, y = 0, z = 0 }))
		T.igual(d.acao, "Teleportar")
	end)

	T.caso("combate pela coragem: o Cão ataca, o Axolote se esconde, a Lebre fica", function()
		local ini = { x = 10, y = 0, z = 0, id = "f1" }
		local dc = IA.decidir(entrada(cao, { x = 20, y = 0, z = 0 }, { inimigo = ini }))
		T.igual(dc.acao, "Atacar")
		T.igual(dc.alvoId, "f1")
		local da = IA.decidir(entrada(axo, { x = 20, y = 0, z = 0 }, { inimigo = ini }))
		T.igual(da.acao, "Fugir")
		T.perto(da.alvo and da.alvo.x or 0, -4, 1e-6, "do lado oposto ao inimigo")
		local dl = IA.decidir(entrada(lebre, { x = 20, y = 0, z = 0 }, { inimigo = ini }))
		T.igual(dl.acao, "Seguir")
	end)

	T.caso("inimigo longe do dono não puxa a criatura", function()
		local d = IA.decidir(entrada(cao, { x = 20, y = 0, z = 0 }, { inimigo = { x = 30, y = 0, z = 0, id = "f" } }))
		T.igual(d.acao, "Seguir")
	end)

	T.caso("curiosidade: investiga às vezes, conforme a espécie", function()
		local interesse = { x = 6, y = 0, z = 6 }
		local sim = IA.decidir(entrada(lebre, { x = 20, y = 0, z = 0 }, { interesse = interesse, aleatorio = 0.1 }))
		T.igual(sim.acao, "Investigar")
		local nao = IA.decidir(entrada(lebre, { x = 20, y = 0, z = 0 }, { interesse = interesse, aleatorio = 0.5 }))
		T.igual(nao.acao, "Seguir")
	end)

	T.caso("permanecer: fica na âncora; só o corajoso defende", function()
		local ancora = { x = 5, y = 0, z = 5 }
		T.igual(IA.decidir(entrada(cao, ancora, { comando = "Permanecer", ancora = ancora })).acao, "Parado")
		T.igual(IA.decidir(entrada(cao, { x = 9, y = 0, z = 5 }, { comando = "Permanecer", ancora = ancora })).acao, "Seguir")
		local ini = { x = 8, y = 0, z = 5, id = "f2" }
		T.igual(IA.decidir(entrada(cao, ancora, { comando = "Permanecer", ancora = ancora, inimigo = ini })).acao, "Atacar")
		T.igual(IA.decidir(entrada(axo, ancora, { comando = "Permanecer", ancora = ancora, inimigo = ini })).acao, "Parado")
	end)

	T.caso("retornar corre até o dono; montada não decide nada", function()
		local r = IA.decidir(entrada(cao, { x = 20, y = 0, z = 0 }, { comando = "Retornar" }))
		T.igual(r.acao, "Seguir")
		T.igual(r.velocidade, 1.8)
		T.igual(IA.decidir(entrada(cao, ORIGEM, { comando = "Montada" })).acao, "Montada")
	end)
end
