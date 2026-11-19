--!strict
-- NÃO EXECUTADO. Dimensões e os places do Roblox onde cada uma roda. Só dados (T).
-- placeId = 0: o place ainda não existe ou não foi publicado. O portal mostra "em construção" e não teleporta.
-- Para ligar uma dimensão: publicar o place no MESMO experience (TeleportService só vai entre places do mesmo
-- universo) e preencher o placeId aqui. Nenhum mapa novo é criado nesta etapa; o Campo das Bolhas continua como
-- está (só o id dele aparece aqui).
-- hub = true: a dimensão de chegada (o portal de volta sempre leva para lá).

return {
	lista = {
		{
			id = "IlhaDasTempestades", nome = "Ilha das Tempestades", hub = true, placeId = 0,
			requisitos = {}, requisitoPublico = "",
		},
		{
			id = "CampoDasBolhas", nome = "Campo das Bolhas", hub = false, placeId = 0,
			-- Ato 1, passo 6: o diário do Guardião aponta o Campo das Bolhas
			requisitos = { segredos = { "DiarioDoGuardiao" } },
			requisitoPublico = "Vença o Guardião da Tormenta: o diário dele aponta o caminho.",
		},
	},
}
