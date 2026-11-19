--!strict
-- NÃO EXECUTADO. Livros mágicos — parte PÚBLICA (o que a interface pode mostrar). Só dados.
-- Requisitos ocultos e a solução de enigmas ficam no servidor: ServerScriptService/Guardioes/ConfigSecreta/Livros.luau.
-- Posições são PLANO: nenhum mapa foi alterado. 'local' cita estruturas já previstas no GDD.

export type Livro = {
	id: string,
	nome: string,
	ensina: string, -- id da habilidade (Config/Locomocao/Habilidades)
	dimensao: string,
	localPlanejado: string,
	missao: string,
	enigma: string, -- resumo público (sem a solução)
	requisitoPublico: string, -- o que a interface diz quando falta algo
	oculto: boolean,
}

local lista: { Livro } = {
	{
		id = "GrimorioDosCeus", nome = "Grimório dos Céus", ensina = "VooMagico",
		dimensao = "IlhaDasTempestades",
		localPlanejado = "Biblioteca do Observatório (sala de mapas estelares, depois da restauração do telescópio)",
		missao = "AsAnotacoesDoAstronomo",
		enigma = "Alinhar as lentes do telescópio na ordem das constelações descritas nas anotações.",
		requisitoPublico = "Restaure o Observatório e decifre as anotações do astrônomo.",
		oculto = false,
	},
	{
		id = "TomoDasCorrentesAstrais", nome = "Tomo das Correntes Astrais", ensina = "CorrentesAstrais",
		dimensao = "IlhaDasTempestades",
		localPlanejado = "Topo da Torre Meteorológica, numa estante que só aparece com a energia religada",
		missao = "OsVentosDaTorre",
		enigma = "Atravessar os anéis de vento da torre em voo, sem tocar o chão, antes da tempestade virar.",
		requisitoPublico = "Aprenda o voo mágico e religue a Torre Meteorológica.",
		oculto = false,
	},
	{
		id = "CodiceDaLeveza", nome = "Códice da Leveza", ensina = "Leveza",
		dimensao = "CampoDasBolhas",
		localPlanejado = "PLANO para a expansão do Campo das Bolhas (arquivos dele não foram tocados)",
		missao = "OPesoDasBolhas",
		enigma = "Subir até a bolha mais alta usando só correntes de ar, gastando pouca energia.",
		requisitoPublico = "Disponível quando o Campo das Bolhas for liberado.",
		oculto = false,
	},
	{
		id = "ManuscritoSemNome", nome = "Manuscrito Sem Nome", ensina = "?",
		dimensao = "?",
		localPlanejado = "?",
		missao = "?",
		enigma = "?",
		requisitoPublico = "Há algo escrito nas margens de outros livros…",
		oculto = true,
	},
}

local porId: { [string]: Livro } = {}
for _, l in lista do
	porId[l.id] = l
end

return { lista = lista, porId = porId }
