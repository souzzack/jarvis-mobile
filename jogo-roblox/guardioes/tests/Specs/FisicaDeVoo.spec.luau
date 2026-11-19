-- NÃO EXECUTADO. Física aérea: aceleração gradual, teto de velocidade, frenagem, inclinação, planador, custo.
-- Voo mágico: velMax 32 · aceleração 36 · desaceleração 30 · vertical 16 (acel 30) · custos 6 / 4 (pairar).

return function(T, M)
	local F = M.FisicaDeVoo
	local voo = M.Perfis.porId.VooMagico
	local planador = M.Perfis.porId.Planador
	local plataforma = M.Perfis.porId.PlataformaFirmamento
	local FRENTE = { dx = 0, dz = 1, vertical = 0, impulso = false }
	local PARADO = { dx = 0, dz = 0, vertical = 0, impulso = false }

	local function rodar(e, p, ent, segundos: number, amb: any?)
		local custo = 0
		for _ = 1, math.floor(segundos / 0.05 + 0.5) do
			custo += F.passo(e, p, ent, 0.05, amb)
		end
		return custo
	end

	T.caso("acelera aos poucos e não passa da velocidade máxima", function()
		local e = F.novo()
		F.passo(e, voo, FRENTE, 0.1)
		T.perto(e.vz, 3.6, 1e-6, "36 × 0,1")
		rodar(e, voo, FRENTE, 2)
		T.perto(F.velocidadeHorizontal(e), 32, 1e-6)
	end)

	T.caso("solta o comando: freia com a desaceleração do perfil", function()
		local e = F.novo()
		e.vz = 32
		rodar(e, voo, PARADO, 0.5)
		T.perto(e.vz, 17, 1e-6, "32 − 30 × 0,5")
	end)

	T.caso("impulso sem velImpulso não acelera além do normal", function()
		local e = F.novo()
		local _, ativo = F.passo(e, voo, { dx = 0, dz = 1, vertical = 0, impulso = true }, 0.05)
		T.falso(ativo)
		rodar(e, voo, { dx = 0, dz = 1, vertical = 0, impulso = true }, 3)
		T.perto(F.velocidadeHorizontal(e), 32, 1e-6)
		local comImpulso = table.clone(voo)
		comImpulso.velImpulso = 48
		rodar(e, comImpulso, { dx = 0, dz = 1, vertical = 0, impulso = true }, 3)
		T.perto(F.velocidadeHorizontal(e), 48, 1e-6)
	end)

	T.caso("subida limitada à velocidade vertical do perfil", function()
		local e = F.novo()
		rodar(e, voo, { dx = 0, dz = 0, vertical = 1, impulso = false }, 2)
		T.perto(e.vy, 16, 1e-6)
	end)

	T.caso("curva inclina o corpo, sem passar do limite", function()
		local e = F.novo(0)
		e.vz = 32
		rodar(e, voo, { dx = -1, dz = 0, vertical = 0, impulso = false }, 0.3)
		T.verdade(math.abs(e.inclinacao) > 0.01, "inclinou")
		T.verdade(math.abs(e.inclinacao) <= math.rad(voo.inclinacaoMax) + 1e-6, "dentro do limite")
	end)

	T.caso("custo: pairar 4/s, voar 6/s, planador 0", function()
		local e = F.novo()
		T.perto(rodar(e, voo, PARADO, 1), 4, 1e-6)
		local e2 = F.novo()
		e2.vz = 32
		T.perto(rodar(e2, voo, FRENTE, 1), 6, 1e-6)
		local e3 = F.novo()
		e3.vz = 22
		T.perto(rodar(e3, planador, PARADO, 1), 0)
	end)

	T.caso("planador perde altura; corrente ascendente faz subir", function()
		local e = F.novo(0)
		e.vz = 22
		rodar(e, planador, PARADO, 3)
		T.perto(e.vy, -6, 1e-6)
		T.verdade(F.velocidadeHorizontal(e) >= planador.velMin - 1e-6, "nunca para no ar")
		rodar(e, planador, PARADO, 3, { correnteAscendente = 10 })
		T.perto(e.vy, 4, 1e-6)
	end)

	T.caso("plataforma não sobe acima da altura máxima sobre o chão", function()
		local e = F.novo()
		rodar(e, plataforma, { dx = 0, dz = 0, vertical = 1, impulso = false }, 1, { alturaSobreSolo = 9 })
		T.verdade(e.vy <= 0, "não sobe")
	end)

	T.caso("limites do servidor saem do mesmo perfil", function()
		local l = F.limites(voo)
		T.igual(l.velHorizontal, 32)
		T.igual(l.velSubida, 16)
		local lp = F.limites(planador)
		T.igual(lp.velQueda, 24)
	end)
end
