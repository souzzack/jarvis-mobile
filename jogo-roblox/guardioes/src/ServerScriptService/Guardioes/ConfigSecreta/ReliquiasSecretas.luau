--!strict
-- NÃO EXECUTADO. RELÍQUIAS ??? (SÓ SERVIDOR). O EquipmentSystem junta estas entradas ao catálogo no servidor; o
-- cliente só recebe nome e efeito DEPOIS que o jogador tem o item (na lista do inventário dele).
-- Obtenção: SecretDiscoverySystem (câmara sob o altar, junto do Artefato Desconhecido nº 1). Nunca por compra.

return {
	{
		id = "LascaDaSetimaEstrela", nome = "Lasca da Sétima Estrela", tipo = "Reliquia", raridade = "Oculta", atributos = {},
		ativa = { efeito = "FolegoEstelar", recarga = 180 },
		efeito = "Ativa (Z): enche a energia de voo e a estamina na hora. Recarga 3 min.",
	},
}
