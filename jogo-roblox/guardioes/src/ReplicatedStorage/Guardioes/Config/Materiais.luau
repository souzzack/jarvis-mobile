--!strict
-- NÃO EXECUTADO. Materiais (nome e origem para a interface). Só dados. Materiais de segredo (???) não ficam aqui.

local lista = {
	{ id = "FragmentoDeFaisca", nome = "Fragmento de Faísca", origem = "Faíscas Errantes (Ilha das Tempestades)" },
	{ id = "NucleoDeTempestade", nome = "Núcleo de Tempestade", origem = "Raro das Faíscas; missão O Horizonte Partido" },
	{ id = "PenaDeRaia", nome = "Pena de Raia", origem = "Afagar uma Raia-das-Nuvens adulta" },
	{ id = "LigaArcana", nome = "Liga Arcana", origem = "Fabricação na Oficina (Etapa F)" },
	{ id = "SementeFlutuante", nome = "Semente Flutuante", origem = "Santuário (Etapa F/G)" },
	{ id = "CascaAntiga", nome = "Casca Antiga", origem = "Santuário (Etapa F/G)" },
	{ id = "EssenciaDeVento", nome = "Essência de Vento", origem = "Torre Meteorológica (Etapa G)" },
}

local porId: { [string]: any } = {}
for _, m in lista do
	porId[m.id] = m
end

return { lista = lista, porId = porId }
