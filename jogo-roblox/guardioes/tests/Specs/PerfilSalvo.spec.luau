-- NÃO EXECUTADO. Perfil v2 (migração sem perder nada, validação) e trava de sessão (anti-duplicação).

return function(T, M)
	local P = M.Perfil
	local Tr = M.TravaDeSessao

	T.caso("sem save: perfil novo v2", function()
		local p, s = P.migrar(nil, 100)
		T.igual(s, "novo")
		T.igual(p.versao, 2)
		T.verdade((P.validar(p)))
	end)

	T.caso("save antigo/desconhecido: guarda INTEIRO como legado e passa as moedas", function()
		local p, s = P.migrar({ moedas = 150, terrenos = { 1, 2 } }, 100)
		T.igual(s, "migradoDoLegado")
		T.igual(p.moedas, 150)
		T.igual(p.legadoMagnata.terrenos[2], 2)
	end)

	T.caso("v2 antigo sem campo novo: completa sem apagar o que existe", function()
		local base = P.novo(1)
		base.moedas = 7
		base.companheiros = nil :: any
		local p, s = P.migrar(base, 100)
		T.igual(s, "completado")
		T.igual(p.moedas, 7)
		T.igual(type(p.companheiros), "table")
	end)

	T.caso("versão futura: somente leitura (não converte)", function()
		local _, s = P.migrar({ versao = 3 }, 100)
		T.igual(s, "versaoFutura")
	end)

	T.caso("validação recusa dados quebrados e concessões de teste", function()
		local p = P.novo(1)
		p.habilidades.VooMagico = "teste"
		local ok, motivo = P.validar(p)
		T.falso(ok)
		T.igual(motivo, "habilidade")
		local q = P.novo(1)
		q.companheiros["g1"] = { guid = "outro", especie = "CaoTrovao", xp = 0 }
		T.igual(select(2, P.validar(q)), "companheiro")
		local r = P.novo(1)
		r.criaturaAtiva = "inexistente"
		T.igual(select(2, P.validar(r)), "criaturaAtiva")
		local s = P.novo(1)
		s.moedas = -1
		T.igual(select(2, P.validar(s)), "moedas")
	end)

	T.caso("cópia profunda é independente", function()
		local p = P.novo(1)
		p.livrosLidos.GrimorioDosCeus = true
		local c = P.copiar(p)
		c.livrosLidos.GrimorioDosCeus = nil
		T.verdade(p.livrosLidos.GrimorioDosCeus)
	end)

	T.caso("trava: o primeiro servidor pega; o segundo espera até expirar", function()
		local r, ok = Tr.adquirir(nil, "A", 100, 300)
		T.verdade(ok)
		T.igual(r and r.trava and r.trava.ate, 400)
		local r2, ok2, m2 = Tr.adquirir(r, "B", 200, 300)
		T.falso(ok2)
		T.igual(m2, "travado")
		T.igual(r2, nil, "não escreve")
		local _, ok3 = Tr.adquirir(r, "B", 401, 300)
		T.verdade(ok3)
	end)

	T.caso("salvar: só o dono da trava escreve; liberar solta a trava", function()
		local r = Tr.adquirir(nil, "A", 100, 300)
		local s1, ok1, m1 = Tr.salvar(r, { versao = 2 }, "A", 150, 300, false)
		T.verdade(ok1)
		T.igual(m1, "salvo")
		T.igual(s1 and s1.trava and s1.trava.ate, 450)
		local _, okB, mB = Tr.salvar(s1, { versao = 2 }, "B", 160, 300, false)
		T.falso(okB)
		T.igual(mB, "travaPerdida")
		local s3, ok3, m3 = Tr.salvar(s1, { versao = 2 }, "A", 170, 300, true)
		T.verdade(ok3)
		T.igual(m3, "liberado")
		T.igual(s3 and s3.trava, nil)
		local _, ok4 = Tr.salvar(s3, { versao = 2 }, "A", 180, 300, false)
		T.falso(ok4, "depois de liberar, não escreve mais")
	end)
end
