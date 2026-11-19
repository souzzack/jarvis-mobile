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
	montariaNaoVoa = "Esta montaria não voa",
	longe = "Chegue mais perto",
	semCriatura = "Nenhuma criatura ativa",
	jaMontado = "Já está montado",
	nomeInvalido = "Nome inválido",
	nomeFiltrado = "Esse nome não é permitido",
	jaLido = "Você já aprendeu com este livro",
	livroBloqueado = "Você ainda não entende este livro",
	cedoDemais = "Espere um pouco",
	naoAdulto = "A criatura precisa ser adulta",
	pontos = "Afinidade ainda insuficiente",
	faltaRequisito = "Ainda faltam requisitos",
	naoDescoberto = "Você ainda não descobriu este lugar",
	emCombate = "Não dá para viajar em combate",
	semBase = "Nenhuma parcela livre neste servidor",
	naoEhSua = "Esta base não é sua",
	semEspecial = "Este equipamento não tem habilidade especial",
	torreSemEnergia = "A Torre ainda não tem energia: restaure a Torre Meteorológica",
	encaixeErrado = "Esse item não vai nesse lugar",
	melhoriaMaxima = "Já está no +10",
	precisaOficina = "Melhorias até +5: na Oficina dos Inventores restaurada",
	precisaForja4 = "Melhorias +6 a +10: na Forja da sua base, nível 4",
	encaixeInvalido = "Encaixe desconhecido",
	telescopioQuebrado = "O telescópio está quebrado: restaure o Observatório",
	outraForma = "A especial é de outra forma do artefato",
	racaFixa = "A raça só muda agora pelo Ritual de Origem",
	ocupado = "Termine o golpe atual primeiro",
	precisaRitual = "Trocar a afinidade exige o Ritual de Realinhamento",
	indisponivel = "Esta afinidade ainda não está disponível",
	especieIncompativel = "Esta espécie não desenvolve essa afinidade",
	-- companhias
	semPermissao = "Seu cargo não permite isso",
	jaMembro = "Já faz parte de uma companhia",
	companhiaCheia = "A companhia está cheia",
	semConvite = "Convite inexistente ou expirado",
	dissolvida = "Esta companhia foi dissolvida",
	naoMembro = "Não é membro da companhia",
	liderNaoSai = "Transfira a liderança ou dissolva a companhia antes de sair",
	cargoInvalido = "Cargo inválido",
	quantidade = "Quantidade inválida",
	semItem = "Nada disponível desse material para o seu cargo",
	limiteDiario = "Limite diário de retirada atingido",
	nomeCompanhiaInvalido = "Nome inválido (3 a 20 letras, sem símbolos especiais)",
	nomeEmUso = "Já existe uma companhia com esse nome",
	emblemaInvalido = "Emblema inválido",
	semCompanhia = "Você não está em uma companhia",
	jaAgendada = "A dissolução já está agendada",
	gravacao = "Não foi possível salvar agora; tente de novo",
	companhiaOcupada = "Aguarde a ação anterior terminar",
	-- base: Depósito e consumíveis
	depositoCheio = "Depósito cheio: desmonte um equipamento ou melhore o Depósito da base",
	retireAntes = "Retire o item antes de desmontar",
	reliquiaUnica = "Relíquias não se desmontam",
	semReliquia = "Nenhuma relíquia equipada",
}

local Mensagens = {}

function Mensagens.texto(motivo: any): string?
	if typeof(motivo) ~= "string" then
		return nil
	end
	return TEXTOS[motivo]
end

return Mensagens
