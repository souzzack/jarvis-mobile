--!strict
-- NÃO EXECUTADO. REGISTRO DE SEGREDOS (SÓ SERVIDOR): marcas no mapa, capacidades investigativas, recompensas,
-- registros de lore, conhecimentos e receitas secretas. Ids estáveis (ficam salvos).

local INV = "OSegredoDoPrimeiroArquivista"

return {
	-- sal secreto da semente (ordens por jogador). Diferente do sal do segredo do Ato 1 de propósito.
	sal = "Arquivistas*Atlas-antes-da-Fratura#1",

	-- Parts com o atributo "GuardioesMisterio" = id da marca (pasta workspace.GuardioesMisterios)
	marcas = {
		MarcaInscricao = { tipo = "pista", investigacao = INV, pista = "InscricaoDoObservatorio", acao = "Ler" },
		MarcaSimbolo = { tipo = "pista", investigacao = INV, pista = "SimboloOculto", acao = "Examinar" },
		MarcaDiario = { tipo = "pista", investigacao = INV, pista = "DiarioDeCampo", acao = "Ler" },
		MarcoPedra = { tipo = "enigma", puzzle = "OSinal", elemento = "Pedra", acao = "Tocar" },
		MarcoCobre = { tipo = "enigma", puzzle = "OSinal", elemento = "Cobre", acao = "Tocar" },
		MarcoCristal = { tipo = "enigma", puzzle = "OSinal", elemento = "Cristal", acao = "Tocar" },
		PortaSemMoldura = { tipo = "portal", portal = "PortaDaBiblioteca", acao = "Examinar" },
	},

	-- HABILIDADES INVESTIGATIVAS (seção 9): interface única; cada uma tem VÁRIAS fontes, para nenhuma espécie,
	-- raça ou companhia ser obrigatória (seção 13). fontes.companheiro = habilidade da criatura ATIVA e perto;
	-- livros = livro lido; equipamentos = item equipado (por id).
	capacidades = {
		PercepcaoEnergetica = {
			nome = "Percepção energética", alcance = 16, recarga = 0, animacao = "ReagirAEnergia", efeito = "BrilhoArcanoFraco",
			fontes = { companheiro = { "FaroDeCristal", "TrilhaEscondida" }, livros = { "GrimorioDosCeus" }, equipamentos = { "AmuletoEspectral" } },
		},
		FaroAncestral = {
			nome = "Faro ancestral", alcance = 14, recarga = 0, animacao = "Farejar", efeito = "RastroDourado",
			fontes = { companheiro = { "FarejarMaterial", "CavarTesouro" }, livros = { "TomoDasCorrentesAstrais" } },
		},
		VisaoArcana = {
			nome = "Visão arcana", alcance = 20, recarga = 0, animacao = "OlharFixo", efeito = "VeuArcano",
			fontes = { livros = { "GrimorioDosCeus" }, equipamentos = { "AmuletoEspectral", "LascaDaSetimaEstrela" } },
		},
		RessonanciaDimensional = {
			nome = "Ressonância dimensional", alcance = 12, recarga = 0, animacao = "Vibrar", efeito = "OndaDimensional",
			fontes = { companheiro = { "ContemplacaoCeleste" }, equipamentos = { "LascaDaSetimaEstrela" }, livros = { "CodiceDaLeveza" } },
		},
		LigacaoNatural = {
			nome = "Ligação natural", alcance = 16, recarga = 0, animacao = "Escutar", efeito = "FolhasGirando",
			fontes = { companheiro = { "SentirCorrente", "Sopro" }, livros = { "CodiceDaLeveza" } },
		},
	},

	-- RECOMPENSAS: concedidas UMA vez (perfil.misterios.recompensas) numa transação só (SecretRewardService)
	recompensas = {
		RecCap1_OSinal = {
			materiais = { FolhaDeRegistro = 1 },
			registros = { "Arq01_OSinal" },
			conhecimentos = { "LeituraDeSinais" },
			receitas = { "TintaDoArquivista" },
			xp = 150,
		},
	},

	-- REGISTROS (lore). categoria: RegistroAntigo | ConhecimentoProibido | FragmentoDesconhecido (docs/lore)
	registros = {
		Arq01_OSinal = {
			titulo = "Registro do Arquivista A. (fragmento 1)", categoria = "RegistroAntigo",
			texto = "\"Os marcos ainda respondem. A ilha guarda a voz do Atlas como uma concha guarda o mar. Os outros acham que é superstição. Vou anotar tudo, para o caso de eu não voltar.\"",
		},
	},
	conhecimentos = {
		LeituraDeSinais = { nome = "Leitura de sinais", texto = "Você aprendeu a reconhecer os sinais que os Arquivistas deixavam em pedra." },
	},

	-- RECEITAS SECRETAS: só fabricáveis se estiverem em perfil.misterios.receitas (ArtifactResearchService)
	receitas = {
		TintaDoArquivista = {
			id = "TintaDoArquivista", nome = "Tinta do Arquivista (teste)", teste = true,
			estacao = "Bancada", estacaoNivel = 1,
			materiais = { FolhaDeRegistro = 1, CascaAntiga = 2 },
			resultado = { tipo = "material", id = "TintaDoArquivista", qtd = 1 },
		},
	},

	-- PESQUISAS (as 7 etapas da seção 11). A de teste usa só o capítulo 1.
	pesquisas = {
		PesquisaTinta = {
			nome = "Tinta do Arquivista (teste)",
			etapas = {
				{ nome = "Uma pista", condicao = { pista = "InscricaoDoObservatorio" } },
				{ nome = "A origem", condicao = { capitulo = INV .. "#1" } },
				{ nome = "O enigma", condicao = { enigma = "OSinal" } },
				{ nome = "A receita", condicao = { receita = "TintaDoArquivista" } },
				{ nome = "Os componentes", condicao = { materiais = { FolhaDeRegistro = 1, CascaAntiga = 2 } } },
				{ nome = "A fabricação", condicao = { fabricado = "TintaDoArquivista" } },
				{ nome = "Além da tinta", condicao = { evolucao = "TintaRevelada" } }, -- etapa 7: futura
			},
		},
	},
}
