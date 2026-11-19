--!strict
-- NÃO EXECUTADO. VÍNCULO DIMENSIONAL — afinidades que uma criatura pode desenvolver. Só dados.
-- Uma afinidade NOVA é só uma entrada nova aqui (nenhuma mudança em Companheiros/VinculoDimensional).
-- Pontos vêm de OBJETIVOS (cada um conta uma vez por criatura), nunca de tempo parado numa região.
-- A especialização exige criatura adulta e pontos >= limiar; trocar exige o ritual de realinhamento (reversível).

export type Objetivo = { id: string, pontos: number, descricao: string }
export type Afinidade = {
	id: string,
	nome: string,
	dimensao: string,
	limiar: number,
	objetivos: { Objetivo },
	habilidades: { string }, -- liberadas na especialização (variante da espécie, não outra espécie)
	visual: string, -- detalhe de aparência que se soma ao modelo da espécie (a criatura continua reconhecível)
	disponivel: boolean,
}

local lista: { Afinidade } = {
	{
		id = "Tempestade", nome = "Afinidade da Tempestade", dimensao = "IlhaDasTempestades", limiar = 100,
		objetivos = {
			{ id = "TempSobreviverTormenta", pontos = 25, descricao = "Atravessar a Planície durante uma tormenta com a criatura." },
			{ id = "TempCarregarBobinas", pontos = 25, descricao = "Ajudar a religar 3 bobinas da Torre." },
			{ id = "TempDerrotarRainha", pontos = 30, descricao = "Vencer a Rainha-Bobina com a criatura participando." },
			{ id = "TempRaioNoSantuario", pontos = 20, descricao = "Receber um raio no altar do Santuário (evento de chuva)." },
		},
		habilidades = { "ImpulsoEnergetico", "ResistenciaTempestade" },
		visual = "Veios azuis elétricos que pulsam com o vento",
		disponivel = true,
	},
	{
		id = "Bolhas", nome = "Afinidade das Bolhas", dimensao = "CampoDasBolhas", limiar = 100,
		objetivos = {
			{ id = "BolSubirCorrentes", pontos = 35, descricao = "Subir as correntes até a bolha mais alta." },
			{ id = "BolProtegerGerador", pontos = 35, descricao = "Proteger o gerador de bolhas durante o evento." },
			{ id = "BolFlutuarJunto", pontos = 30, descricao = "Completar o percurso flutuante sem tocar o chão." },
		},
		habilidades = { "EscudoDeBolha", "FlutuacaoTemporaria" },
		visual = "Brilho iridescente e pequenas bolhas que sobem do corpo",
		disponivel = false, -- dimensão ainda não liberada (Campo das Bolhas congelado)
	},
	{
		id = "Vulcao", nome = "Afinidade Vulcânica", dimensao = "IlhaDosVulcoes", limiar = 100,
		objetivos = {}, habilidades = { "ResistenciaCalor", "PassoDeBrasa" },
		visual = "Fissuras alaranjadas na pele, como rocha esfriando", disponivel = false,
	},
	{
		id = "Gelo", nome = "Afinidade do Gelo", dimensao = "CidadeCongelada", limiar = 100,
		objetivos = {}, habilidades = { "ResistenciaFrio", "SoproLento" },
		visual = "Pontas cristalizadas e hálito frio visível", disponivel = false,
	},
}

local porId: { [string]: Afinidade } = {}
local objetivoParaAfinidade: { [string]: string } = {}
for _, a in lista do
	porId[a.id] = a
	for _, o in a.objetivos do
		objetivoParaAfinidade[o.id] = a.id
	end
end

return { lista = lista, porId = porId, objetivoParaAfinidade = objetivoParaAfinidade }
