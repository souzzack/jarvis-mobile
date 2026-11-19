-- NÃO EXECUTADO. Conferência de deslocamento no servidor.
-- Limite horizontal 32 studs/s, fator 1,25, folga 4: em 0,1 s cabem 32 × 1,25 × 0,1 + 4 = 8 studs.

return function(T, M)
	local V = M.Validador
	local lim = { velHorizontal = 32, velSubida = 16, velQueda = 30, alturaMax = 600 }

	local function a(x: number, y: number, t: number)
		return { x = x, y = y, z = 0, t = t }
	end

	T.caso("dentro do limite passa; acima falha com o motivo certo", function()
		T.verdade((V.verificar(a(0, 10, 0), a(7, 10, 0.1), lim, 1.25, 4)))
		local ok, mot = V.verificar(a(0, 10, 0), a(9, 10, 0.1), lim, 1.25, 4)
		T.falso(ok)
		T.igual(mot, "horizontal")
		local _, mot2 = V.verificar(a(0, 10, 0), a(0, 17, 0.1), lim, 1.25, 4) -- cabem 16 × 1,25 × 0,1 + 4 = 6
		T.igual(mot2, "subida")
		local _, mot3 = V.verificar(a(0, 10, 0), a(0, 700, 5), lim, 1.25, 4)
		T.igual(mot3, "altitude")
	end)

	T.caso("uma violação isolada é tolerada; duas seguidas corrigem para a última válida", function()
		local r = V.novoRegistro()
		V.registrar(r, a(0, 10, 0), lim, 1.25, 4, 2)
		V.registrar(r, a(5, 10, 0.1), lim, 1.25, 4, 2)
		local c1 = V.registrar(r, a(50, 10, 0.2), lim, 1.25, 4, 2)
		T.falso(c1, "primeira violação: tolera")
		local c2, volta = V.registrar(r, a(100, 10, 0.3), lim, 1.25, 4, 2)
		T.verdade(c2, "segunda seguida: corrige")
		T.igual(volta and volta.x, 5)
		T.igual(r.total, 2)
	end)

	T.caso("amostra válida zera a contagem de violações seguidas", function()
		local r = V.novoRegistro()
		V.registrar(r, a(0, 10, 0), lim, 1.25, 4, 2)
		V.registrar(r, a(50, 10, 0.1), lim, 1.25, 4, 2)
		V.registrar(r, a(2, 10, 0.2), lim, 1.25, 4, 2)
		T.igual(r.violacoesSeguidas, 0)
	end)

	T.caso("reancorar aceita o teleporte legítimo do servidor", function()
		local r = V.novoRegistro()
		V.registrar(r, a(0, 10, 0), lim, 1.25, 4, 2)
		V.reancorar(r, a(500, 10, 0.1))
		local c = V.registrar(r, a(503, 10, 0.2), lim, 1.25, 4, 2)
		T.falso(c)
		T.igual(r.violacoesSeguidas, 0)
	end)
end
