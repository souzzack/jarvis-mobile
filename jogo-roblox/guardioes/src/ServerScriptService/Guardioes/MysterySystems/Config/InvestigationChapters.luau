--!strict
-- NÃO EXECUTADO. INVESTIGAÇÕES E CAPÍTULOS (SÓ SERVIDOR). Mistérios, complemento 03, seções 4 e 12.
-- Ids são ESTÁVEIS (ficam salvos no perfil): nunca renomear; para mudar conteúdo, subir versaoConteudo.
-- Só capítulos com lancado = true aceitam progresso. Textos de pista podem ter {1} {2} {3}: o servidor
-- preenche com a ORDEM DO JOGADOR (semente), então copiar a resposta de outra pessoa não funciona.
-- categoria: A ambiental · B arcano · C criaturas · D dimensões ocultas · E supremo ???

return {
	OSegredoDoPrimeiroArquivista = {
		nome = "O Segredo do Primeiro Arquivista",
		descricao = "Alguém estudou a Ilha das Tempestades muito antes da Fratura, e deixou sinais para quem soubesse procurar.",
		dimensao = "IlhaDasTempestades",
		categoria = "E",
		versaoConteudo = 1,
		requer = {}, -- outras investigações que precisam estar concluídas antes
		descobertaPor = "InscricaoDoObservatorio",
		capitulos = {
			{
				n = 1, nome = "O Sinal do Observatório", lancado = true,
				pistas = {
					InscricaoDoObservatorio = {
						ordem = 1, nome = "Inscrição no Observatório", descobre = true, categoria = "A",
						texto = "Letras miúdas na pedra: \"Quem quiser ouvir o Atlas, comece pelo marco de {1}.\"",
					},
					SimboloOculto = {
						ordem = 2, nome = "Símbolo que só aparece para quem sente energia", categoria = "C",
						capacidade = "PercepcaoEnergetica", -- criatura, livro ou equipamento (ver Secrets.capacidades)
						texto = "Duas linhas de luz fraca cruzam a parede e apontam para o marco de {2}.",
					},
					DiarioDeCampo = {
						ordem = 3, nome = "Folha de um diário de campo", categoria = "A",
						texto = "\"…e o último, sempre o de {3}. Se o sinal responder, não estou louco.\" — assinado: A., Arquivista.",
					},
				},
				objetivos = {
					{ id = "ReunirPistas", nome = "Reunir as três pistas do sinal", tipo = "pistas", pistas = { "InscricaoDoObservatorio", "SimboloOculto", "DiarioDeCampo" } },
					{ id = "OSinal", nome = "Ativar os três marcos na ordem certa", tipo = "enigma", puzzle = "OSinal", visivelApos = "ReunirPistas" },
				},
				recompensa = "RecCap1_OSinal",
			},
			{
				-- uma criatura pacífica (o Vigia de Cristal) ajuda a ver símbolos; alternativa: habilidade ou livro
				n = 2, nome = "O Guardião Adormecido", lancado = true,
				pistas = {
					VigiaDesperto = {
						ordem = 1, nome = "O Vigia de Cristal", categoria = "C",
						texto = "Uma criatura de cristal dormia encostada na parede. Acordou sem medo e passou a olhar fixo para três pontos.",
					},
					SimboloDoVigiaA = {
						ordem = 2, nome = "Primeiro símbolo que o Vigia olhou", categoria = "C", capacidade = "OlharDoVigia",
						texto = "Riscado na pedra: o {1}.",
					},
					SimboloDoVigiaB = {
						ordem = 3, nome = "Segundo símbolo que o Vigia olhou", categoria = "C", capacidade = "OlharDoVigia",
						texto = "Quase apagado: o {2}; e, embaixo, o {3}.",
					},
				},
				objetivos = {
					{ id = "SimbolosDoVigia", nome = "Encontrar o que o Vigia está olhando", tipo = "pistas", pistas = { "VigiaDesperto", "SimboloDoVigiaA", "SimboloDoVigiaB" } },
					{ id = "OlhosDoVigia", nome = "Virar os três cristais como nos símbolos", tipo = "enigma", puzzle = "OlhosDoVigia", visivelApos = "SimbolosDoVigia" },
				},
				recompensa = "RecCap2_Vigia",
			},
			{
				-- a ordem das torres está numa placa e na cantiga do Vigia; as torres pedem a Torre Meteorológica
				-- restaurada (integração com a Restauração)
				n = 3, nome = "As Três Torres Esquecidas", lancado = true,
				pistas = {
					PlacaDasTorres = {
						ordem = 1, nome = "Placa das três torres", categoria = "A",
						texto = "Na placa gasta: \"A primeira a acordar é a torre do {1}.\"",
					},
					CantigaDoVigia = {
						ordem = 2, nome = "A cantiga do Vigia", categoria = "C",
						texto = "O Vigia cantarola baixinho, sempre igual: depois vem a do {2}, e por fim a do {3}.",
					},
				},
				objetivos = {
					{ id = "OrdemDasTorres", nome = "Descobrir a ordem das torres", tipo = "pistas", pistas = { "PlacaDasTorres", "CantigaDoVigia" } },
					{ id = "TresTorres", nome = "Acordar as três torres na ordem", tipo = "enigma", puzzle = "TresTorres", visivelApos = "OrdemDasTorres" },
				},
				recompensa = "RecCap3_Torres",
			},
			{ n = 4, nome = "A Chave Incompleta", lancado = false, pistas = {}, objetivos = {} },
			{ n = 5, nome = "A Mensagem Entre Dimensões", lancado = false, pistas = {}, objetivos = {}, dimensao = "CampoDasBolhas" },
			{ n = 6, nome = "A Biblioteca do Vazio", lancado = false, pistas = {}, objetivos = {}, dimensao = "BibliotecaDoVazio" },
			{ n = 7, nome = "A Primeira Receita ???", lancado = false, pistas = {}, objetivos = {} },
		},
	},
}
