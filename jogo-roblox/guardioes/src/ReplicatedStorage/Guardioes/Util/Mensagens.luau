--!strict
-- NÃO EXECUTADO. Texto para cada motivo de recusa: diz O QUE falta, sem revelar segredos (??? nunca é citado).
-- nil = não mostrar nada (recusas internas/silenciosas).

local TEXTOS: { [string]: string } = {
	estamina = "Sem estamina",
	energia = "Energia de voo insuficiente",
	zonaProibida = "Não é possível voar aqui",
	semEspaco = "Sem espaço livre",
	atordoado = "Atordoado",
	naoAprendido = "Você ainda não aprendeu isso",
	baixo = "Precisa de mais altura para planar",
	semImpulso = "Impulso ainda não aprendido",
	bloqueada = "Forma ainda adormecida: avance na história deste artefato",
	recarga = "Aguarde a recarga",
	transformando = "Transformação em andamento",
	naoPossui = "Item não encontrado no inventário",
	locomocao = "Indisponível enquanto se desloca",
	formaDeLocomocao = "Volte à forma de arma para atacar",
	golpe = "Derrubado do voo!",
	energiaAcabou = "A energia acabou",
	locomocaoRecusada = "A transformação foi interrompida",
	montado = "Desmonte primeiro",
	semMontaria = "Nenhuma montaria ativa",
	emVoo = "Pouse primeiro",
	jovemDemais = "Ainda jovem demais para carregar alguém",
	especieSemMontaria = "Esta criatura não pode ser montada",
	Atordoado = "Atordoado",
}

local Mensagens = {}

function Mensagens.texto(motivo: any): string?
	if typeof(motivo) ~= "string" then
		return nil
	end
	return TEXTOS[motivo]
end

return Mensagens
