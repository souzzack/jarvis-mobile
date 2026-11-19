--!strict
-- NÃO EXECUTADO. Objetivos semanais COOPERATIVOS das companhias (GDD 10). Só dados (T).
-- Cada semana (segunda 00:00 UTC) a companhia recebe 3 objetivos sorteados desta lista (sorteio fixo por
-- companhia e semana: todos os servidores chegam ao mesmo resultado). O alvo cresce um pouco com o número de
-- membros. Só conclui com pelo menos 2 pessoas contribuindo (ou todas, se a companhia tiver 1 membro).
-- Recompensa: XP da companhia + materiais modestos para CADA pessoa que contribuiu (nunca poder de combate direto).
-- Só tipos que se repetem toda semana e não dão para "fabricar" sem jogar: restaurar acaba (cada estrutura uma
-- vez) e depositar no cofre dá para repetir depositando e retirando, por isso ficaram de fora.

return {
	porSemana = 3,
	minContribuintes = 2,
	crescimentoPorMembro = 0.15, -- alvo × (1 + 0,15 × (membros − 1)), no máximo × 3
	tetoCrescimento = 3,
	lista = {
		{ id = "CacaDeFaiscas", nome = "Caça às Faíscas", tipo = "DerrotarComum", alvo = 40, xp = 250, recompensa = { FragmentoDeFaisca = 6 } },
		{ id = "ChefesDaIlha", nome = "Chefes da Ilha", tipo = "DerrotarChefe", alvo = 3, xp = 400, recompensa = { NucleoDeTempestade = 1 } },
		{ id = "MaosNaForja", nome = "Mãos na Forja", tipo = "Fabricar", alvo = 8, xp = 250, recompensa = { FragmentoDeFaisca = 4, CascaAntiga = 2 } },
		{ id = "EscudosFirmes", nome = "Escudos Firmes", tipo = "Aparar", alvo = 30, xp = 300, recompensa = { SementeFlutuante = 3 } },
	},
}
