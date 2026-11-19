--!strict
-- NÃO EXECUTADO. Um RemoteEvent por sistema, com o tipo da mensagem como primeiro argumento (poucas chamadas,
-- payload pequeno). O servidor cria a pasta; o cliente espera por ela.

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotos = {}

-- mensagens do combate (cliente → servidor)
Remotos.Combate = {
	ATACAR = 1, -- (alvoId: string?)
	PESADO = 2, -- (alvoId: string?)
	ESQUIVAR = 3, -- (dirX: number, dirZ: number)
	DEFESA_INICIO = 4,
	DEFESA_FIM = 5,
}

-- eventos do combate (servidor → cliente)
Remotos.EventoCombate = {
	RESULTADO_GOLPE = 1, -- (alvoId, tipo, dano) para todos: números de dano e efeitos
	REJEITADO = 2, -- (acao, motivo) só para quem pediu: o cliente desfaz a previsão
	ESTAMINA = 3, -- (valor, max) só para o dono, no máximo 5 vezes por segundo
	ESTADO = 4, -- (estado: string) correção do estado oficial
	RECEBEU_GOLPE = 5, -- (tipo, dano, origemId) para o jogador atingido
	TELEGRAFIA = 6, -- (inimigoId, ataque, duracao) para todos: aviso do ataque do inimigo
	INIMIGO_MORREU = 7, -- (inimigoId)
	ARMA = 8, -- (arma: tabela de Config/Armas) a arma ativa do dono, para a previsão local usar os MESMOS tempos
}

-- locomoção (cliente → servidor): só INTENÇÕES; posição/velocidade nunca são aceitas do cliente
Remotos.Locomocao = {
	DECOLAR = 1, -- (perfilId: string) "VooMagico" | "AsasNaturais"
	POUSAR = 2,
	IMPULSO = 3, -- (ligar: boolean)
	PLANADOR_ABRIR = 4,
	PLANADOR_FECHAR = 5,
}

-- eventos da locomoção (servidor → cliente)
Remotos.EventoLocomocao = {
	ESTADO = 1, -- (estado, modo, motivo?) correção do estado oficial (só o dono)
	PERFIL = 2, -- (perfil: tabela) perfil EFETIVO calculado no servidor para o modo ativo (só o dono)
	ENERGIA = 3, -- (valor, max) no máximo 5×/s
	REJEITADO = 4, -- (acao, motivo)
	CORRECAO = 5, -- (x, y, z) o servidor devolveu o personagem à última posição válida
	HABILIDADES = 6, -- (lista de ids, raca) o que o personagem sabe (para a interface)
}

-- artefatos metamórficos
Remotos.Artefato = {
	TRANSFORMAR = 1, -- (guid: string, forma: string)
	EVOLUIR = 2, -- (guid) o servidor confere missões/desafios/materiais e faz a transação atômica
	EQUIPAR = 3, -- (guid) só a pé
}
Remotos.EventoArtefato = {
	INVENTARIO = 1, -- (lista { guid, id, estagio, forma }) só o dono
	REJEITADO = 2, -- (guid, motivo)
	FORMA = 3, -- (guid, forma, transformando: boolean) só o dono (os outros leem atributos do personagem)
	EVOLUIU = 4, -- (guid, estagio)
	FALTA = 5, -- (guid, lista do que falta para o próximo estágio)
}

-- inventário, missões e progressão (servidor → cliente; os pedidos de mudança passam pelos sistemas donos)
Remotos.EventoInventario = { MATERIAIS = 1, SAQUE = 2 } -- MATERIAIS: (lista {id, nome, qtd}); SAQUE: ({id → qtd})
Remotos.EventoMissao = { LISTA = 1, CONCLUIDA = 2 } -- LISTA: (missões ativas com linhas de progresso); CONCLUIDA: (nome)
Remotos.EventoProgressao = { NIVEL = 1 } -- (nivel, xp, xpParaProximo, subiu: boolean)

-- companheiros (criaturas individuais; não confundir com Companhias = guildas)
Remotos.Companheiro = {
	ATIVAR = 1, -- (guid)
	COMANDO = 2, -- (guid, "Acompanhar" | "Permanecer" | "Retornar")
	AFAGAR = 3, -- (guid)
	RENOMEAR = 4, -- (guid, nome) passa pelo filtro de texto do Roblox
	EVOLUIR = 5, -- (guid) o servidor confere todos os requisitos
	ESPECIALIZAR = 6, -- (guid, afinidadeId)
}
Remotos.EventoCompanheiro = {
	LISTA = 1, -- (lista de cartões) só o dono
	REJEITADO = 2, -- (acao, motivo)
	EVOLUIU = 3, -- (guid, estagio)
	REVELAR = 4, -- (lista de Parts escondidas, nomeDaCriatura): o cliente do dono mostra
}

