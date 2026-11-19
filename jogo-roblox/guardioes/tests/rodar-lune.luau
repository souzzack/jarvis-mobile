-- NÃO EXECUTADO (o Lune não pôde ser instalado nesta sessão). Rodar os testes fora do Studio com o Lune:
--   cd jogo-roblox/guardioes && lune run tests/rodar-lune.luau
-- Os módulos testados são de LÓGICA PURA (sem API do Roblox), por isso rodam no Lune.
-- Caminhos literais de propósito (o require por string do Luau pede literais).

local Rodar = require("./Rodar")

local M = {
	MaquinaDeCombo = require("../src/ReplicatedStorage/Guardioes/Combate/MaquinaDeCombo"),
	Dano = require("../src/ReplicatedStorage/Guardioes/Combate/Dano"),
	Estamina = require("../src/ReplicatedStorage/Guardioes/Combate/Estamina"),
	Postura = require("../src/ReplicatedStorage/Guardioes/Combate/Postura"),
	Alcance = require("../src/ReplicatedStorage/Guardioes/Combate/Alcance"),
	LimiteDeTaxa = require("../src/ReplicatedStorage/Guardioes/Util/LimiteDeTaxa"),
	Raridades = require("../src/ReplicatedStorage/Guardioes/Config/Raridades"),
	CfgCombate = require("../src/ReplicatedStorage/Guardioes/Config/Combate"),
	Espada = require("../src/ReplicatedStorage/Guardioes/Config/Armas/Espada"),
}

local specs = {
	{ nome = "Alcance.spec", fn = require("./Specs/Alcance.spec") },
	{ nome = "Dano.spec", fn = require("./Specs/Dano.spec") },
	{ nome = "Estamina.spec", fn = require("./Specs/Estamina.spec") },
	{ nome = "LimiteDeTaxa.spec", fn = require("./Specs/LimiteDeTaxa.spec") },
	{ nome = "MaquinaDeCombo.spec", fn = require("./Specs/MaquinaDeCombo.spec") },
	{ nome = "Postura.spec", fn = require("./Specs/Postura.spec") },
	{ nome = "Raridades.spec", fn = require("./Specs/Raridades.spec") },
}

local _, falhou = Rodar(M, specs)
if falhou > 0 then
	error("há testes falhando")
end
