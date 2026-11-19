--!strict
-- NÃO EXECUTADO. Artefato metamórfico: ESCUDO DO FIRMAMENTO (Druida). Só dados.
-- Forma de defesa e forma de plataforma flutuante (abismos pequenos, deslocamentos curtos e lentos).

return {
	id = "EscudoDoFirmamento",
	nome = "Escudo do Firmamento",
	raridade = "Druida",
	formaInicial = "Escudo",
	formas = {
		Escudo = {
			tipo = "Defesa", estagioMin = 1, efeito = "CascaDeRaiz",
			-- (Etapa D) defesa: redução extra de 10% e janela de aparar +0,04 s enquanto equipado
			atributos = { reducaoDefesaExtra = 0.10, janelaAparExtra = 0.04 },
		},
		Plataforma = {
			tipo = "Locomocao", perfil = "PlataformaFirmamento", estagioMin = 2, efeito = "DiscoDeFolhas",
			montagem = { "DeitarEscudo", "BrotarRaizes", "AbrirFolhas", "Flutuar" },
		},
	},
	transformacao = { duracao = 0.7, recarga = 3.0, custoEnergia = 6, golpeCancelaAcima = 10 },
	retornoAoCombate = { alturaLivre = 3, velQueda = 12, duracaoMax = 2.0 },
	estagios = {
		{ n = 1, descricao = "Escudo.", requisitos = {} },
		{ n = 2, descricao = "Plataforma liberada no Santuário.", requisitos = { missoes = { "RaizesNoCeu" } } },
		{ n = 3, descricao = "Plataforma 30% mais duradoura.", requisitos = { materiais = { SementeFlutuante = 5, CascaAntiga = 4 } }, bonus = { perfil = "PlataformaFirmamento", mods = { { campo = "custoPorSeg", multiplicar = 0.7 } } } },
	},
}
