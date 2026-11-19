--!strict
-- NÃO EXECUTADO NO STUDIO. EquipmentSystem: armaduras e acessórios (GDD 7.4).
--  * Itens com GUID em perfil.equipamentos (nascem só no servidor: fabricação). Encaixes em perfil.equipado.
--  * EQUIPAR(guid, encaixe) / RETIRAR(encaixe): o servidor confere posse, tipo × encaixe e que o mesmo item não
--    fique em dois encaixes; grava numa transação (a validação do perfil recusa estados impossíveis).
--  * Efeitos (Equipamento/Equipamento.totais, com orçamento de raridade e tetos): defesa e aparo no
--    CombatSystem, vida no ProgressionSystem, energia de voo no MovementSystem.
--  * A ARMA continua sendo o artefato equipado (MetamorphicArtifactSystem).
--  * RELÍQUIA (encaixe "Reliquia"): ativa com recarga longa (Z). Recarga ÚNICA por jogador (trocar de relíquia não
--    zera) e salva no perfil. Relíquias ??? vêm de ConfigSecreta/ReliquiasSecretas, juntadas ao catálogo SÓ aqui
--    no servidor; o cliente vê nome e efeito só de quem já tem o item.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local G = ReplicatedStorage:WaitForChild("Guardioes")
local Eq = require(G.Equipamento.Equipamento)
local Melhoria = require(G.Equipamento.Melhoria)
local Catalogo = require(G.Config.Equipamentos)
local Raridades = require(G.Config.Raridades)
local BaseLogica = require(G.Base.Base)
local CfgBase = require(G.Config.Base)
local LimiteDeTaxa = require(G.Util.LimiteDeTaxa)
local Remotos = require(G.Rede.Remotos)
local Reliquia = require(G.Equipamento.Reliquia)
local Secretas = require(script.Parent.Parent.ConfigSecreta.ReliquiasSecretas)

-- catálogo do servidor = público + secreto (a tabela pública do cliente não muda: cada lado tem a sua cópia)
for _, r in Secretas do
	if not Catalogo.porId[r.id] then
		Catalogo.porId[r.id] = r
	end
end

local EQ = Remotos.Equipamento
local EE = Remotos.EventoEquipamento

local EquipmentSystem = { Nome = "EquipmentSystem" }

local evento: RemoteEvent
local playerData: any
local combate: any
local progressao: any
local movimento: any
local inventario: any
local fabricacao: any
local restauracao: any
local ctxSistemas: any = nil
local baldes: { [Player]: LimiteDeTaxa.Balde } = {}

local function aplicar(p: Player)
	local perfil = playerData.obter(p)
	if not perfil then
		return
	end
	local t = Eq.totais(perfil.equipado, perfil.equipamentos, Catalogo.porId, Raridades.porId, Raridades.tetoMelhoria)
	combate.definirEquipamento(p, t.defesa, t.janelaAparar)
	progressao.definirVidaExtra(p, t.vidaBonus)
	movimento.definirEnergiaExtra(p, t.energiaVoo)
	local itens = {}
	for guid, item in perfil.equipamentos do
		local cfg = Catalogo.porId[item.id]
		if cfg then
			table.insert(itens, {
				guid = guid, id = item.id, nome = cfg.nome, tipo = cfg.tipo, raridade = cfg.raridade, melhoria = item.melhoria or 0,
				proximaMelhoria = if cfg.tipo ~= "Reliquia" and (item.melhoria or 0) < Melhoria.MAX then {
					custo = Melhoria.custo((item.melhoria or 0) + 1, cfg.materialDeOrigem), onde = Melhoria.onde((item.melhoria or 0) + 1),
				} else nil,
				atributos = cfg.atributos, efeito = cfg.efeito, encaixe = Eq.ondeEsta(perfil.equipado, guid),
			})
		end
	end
	table.sort(itens, function(a, b)
		return a.nome < b.nome
	end)
	evento:FireClient(p, EE.LISTA, itens, t, { tem = Eq.contarNoDeposito(perfil.equipamentos), cabe = BaseLogica.capacidadeDoDeposito(perfil.base, CfgBase.espacos.Deposito) })
	-- relíquia equipada (para a tecla Z): nome e quanto falta da recarga
	local gRel = perfil.equipado.Reliquia
	local rel = gRel and perfil.equipamentos[gRel] and Catalogo.porId[perfil.equipamentos[gRel].id]
	evento:FireClient(p, EE.RELIQUIA, if rel then rel.nome else nil, Reliquia.falta(perfil.reliquiaRecargaAte, os.time()), if rel then rel.ativa.recarga else 0)
