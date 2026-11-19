--!strict
-- NÃO EXECUTADO. Estruturas restauráveis da Ilha das Tempestades (GDD 8). Só dados (T).
-- O estado é POR JOGADOR. Os modelos aprovados (oficina, observatório, torre) não são alterados: a
-- restauração liga FUNÇÕES (estação de fabricação, livros, missões) e pode acender detalhes visuais por
-- atributo, mas nunca troca o modelo.

local lista = {
	{
		id = "OficinaDosInventores",
		nome = "Oficina dos Inventores",
		funcao = "Fabricação (Liga Arcana e receitas Druida provisórias)",
		etapas = {
			{ nome = "Tirar os destroços da bancada", materiais = { FragmentoDeFaisca = 4 } },
			{ nome = "Religar a fornalha", materiais = { FragmentoDeFaisca = 6, NucleoDeTempestade = 1 } },
		},
	},
	{
		id = "Observatorio",
		nome = "Observatório",
		funcao = "Biblioteca de mapas estelares (Grimório dos Céus) e missões de investigação",
		etapas = {
			{ nome = "Remendar a cúpula", materiais = { FragmentoDeFaisca = 5 } },
			{ nome = "Polir as lentes", materiais = { NucleoDeTempestade = 1, PenaDeRaia = 2 } },
		},
	},
	{
		id = "TorreMeteorologica",
		nome = "Torre Meteorológica",
		funcao = "Energia da ilha; estante do Tomo das Correntes Astrais; arena do Guardião",
		etapas = {
			{ nome = "Trocar os cabos", materiais = { FragmentoDeFaisca = 8 } },
			{ nome = "Recarregar as bobinas", materiais = { GlandulaDeBobinaViva = 2, NucleoDeTempestade = 1 } },
			{ nome = "Alinhar o para-raios", materiais = { LigaArcana = 1 } },
		},
	},
}

local porId: { [string]: any } = {}
for _, e in lista do
	porId[e.id] = e
end

return {
	lista = lista,
	porId = porId,
	ajudaMinima = 0.25, -- quem entregou ≥ 25% da etapa conclui junto com o vizinho que concluiu
	raioDeAjuda = 30,
}
