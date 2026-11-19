--!strict
-- NÃO EXECUTADO. ENIGMAS (SÓ SERVIDOR). Um enigma = uma entrada de dados; o motor é MysterySystems/Enigma.
-- escopo: "individual" (estado por jogador) | "cooperativo" (estado de sessão compartilhado; a recompensa é
-- individual e só para quem participou e estava perto). raio: distância máxima entre jogador e elemento.
-- objetivo: { investigacao, id } marcado quando o enigma é resolvido.

return {
	-- PROTÓTIPO (capítulo 1): três marcos; a ordem sai da semente do jogador e está espalhada nas pistas
	OSinal = {
		tipo = "Sequencia", escopo = "individual", raio = 10,
		elementos = { "Pedra", "Cobre", "Cristal" },
		nomes = { Pedra = "pedra", Cobre = "cobre", Cristal = "cristal" }, -- como as pistas chamam cada um
		ordem = "semente",
		objetivo = { investigacao = "OSegredoDoPrimeiroArquivista", id = "OSinal" },
	},
	-- EXEMPLOS de cada tipo (configs válidas, testadas no spec; ainda sem lugar no mapa)
	ExemploAlinhamento = { tipo = "Alinhamento", escopo = "individual", raio = 10, elementos = { "EspelhoA", "EspelhoB", "EspelhoC" }, posicoes = 4 },
	ExemploColeta = { tipo = "Coleta", escopo = "individual", raio = 10, itens = { "Pagina1", "Pagina2", "Pagina3" } },
	ExemploRessonancia = { tipo = "Ressonancia", escopo = "individual", raio = 12, elementos = { "CristalA", "CristalB" }, capacidade = "RessonanciaDimensional" },
	ExemploExploracao = { tipo = "Exploracao", escopo = "individual", raio = 0, alvos = { "TopoDaTorre" } },
	ExemploCooperativo = { tipo = "Cooperativo", escopo = "cooperativo", raio = 12, elementos = { "SinoA", "SinoB" }, minJogadores = 2, janela = 8 },
	ExemploInterdimensional = { tipo = "Interdimensional", escopo = "individual", raio = 10, marcas = { "SinalIlha", "SinalBolhas" } },
}
