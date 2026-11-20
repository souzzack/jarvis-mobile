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
			{
				-- as três torres abriram um nicho; três dentes de uma chave estão espalhados (um no alto: voar OU
				-- subir pelos degraus — o voo não é obrigatório). A chave não funciona por inteiro na Ilha.
				n = 4, nome = "A Chave Incompleta", lancado = true,
				pistas = {
					NichoDasTorres = {
						ordem = 1, nome = "O nicho das três vozes", categoria = "A",
						texto = "Quando as torres falaram juntas, um nicho se abriu na pedra. Dentro, o encaixe de uma chave de três dentes.",
					},
					AnotacaoDosDentes = {
						ordem = 2, nome = "Anotação sobre os dentes", categoria = "A",
						texto = "\"Separei os dentes: um fica com o vento, outro no chão do raio, o último no alto, onde só chega quem voa ou quem sobe com paciência.\" — A.",
					},
				},
				objetivos = {
					{ id = "OndeEstaoOsDentes", nome = "Descobrir onde estão os dentes", tipo = "pistas", pistas = { "NichoDasTorres", "AnotacaoDosDentes" } },
					{ id = "DentesDaChave", nome = "Reunir os três dentes da chave", tipo = "enigma", puzzle = "DentesDaChave", visivelApos = "OndeEstaoOsDentes" },
				},
				recompensa = "RecCap4_Chave",
			},
			{
				-- no Campo das Bolhas: a outra metade da fechadura. A Chave Incompleta (marca do capítulo 4) abre; depois,
				-- três bolhas tocadas na ordem da semente soltam a mensagem de A. (sobre a Fratura, sem culpados)
				n = 5, nome = "A Mensagem Entre Dimensões", lancado = true, dimensao = "CampoDasBolhas",
				pistas = {
					MetadeDaFechadura = {
						ordem = 1, nome = "A outra metade da fechadura", categoria = "D",
						texto = "Presa numa bolha de pedra que não estoura: a metade de uma fechadura. Os encaixes têm o formato exato dos dentes da sua chave.",
					},
					VozNaBolha = {
						ordem = 2, nome = "Uma voz guardada numa bolha", categoria = "A",
						texto = "A bolha repete uma voz, a de A.: \"Se a chave chegou até aqui, a Ilha confiou em você. Toque as bolhas na ordem em que a tempestade chega: a de {1}, depois a de {2}, por último a de {3}.\"",
					},
				},
				objetivos = {
					{ id = "PistasDaMensagem", nome = "Entender o que a fechadura pede", tipo = "pistas", pistas = { "MetadeDaFechadura", "VozNaBolha" } },
					{ id = "FechaduraDasBolhas", nome = "Girar a Chave Incompleta na outra metade", tipo = "enigma", puzzle = "FechaduraDasBolhas", visivelApos = "PistasDaMensagem" },
					{ id = "EcoDasBolhas", nome = "Tocar as três bolhas na ordem da tempestade", tipo = "enigma", puzzle = "EcoDasBolhas", visivelApos = "FechaduraDasBolhas" },
				},
				recompensa = "RecCap5_Mensagem",
			},
			{ n = 6, nome = "A Biblioteca do Vazio", lancado = false, pistas = {}, objetivos = {}, dimensao = "BibliotecaDoVazio" },
			{ n = 7, nome = "A Primeira Receita ???", lancado = false, pistas = {}, objetivos = {} },
		},
	},
}
