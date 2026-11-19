--!strict
-- NÃO EXECUTADO. Materiais (nome e origem para a interface). Só dados. Materiais de segredo (???) não ficam aqui.

local lista = {
	{ id = "FragmentoDeFaisca", nome = "Fragmento de Faísca", origem = "Faíscas Errantes (Ilha das Tempestades)" },
	{ id = "NucleoDeTempestade", nome = "Núcleo de Tempestade", origem = "Raro das Faíscas; missão O Horizonte Partido" },
	{ id = "PenaDeRaia", nome = "Pena de Raia", origem = "Afagar uma Raia-das-Nuvens adulta" },
	{ id = "LigaArcana", nome = "Liga Arcana", origem = "Fabricação na Oficina dos Inventores restaurada" },
	{ id = "SementeFlutuante", nome = "Semente Flutuante", origem = "Jardim da base; Santuário" },
	{ id = "CascaAntiga", nome = "Casca Antiga", origem = "Jardim da base; Santuário" },
	{ id = "GlandulaDeBobinaViva", nome = "Glândula de Bobina Viva", origem = "Rainha-Bobina (material Druida)" },
	{ id = "JubaEstatica", nome = "Juba Estática", origem = "Cão-Trovão Alfa (material Druida)" },
	{ id = "CoracaoDaTormenta", nome = "Coração da Tormenta", origem = "Guardião da Tormenta (material Arcano)" },
	{ id = "PenaDoRelampagoAntigo", nome = "Pena do Relâmpago Antigo", origem = "Guardião da Tormenta (material Arcano)" },
	{ id = "EssenciaDeVento", nome = "Essência de Vento", origem = "Colosso das Ruínas (turbinas antigas)" },
	{ id = "NucleoEnferrujado", nome = "Núcleo Enferrujado", origem = "Colosso das Ruínas (material Druida)" },
	{ id = "LenteEspectral", nome = "Lente Espectral", origem = "Espectro do Observatório (material Druida)" },
}

local porId: { [string]: any } = {}
for _, m in lista do
	porId[m.id] = m
end

return { lista = lista, porId = porId }
