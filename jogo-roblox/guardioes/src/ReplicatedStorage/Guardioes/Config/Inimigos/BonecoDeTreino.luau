--!strict
-- NÃO EXECUTADO. Alvo de treino: não anda nem ataca; serve para testar acerto, combo, postura e números de dano.

local Boneco = {
	id = "BonecoDeTreino",
	nome = "Boneco de Treino",
	categoria = "Teste",
	vida = 400,
	postura = 100,
	defesa = 0,
	raio = 1.6, -- raio do corpo (somado ao alcance do golpe)
	altura = 5,
	cor = "#C8B08A",
	ataques = {},
	ia = { percepcao = 0, perseguir = false, velocidade = 0, distanciaAtaque = 0 },
	retornoSeg = 5, -- volta 5 s depois de "morrer"
	recompensas = {}, -- o LootSystem entra na Etapa E
}

return Boneco
