--!strict
-- NÃO EXECUTADO. Consumíveis da Bancada (GDD 9). Só dados (T). Ficam na bolsa como materiais (Config/Materiais).
-- efeito.tipo: "Cura" (vida ao longo de 'duracao' s) | "Energia" (energia de voo na hora) | "Estamina" (na hora).
-- Recarga por TIPO de efeito (dois bálsamos seguidos não somam). Valores pequenos de propósito: ajudam, mas não
-- substituem defender, aparar e pousar para recuperar (o combate continua sendo de habilidade).

local lista = {
	{ id = "BalsamoDeCasca", nome = "Bálsamo de Casca", tecla = 2, efeito = { tipo = "Cura", valor = 35, duracao = 3 }, recarga = 20, emVoo = true, emCombate = true },
	{ id = "TonicoDeVento", nome = "Tônico de Vento", tecla = 3, efeito = { tipo = "Energia", valor = 40 }, recarga = 25, emVoo = true, emCombate = true },
	{ id = "InfusaoDeFaisca", nome = "Infusão de Faísca", tecla = 4, efeito = { tipo = "Estamina", valor = 50 }, recarga = 30, emVoo = false, emCombate = true },
}

local porId: { [string]: any } = {}
for _, c in lista do
	porId[c.id] = c
end

return { lista = lista, porId = porId }
