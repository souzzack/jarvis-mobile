-- NÃO EXECUTADO. Colosso das Ruínas (aparos abrem o núcleo, onda) e Espectro do Observatório (noite, lentes, reflexo).

return function(T, M)
	local Co = M.Colosso
	local Es = M.Espectro
	local cfgC = { aparosParaAbrir = 3, exposicao = 8, intervaloOnda = 11, telegrafiaOnda = 1.5 }
	local cfgE = { lentes = 4, intervaloTeleporte = 9, janelaReflexo = 6, recargaTelescopio = 15 }
	local function fixo(v: number)
		return function()
			return v
		end
	end

	T.caso("Colosso: 3 aparos abrem o núcleo por 8 s; depois fecha", function()
		local e = Co.novo(0, cfgC)
		T.falso(Co.aparado(e, 1, cfgC))
		T.falso(Co.aparado(e, 2, cfgC))
		T.verdade(Co.aparado(e, 3, cfgC))
		T.verdade(Co.exposto(e, 5))
		T.falso(Co.aparado(e, 6, cfgC), "aberto não conta aparo")
		T.igual(Co.atualizar(e, 11.5, cfgC, true), "Fechou")
		T.igual(e.aparos, 0)
	end)

	T.caso("Colosso: pisoteio telegrafado e depois a onda", function()
		local e = Co.novo(0, cfgC)
		T.igual(Co.atualizar(e, 10, cfgC, false), nil)
		T.igual(Co.atualizar(e, 11, cfgC, false), "TelegrafaOnda")
		T.igual(Co.atualizar(e, 12, cfgC, false), nil)
		T.igual(Co.atualizar(e, 12.5, cfgC, false), "Onda")
		T.igual(e.proximaOnda, 23.5)
	end)

	T.caso("Espectro: noite que atravessa a meia-noite", function()
		T.verdade(Es.noite(22, 18, 6))
		T.verdade(Es.noite(3, 18, 6))
		T.falso(Es.noite(12, 18, 6))
		T.falso(Es.noite(6, 18, 6))
	end)

	T.caso("Espectro: teleporta para OUTRA lente a cada 9 s", function()
		local e = Es.novo(0, cfgE)
		T.igual(Es.atualizar(e, 5, cfgE, fixo(0)), nil)
		T.igual(Es.atualizar(e, 9, cfgE, fixo(0)), 2, "nunca a mesma (1 → pula para 2)")
		T.igual(Es.atualizar(e, 18, cfgE, fixo(0.99)), 4)
		T.igual(e.proximoTeleporte, 27)
	end)

	T.caso("Espectro: reflexo exige o Observatório, tem recarga e segura o teleporte", function()
		local e = Es.novo(0, cfgE)
		local ok, m = Es.refletir(e, 3, cfgE, false)
		T.falso(ok)
		T.igual(m, "telescopioQuebrado")
		T.verdade((Es.refletir(e, 3, cfgE, true)))
		T.verdade(Es.vulneravel(e, 8))
		T.falso(Es.vulneravel(e, 9.5))
		T.igual(e.proximoTeleporte, 9, "o teleporte espera o fim do reflexo")
		T.igual(Es.atualizar(e, 8, cfgE, fixo(0)), nil, "não foge durante o reflexo")
		T.igual(select(2, Es.refletir(e, 10, cfgE, true)), "recarga")
	end)
end
