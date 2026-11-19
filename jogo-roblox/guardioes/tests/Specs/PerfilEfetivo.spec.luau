-- NÃO EXECUTADO. Perfil efetivo = base + habilidades + estágio, com tetos anti-inflação.

return function(T, M)
	local PE = M.PerfilEfetivo
	local H = M.Habilidades.porId
	local voo = M.Perfis.porId.VooMagico
	local planador = M.Perfis.porId.Planador

	T.caso("sem fontes: cópia idêntica (e não altera o original)", function()
		local p = PE.calcular(voo, {})
		T.igual(p.velMax, 32)
		p.velMax = 999
		T.igual(voo.velMax, 32, "original intacto")
	end)

	T.caso("Correntes Astrais libera impulso (velMax × 1,5) e +6° de inclinação", function()
		local p = PE.calcular(voo, { H.CorrentesAstrais })
		T.perto(p.velImpulso, 48)
		T.perto(p.inclinacaoMax, 36)
	end)

	T.caso("Leveza: −20% nos custos", function()
		local p = PE.calcular(voo, { H.Leveza })
		T.perto(p.custoPorSeg, 4.8)
		T.perto(p.custoPairarPorSeg, 3.2)
	end)

	T.caso("teto: bônus empilhados não passam de 1,35× a velocidade base", function()
		local p = PE.calcular(voo, { { perfis = { "VooMagico" }, mods = { { campo = "velMax", somar = 100 } } } })
		T.perto(p.velMax, 32 * 1.35)
	end)

	T.caso("piso: custos nunca caem abaixo da metade", function()
		local p = PE.calcular(voo, { { perfis = { "*" }, mods = { { campo = "custoPorSeg", multiplicar = 0.1 } } } })
		T.perto(p.custoPorSeg, 3)
	end)

	T.caso("bônus de outro perfil não vaza; '*' não afeta o planador", function()
		local p = PE.calcular(voo, { { perfis = { "PranchaHorizonte" }, mods = { { campo = "velMax", somar = 4 } } } })
		T.igual(p.velMax, 32)
		local g = PE.calcular(planador, { H.CorrentesAstrais })
		T.igual(g.velImpulso, 0)
	end)
end
