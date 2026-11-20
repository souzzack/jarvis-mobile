-- NÃO EXECUTADO. Portais entre dimensões (places): dimensão atual, estado de cada destino e TeleportData.

return function(T, M)
	local P = M.Portal
	local D = {
		{ id = "Hub", nome = "Hub", hub = true, placeId = 111 },
		{ id = "Bolhas", nome = "Bolhas", hub = false, placeId = 222 },
		{ id = "Futura", nome = "Futura", hub = false, placeId = 0 },
	}

	T.caso("dimensão atual pelo PlaceId; desconhecido ou Studio (0) = hub", function()
		T.igual(P.dimensaoAtual(222, D), "Bolhas")
		T.igual(P.dimensaoAtual(111, D), "Hub")
		T.igual(P.dimensaoAtual(999, D), "Hub")
		T.igual(P.dimensaoAtual(0, D), "Hub", "place 0 nunca casa com uma dimensão sem place")
	end)

	T.caso("estado: aqui, em construção, bloqueada, ok; voltar ao hub sempre pode", function()
		T.igual(P.estado(D[1], "Hub", true), "aqui")
		T.igual(P.estado(D[3], "Hub", true), "emConstrucao", "sem place não teleporta")
		T.igual(P.estado(D[2], "Hub", false), "bloqueada")
		T.igual(P.estado(D[2], "Hub", true), "ok")
		T.igual(P.estado(D[1], "Bolhas", false), "ok", "o hub não pede requisito")
	end)

	T.caso("dimensão no mesmo place: viaja sem placeId; a área decide onde o jogador está", function()
		local local1 = { id = "Area", nome = "Área", hub = false, placeId = 0, noPlace = true }
		T.igual(P.estado(local1, "Hub", true), "ok", "noPlace não fica em construção")
		T.igual(P.estado(local1, "Hub", false), "bloqueada", "mas ainda pede os requisitos")
		T.igual(P.estado(local1, "Area", true), "aqui")
		local chegadas = { { id = "Area", x = 100, z = 0, raio = 50 } }
		T.igual(P.dimensaoPorPosicao(120, 10, chegadas, "Hub"), "Area")
		T.igual(P.dimensaoPorPosicao(0, 0, chegadas, "Hub"), "Hub")
		T.igual(P.dimensaoPorPosicao(151, 0, chegadas, "Hub"), "Hub", "fora do raio")
	end)

	T.caso("TeleportData: só o formato exato e origem conhecida", function()
		local dados = P.dadosDeChegada("Hub")
		T.igual(P.lerChegada(dados, D), "Hub")
		T.igual(P.lerChegada(nil, D), nil)
		T.igual(P.lerChegada("Portal", D), nil)
		T.igual(P.lerChegada({ chegada = "Portal", de = "Inventada" }, D), nil, "origem forjada")
		T.igual(P.lerChegada({ chegada = "Outro", de = "Hub" }, D), nil)
		T.igual(P.lerChegada({ chegada = "Portal", de = string.rep("x", 100) }, D), nil, "texto enorme")
		T.igual(P.lerChegada({ chegada = "Portal", de = "Hub", moedas = 1e9 }, D), "Hub", "campos extras são ignorados (nunca lidos)")
	end)

	T.caso("config real: um hub, ids únicos, requisito público quando há requisito", function()
		local hubs, ids = 0, {}
		for _, d in M.Dimensoes.lista do
			if d.hub then
				hubs += 1
			end
			T.falso(ids[d.id], d.id)
			ids[d.id] = true
			T.verdade(type(d.placeId) == "number", d.id)
			if d.requisitos and next(d.requisitos) then
				T.verdade(type(d.requisitoPublico) == "string" and #d.requisitoPublico > 0, d.id)
			end
		end
		T.igual(hubs, 1)
		T.verdade(M.Portal.porId(M.Dimensoes.lista, "CampoDasBolhas") ~= nil, "o id usado por livros e segredos existe")
	end)
end
