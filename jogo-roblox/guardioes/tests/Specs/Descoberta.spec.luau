-- NÃO EXECUTADO. Segredos ???: semente por jogador, ordens, sequência, revelação gradual, situação da cadeia
-- e a coerência da cadeia do Ato 1 (ConfigSecreta/SegredosAto1).

return function(T, M)
	local D = M.Descoberta
	local S = M.SegredosAto1

	local function ehPermutacao(t, n)
		if #t ~= n then
			return false
		end
		local visto = {}
		for _, v in t do
			if v < 1 or v > n or visto[v] then
				return false
			end
			visto[v] = true
		end
		return true
	end

	T.caso("hash e semente: determinísticos e diferentes por jogador", function()
		T.igual(D.hash(""), 2166136261, "FNV-1a vazio")
		T.igual(D.hash("a"), 3826002220, "FNV-1a de 'a'")
		T.igual(D.semente(10, "X"), D.semente(10, "X"))
		T.verdade(D.semente(10, "X") ~= D.semente(11, "X"), "outro jogador")
		T.verdade(D.semente(10, "X") ~= D.semente(10, "Y"), "outro segredo")
	end)

	T.caso("permutação válida, repetível e variada entre sementes", function()
		local a = D.permutacao(12345, 6)
		T.verdade(ehPermutacao(a, 6))
		T.igual(table.concat(a, ","), table.concat(D.permutacao(12345, 6), ","), "mesma semente, mesma ordem")
		local diferentes = {}
		for s = 1, 40 do
			diferentes[table.concat(D.permutacao(D.hash("j" .. s), 3), ",")] = true
		end
		local n = 0
		for _ in diferentes do
			n += 1
		end
		T.verdade(n >= 4, "várias ordens aparecem (há 6 possíveis para 3 lentes)")
		T.igual(#D.permutacao(7, 1), 1)
	end)

	T.caso("ordem circular a partir de um ponto", function()
		T.igual(table.concat(D.ordemCircular(4, 6), ","), "4,5,6,1,2,3")
		T.igual(table.concat(D.ordemCircular(1, 6), ","), "1,2,3,4,5,6")
		T.igual(table.concat(D.ordemCircular(6, 6), ","), "6,1,2,3,4,5")
	end)

	T.caso("sequência: certo, errado recomeça, completo", function()
		local s = D.sequencia({ 3, 1, 2 })
		T.igual(D.ativar(s, 3), "certo")
		T.igual(D.ativar(s, 2), "errado")
		T.igual(s.pos, 0, "recomeçou")
		T.igual(D.ativar(s, 3), "certo")
		T.igual(D.ativar(s, 1), "certo")
		T.igual(D.ativar(s, 2), "completo")
		T.igual(D.ativar(s, 9), "completo", "depois de completa não volta atrás")
	end)

	T.caso("revelação gradual só acrescenta palavras", function()
		local txt = "um arco partido ao meio cuja corda vibra"
		T.igual(D.revelar(txt, 0), "??? ??? ??? ??? ??? ??? ??? ???")
		T.igual(D.revelar(txt, 1), txt)
		local antes = D.revelar(txt, 0.25)
		local depois = D.revelar(txt, 0.75)
		local pa, pd = {}, {}
		for w in string.gmatch(antes, "%S+") do
			table.insert(pa, w)
		end
		for w in string.gmatch(depois, "%S+") do
			table.insert(pd, w)
		end
		local mostradas = 0
		for i, w in pa do
			if w ~= "???" then
				mostradas += 1
				T.igual(pd[i], w, "palavra revelada continua revelada")
			end
		end
		T.igual(mostradas, 2, "25% de 8 palavras")
	end)

	T.caso("situação da cadeia: feita, disponível e bloqueada por outra dimensão", function()
		local etapas = {
			{ id = "A", conjunto = "segredos", requer = {} },
			{ id = "B", conjunto = "enigmas", requer = { "A" } },
			{ id = "C", conjunto = "segredos", requer = { "A" }, dimensao = "CampoDasBolhas" },
		}
		local s1 = D.situacao(etapas, { segredos = {}, enigmas = {} }, {})
		T.verdade(s1[1].disponivel)
		T.falso(s1[2].disponivel, "B espera A")
		T.verdade(s1[3].bloqueadaPorDimensao)
		local s2 = D.situacao(etapas, { segredos = { A = true }, enigmas = {} }, { CampoDasBolhas = true })
		T.verdade(s2[1].feita)
		T.falso(s2[1].disponivel, "feita não fica 'disponível'")
		T.verdade(s2[2].disponivel)
		T.verdade(s2[3].disponivel)
		T.perto(D.fracaoFeita(s2), 1 / 3, 1e-9)
	end)

	T.caso("parado: medido pelas amostras do servidor", function()
		local a = { { 0, 0, 0, 0 }, { 1, 0.2, 0, 0 }, { 2, 0.3, 0, 0.1 } }
		T.verdade(D.parado(a, 0, 0.6))
		table.insert(a, { 3, 2, 0, 0 })
		T.falso(D.parado(a, 0, 0.6), "andou")
		T.verdade(D.parado(a, 3, 0.6), "conta só desde o início da contemplação")
		T.falso(D.parado({}, 0, 0.6), "sem amostras não conta")
	end)

	T.caso("cadeia do Ato 1 é coerente (ids, dependências, lentes, ritual)", function()
		local ids = {}
		for _, e in S.etapas do
			T.falso(ids[e.id], "id repetido: " .. e.id)
			ids[e.id] = true
			T.verdade(e.conjunto == "segredos" or e.conjunto == "enigmas", e.id)
			T.verdade(type(e.nome) == "string" and type(e.texto) == "string" and type(e.dica) == "string", e.id)
		end
		for i, e in S.etapas do
			for _, r in e.requer or {} do
				T.verdade(ids[r], e.id .. " requer " .. r)
				-- dependência sempre aparece ANTES no diário (sem ciclo)
				local pos
				for j, x in S.etapas do
					if x.id == r then
						pos = j
					end
				end
				T.verdade(pos < i, e.id .. " depois de " .. r)
			end
		end
		T.igual(#S.estrelas, 6)
		for _, idx in S.lentes do
			T.verdade(S.estrelas[idx] ~= nil)
		end
		for id in S.ritual.materiais do
			T.verdade(M.Materiais.porId[id] ~= nil, "material do ritual existe: " .. id)
		end
		for _, l in S.livrosComMargem do
			T.verdade(S.margens[l] ~= nil, "margem de " .. l)
		end
		-- o Manuscrito revela exatamente a Parte 1 e pede as duas etapas que a cadeia diz
		local man = M.LivrosSecretos.ManuscritoSemNome
		T.igual(man.revela[1], "ReceitaArcoDasAsas_Parte1")
		T.igual(table.concat(man.requisitos.segredos, ","), "MargensDosLivros,SeteEstrelasSobChuva")
	end)

	T.caso("anotação das lentes cita os 3 mundos (nunca as cores)", function()
		local txt = string.format(S.anotacao, "X1", "X2", "X3")
		T.verdade(string.find(txt, "X1") ~= nil and string.find(txt, "X3") ~= nil)
		for _, e in S.estrelas do
			T.falso(string.find(txt, e.cor) ~= nil, "a anotação não entrega a cor " .. e.cor)
		end
	end)
end
