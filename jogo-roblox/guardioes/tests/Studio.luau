--!strict
-- NÃO EXECUTADO. Rodar os testes no Roblox Studio (com o Rojo sincronizado, fica em ServerStorage.GuardioesTestes).
-- Na barra de comandos do Studio (modo Edit ou Run):
--   require(game.ServerStorage.GuardioesTestes.Studio)()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rodar = require(script.Parent.Rodar)

return function()
	local G = ReplicatedStorage:WaitForChild("Guardioes")
	local M = {
		MaquinaDeCombo = require(G.Combate.MaquinaDeCombo),
		Dano = require(G.Combate.Dano),
		Estamina = require(G.Combate.Estamina),
		Postura = require(G.Combate.Postura),
		Alcance = require(G.Combate.Alcance),
		LimiteDeTaxa = require(G.Util.LimiteDeTaxa),
		Raridades = require(G.Config.Raridades),
		CfgCombate = require(G.Config.Combate),
		Espada = require(G.Config.Armas.Espada),
		-- locomoção, artefatos e companheiros (complemento)
		MaquinaDeLocomocao = require(G.Locomocao.MaquinaDeLocomocao),
		FisicaDeVoo = require(G.Locomocao.FisicaDeVoo),
		PerfilEfetivo = require(G.Locomocao.PerfilEfetivo),
		Validador = require(G.Locomocao.ValidadorDeDeslocamento),
		Perfis = require(G.Config.Locomocao.Perfis),
		Habilidades = require(G.Config.Locomocao.Habilidades),
		MaquinaDeArtefato = require(G.Artefatos.MaquinaDeArtefato),
		ProgressaoDeArtefato = require(G.Artefatos.ProgressaoDeArtefato),
		ArtefatoEspadaDoHorizonte = require(G.Config.Artefatos.EspadaDoHorizonte),
		DadosDaCriatura = require(G.Companheiros.DadosDaCriatura),
		Crescimento = require(G.Companheiros.Crescimento),
		VinculoDimensional = require(G.Companheiros.VinculoDimensional),
		Afinidades = require(G.Config.AfinidadesDimensionais),
		Especies = {
			CaoTrovao = require(G.Config.Especies.CaoTrovao),
			AxoloteNebular = require(G.Config.Especies.AxoloteNebular),
			RaiaDasNuvens = require(G.Config.Especies.RaiaDasNuvens),
			LebreDeFaisca = require(G.Config.Especies.LebreDeFaisca),
		},
		-- etapas 6 a 9 (servidor: Studio roda a barra de comandos no contexto do servidor)
		IADoCompanheiro = require(G.Companheiros.IADoCompanheiro),
		Requisitos = require(G.Util.Requisitos),
		LivrosSecretos = require(game:GetService("ServerScriptService").Guardioes.ConfigSecreta.Livros),
		Perfil = require(game:GetService("ServerScriptService").Guardioes.Dados.Perfil),
		TravaDeSessao = require(game:GetService("ServerScriptService").Guardioes.Dados.TravaDeSessao),
		-- inventário, saque, missões, nível
		Bolsa = require(G.Inventario.Bolsa),
		Saque = require(G.Loot.Saque),
		Missao = require(G.Missoes.Missao),
		Missoes = require(G.Config.Missoes),
		Nivel = require(G.Progressao.Nivel),
		-- fabricação, restauração, chefe
		Receita = require(G.Fabricacao.Receita),
		Receitas = require(G.Config.Receitas),
		Restauracao = require(G.Restauracao.Restauracao),
		Restauracoes = require(G.Config.Restauracoes),
		CargaDaRainha = require(G.Chefes.CargaDaRainha),
		-- base pessoal, viagem, Alfa
		Base = require(G.Base.Base),
		CfgBase = require(G.Config.Base),
		Viagem = require(G.Viagem.Viagem),
		MatilhaDoAlfa = require(G.Chefes.MatilhaDoAlfa),
		-- especiais
		Especial = require(G.Combate.Especial),
		Especiais = require(G.Config.Especiais),
		Tormenta = require(G.Chefes.Tormenta),
		Colosso = require(G.Chefes.Colosso),
		Espectro = require(G.Chefes.Espectro),
	}
	local specs = {}
	for _, m in script.Parent.Specs:GetChildren() do
		if m:IsA("ModuleScript") then
			table.insert(specs, { nome = m.Name, fn = require(m) :: any })
		end
	end
	table.sort(specs, function(a, b)
		return a.nome < b.nome
	end)
	return Rodar(M, specs)
end
