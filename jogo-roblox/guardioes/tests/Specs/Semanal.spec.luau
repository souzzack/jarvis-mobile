-- NÃO EXECUTADO. Objetivos semanais cooperativos das companhias.

return function(T, M)
	local S = M.Semanal
	local cfg = M.ObjetivosSemanais
	local DIA = 86400
	local SEG = 4 * DIA -- segunda, 05/01/1970 00:00 UTC

	T.caso("semana vira na segunda 00:00 UTC", function()
		T.igual(S.semana(SEG), 0)
		T.igual(S.semana(SEG + 7 * DIA - 1), 0, "domingo 23:59:59")
		T.igual(S.semana(SEG + 7 * DIA), 1)
		T.igual(S.fimDaSemana(0), SEG + 7 * DIA)
		-- 16/11/2026 (segunda) e 22/11/2026 (domingo) caem na mesma semana; 23/11 na seguinte
		local seg16 = 1794787200
		T.igual(S.semana(seg16), S.semana(seg16 + 6 * DIA + 86399))
		T.igual(S.semana(seg16 + 7 * DIA), S.semana(seg16) + 1)
	end)

	T.caso("sorteio: fixo por companhia e semana, sem repetir", function()
		local a = S.sortear("c1", 10, #cfg.lista, cfg.porSemana)
		T.igual(#a, cfg.porSemana)
		T.igual(table.concat(a, ","), table.concat(S.sortear("c1", 10, #cfg.lista, cfg.porSemana), ","), "todos os servidores iguais")
		local visto = {}
		for _, i in a do
			T.falso(visto[i], "repetido")
			visto[i] = true
			T.verdade(i >= 1 and i <= #cfg.lista)
		end
		local variou = false
		for sem = 11, 30 do
			if table.concat(S.sortear("c1", sem, #cfg.lista, cfg.porSemana), ",") ~= table.concat(a, ",") then
				variou = true
			end
		end
		T.verdade(variou, "as semanas mudam")
	end)

	T.caso("alvo cresce com membros, com teto", function()
		T.igual(S.alvo(40, 1, cfg), 40)
		T.igual(S.alvo(40, 5, cfg), 64) -- 40 × 1,6
		T.igual(S.alvo(40, 30, cfg), 120, "teto × 3")
		T.igual(S.alvo(1, 1, cfg), 1)
	end)

	T.caso("preparar: mantém a semana; semana nova zera sem mexer na antiga", function()
		local e1, novo1 = S.preparar(nil, "c1", SEG + 100, 3, cfg)
		T.verdade(novo1)
		T.igual(#e1.objetivos, cfg.porSemana)
		local e2, novo2 = S.preparar(e1, "c1", SEG + 200, 3, cfg)
		T.falso(novo2)
		T.verdade(e1 == e2)
		local e3, novo3 = S.preparar(e1, "c1", SEG + 7 * DIA + 1, 3, cfg)
		T.verdade(novo3)
		T.igual(e3.semana, e1.semana + 1)
		T.igual(e1.semana, 0, "a antiga não mudou")
	end)

	local function estadoCom(tipo, alvo)
		return { semana = 0, objetivos = { { id = "X", tipo = tipo, alvo = alvo, feito = 0, concluido = false } }, contribuicao = { X = {} } }
	end

	T.caso("registrar soma por tipo, limita ao alvo e guarda quem ajudou", function()
		local e = estadoCom("Fabricar", 5)
		T.falso(S.registrar(e, "Aparar", "1", 3), "tipo diferente")
		T.verdade(S.registrar(e, "Fabricar", "1", 3))
		S.registrar(e, "Fabricar", "2", 9)
		T.igual(e.objetivos[1].feito, 5)
		T.igual(e.contribuicao.X["1"], 3)
		T.igual(e.contribuicao.X["2"], 9)
		T.falso(S.registrar(e, "Fabricar", "1", 0))
	end)

	T.caso("conclui só com 2 pessoas (cooperativo) e uma vez só", function()
		local e = estadoCom("Aparar", 4)
		S.registrar(e, "Aparar", "1", 10)
		T.igual(#S.concluir(e, 5, cfg), 0, "uma pessoa só não conclui")
		S.registrar(e, "Aparar", "2", 1)
		local c = S.concluir(e, 5, cfg)
		T.igual(#c, 1)
		T.igual(table.concat(c[1].contribuintes, ","), "1,2")
		T.verdade(e.objetivos[1].concluido)
		T.igual(#S.concluir(e, 5, cfg), 0, "não paga de novo")
		T.falso(S.registrar(e, "Aparar", "3", 1), "concluído não soma mais")
	end)

	T.caso("companhia de 1 membro conclui sozinha", function()
		local e = estadoCom("DerrotarComum", 2)
		S.registrar(e, "DerrotarComum", "7", 2)
		T.igual(#S.concluir(e, 1, cfg), 1)
	end)

	T.caso("catálogo: ids únicos, recompensas com materiais existentes", function()
		local ids = {}
		for _, o in cfg.lista do
			T.falso(ids[o.id], o.id)
			ids[o.id] = true
			T.verdade(o.alvo >= 1 and o.xp > 0)
			for mat in o.recompensa do
				T.verdade(M.Materiais.porId[mat] ~= nil, mat)
			end
		end
		T.verdade(#cfg.lista >= cfg.porSemana)
	end)
end
