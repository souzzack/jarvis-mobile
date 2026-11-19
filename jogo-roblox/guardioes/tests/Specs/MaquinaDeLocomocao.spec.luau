-- NÃO EXECUTADO. MovementStateMachine: transições, recusas e exclusividade de modos.
-- Voo mágico: decolagem 0,45 s · pouso 0,35 s · sem impulso. Interrupção: 0,6 s.

return function(T, M)
	local ML = M.MaquinaDeLocomocao
	local voo = M.Perfis.porId.VooMagico
	local planador = M.Perfis.porId.Planador
	local plataforma = M.Perfis.porId.PlataformaFirmamento

	local function ctx(extra: { [string]: any }?)
		local c: { [string]: any } = { noSolo = true, altura = 0, zonaProibida = false, espacoLivre = true, atordoado = false, energia = 100, movendo = false }
		for k, v in extra or {} do
			c[k] = v
		end
		return c
	end
	local AR = { noSolo = false, altura = 10 }

	local function voando(t0: number?)
		local m = ML.nova(0)
		ML.decolar(m, voo, ctx(), 15, t0 or 0)
		ML.atualizar(m, voo, ctx(AR), 0.6, (t0 or 0) + 0.5)
		return m
	end

	T.caso("decolar → Decolagem → (0,45 s) → Pairar", function()
		local m = ML.nova(0)
		local ok = ML.decolar(m, voo, ctx(), 15, 0)
		T.verdade(ok)
		T.igual(m.estado, "Decolagem")
		T.igual(m.modo, "VooMagico")
		T.igual(#ML.atualizar(m, voo, ctx(AR), 0.6, 0.3), 0)
		local ev = ML.atualizar(m, voo, ctx(AR), 0.6, 0.5)
		T.igual(ev[1].tipo, "Decolou")
		T.igual(m.estado, "Pairar")
	end)

	T.caso("Pairar ↔ Voo pela entrada horizontal", function()
		local m = voando()
		ML.atualizar(m, voo, ctx({ noSolo = false, altura = 10, movendo = true }), 0.6, 0.6)
		T.igual(m.estado, "Voo")
		ML.atualizar(m, voo, ctx(AR), 0.6, 0.7)
		T.igual(m.estado, "Pairar")
	end)

	T.caso("decolar recusa: zona, espaço, energia, atordoado, já no ar", function()
		local function motivo(c)
			local _, mot = ML.decolar(ML.nova(0), voo, c, 15, 0)
			return mot
		end
		T.igual(motivo(ctx({ zonaProibida = true })), "zonaProibida")
		T.igual(motivo(ctx({ espacoLivre = false })), "semEspaco")
		T.igual(motivo(ctx({ energia = 10 })), "energia")
		T.igual(motivo(ctx({ atordoado = true })), "atordoado")
		local m = voando()
		local ok, mot = ML.decolar(m, voo, ctx(AR), 15, 1)
		T.falso(ok, "dois voos ao mesmo tempo")
		T.igual(mot, "Pairar")
	end)

	T.caso("impulso só com perfil que tem impulso", function()
		local m = voando()
		local ok, mot = ML.impulso(m, voo, true, 0.6)
		T.falso(ok)
		T.igual(mot, "semImpulso")
		local comImpulso = table.clone(voo)
		comImpulso.velImpulso = 48
		T.verdade((ML.impulso(m, comImpulso, true, 0.6)))
		T.igual(m.estado, "Impulso")
		ML.impulso(m, comImpulso, false, 0.7)
		T.igual(m.estado, "Voo")
	end)

	T.caso("pousar: Descida → tocou o chão → Pouso → (0,35 s) → Solo", function()
		local m = voando()
		T.verdade((ML.pousar(m, 0.6)))
		T.igual(m.estado, "Descida")
		local ev = ML.atualizar(m, voo, ctx({ noSolo = false, altura = 0.3 }), 0.6, 1.0)
		T.igual(ev[1].tipo, "TocouSolo")
		T.igual(m.estado, "Pouso")
		ev = ML.atualizar(m, voo, ctx(), 0.6, 1.4)
		T.igual(ev[1].tipo, "Pousou")
		T.igual(m.estado, "Solo")
		T.igual(m.modo, nil)
	end)

	T.caso("energia zerada: Interrompido → Descida → Pouso (sem custo na descida)", function()
		local m = voando()
		local ev = ML.atualizar(m, voo, ctx({ noSolo = false, altura = 10, energia = 0 }), 0.6, 0.6)
		T.igual(ev[1].tipo, "Interrompido")
		T.igual(ev[1].motivo, "energia")
		ML.atualizar(m, voo, ctx({ noSolo = false, altura = 8, energia = 0 }), 0.6, 1.3)
		T.igual(m.estado, "Descida")
		ML.atualizar(m, voo, ctx({ noSolo = false, altura = 5, energia = 0 }), 0.6, 1.4)
		T.igual(m.estado, "Descida", "descida não é interrompida por falta de energia")
		ML.atualizar(m, voo, ctx(), 0.6, 1.5)
		T.igual(m.estado, "Pouso")
	end)

	T.caso("zona proibida e atordoamento derrubam o voo", function()
		local m = voando()
		ML.atualizar(m, voo, ctx({ noSolo = false, altura = 10, zonaProibida = true }), 0.6, 0.6)
		T.igual(m.estado, "Interrompido")
		T.igual(m.motivo, "zonaProibida")
		local m2 = voando()
		ML.atualizar(m2, voo, ctx({ noSolo = false, altura = 10, atordoado = true }), 0.6, 0.6)
		T.igual(m2.motivo, "atordoado")
	end)

	T.caso("voo encostando no chão pousa sozinho; plataforma não", function()
		local m = voando()
		ML.atualizar(m, voo, ctx(), 0.6, 0.9)
		T.igual(m.estado, "Pouso")
		local p = ML.nova(0)
		ML.decolar(p, plataforma, ctx(), 15, 0)
		ML.atualizar(p, plataforma, ctx(AR), 0.6, 0.4)
		ML.atualizar(p, plataforma, ctx(), 0.6, 1.0)
		T.igual(p.estado, "Pairar")
	end)

	T.caso("planador: precisa de altura; fecha ao tocar o chão", function()
		local m = ML.nova(0)
		local ok, mot = ML.abrirPlanador(m, planador, ctx({ noSolo = false, altura = 3 }), 8, 0)
		T.falso(ok)
		T.igual(mot, "baixo")
		T.verdade((ML.abrirPlanador(m, planador, ctx({ noSolo = false, altura = 20 }), 8, 0)))
		T.igual(m.estado, "Planando")
		T.igual(m.tipoModo, "Planador")
		local ev = ML.atualizar(m, planador, ctx(), 0.6, 2)
		T.igual(ev[1].tipo, "Pousou")
		T.igual(m.estado, "Solo")
	end)

	T.caso("um modo por vez: do planador para o voo troca; do voo não abre planador", function()
		local m = ML.nova(0)
		ML.abrirPlanador(m, planador, ctx({ noSolo = false, altura = 20 }), 8, 0)
		T.verdade((ML.decolar(m, voo, ctx({ noSolo = false, altura = 20 }), 15, 1)))
		T.igual(m.modo, "VooMagico")
		local v = voando()
		local ok, mot = ML.abrirPlanador(v, planador, ctx(AR), 8, 1)
		T.falso(ok)
		T.igual(mot, "Pairar")
	end)

	T.caso("montaria: monta no chão; voo próprio recusado; voo da montaria volta a Montado", function()
		local m = ML.nova(0)
		T.verdade((ML.montar(m, "guid-raia", ctx(), 0)))
		T.igual(m.estado, "Montado")
		local _, mot = ML.decolar(m, voo, ctx(), 15, 0.1)
		T.igual(mot, "montado")
		local raia = table.clone(M.Especies.RaiaDasNuvens.montaria.perfilVoo)
		raia.montaria = true
		T.verdade((ML.decolar(m, raia, ctx(), 15, 0.2)))
		ML.atualizar(m, raia, ctx(AR), 0.6, 1.1)
		T.igual(m.estado, "Pairar")
		local ok2, mot2 = ML.desmontar(m, 1.2)
		T.falso(ok2)
		T.igual(mot2, "emVoo")
		ML.pousar(m, 1.3)
		ML.atualizar(m, raia, ctx(), 0.6, 1.4)
		ML.atualizar(m, raia, ctx(), 0.6, 2.2)
		T.igual(m.estado, "Montado")
		T.verdade((ML.desmontar(m, 2.3)))
		T.igual(m.estado, "Solo")
	end)

	T.caso("perfil de montaria sem estar montado é recusado", function()
		local raia = table.clone(M.Especies.RaiaDasNuvens.montaria.perfilVoo)
		raia.montaria = true
		local _, mot = ML.decolar(ML.nova(0), raia, ctx(), 15, 0)
		T.igual(mot, "semMontaria")
	end)

	T.caso("só ataca a pé; reiniciar volta ao chão e solta a montaria", function()
		local m = voando()
		T.falso(ML.podeAtacar(m))
		ML.reiniciar(m, 1)
		T.verdade(ML.podeAtacar(m))
		local mo = ML.nova(0)
		ML.montar(mo, "g", ctx(), 0)
		T.falso(ML.podeAtacar(mo))
		ML.reiniciar(mo, 1)
		T.igual(mo.montariaId, nil)
	end)
end
