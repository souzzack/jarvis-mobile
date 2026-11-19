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
	-- locomoção, artefatos e companheiros (complemento)
	MaquinaDeLocomocao = require("../src/ReplicatedStorage/Guardioes/Locomocao/MaquinaDeLocomocao"),
	FisicaDeVoo = require("../src/ReplicatedStorage/Guardioes/Locomocao/FisicaDeVoo"),
	PerfilEfetivo = require("../src/ReplicatedStorage/Guardioes/Locomocao/PerfilEfetivo"),
	Validador = require("../src/ReplicatedStorage/Guardioes/Locomocao/ValidadorDeDeslocamento"),
	Perfis = require("../src/ReplicatedStorage/Guardioes/Config/Locomocao/Perfis"),
	Habilidades = require("../src/ReplicatedStorage/Guardioes/Config/Locomocao/Habilidades"),
	MaquinaDeArtefato = require("../src/ReplicatedStorage/Guardioes/Artefatos/MaquinaDeArtefato"),
	ProgressaoDeArtefato = require("../src/ReplicatedStorage/Guardioes/Artefatos/ProgressaoDeArtefato"),
	ArtefatoEspadaDoHorizonte = require("../src/ReplicatedStorage/Guardioes/Config/Artefatos/EspadaDoHorizonte"),
	DadosDaCriatura = require("../src/ReplicatedStorage/Guardioes/Companheiros/DadosDaCriatura"),
	Crescimento = require("../src/ReplicatedStorage/Guardioes/Companheiros/Crescimento"),
	VinculoDimensional = require("../src/ReplicatedStorage/Guardioes/Companheiros/VinculoDimensional"),
	Afinidades = require("../src/ReplicatedStorage/Guardioes/Config/AfinidadesDimensionais"),
	Especies = {
		CaoTrovao = require("../src/ReplicatedStorage/Guardioes/Config/Especies/CaoTrovao"),
		AxoloteNebular = require("../src/ReplicatedStorage/Guardioes/Config/Especies/AxoloteNebular"),
		RaiaDasNuvens = require("../src/ReplicatedStorage/Guardioes/Config/Especies/RaiaDasNuvens"),
		LebreDeFaisca = require("../src/ReplicatedStorage/Guardioes/Config/Especies/LebreDeFaisca"),
	},
	-- etapas 6 a 9
	IADoCompanheiro = require("../src/ReplicatedStorage/Guardioes/Companheiros/IADoCompanheiro"),
	Requisitos = require("../src/ReplicatedStorage/Guardioes/Util/Requisitos"),
	LivrosSecretos = require("../src/ServerScriptService/Guardioes/ConfigSecreta/Livros"),
	Perfil = require("../src/ServerScriptService/Guardioes/Dados/Perfil"),
	TravaDeSessao = require("../src/ServerScriptService/Guardioes/Dados/TravaDeSessao"),
	-- inventário, saque, missões, nível
	Bolsa = require("../src/ReplicatedStorage/Guardioes/Inventario/Bolsa"),
	Saque = require("../src/ReplicatedStorage/Guardioes/Loot/Saque"),
	Missao = require("../src/ReplicatedStorage/Guardioes/Missoes/Missao"),
	Missoes = require("../src/ReplicatedStorage/Guardioes/Config/Missoes"),
	Nivel = require("../src/ReplicatedStorage/Guardioes/Progressao/Nivel"),
	-- fabricação, restauração, chefe
	Receita = require("../src/ReplicatedStorage/Guardioes/Fabricacao/Receita"),
	Receitas = require("../src/ReplicatedStorage/Guardioes/Config/Receitas"),
	Restauracao = require("../src/ReplicatedStorage/Guardioes/Restauracao/Restauracao"),
	Restauracoes = require("../src/ReplicatedStorage/Guardioes/Config/Restauracoes"),
	CargaDaRainha = require("../src/ReplicatedStorage/Guardioes/Chefes/CargaDaRainha"),
	-- base pessoal, viagem, Alfa
	Base = require("../src/ReplicatedStorage/Guardioes/Base/Base"),
	CfgBase = require("../src/ReplicatedStorage/Guardioes/Config/Base"),
	Viagem = require("../src/ReplicatedStorage/Guardioes/Viagem/Viagem"),
	MatilhaDoAlfa = require("../src/ReplicatedStorage/Guardioes/Chefes/MatilhaDoAlfa"),
}

local specs = {
	{ nome = "Alcance.spec", fn = require("./Specs/Alcance.spec") },
	{ nome = "Dano.spec", fn = require("./Specs/Dano.spec") },
	{ nome = "Estamina.spec", fn = require("./Specs/Estamina.spec") },
	{ nome = "LimiteDeTaxa.spec", fn = require("./Specs/LimiteDeTaxa.spec") },
	{ nome = "MaquinaDeCombo.spec", fn = require("./Specs/MaquinaDeCombo.spec") },
	{ nome = "Postura.spec", fn = require("./Specs/Postura.spec") },
	{ nome = "Raridades.spec", fn = require("./Specs/Raridades.spec") },
	{ nome = "Artefatos.spec", fn = require("./Specs/Artefatos.spec") },
	{ nome = "Companheiros.spec", fn = require("./Specs/Companheiros.spec") },
	{ nome = "FisicaDeVoo.spec", fn = require("./Specs/FisicaDeVoo.spec") },
	{ nome = "MaquinaDeLocomocao.spec", fn = require("./Specs/MaquinaDeLocomocao.spec") },
	{ nome = "PerfilEfetivo.spec", fn = require("./Specs/PerfilEfetivo.spec") },
	{ nome = "ValidadorDeDeslocamento.spec", fn = require("./Specs/ValidadorDeDeslocamento.spec") },
	{ nome = "IADoCompanheiro.spec", fn = require("./Specs/IADoCompanheiro.spec") },
	{ nome = "PerfilSalvo.spec", fn = require("./Specs/PerfilSalvo.spec") },
	{ nome = "Requisitos.spec", fn = require("./Specs/Requisitos.spec") },
	{ nome = "Inventario.spec", fn = require("./Specs/Inventario.spec") },
	{ nome = "FabricacaoRestauracaoChefe.spec", fn = require("./Specs/FabricacaoRestauracaoChefe.spec") },
	{ nome = "BaseViagemAlfa.spec", fn = require("./Specs/BaseViagemAlfa.spec") },
}

local _, falhou = Rodar(M, specs)
if falhou > 0 then
	error("há testes falhando")
end
