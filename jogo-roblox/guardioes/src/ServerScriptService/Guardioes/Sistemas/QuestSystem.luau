--!strict
-- NÃO EXECUTADO NO STUDIO. QuestSystem: missões por eventos do jogo (Config/Missoes + Missoes/Missao).
--  * Aceite automático quando os requisitos (Util/Requisitos) são cumpridos.
--  * Eventos vindos dos outros sistemas, sempre do servidor: derrotar (EnemySystem), derrotarComCriatura
--    (EnemySystem + CompanionSystem), ler (MagicBookSystem), voar/planar (MovementSystem).
--  * Progresso salvo em perfil.missoesProgresso; concluída em perfil.missoes (destrava livros e estágios).
--  * Recompensa: primeiro marca a missão concluída (transação) — assim nunca paga duas vezes — e depois
--    entrega XP, materiais, marco da criatura (só se a criatura ativa for da espécie) e objetivo dimensional.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local G = ReplicatedStorage:WaitForChild("Guardioes")
local Missoes = require(G.Config.Missoes)
local Missao = require(G.Missoes.Missao)
local Requisitos = require(G.Util.Requisitos)
local Saque = require(G.Loot.Saque)
local Loot = require(G.Config.Loot)
local Remotos = require(G.Rede.Remotos)

local EM = Remotos.EventoMissao
local RAIO_CRIATURA = 40

local QuestSystem = { Nome = "QuestSystem" }

local evento: RemoteEvent
local playerData: any
local habilidades: any
local companheiros: any
local inventario: any
local progressao: any
local ctxSistemas: any = nil

local function disponivel(p: Player, perfil: any, m: any): boolean
	if perfil.missoes[m.id] then
		return false
	end
	local hab = {}
	for _, id in habilidades.lista(p) do
		hab[id] = true
	end
	local prog = Requisitos.unir({ missoes = perfil.missoes, habilidades = hab, livros = perfil.livrosLidos, restauracoes = perfil.restauracoes, dimensoes = perfil.dimensoes, segredos = perfil.segredos, receitas = perfil.receitas })
	return (Requisitos.avaliar(m.requisitos or {}, prog))
end

local function enviar(p: Player)
	local perfil = playerData.obter(p)
	if not perfil then
		return
	end
	local lista = {}
	for _, m in Missoes.lista do
		if disponivel(p, perfil, m) then
			table.insert(lista, { id = m.id, nome = m.nome, descricao = m.descricao, linhas = Missao.resumo(perfil.missoesProgresso[m.id] or {}, m) })
		end
	end
	evento:FireClient(p, EM.LISTA, lista)
end

local function recompensar(p: Player, m: any)
	local r = m.recompensas or {}
	if r.xp then
		progressao.ganharXp(p, r.xp, "missao:" .. m.id)
	end
	if r.materiais then
		inventario.darMateriais(p, r.materiais, "missao:" .. m.id)
	end
	if r.marcoCriatura then
		local c = companheiros.ativa(p)
		if c and c.especie == r.marcoCriatura.especie then
			companheiros.registrarMarco(p, r.marcoCriatura.marco)
		end
	end
	if r.objetivoDimensional then
		companheiros.registrarObjetivoDimensional(p, r.objetivoDimensional)
	end
	evento:FireClient(p, EM.CONCLUIDA, m.nome)
end

-- ponto único de entrada de eventos (outros sistemas também podem chamar: QuestSystem.registrar)
function QuestSystem.registrar(p: Player, ev: Missao.Evento)
	local perfil = playerData.obter(p)
	if not perfil then
		return
	end
	local concluidas: { any } = {}
	local mudou = false
	for _, m in Missoes.lista do
		if disponivel(p, perfil, m) then
			local prog = table.clone(perfil.missoesProgresso[m.id] or {})
			local alterou, concluiu = Missao.registrar(prog, m, ev)
			if alterou then
				mudou = true
				local ok = playerData.atualizar(p, function(pf)
					if pf.missoes[m.id] then
						return false -- já concluída por outro caminho: não paga de novo
					end
					if concluiu then
						pf.missoes[m.id] = true
						pf.missoesProgresso[m.id] = nil
					else
						pf.missoesProgresso[m.id] = prog
					end
					return true
				end)
				if ok and concluiu then
					table.insert(concluidas, m)
				end
			end
		end
	end
	for _, m in concluidas do
		recompensar(p, m)
	end
	if mudou then
		enviar(p)
	end
end

function QuestSystem.Init(ctx: any)
	ctxSistemas = ctx
	evento = Remotos.evento("Missoes")
end

function QuestSystem.Start()
	playerData = ctxSistemas.obter("PlayerDataSystem")
	habilidades = ctxSistemas.obter("MovementAbilitySystem")
	companheiros = ctxSistemas.obter("CompanionSystem")
	inventario = ctxSistemas.obter("InventorySystem")
	progressao = ctxSistemas.obter("ProgressionSystem")
	local inimigos = ctxSistemas.obter("EnemySystem")
	local livros = ctxSistemas.obter("MagicBookSystem")
	local movimento = ctxSistemas.obter("MovementSystem")
	local restauracao = ctxSistemas.obter("RestorationSystem")
	local fabricacao = ctxSistemas.obter("CraftingSystem")
	restauracao.restaurou.conectar(function(p: Player, id: string)
		QuestSystem.registrar(p, { tipo = "restaurar", alvo = id })
		enviar(p) -- requisitos de restauração podem liberar missões novas
	end)
	fabricacao.fabricou.conectar(function(p: Player, receitaId: string)
		QuestSystem.registrar(p, { tipo = "fabricar", alvo = receitaId })
	end)

	inimigos.morreu.conectar(function(ini: any, contribuicao: { [Player]: number })
		local onde = ini.raiz and ini.raiz.Position
		for _, p in Saque.elegiveis(contribuicao, Loot.minimoDeContribuicao) do
			QuestSystem.registrar(p, { tipo = "derrotar", alvo = ini.cfg.id })
			local c, _, raiz = companheiros.ativa(p)
			if c and raiz and onde and (raiz.Position - onde).Magnitude <= RAIO_CRIATURA then
				QuestSystem.registrar(p, { tipo = "derrotarComCriatura", alvo = c.especie })
			end
		end
	end)
	livros.lido.conectar(function(p: Player, livroId: string)
		QuestSystem.registrar(p, { tipo = "ler", alvo = livroId })
	end)
	movimento.mudouEstado.conectar(function(p: Player, estado: string, modo: string?)
		if estado == "Voo" and modo then
			QuestSystem.registrar(p, { tipo = "voar", alvo = modo })
		elseif estado == "Planando" then
			QuestSystem.registrar(p, { tipo = "planar", alvo = modo or "Planador" })
		end
	end)
	playerData.carregado.conectar(function(p: Player)
		enviar(p)
	end)
	habilidades.mudou.conectar(function(p: Player)
		enviar(p) -- requisito de habilidade pode ter liberado missão
	end)
end

return QuestSystem
