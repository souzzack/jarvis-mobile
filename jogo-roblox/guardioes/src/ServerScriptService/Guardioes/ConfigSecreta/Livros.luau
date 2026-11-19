--!strict
-- NÃO EXECUTADO. Requisitos de leitura dos livros (SERVIDOR). A parte pública está em Config/LivrosMagicos.
-- O MagicBookSystem (Etapa 9) confere estes requisitos antes de conceder a habilidade, e o progresso fica salvo
-- no perfil (habilidades + livrosLidos): ninguém precisa achar o mesmo livro de novo depois de reentrar.

return {
	GrimorioDosCeus = {
		requisitos = { restauracoes = { "Observatorio" }, missoes = { "AsAnotacoesDoAstronomo" }, enigma = "LentesNaOrdem" },
		concede = { "VooMagico" },
	},
	TomoDasCorrentesAstrais = {
		requisitos = { habilidades = { "VooMagico" }, restauracoes = { "TorreMeteorologica" }, missoes = { "OsVentosDaTorre" } },
		concede = { "CorrentesAstrais" },
	},
	CodiceDaLeveza = {
		requisitos = { dimensoes = { "CampoDasBolhas" }, missoes = { "OPesoDasBolhas" } },
		concede = { "Leveza" },
	},
	ManuscritoSemNome = {
		-- encadeado: anotações nas margens dos três outros livros + Contemplação Celestial (GDD, segredo do Ato 1)
		requisitos = { livros = { "GrimorioDosCeus", "TomoDasCorrentesAstrais", "CodiceDaLeveza" }, segredos = { "MargensDosLivros", "SeteEstrelasSobChuva" } },
		concede = {}, -- revela a primeira parte da receita do Arco das Asas Perdidas (SecretDiscoverySystem)
		revela = { "ReceitaArcoDasAsas_Parte1" },
	},
}