end

-- desmontar: só item NÃO equipado; devolve parte do material (Eq.desmontar) na MESMA gravação que o remove
local function desmontar(p: Player, guid: string)
	local perfil = playerData.obter(p)
	local item = perfil and perfil.equipamentos[guid]
	local cfg = item and Catalogo.porId[item.id]
	if not perfil or not item or not cfg then
		evento:FireClient(p, EE.REJEITADO, "naoPossui")
		return
	end
	if cfg.tipo == "Reliquia" then
		evento:FireClient(p, EE.REJEITADO, "reliquiaUnica")
		return
	end
	if Eq.ondeEsta(perfil.equipado, guid) then
		evento:FireClient(p, EE.REJEITADO, "retireAntes")
		return
	end
	local ok = inventario.transacao(p, {
		darMateriais = Eq.desmontar(cfg),
		alterarPerfil = function(pf)
			if not pf.equipamentos[guid] or Eq.ondeEsta(pf.equipado, guid) then
				return false
			end
			pf.equipamentos[guid] = nil
			return true
		end,
	})
	if ok then
		evento:FireClient(p, EE.DESMONTOU, cfg.nome)
		aplicar(p)
	else
		evento:FireClient(p, EE.REJEITADO, "gravacao")
	end
end

local function equipar(p: Player, guid: string, encaixe: string)
	local perfil = playerData.obter(p)
	if not perfil then
		return
	end
	local item = perfil.equipamentos[guid]
	local cfg = item and Catalogo.porId[item.id]
	if not cfg then
		evento:FireClient(p, EE.REJEITADO, "naoPossui")
		return
	end
	local ok, motivo = Eq.podeEquipar(cfg, encaixe)
	if not ok then
		evento:FireClient(p, EE.REJEITADO, motivo)
		return
	end
	local gravou = playerData.atualizar(p, function(pf)
		local antes = Eq.ondeEsta(pf.equipado, guid)
		if antes then
			pf.equipado[antes] = nil -- mudar de encaixe (ex.: acessório 1 → 2)
		end
		pf.equipado[encaixe] = guid
		return true
	end)
	if gravou then
		aplicar(p)
	end
end

-- melhorar +1: estação certa por perto, restauração (até +5) e materiais — consumo e nível juntos (transação)
local function melhorar(p: Player, guid: string)
	local perfil = playerData.obter(p)
	local item = perfil and perfil.equipamentos[guid]
	local cfg = item and Catalogo.porId[item.id]
	if not perfil or not item or not cfg then
		evento:FireClient(p, EE.REJEITADO, "naoPossui")
		return
	end
	local atual = item.melhoria or 0
	if atual >= Melhoria.MAX then
		evento:FireClient(p, EE.REJEITADO, "melhoriaMaxima")
		return
	end
	local alvo = atual + 1
	local onde = Melhoria.onde(alvo)
	if (fabricacao.estacoesPerto(p)[onde.estacao] or 0) < onde.nivelEstacao then
		evento:FireClient(p, EE.REJEITADO, if onde.estacao == "Forja" then "precisaForja4" else "precisaOficina")
		return
	end
	if onde.restauracao and not restauracao.restaurada(p, onde.restauracao) then
		evento:FireClient(p, EE.REJEITADO, "precisaOficina")
		return
	end
	local ok, faltando = inventario.transacao(p, {
		consumir = Melhoria.custo(alvo, cfg.materialDeOrigem),
		alterarPerfil = function(pf)
			local it = pf.equipamentos[guid]
			if not it or (it.melhoria or 0) ~= atual then
				return false -- mudou no meio: não paga duas vezes
			end
			it.melhoria = alvo
			return true
		end,
	})
	if not ok then
		evento:FireClient(p, EE.FALTA, guid, faltando)
		return
	end
	evento:FireClient(p, EE.MELHOROU, cfg.nome, alvo)
	aplicar(p)
end

