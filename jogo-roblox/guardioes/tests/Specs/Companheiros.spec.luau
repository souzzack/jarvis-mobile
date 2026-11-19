-- NÃO EXECUTADO. Criaturas companheiras: dados, vínculo com teto diário, crescimento, montaria e Vínculo Dimensional.

return function(T, M)
	local D = M.DadosDaCriatura
	local C = M.Crescimento
	local V = M.VinculoDimensional
	local Af = M.Afinidades
	local cao = M.Especies.CaoTrovao
	local axo = M.Especies.AxoloteNebular

	T.caso("nova criatura começa filhote, com GUID e nome", function()
		local c = D.nova("guid-1", "CaoTrovao", "Trovisco")
		T.igual(c.estagio, "Filhote")
		T.igual(c.guid, "guid-1")
		T.igual(D.nivelVinculo(c), 0)
	end)

	T.caso("formato do nome", function()
		T.verdade(D.nomeValido("Faísca"))
		T.verdade(D.nomeValido("Bolinha de Cobre"))
		T.falso(D.nomeValido(""))
		T.falso(D.nomeValido(" Espaço"))
		T.falso(D.nomeValido("<b>x</b>"))
		T.falso(D.nomeValido(string.rep("a", 21)))
		T.falso(D.nomeValido(42))
	end)

	T.caso("vínculo: teto diário por atividade; novo dia libera de novo", function()
		local c = D.nova("g", "CaoTrovao", "T")
		T.igual(D.ganharVinculo(c, "Carinho", 100, 1), 100)
		T.igual(D.ganharVinculo(c, "Carinho", 100, 1), 20, "teto de 120 no dia")
		T.igual(D.ganharVinculo(c, "Exploracao", 50, 1), 50, "outra atividade tem teto próprio")
		T.igual(D.ganharVinculo(c, "Carinho", 100, 2), 100, "dia seguinte")
		T.igual(D.nivelVinculo(c), 2)
	end)

	T.caso("crescimento exige XP, vínculo e marcos (não só tempo)", function()
		local c = D.nova("g", "CaoTrovao", "T")
		local ok, falta = C.avaliar(c, cao)
		T.falso(ok)
		T.igual(#falta, 4, "xp, vínculo e 2 marcos")
		c.xp = 800
		c.vinculo = 300
		D.registrarMarco(c, "CaoPrimeiraCaca")
		D.registrarMarco(c, "CaoDefenderDono")
		T.verdade((C.evoluir(c, cao)))
		T.igual(c.estagio, "Juvenil")
		T.igual(c.habilidades[2], "Latido")
	end)

	T.caso("adulto exige o desafio da espécie; adulto é o máximo", function()
		local c = D.nova("g", "CaoTrovao", "T")
		c.estagio, c.xp, c.vinculo = "Juvenil", 3000, 700
		D.registrarMarco(c, "CaoEncontrarAlfa")
		local ok, falta = C.avaliar(c, cao)
		T.falso(ok)
		T.igual(falta[1].tipo, "desafio")
		D.registrarDesafio(c, "CaoProvaDaMatilha")
		T.verdade((C.evoluir(c, cao)))
		T.igual(c.estagio, "Adulto")
		local okMax, faltaMax = C.avaliar(c, cao)
		T.falso(okMax)
		T.igual(faltaMax[1].tipo, "maximo")
	end)

	T.caso("montaria: só adulto de espécie que carrega alguém", function()
		local c = D.nova("g", "CaoTrovao", "T")
		c.estagio = "Juvenil"
		local _, m1 = C.podeMontar(c, cao)
		T.igual(m1, "jovemDemais")
		c.estagio = "Adulto"
		T.verdade((C.podeMontar(c, cao)))
		local a = D.nova("g2", "AxoloteNebular", "Nebu")
		a.estagio = "Adulto"
		local _, m2 = C.podeMontar(a, axo)
		T.igual(m2, "especieSemMontaria")
	end)

	T.caso("Vínculo Dimensional: objetivos contam uma vez; especialização exige adulto e limiar", function()
		local c = D.nova("g", "CaoTrovao", "T")
		T.verdade((V.registrarObjetivo(c, Af, "TempSobreviverTormenta")))
		local ok2, m2 = V.registrarObjetivo(c, Af, "TempSobreviverTormenta")
		T.falso(ok2)
		T.igual(m2, "jaConcluido")
		local _, m3 = V.registrarObjetivo(c, Af, "Inexistente")
		T.igual(m3, "objetivoDesconhecido")
		T.igual(c.afinidades.Tempestade, 25)
		local _, m4 = V.especializar(c, cao, Af, "Tempestade", false)
		T.igual(m4, "naoAdulto")
		c.estagio = "Adulto"
		local _, m5 = V.especializar(c, cao, Af, "Tempestade", false)
		T.igual(m5, "pontos")
		for _, id in { "TempCarregarBobinas", "TempDerrotarRainha", "TempRaioNoSantuario" } do
			V.registrarObjetivo(c, Af, id)
		end
		T.verdade((V.especializar(c, cao, Af, "Tempestade", false)))
		local hab = V.habilidadesEfetivas(c, Af)
		T.igual(hab[#hab], "ResistenciaTempestade")
		T.igual(c.especie, "CaoTrovao", "continua a mesma espécie")
	end)

	T.caso("afinidade indisponível ou incompatível; trocar exige ritual", function()
		local c = D.nova("g", "CaoTrovao", "T")
		c.estagio = "Adulto"
		local _, m1 = V.especializar(c, cao, Af, "Bolhas", false)
		T.igual(m1, "indisponivel")
		-- tabela de teste com duas afinidades disponíveis (o código não muda para novas afinidades)
		local teste = {
			porId = {
				X = { id = "X", limiar = 10, disponivel = true, objetivos = { { id = "x1", pontos = 10 } }, habilidades = { "hx" } },
				Y = { id = "Y", limiar = 10, disponivel = true, objetivos = { { id = "y1", pontos = 10 } }, habilidades = { "hy" } },
			},
			objetivoParaAfinidade = { x1 = "X", y1 = "Y" },
		}
		local esp = { afinidadesPossiveis = { "X", "Y" } }
		local _, m2 = V.especializar(c, { afinidadesPossiveis = {} }, teste, "X", false)
		T.igual(m2, "especieIncompativel")
		V.registrarObjetivo(c, teste, "x1")
		V.registrarObjetivo(c, teste, "y1")
		T.verdade((V.especializar(c, esp, teste, "X", false)))
		local _, m3 = V.especializar(c, esp, teste, "Y", false)
		T.igual(m3, "precisaRitual")
		T.verdade((V.especializar(c, esp, teste, "Y", true)))
		T.igual(c.especializacao, "Y")
	end)
end
