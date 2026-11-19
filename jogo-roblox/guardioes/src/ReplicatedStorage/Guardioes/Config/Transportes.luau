--!strict
-- NÃO EXECUTADO. Catálogo de TRANSPORTES para a tela de gerenciamento (Sistema 8 e 14). Só dados.
-- 'requisito' é o texto PÚBLICO mostrado quando indisponível (nunca revela segredos ???; o Arco não aparece).
-- 'perfil' liga às velocidades/custos reais (Config/Locomocao/Perfis), lidos pela própria tela.

return {
	lista = {
		{ id = "AsasNaturais", nome = "Asas (raça Alada)", tipo = "Voo", perfil = "AsasNaturais", requisito = "Raça Alada" },
		{ id = "VooMagico", nome = "Voo mágico", tipo = "Voo", perfil = "VooMagico", requisito = "Ler o Grimório dos Céus" },
		{ id = "Planador", nome = "Planador", tipo = "Planador", perfil = "Planador", requisito = "Aprender a planar" },
		{ id = "PranchaComum", nome = "Prancha de viagem", tipo = "Prancha", perfil = "PranchaComum", requisito = "Fabricar na Forja da base (nível 2)" },
		{ id = "PranchaHorizonte", nome = "Espada do Horizonte (prancha)", tipo = "Artefato", perfil = "PranchaHorizonte", requisito = "Espada do Horizonte no estágio 2" },
		{ id = "PlataformaFirmamento", nome = "Escudo do Firmamento (plataforma)", tipo = "Artefato", perfil = "PlataformaFirmamento", requisito = "Escudo do Firmamento no estágio 2" },
		{ id = "VassouraVentos", nome = "Cajado dos Ventos (vassoura)", tipo = "Artefato", perfil = "VassouraVentos", requisito = "Cajado dos Ventos Antigos no estágio 2" },
		{ id = "Montaria", nome = "Montaria", tipo = "Montaria", perfil = nil, requisito = "Criatura adulta de espécie montável" },
	},
	-- só estes podem ser o "preferido" da tecla de voo (os de artefato usam a tecla de forma; montaria, a de montar)
	preferiveis = { AsasNaturais = true, VooMagico = true, PranchaComum = true },
}
