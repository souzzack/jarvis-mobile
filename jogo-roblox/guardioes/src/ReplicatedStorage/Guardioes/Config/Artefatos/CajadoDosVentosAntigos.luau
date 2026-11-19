--!strict
-- NÃO EXECUTADO. Artefato metamórfico: CAJADO DOS VENTOS ANTIGOS (Arcano). Só dados.
-- Forma de combate (correntes de vento, estilo Arcanista — arma planejada para a Etapa D) e forma de voo
-- (veículo mágico, como uma vassoura encantada): mais ágil que a prancha, um pouco mais lento em linha reta.

return {
	id = "CajadoDosVentosAntigos",
	nome = "Cajado dos Ventos Antigos",
	raridade = "Arcano",
	formaInicial = "Cajado",
	formas = {
		Cajado = { tipo = "Combate", arma = "CajadoDosVentos", estagioMin = 1, efeito = "Redemoinho" },
		Vassoura = {
			tipo = "Locomocao", perfil = "VassouraVentos", estagioMin = 2, efeito = "RastroDeVento",
			montagem = { "GirarCajado", "DeitarHorizontal", "AbrirCerdasDeVento", "Assento" },
		},
	},
	transformacao = { duracao = 0.5, recarga = 1.5, custoEnergia = 8, golpeCancelaAcima = 12 },
	retornoAoCombate = { alturaLivre = 6, velQueda = 12, duracaoMax = 3.0 },
	estagios = {
		{ n = 1, descricao = "Cajado (Arcanista).", requisitos = {} },
		{ n = 2, descricao = "Forma de voo.", requisitos = { missoes = { "OSoproDosAntigos" } } },
		{ n = 3, descricao = "Curvas mais fechadas e subida mais rápida.", requisitos = { materiais = { EssenciaDeVento = 6, LigaArcana = 2 } }, bonus = { perfil = "VassouraVentos", mods = { { campo = "velVerticalMax", somar = 4 }, { campo = "inclinacaoMax", somar = 6 } } } },
	},
}
