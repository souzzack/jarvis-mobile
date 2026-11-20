--!strict
-- NÃO EXECUTADO. DIMENSÕES OCULTAS E PASSAGENS SECRETAS (SÓ SERVIDOR). Seções 7 e 8.
-- placeId = 0 em todas (nenhuma tem place próprio). A Biblioteca do Vazio já existe como ÁREA deste place
-- (noPlace = true; chegada = Part com GuardioesChegadaDimensao = "BibliotecaDoVazio" em workspace.GuardioesViagem).
-- As outras 3 são CONCEITOS: o portal pode ser descoberto, mas a viagem responde "em construção".

return {
	dimensoes = {
		BibliotecaDoVazio = {
			id = "BibliotecaDoVazio", nome = "Biblioteca do Vazio", hub = false, placeId = 0, noPlace = true, ordemDeConstrucao = 1,
			identidade = "Arquitetura monumental, livros flutuantes, portais instáveis; enigmas de conhecimento. Registros dos Arquivistas e uma das primeiras receitas ???.",
			mecanica = "Estantes que se reorganizam pela leitura; sequências e traduções; coleta de páginas entre salas.",
		},
		ReinoDosReflexos = {
			id = "ReinoDosReflexos", nome = "Reino dos Reflexos", hub = false, placeId = 0, ordemDeConstrucao = 2,
			identidade = "Arquitetura espelhada, ilusões e caminhos que só existem no reflexo.",
			mecanica = "Alinhamento de espelhos; portais que dependem de observar o reflexo, não o objeto.",
		},
		JardimEsquecido = {
			id = "JardimEsquecido", nome = "Jardim Esquecido", hub = false, placeId = 0, ordemDeConstrucao = 3,
			identidade = "Vegetação fantástica, criaturas raras e santuários ligados à origem de algumas espécies.",
			mecanica = "Enigmas de vínculo (capacidades das criaturas), afinidade dimensional e ressonância.",
		},
		OIntervalo = {
			id = "OIntervalo", nome = "O Intervalo", hub = false, placeId = 0, ordemDeConstrucao = 4,
			identidade = "Plataformas suspensas e construções partidas pela instabilidade temporal da Fratura.",
			mecanica = "Mecanismos temporais (estados que voltam), travessias aéreas e enigmas interdimensionais.",
		},
	},
	portais = {
		PortaDaBiblioteca = {
			id = "PortaDaBiblioteca", nome = "Porta sem moldura",
			origem = "IlhaDasTempestades", destino = "BibliotecaDoVazio",
			descoberta = "PortaSemMoldura", -- marca que, examinada, registra a descoberta
			-- condições para ABRIR: a mensagem de A. (capítulo 5) diz que a porta "vai te reconhecer". O capítulo 6
			-- acontece DENTRO da Biblioteca, então não pode ser requisito para entrar nela.
			condicoes = { capitulos = { "OSegredoDoPrimeiroArquivista#5" } },
			grupo = { min = 1, max = 4 }, -- a companhia pode ir junto (cada um precisa do portal aberto)
			retorno = "origem", -- volta sempre para onde entrou
		},
	},
}
