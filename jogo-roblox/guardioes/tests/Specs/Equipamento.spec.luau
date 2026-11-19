-- NÃO EXECUTADO. Equipamentos: encaixes, soma com orçamento de raridade, tetos e validação do perfil.

return function(T, M)
	local Eq = M.Equipamento
	local Cat = M.Equipamentos.porId
	local Rar = M.Raridades.porId

	T.caso("tipo × encaixe", function()
		T.verdade((Eq.podeEquipar(Cat.ElmoDaMatilha, "Cabeca")))
		T.igual(select(2, Eq.podeEquipar(Cat.ElmoDaMatilha, "Corpo")), "encaixeErrado")
		T.verdade((Eq.podeEquipar(Cat.AmuletoEspectral, "Acessorio2")))
		T.igual(select(2, Eq.podeEquipar(Cat.AmuletoEspectral, "Bolso")), "encaixeInvalido")
	end)

	T.caso("conjunto Druida + botas comuns: atributos × multiplicador da raridade", function()
		local itens = { g1 = { id = "ElmoDaMatilha" }, g2 = { id = "CouracaDasRuinas" }, g3 = { id = "BotasDeViajante" }, g4 = { id = "AmuletoEspectral" } }
		local t = Eq.totais({ Cabeca = "g1", Corpo = "g2", Pernas = "g3", Acessorio1 = "g4" }, itens, Cat, Rar)
		T.igual(t.defesa, 48, "10×1,42 + 18×1,42 + 4 + 3×1,42 = 48,02")
		T.igual(t.vidaBonus, 43, "30 × 1,42 = 42,6")
		T.igual(t.energiaVoo, 21, "15 × 1,42 = 21,3")
		T.perto(t.janelaAparar, 0.03, 1e-9)
	end)

	T.caso("tetos globais seguram combinações exageradas", function()
		local cat = { X = { tipo = "Corpo", raridade = "Comum", atributos = { defesa = 100, janelaAparar = 0.05 } } }
		local t = Eq.totais({ Corpo = "a", Cabeca = "b" }, { a = { id = "X" }, b = { id = "X" } }, cat, Rar)
		T.igual(t.defesa, 120)
		T.perto(t.janelaAparar, 0.08, 1e-9)
	end)

	T.caso("onde está o item e item inexistente ignorado", function()
		T.igual(Eq.ondeEsta({ Cabeca = "g1" }, "g1"), "Cabeca")
		T.igual(Eq.ondeEsta({ Cabeca = "g1" }, "g2"), nil)
		T.igual(Eq.totais({ Cabeca = "sumiu" }, {}, Cat, Rar).defesa, 0)
	end)

	T.caso("perfil recusa item inexistente equipado e o mesmo item em dois encaixes", function()
		local P = M.Perfil
		local p = P.novo(1)
		p.equipado.Cabeca = "nada"
		T.igual(select(2, P.validar(p)), "equipado")
		local q = P.novo(1)
		q.equipamentos.g = { id = "AmuletoEspectral" }
		q.equipado.Acessorio1, q.equipado.Acessorio2 = "g", "g"
		T.igual(select(2, P.validar(q)), "equipado")
		local ok = P.novo(1)
		ok.equipamentos.g = { id = "AmuletoEspectral" }
		ok.equipado.Acessorio1 = "g"
		T.verdade((P.validar(ok)))
	end)
end
