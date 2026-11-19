-- NÃO EXECUTADO. Resolução de dano: esquivado → aparado → defendido → acerto.

return function(T, M)
	local Dano = M.Dano

	local function entrada(extra: { [string]: any }?)
		local e: { [string]: any } = {
			danoBase = 10, postura = 8,
			alvoInvulneravel = false, alvoAparando = false, alvoDefendendo = false, frontal = true,
			reducaoDefesa = 0.70, custoEstaminaPorDano = 0.60, posturaAparar = 40,
		}
		for k, v in extra or {} do
			e[k] = v
		end
		return e
	end

	T.caso("mitigação: 0 de defesa = 1; 100 = metade; negativa conta como 0", function()
		T.perto(Dano.mitigacao(0), 1)
		T.perto(Dano.mitigacao(100), 0.5)
		T.perto(Dano.mitigacao(-50), 1)
	end)

	T.caso("acerto simples", function()
		local r = Dano.resolver(entrada())
		T.igual(r.tipo, "Acerto")
		T.igual(r.dano, 10)
		T.igual(r.posturaNoAlvo, 8)
	end)

	T.caso("invulnerável vence tudo", function()
		local r = Dano.resolver(entrada({ alvoInvulneravel = true, alvoAparando = true, alvoDefendendo = true }))
		T.igual(r.tipo, "Esquivado")
		T.igual(r.dano, 0)
	end)

	T.caso("aparar de frente devolve postura ao atacante; de costas não apara", function()
		local r = Dano.resolver(entrada({ alvoAparando = true, alvoDefendendo = true }))
		T.igual(r.tipo, "Aparado")
		T.igual(r.posturaNoAtacante, 40)
		r = Dano.resolver(entrada({ alvoAparando = true, alvoDefendendo = true, frontal = false }))
		T.igual(r.tipo, "Acerto")
	end)

	T.caso("defesa de frente: 30% do dano, metade da postura, estamina = 60% do bruto", function()
		local r = Dano.resolver(entrada({ alvoDefendendo = true }))
		T.igual(r.tipo, "Defendido")
		T.igual(r.dano, 3)
		T.igual(r.posturaNoAlvo, 4)
		T.perto(r.estaminaDoAlvo, 6)
	end)

	T.caso("bônus de atordoado e de postura", function()
		T.igual(Dano.resolver(entrada({ alvoAtordoado = true, bonusAtordoado = 0.30 })).dano, 13)
		T.igual(Dano.resolver(entrada({ bonusPostura = 0.25 })).posturaNoAlvo, 10)
	end)

	T.caso("dano positivo pequeno nunca vira 0", function()
		T.igual(Dano.resolver(entrada({ danoBase = 0.4 })).dano, 1)
		T.igual(Dano.resolver(entrada({ danoBase = 0 })).dano, 0)
	end)
end
