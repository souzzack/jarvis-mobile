--!strict
-- NÃO EXECUTADO. Receitas (GDD 7.3). Só dados (T). Receitas ??? não ficam aqui (SecretDiscoverySystem).
-- resultado.tipo: "material" (vai para a bolsa) | "artefato" (novo GUID) | "equipamento" (novo GUID, Config/Equipamentos).
-- estacaoNivel: nível mínimo da estação. A Forja é da BASE PESSOAL (só o dono usa a dele).

local lista = {
	{
		id = "LigaArcana",
		nome = "Liga Arcana",
		estacao = "OficinaDosInventores",
		conhecidaDesdeInicio = true,
		requisitos = { restauracoes = { "OficinaDosInventores" } },
		materiais = { FragmentoDeFaisca = 6, NucleoDeTempestade = 1 },
		resultado = { tipo = "material", id = "LigaArcana", qtd = 1 },
	},
	{
		id = "EsbocoDruida_RainhaBobina",
		nome = "Escudo do Firmamento (Druida)",
		estacao = "Forja",
		estacaoNivel = 3, -- GDD 7.3: receitas Druida exigem a Forja da base no nível 3
		conhecidaDesdeInicio = false, -- esboço aprendido na PRIMEIRA vitória contra a Rainha-Bobina
		requisitos = {},
		materiais = { GlandulaDeBobinaViva = 4, SementeFlutuante = 3, CascaAntiga = 2 },
		resultado = { tipo = "artefato", id = "EscudoDoFirmamento", estagio = 1 },
	},
	{
		-- GDD 7.3: derrota do Guardião → Códice Arcano; fabricar exige material Arcano do Guardião + 2 materiais
		-- Druida da mesma dimensão + a Oficina restaurada. (Exemplo 4 do complemento: Guardião → espada-prancha.)
		id = "CodiceArcano_EspadaDoHorizonte",
		nome = "Espada do Horizonte (Arcano)",
		estacao = "OficinaDosInventores",
		conhecidaDesdeInicio = false,
		requisitos = { restauracoes = { "OficinaDosInventores" } },
		materiais = { CoracaoDaTormenta = 1, PenaDoRelampagoAntigo = 2, GlandulaDeBobinaViva = 2, JubaEstatica = 2 },
		resultado = { tipo = "artefato", id = "EspadaDoHorizonte", estagio = 1 },
	},
	-- transporte comum (Forja nível 2)
	{
		id = "PranchaDeViagem", nome = "Prancha de viagem", estacao = "Forja", estacaoNivel = 2, conhecidaDesdeInicio = true, requisitos = {},
		materiais = { FragmentoDeFaisca = 12, PenaDeRaia = 2 }, resultado = { tipo = "transporte", id = "PranchaComum" },
	},
	-- equipamentos comuns (Forja nível 1)
	{
		id = "CapuzDeViajante", nome = "Capuz de Viajante", estacao = "Forja", estacaoNivel = 1, conhecidaDesdeInicio = true, requisitos = {},
		materiais = { FragmentoDeFaisca = 4 }, resultado = { tipo = "equipamento", id = "CapuzDeViajante" },
	},
	{
		id = "BotasDeViajante", nome = "Botas de Viajante", estacao = "Forja", estacaoNivel = 1, conhecidaDesdeInicio = true, requisitos = {},
		materiais = { FragmentoDeFaisca = 4 }, resultado = { tipo = "equipamento", id = "BotasDeViajante" },
	},
	-- esboços Druida dos minibosses (primeira vitória) — Forja nível 3 (GDD 7.3)
	{
		id = "EsbocoDruida_CaoAlfa", nome = "Elmo da Matilha (Druida)", estacao = "Forja", estacaoNivel = 3, conhecidaDesdeInicio = false, requisitos = {},
		materiais = { JubaEstatica = 4, FragmentoDeFaisca = 6 }, resultado = { tipo = "equipamento", id = "ElmoDaMatilha" },
	},
	{
		id = "EsbocoDruida_Colosso", nome = "Couraça das Ruínas (Druida)", estacao = "Forja", estacaoNivel = 3, conhecidaDesdeInicio = false, requisitos = {},
		materiais = { NucleoEnferrujado = 4, FragmentoDeFaisca = 8 }, resultado = { tipo = "equipamento", id = "CouracaDasRuinas" },
	},
	{
		id = "EsbocoDruida_Espectro", nome = "Amuleto Espectral (Druida)", estacao = "Forja", estacaoNivel = 3, conhecidaDesdeInicio = false, requisitos = {},
		materiais = { LenteEspectral = 3, NucleoDeTempestade = 1 }, resultado = { tipo = "equipamento", id = "AmuletoEspectral" },
	},
}

local porId: { [string]: any } = {}
for _, r in lista do
	porId[r.id] = r
end

return { lista = lista, porId = porId }
