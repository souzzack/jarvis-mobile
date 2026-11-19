-- NÃO EXECUTADO. Motor universal de enigmas: os 7 tipos, validação de config e as configs reais.

return function(T, M)
	local E = M.Enigma
	local P = M.Puzzles

	T.caso("todas as configs reais são válidas (um script para todos os enigmas)", function()
		for id, cfg in P do
			local ok, problema = E.validarConfig(cfg)
			T.verdade(ok, id .. ": " .. tostring(problema))
		end
		T.falso(E.validarConfig({ tipo = "Inventado" }))
		T.falso(E.validarConfig({ tipo = "Cooperativo", elementos = { "A" }, minJogadores = 1, janela = 5 }), "cooperativo com 1 jogador não é cooperativo")
	end)

	T.caso("Sequencia: ordem pela semente, erro recomeça, completo trava", function()
		local cfg = P.OSinal
		local st = E.novo(cfg, 12345)
		T.igual(#st.ordem, 3)
		local outro = E.novo(cfg, 12345)
		T.igual(table.concat(st.ordem, ","), table.concat(outro.ordem, ","), "mesma semente, mesma ordem")
		T.igual(E.agir(st, cfg, { elemento = st.ordem[1] }), "certo")
		local errado = if st.ordem[2] == "Pedra" then "Cobre" else "Pedra"
		if errado == st.ordem[2] then
			errado = "Cristal"
		end
		T.igual(E.agir(st, cfg, { elemento = errado }), "errado")
		T.igual(st.pos, 0)
		for i = 1, 2 do
			E.agir(st, cfg, { elemento = st.ordem[i] })
		end
		T.igual(E.agir(st, cfg, { elemento = st.ordem[3] }), "completo")
		T.igual(E.agir(st, cfg, { elemento = st.ordem[1] }), "semEfeito")
		T.igual(E.agir(E.novo(cfg, 1), cfg, { elemento = "Inventado" }), "invalida")
	end)

	T.caso("Sequencia: sementes diferentes dão ordens diferentes", function()
		local vistas = {}
		for s = 1, 30 do
			vistas[table.concat(E.novo(P.OSinal, M.Descoberta.hash("p" .. s)).ordem, ",")] = true
		end
		local n = 0
		for _ in vistas do
			n += 1
		end
		T.verdade(n >= 3)
	end)

	T.caso("Alinhamento: nunca começa resolvido; girar até o alvo completa", function()
		local cfg = P.ExemploAlinhamento
		for s = 1, 20 do
			local st = E.novo(cfg, s)
			local resolvido = true
			for _, el in cfg.elementos do
				if st.pos[el] ~= st.alvo[el] then
					resolvido = false
				end
			end
			T.falso(resolvido, "semente " .. s)
		end
		local st = E.novo(cfg, 7)
		local ultimo
		for _, el in cfg.elementos do
			while st.pos[el] ~= st.alvo[el] do
				ultimo = E.agir(st, cfg, { elemento = el })
			end
		end
		T.igual(ultimo, "completo")
	end)

	T.caso("Coleta, Exploracao e Interdimensional", function()
		local c = P.ExemploColeta
		local st = E.novo(c, 0)
		T.igual(E.agir(st, c, { item = "Pagina2" }), "certo")
		T.igual(E.agir(st, c, { item = "Pagina2" }), "semEfeito")
		E.agir(st, c, { item = "Pagina1" })
		T.igual(E.agir(st, c, { item = "Pagina3" }), "completo")
		local x = P.ExemploExploracao
		local sx = E.novo(x, 0)
		T.igual(E.agir(sx, x, { alvo = "TopoDaTorre" }, { dentro = false }), "errado", "o servidor não viu o jogador lá")
		T.igual(E.agir(sx, x, { alvo = "TopoDaTorre" }, { dentro = true }), "completo")
		local d = P.ExemploInterdimensional
		local sd = E.novo(d, 0)
		T.igual(E.agir(sd, d, {}, { marcas = { SinalIlha = true } }), "errado")
		T.igual(E.agir(sd, d, {}, { marcas = { SinalIlha = true, SinalBolhas = true } }), "completo")
	end)

	T.caso("Ressonancia: sem a capacidade o mecanismo não responde", function()
		local cfg = P.ExemploRessonancia
		local st = E.novo(cfg, 0)
		T.igual(E.agir(st, cfg, { elemento = "CristalA" }, { capacidades = {} }), "errado")
		local ctx = { capacidades = { RessonanciaDimensional = true } }
		T.igual(E.agir(st, cfg, { elemento = "CristalA" }, ctx), "certo")
		T.igual(E.agir(st, cfg, { elemento = "CristalB" }, ctx), "completo")
	end)

	T.caso("Cooperativo: precisa de 2 pessoas diferentes dentro da janela", function()
		local cfg = P.ExemploCooperativo
		local st = E.novo(cfg, 0)
		E.agir(st, cfg, { elemento = "SinoA", jogador = "1", agora = 0 })
		T.igual(E.agir(st, cfg, { elemento = "SinoB", jogador = "1", agora = 1 }), "certo", "a mesma pessoa nos dois sinos")
		T.igual(E.agir(st, cfg, { elemento = "SinoB", jogador = "2", agora = 2 }), "completo")
		T.igual(table.concat(E.participantes(st), ","), "1,2")
		local s2 = E.novo(cfg, 0)
		E.agir(s2, cfg, { elemento = "SinoA", jogador = "1", agora = 0 })
		T.igual(E.agir(s2, cfg, { elemento = "SinoB", jogador = "2", agora = 100 }), "certo", "fora da janela recomeça")
		T.igual(E.agir(s2, cfg, { elemento = "SinoB", jogador = "2", agora = 101, }), "certo")
		T.igual(E.agir(s2, cfg, { elemento = "SinoA", jogador = "1", agora = 102 }), "completo")
	end)
end
