--!strict
-- NÃO EXECUTADO. Catálogo de armaduras e acessórios (GDD 7.4). Só dados (T).
-- tipo: "Cabeca" | "Corpo" | "Pernas" | "Acessorio". Atributos BASE (antes do multiplicador da raridade).
-- Os Druida saem dos esboços dos minibosses (primeira vitória) e pedem a Forja da base nível 3.

local lista = {
	{ id = "CapuzDeViajante", nome = "Capuz de Viajante", tipo = "Cabeca", raridade = "Comum", atributos = { defesa = 4 } },
	{ id = "BotasDeViajante", nome = "Botas de Viajante", tipo = "Pernas", raridade = "Comum", atributos = { defesa = 4 } },
	{ id = "ElmoDaMatilha", nome = "Elmo da Matilha", tipo = "Cabeca", raridade = "Druida", materialDeOrigem = "JubaEstatica", atributos = { defesa = 10, janelaAparar = 0.03 }, efeito = "Aparo um pouco mais tolerante (lição do Alfa)" },
	{ id = "CouracaDasRuinas", nome = "Couraça das Ruínas", tipo = "Corpo", raridade = "Druida", materialDeOrigem = "NucleoEnferrujado", atributos = { defesa = 18, vidaBonus = 30 }, efeito = "Couraça do Colosso" },
	{ id = "PingenteDePena", nome = "Pingente de Pena", tipo = "Acessorio", raridade = "Comum", atributos = { energiaVoo = 6 }, efeito = "Um pouco mais de energia de voo" },
	{ id = "AmuletoEspectral", nome = "Amuleto Espectral", tipo = "Acessorio", raridade = "Druida", materialDeOrigem = "LenteEspectral", atributos = { defesa = 3, energiaVoo = 15 }, efeito = "Mais energia de voo (leveza do Espectro)" },
	-- relíquias (GDD 7.4). Públicas aqui; as de segredo (???) ficam em ConfigSecreta/ReliquiasSecretas (só servidor).
	{
		id = "OlhoDaTormenta", nome = "Olho da Tormenta", tipo = "Reliquia", raridade = "Arcano", atributos = {},
		ativa = { efeito = "EscudoDeEstatica", reducao = 0.4, duracao = 6, recarga = 120 },
		efeito = "Ativa (Z): por 6 s, os golpes recebidos causam 40% menos dano. Recarga 2 min. Do Guardião da Tormenta.",
	},
}

local porId: { [string]: any } = {}
for _, e in lista do
	porId[e.id] = e
end

return { lista = lista, porId = porId }
