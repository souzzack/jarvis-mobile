-- NÃO EXECUTADO. Relíquias: encaixe, ativa com recarga longa, fora do Depósito, catálogo secreto separado.

return function(T, M)
	local R = M.Reliquia
	local Eq = M.Equipamento
	local olho = M.Equipamentos.porId.OlhoDaTormenta

	local function e(agora, ate)
		return { agora = agora, recargaAte = ate, vivo = true, atordoado = false }
	end

	T.caso("encaixe próprio: relíquia só vai no encaixe Reliquia", function()
		T.verdade(Eq.podeEquipar(olho, "Reliquia"))
		T.igual(select(2, Eq.podeEquipar(olho, "Acessorio1")), "encaixeErrado")
		T.igual(select(2, Eq.podeEquipar(M.Equipamentos.porId.CapuzDeViajante, "Reliquia")), "encaixeErrado")
	end)

	T.caso("ativar: pronta, recarga, atordoado, sem relíquia", function()
		T.verdade(R.podeAtivar(olho, e(1000, 0)))
		T.igual(R.proximaRecarga(olho, 1000), 1000 + olho.ativa.recarga)
		T.igual(select(2, R.podeAtivar(olho, e(1000, 1050))), "recarga")
		T.verdade(R.podeAtivar(olho, e(1050, 1050)), "no segundo exato fica pronta")
		local at = e(1000, 0)
		at.atordoado = true
		T.igual(select(2, R.podeAtivar(olho, at)), "atordoado")
		T.igual(select(2, R.podeAtivar(nil, e(1000, 0))), "semReliquia")
		T.igual(select(2, R.podeAtivar(M.Equipamentos.porId.CapuzDeViajante, e(1000, 0))), "semReliquia", "item comum não ativa")
		T.igual(R.falta(1050, 1000), 50)
		T.igual(R.falta(900, 1000), 0)
	end)

	T.caso("recarga é LONGA (GDD 7.4) e o efeito é limitado", function()
		T.verdade(olho.ativa.recarga >= 60)
		T.verdade(olho.ativa.reducao <= 0.6, "o CombatSystem limita a 0,6; a config já respeita")
		T.verdade(olho.ativa.duracao < olho.ativa.recarga / 4, "ativo bem menos tempo do que espera")
		for _, r in M.ReliquiasSecretas do
			T.verdade(r.ativa.recarga >= 60, r.id)
		end
	end)

	T.caso("relíquias não contam no Depósito", function()
		local itens = {
			a = { id = "CapuzDeViajante" },
			b = { id = "OlhoDaTormenta", reliquia = true },
			c = { id = "BotasDeViajante", melhoria = 2 },
		}
		T.igual(Eq.contarNoDeposito(itens), 2)
		T.igual(Eq.contarNoDeposito({}), 0)
	end)

	T.caso("relíquia sem atributos passivos: os totais não mudam", function()
		local itens = { g1 = { id = "CapuzDeViajante" }, g2 = { id = "OlhoDaTormenta", reliquia = true } }
		local so = Eq.totais({ Cabeca = "g1" }, itens, M.Equipamentos.porId, M.Raridades.porId, M.Raridades.tetoMelhoria)
		local com = Eq.totais({ Cabeca = "g1", Reliquia = "g2" }, itens, M.Equipamentos.porId, M.Raridades.porId, M.Raridades.tetoMelhoria)
		T.igual(com.defesa, so.defesa)
		T.igual(com.vidaBonus, so.vidaBonus)
	end)

	T.caso("relíquia ??? fica fora do catálogo público", function()
		-- confere a LISTA pública (o arquivo que vai para o cliente): no Play, o EquipmentSystem junta as
		-- secretas em porId só na cópia do servidor, de propósito, então porId não serve para esta checagem
		for _, r in M.ReliquiasSecretas do
			for _, e in M.Equipamentos.lista do
				T.verdade(e.id ~= r.id, "não pode estar em Config/Equipamentos: " .. r.id)
			end
			T.igual(r.tipo, "Reliquia")
			T.igual(r.raridade, "Oculta")
		end
	end)
end
