--!strict
-- NÃO EXECUTADO. Habilidades ESPECIAIS de armas e escudos (Sistema 1 do complemento: "habilidades especiais de
-- armas e escudos"). Uma por FORMA de artefato. Só dados (T). A especial do Arco (???) fica no servidor.
-- tipo:
--   "Investida" — avança 'avanco' studs e acerta tudo na linha (alcance/arco) — Espada do Horizonte
--   "Bastiao"   — por 'duracao' s, todo golpe DE FRENTE vira aparo (devolve postura) — Escudo do Firmamento
--   "Rajada"    — golpe em volta (360°) + impulso vertical do próprio jogador — Cajado dos Ventos
--   "Disparo"   — tiro de longo alcance, arco estreito — Arco das Asas (???)
-- usoEmVoo: estágio mínimo do artefato para usar a especial SAINDO da forma de locomoção (o artefato volta
-- à forma de combate na hora e a especial sai em seguida — o "Corte em Voo" do estágio 4).

return {
	porArtefato = {
		EspadaDoHorizonte = {
			forma = "Espada",
			id = "LinhaDeRelampago",
			nome = "Linha de Relâmpago",
			tipo = "Investida",
			recarga = 8,
			custoEstamina = 20,
			alcance = 10,
			arcoGraus = 30,
			dano = 22,
			postura = 25,
			avanco = 10,
			usoEmVoo = 4,
			animacao = "HorizonteLinha",
		},
		EscudoDoFirmamento = {
			forma = "Escudo",
			id = "Bastiao",
			nome = "Bastião",
			tipo = "Bastiao",
			recarga = 12,
			custoEstamina = 15,
			duracao = 1.5,
			animacao = "EscudoBastiao",
		},
		CajadoDosVentosAntigos = {
			forma = "Cajado",
			id = "RajadaAscendente",
			nome = "Rajada Ascendente",
			tipo = "Rajada",
			recarga = 10,
			custoEstamina = 18,
			alcance = 8,
			arcoGraus = 360,
			dano = 12,
			postura = 30,
			impulsoVertical = 40,
			animacao = "CajadoRajada",
		},
	},
}