-- ativar a relíquia equipada. A recarga é gravada ANTES do efeito (o mesmo pedido duas vezes só vale uma).
local function ativarReliquia(p: Player)
	local perfil = playerData.obter(p)
	if not perfil then
		return
	end
	local guid = perfil.equipado.Reliquia
	local item = guid and perfil.equipamentos[guid]
	local cfg = item and Catalogo.porId[item.id]
	local ch = p.Character
	local hum = ch and ch:FindFirstChildOfClass("Humanoid")
	local agora = os.time()
	local pode, motivo = Reliquia.podeAtivar(cfg, {
		agora = agora, recargaAte = perfil.reliquiaRecargaAte, vivo = hum ~= nil and hum.Health > 0, atordoado = combate.atordoado(p),
	})
	if not pode then
		evento:FireClient(p, EE.REJEITADO, motivo)
		return
	end
	local antes = perfil.reliquiaRecargaAte
	local gravou = playerData.atualizar(p, function(pf)
		if pf.reliquiaRecargaAte ~= antes then
			return false
		end
		pf.reliquiaRecargaAte = Reliquia.proximaRecarga(cfg, agora)
		return true
	end)
	if not gravou then
		return
	end
	local ef = cfg.ativa
	if ef.efeito == "EscudoDeEstatica" then
		combate.reduzirDano(p, ef.reducao, ef.duracao)
	elseif ef.efeito == "FolegoEstelar" then
		movimento.recuperarEnergia(p, math.huge)
		combate.recuperarEstamina(p, math.huge)
	end
	evento:FireClient(p, EE.RELIQUIA, cfg.nome, ef.recarga, ef.recarga, ef.duracao or 0)
end

-- recompensa de chefe ou segredo: entra direto (única, fora do Depósito) e avisa
function EquipmentSystem.darReliquia(p: Player, id: string): boolean
	local cfg = Catalogo.porId[id]
	if not cfg or cfg.tipo ~= "Reliquia" then
		return false
	end
	if inventario.darReliquia(p, id) then
		evento:FireClient(p, EE.RELIQUIA_NOVA, cfg.nome, cfg.efeito)
		aplicar(p)
		return true
	end
	return false
end

local function retirar(p: Player, encaixe: string)
	local gravou = playerData.atualizar(p, function(pf)
		if pf.equipado[encaixe] == nil then
			return false
		end
		pf.equipado[encaixe] = nil
		return true
	end)
	if gravou then
		aplicar(p)
	end
end

function EquipmentSystem.Init(ctx: any)
	ctxSistemas = ctx
	evento = Remotos.evento("Equipamento")
end

function EquipmentSystem.Start()
	playerData = ctxSistemas.obter("PlayerDataSystem")
	combate = ctxSistemas.obter("CombatSystem")
	progressao = ctxSistemas.obter("ProgressionSystem")
	movimento = ctxSistemas.obter("MovementSystem")
	inventario = ctxSistemas.obter("InventorySystem")
	fabricacao = ctxSistemas.obter("CraftingSystem")
	restauracao = ctxSistemas.obter("RestorationSystem")
	playerData.carregado.conectar(function(p: Player)
		aplicar(p)
	end)
	inventario.mudou.conectar(function(p: Player)
		aplicar(p) -- item fabricado aparece na lista
	end)
	Players.PlayerAdded:Connect(function(p)
		p.CharacterAdded:Connect(function()
			task.defer(aplicar, p) -- personagem novo: vida e energia com o bônus
		end)
	end)
	for _, p in Players:GetPlayers() do
		p.CharacterAdded:Connect(function()
			task.defer(aplicar, p)
		end)
	end
	evento.OnServerEvent:Connect(function(p: Player, tipo: any, a: any, b: any)
		local bl = baldes[p]
		if not bl then
			bl = LimiteDeTaxa.novo(6, 3, os.clock())
			baldes[p] = bl
		end
		if not LimiteDeTaxa.consumir(bl, os.clock()) then
			return
		end
		if tipo == EQ.EQUIPAR and typeof(a) == "string" and typeof(b) == "string" and #a <= 64 then
			equipar(p, a, b)
		elseif tipo == EQ.RETIRAR and typeof(a) == "string" then
			retirar(p, a)
		elseif tipo == EQ.MELHORAR and typeof(a) == "string" and #a <= 64 then
			melhorar(p, a)
		elseif tipo == EQ.DESMONTAR and typeof(a) == "string" and #a <= 64 then
			desmontar(p, a)
		elseif tipo == EQ.ATIVAR_RELIQUIA then
			ativarReliquia(p)
		end
	end)
	Players.PlayerRemoving:Connect(function(p)
		baldes[p] = nil
	end)
end

return EquipmentSystem
