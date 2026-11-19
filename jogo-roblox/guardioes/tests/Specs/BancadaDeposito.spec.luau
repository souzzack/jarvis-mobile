-- NÃO EXECUTADO. Bancada (consumíveis) e Depósito (capacidade de equipamentos) da base.

return function(T, M)
	local C = M.Consumivel
	local Cs = M.Consumiveis
	local B = M.Base
	local cfgDep = M.CfgBase.espacos.Deposito

	local function estado(agora)
		return { agora = agora, emVoo = false, atordoado = false, vivo = true, recargas = {} }
	end

	T.caso("Depósito: capacidade por nível (padrão = nível inicial)", function()
		T.igual(B.capacidadeDoDeposito({ espacos = {} }, cfgDep), 30)
		T.igual(B.capacidadeDoDeposito({ espacos = { Deposito = 3 } }, cfgDep), 60)
		T.igual(B.capacidadeDoDeposito({ espacos = { Deposito = 4 } }, cfgDep), 80)
		T.igual(B.capacidadeDoDeposito({ espacos = { Deposito = 99 } }, cfgDep), 80, "nunca passa do último nível")
		T.igual(B.capacidadeDoDeposito({ espacos = {} }, nil), math.huge, "sem Depósito configurado: sem limite")
		T.igual(cfgDep.max, #cfgDep.capacidade, "um valor de capacidade por nível")
	end)

	T.caso("Depósito e Bancada têm custos de melhoria completos", function()
		for _, id in { "Deposito", "Bancada" } do
			local cfg = M.CfgBase.espacos[id]
			for n = (cfg.nivelInicial or 1) + 1, cfg.max do
				T.verdade(cfg.niveis[n] ~= nil, id .. " nível " .. n)
				for mat in cfg.niveis[n].materiais do
					T.verdade(M.Materiais.porId[mat] ~= nil, id .. ": material existe " .. mat)
				end
			end
		end
	end)

	T.caso("consumível: posse, recarga por tipo, voo e atordoado", function()
		local balsamo = Cs.porId.BalsamoDeCasca
		local infusao = Cs.porId.InfusaoDeFaisca
		local e = estado(100)
		T.igual(select(2, C.podeUsar(balsamo, e, 0)), "naoPossui")
		T.verdade(C.podeUsar(balsamo, e, 1))
		C.marcarRecarga(balsamo, e)
		T.igual(select(2, C.podeUsar(balsamo, e, 5)), "recarga")
		T.verdade(C.podeUsar(Cs.porId.TonicoDeVento, e, 1), "outro tipo de efeito não espera")
		e.agora = 100 + balsamo.recarga
		T.verdade(C.podeUsar(balsamo, e, 1), "recarga acabou")
		e.emVoo = true
		T.igual(select(2, C.podeUsar(infusao, e, 1)), "emVoo", "a infusão é só no chão")
		T.verdade(C.podeUsar(balsamo, e, 1), "o bálsamo pode no ar")
		e.emVoo, e.atordoado = false, true
		T.igual(select(2, C.podeUsar(balsamo, e, 1)), "atordoado")
		e.atordoado, e.vivo = false, false
		T.falso(C.podeUsar(balsamo, e, 1), "morto não usa")
		T.falso(C.podeUsar(nil, estado(0), 1))
	end)

	T.caso("cura em pulsos soma exatamente o total", function()
		local p = C.pulsosDeCura(35, 3)
		T.igual(#p, 6)
		local soma = 0
		for _, v in p do
			soma += v
		end
		T.perto(soma, 35, 1e-9)
		T.igual(#C.pulsosDeCura(10, 0.1), 1, "duração curta: um pulso")
	end)

	T.caso("recuperar estamina/energia não passa do máximo nem reinicia o atraso", function()
		local E = M.Estamina
		local cfg = { max = 100, recuperacaoPorSeg = 10, atrasoRecuperacao = 1 }
		local r = E.nova(100, 0)
		E.gastar(r, cfg, 80, 0)
		E.recuperar(r, cfg, 50, 0.5)
		T.perto(r.valor, 70, 1e-9)
		T.igual(r.ultimoGasto, 0, "não conta como gasto")
		E.recuperar(r, cfg, 999, 0.5)
		T.perto(r.valor, 100, 1e-9)
		E.recuperar(r, cfg, -20, 0.6)
		T.perto(r.valor, 100, 1e-9, "valor negativo não tira")
	end)

	T.caso("consumíveis existem como materiais, têm receita na Bancada e teclas diferentes", function()
		local teclas = {}
		for _, c in Cs.lista do
			T.verdade(M.Materiais.porId[c.id] and M.Materiais.porId[c.id].consumivel, c.id .. " é material consumível")
			local r = M.Receitas.porId[c.id]
			T.verdade(r ~= nil and r.estacao == "Bancada" and r.resultado.id == c.id, c.id .. " na Bancada")
			T.falso(teclas[c.tecla], "tecla repetida " .. c.tecla)
			teclas[c.tecla] = true
		end
		T.igual(M.Receitas.porId.PingenteDePena.estacao, "Bancada", "acessório simples na Bancada")
		T.verdade(M.Equipamentos.porId.PingenteDePena ~= nil)
	end)

	T.caso("desmontar devolve parte (e o material de origem dos Druida)", function()
		local Eq = M.Equipamento
		local comum = Eq.desmontar(M.Equipamentos.porId.CapuzDeViajante)
		T.igual(comum.FragmentoDeFaisca, 2)
		local druida = Eq.desmontar(M.Equipamentos.porId.ElmoDaMatilha)
		T.igual(druida.JubaEstatica, 1)
		T.verdade(druida.JubaEstatica < 3, "menos do que custou (o esboço pede mais)")
	end)
end