-- montarias
Remotos.Montaria = { MONTAR = 1, DESMONTAR = 2 }
Remotos.EventoMontaria = { REJEITADO = 1, MONTADO = 2 } -- MONTADO: (montado: boolean, voadora: boolean)

-- livros mágicos (a leitura começa por ProximityPrompt no servidor; só há eventos de volta)
Remotos.EventoLivro = {
	LIDO = 1, -- (livroId, nomeDoLivro, { nomes das habilidades aprendidas })
	RECUSADO = 2, -- (livroId, textoPublico)
	LISTA = 3, -- (lista { id, nome, ensina, lido, requisito }) — livros ocultos aparecem como "???"
}

-- fabricação (a janela abre pelo ProximityPrompt da estação; o pedido FABRICAR é validado no servidor)
Remotos.Fabricacao = { FABRICAR = 1 } -- (receitaId)
Remotos.EventoFabricacao = {
	LISTA = 1, -- (estacaoId, lista { id, nome, pode, faltando, resultado })
	FEITO = 2, -- (nomeDaReceita)
	REJEITADO = 3, -- (receitaId, motivo)
}
-- restauração (ação pelo ProximityPrompt da estrutura; só eventos de volta)
Remotos.EventoRestauracao = {
	ESTADO = 1, -- (estruturaId, { nome, estado, etapa, total, etapaNome, falta = { material → qtd } })
	AJUDOU = 2, -- (estruturaId, nomeDeQuemConcluiu)
}
-- chefes (para todos na arena)
Remotos.EventoChefe = {
	INICIO = 1, -- (chefeId inimigo, nome)
	CARGA = 2, -- (duracao, pilares)
	FIM_CARGA = 3, -- ("Sucesso" | "Descarga")
	DERROTADO = 4, -- (nome)
	MATILHA = 5, -- (quantos cães)
	CORRIDA = 6, -- (duracao) Alfa imune: apare o golpe dele
}

-- base pessoal (ações pelos prompts da parcela; só eventos de volta)
Remotos.EventoBase = {
	ESTADO = 1, -- ({ espacos = { id, nome, nivel, max, funcao }, trofeus, temParcela })
	REJEITADO = 2, -- (espacoId | motivo, faltando)
	MELHOROU = 3, -- (nomeDoEspaco, nivel)
	COLHEU = 4, -- (itens { id → qtd }, teto)
}
-- viagem rápida
Remotos.Viagem = { VIAJAR = 1, LISTAR = 2 } -- VIAJAR: (pontoId | "MinhaBase")
Remotos.EventoViagem = {
	LISTA = 1, -- (lista { id, nome })
	DESCOBERTO = 2, -- (nome)
	REJEITADO = 3, -- (motivo)
	CHEGOU = 4, -- (pontoId)
}

-- habilidades especiais de armas e escudos
Remotos.Especial = { USAR = 1 }
Remotos.EventoEspecial = {
	USOU = 1, -- (id, tipo, recarga, avanco, impulsoVertical, duracao) só o dono: faz o impulso do corpo
	REJEITADO = 2, -- (motivo)
	ACERTO = 3, -- (inimigoId, tipo, dano) para todos
	EFEITO = 4, -- (userId, tipo) para todos: brilho no personagem
}
-- raça
Remotos.Raca = { ESCOLHER = 1 } -- (racaId)
Remotos.EventoRaca = {
	LISTA = 1, -- (raças, racaAtual?, podeTrocar, precisaEscolher)
	DEFINIDA = 2, -- (id, nome)
	REJEITADO = 3, -- (motivo)
}

local NOMES = { "Combate", "Locomocao", "Artefato", "Companheiro", "Montaria", "Livro", "Inventario", "Missoes", "Progressao", "Fabricacao", "Restauracao", "Chefe", "Base", "Viagem", "Especial", "Raca" }

local pasta: Folder? = nil

local function obterPasta(): Folder
	if pasta then
		return pasta
	end
	local raiz = ReplicatedStorage:WaitForChild("Guardioes")
	if RunService:IsServer() then
		local p = raiz:FindFirstChild("Remotos") :: Folder?
		if not p then
			local nova = Instance.new("Folder")
			nova.Name = "Remotos"
			for _, nome in NOMES do
				local ev = Instance.new("RemoteEvent")
				ev.Name = nome
				ev.Parent = nova
			end
			nova.Parent = raiz
			p = nova
		end
		pasta = p
	else
		pasta = raiz:WaitForChild("Remotos") :: Folder
	end
	return pasta :: Folder
end

function Remotos.evento(nome: string): RemoteEvent
	return obterPasta():WaitForChild(nome) :: RemoteEvent
end

return Remotos
