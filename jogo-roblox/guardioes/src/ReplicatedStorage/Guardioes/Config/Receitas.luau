--!strict
-- NÃO EXECUTADO. Receitas (GDD 7.3). Só dados (T). Receitas ??? não ficam aqui (SecretDiscoverySystem).
-- resultado.tipo: "material" (vai para a bolsa) | "artefato" (novo GUID no inventário).
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
}

local porId: { [string]: any } = {}
for _, r in lista do
	porId[r.id] = r
end

return { lista = lista, porId = porId }
