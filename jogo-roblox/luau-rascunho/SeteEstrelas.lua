--!strict
-- RASCUNHO, NÃO TESTADO NO STUDIO (o Studio não estava conectado quando isto foi escrito).
-- Lugar sugerido: ReplicatedStorage.Magnata.Dados.SeteEstrelas (ModuleScript compartilhado).
-- Dados do símbolo da Constelação das Sete Estrelas: o mesmo símbolo do Axolote Nebular,
-- para ser reaproveitado em ruínas, templos, portais, artefatos e livros.

export type Estrela = { id: string, mundo: string, cor: Color3, x: number, y: number }

local SeteEstrelas = {}

SeteEstrelas.ID_DESCOBERTA = "constelacao_sete_estrelas"

-- Posições normalizadas (raio 1): dois triângulos de raios diferentes em volta da Sétima Estrela.
local function ponto(k: number, raio: number): (number, number)
	local a = math.pi / 2 + k * math.pi / 3
	return math.cos(a) * raio, math.sin(a) * raio
end

local dados = {
	{ "tempestades", "Ilha das Tempestades", Color3.fromHex("3B82F6"), 0, 1.0 },
	{ "bolhas", "Campo das Bolhas", Color3.fromHex("2DD4BF"), 1, 0.8 },
	{ "vulcoes", "Ilha dos Vulcões", Color3.fromHex("EF4444"), 2, 1.0 },
	{ "congelada", "Cidade Congelada", Color3.fromHex("BAE6FD"), 3, 0.8 },
	{ "gigante", "Costas do Gigante", Color3.fromHex("F5C76B"), 4, 1.0 },
	{ "achados", "Achados e Perdidos", Color3.fromHex("A855F7"), 5, 0.8 },
}

SeteEstrelas.estrelas = {} :: { Estrela }
for _, d in dados do
	local x, y = ponto(d[4], d[5])
	table.insert(SeteEstrelas.estrelas, { id = d[1], mundo = d[2], cor = d[3], x = x, y = y })
end
-- A sétima estrela fica no centro. A origem dela é um mistério de propósito: nada aqui a explica.
table.insert(SeteEstrelas.estrelas, { id = "setima", mundo = "?", cor = Color3.fromHex("FFF4D6"), x = 0, y = 0 })

-- Linhas: dois triângulos (1-3-5 e 2-4-6) e raios até o centro (7).
SeteEstrelas.linhas = { { 1, 3 }, { 3, 5 }, { 5, 1 }, { 2, 4 }, { 4, 6 }, { 6, 2 } }
SeteEstrelas.raios = { { 7, 1 }, { 7, 2 }, { 7, 3 }, { 7, 4 }, { 7, 5 }, { 7, 6 } }

SeteEstrelas.diario = {
	titulo = "A Constelação das Sete Estrelas",
	texto = "Seis estrelas cercam uma sétima. Cada uma parece representar um mundo conhecido, mas a estrela central permanece um mistério. Por que o Guardião das Constelações conhece esse símbolo?",
}

return SeteEstrelas
