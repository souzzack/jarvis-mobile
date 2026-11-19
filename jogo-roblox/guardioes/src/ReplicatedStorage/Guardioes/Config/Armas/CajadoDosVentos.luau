--!strict
-- NÃO EXECUTADO. Cajado dos Ventos (estilo Arcanista) — forma de COMBATE do Cajado dos Ventos Antigos. Só dados.
-- Médio alcance, arco largo, dano menor por golpe e mais postura (rajadas de vento empurram o equilíbrio).
-- Mesmo formato de Armas/Espada: o CombatSystem não muda para uma arma nova.

return {
	id = "CajadoDosVentos",
	estilo = "Arcanista",
	combo = {
		{ nome = "Rajada1", preparo = 0.16, golpe = 0.10, recuperacao = 0.26, alcance = 12, arcoGraus = 70, dano = 8, postura = 10, custoEstamina = 9, animacao = "CajadoRajada1" },
		{ nome = "Rajada2", preparo = 0.16, golpe = 0.10, recuperacao = 0.28, alcance = 12, arcoGraus = 70, dano = 9, postura = 11, custoEstamina = 9, animacao = "CajadoRajada2" },
		{ nome = "Redemoinho", preparo = 0.30, golpe = 0.14, recuperacao = 0.45, alcance = 8, arcoGraus = 360, dano = 14, postura = 22, custoEstamina = 14, animacao = "CajadoRedemoinho" },
	},
	pesado = { nome = "LancaDeVento", preparo = 0.60, golpe = 0.12, recuperacao = 0.55, alcance = 22, arcoGraus = 20, dano = 26, postura = 30, custoEstamina = 22, animacao = "CajadoLanca" },
	bonusPosturaComboPerfeito = 0.25,
}
