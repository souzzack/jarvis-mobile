-- NÃO EXECUTADO. Habilidades especiais (regras de uso, "Corte em Voo") e atributos derivados das criaturas.

return function(T, M)
	local E = M.Especial
	local esp = M.Especiais.porArtefato
	local C = M.Crescimento
	local D = M.DadosDaCriatura

	local function ctx(extra: { [string]: any }?)
		local c: { [string]: any } = { formaAtiva = "Espada", tipoAtivo = "Combate", estagio = 2, agora = 10, recargaAte = 0, estamina = 100 }
		for k, v in extra or {} do
			c[k] = v
		end
		return c
	end

	T.caso("especial da forma certa, sem recarga e com estamina", function()
		local ok, motivo, saindo = E.pode(esp.EspadaDoHorizonte, ctx())
		T.verdade(ok)
		T.igual(motivo, "ok")
		T.falso(saindo)
		T.igual(select(2, E.pode(esp.EspadaDoHorizonte, ctx({ recargaAte = 12 }))), "recarga")
		T.igual(select(2, E.pode(esp.EspadaDoHorizonte, ctx({ estamina = 10 }))), "estamina")
		-- { formaAtiva = nil } não cria a chave em Luau; o nil precisa ser atribuído depois
		local trocando = ctx()
		trocando.formaAtiva = nil
		T.igual(select(2, E.pode(esp.EspadaDoHorizonte, trocando)), "transformando")
	end)

	T.caso("Corte em Voo: da prancha só no estágio 4", function()
		local naPrancha = { formaAtiva = "Prancha", tipoAtivo = "Locomocao" }
		local ok, motivo = E.pode(esp.EspadaDoHorizonte, ctx(naPrancha))
		T.falso(ok)
		T.igual(motivo, "formaDeLocomocao")
		naPrancha.estagio = 4
		local ok4, _, saindo = E.pode(esp.EspadaDoHorizonte, ctx(naPrancha))
		T.verdade(ok4)
		T.verdade(saindo)
	end)

	T.caso("especial de outra forma é recusada (escudo na forma de plataforma não usa Bastião)", function()
		local ok, motivo = E.pode(esp.EscudoDoFirmamento, ctx({ formaAtiva = "Plataforma", tipoAtivo = "Locomocao" }))
		T.falso(ok)
		T.igual(motivo, "formaDeLocomocao")
		T.igual(select(2, E.pode(esp.CajadoDosVentosAntigos, ctx({ formaAtiva = "Espada" }))), "outraForma")
	end)

	T.caso("atributos da criatura: papel × estágio × vínculo", function()
		local cao = M.Especies.CaoTrovao
		local c = D.nova("g", "CaoTrovao", "T")
		local a1 = C.atributos(c, cao)
		T.igual(a1.vida, 48)
		T.igual(a1.dano, 4)
		c.estagio = "Adulto"
		local a2 = C.atributos(c, cao)
		T.igual(a2.vida, 120)
		T.igual(a2.dano, 10)
		c.vinculo = 700
		local a3 = C.atributos(c, cao)
		T.igual(a3.vida, 137)
		T.igual(a3.dano, 11)
		local axo = D.nova("a", "AxoloteNebular", "N")
		axo.estagio = "Adulto"
		T.igual(C.atributos(axo, M.Especies.AxoloteNebular).dano, 4, "suporte bate fraco")
	end)
end
