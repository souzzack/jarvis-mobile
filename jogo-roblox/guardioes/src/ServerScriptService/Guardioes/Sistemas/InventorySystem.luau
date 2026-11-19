--!strict
-- NÃO EXECUTADO NO STUDIO. InventorySystem: materiais e artefatos (GUID) do jogador.
--  * Duas bolsas: a SALVA (perfil.materiais / perfil.artefatos, via PlayerData.atualizar) e a de TESTE (memória,
--    ConfigServidor.concessoesDeTeste; nunca salva). As consultas somam as duas.
--  * transacao(p, { consumir, estagio }) é ATÔMICA: planeja o consumo sobre as duas bolsas; grava a parte salva
--    numa transação do PlayerData e só então aplica a parte de teste. Se faltar algo, nada muda.
--  * Itens nunca são criados pelo cliente: darMateriais/darArtefato só são chamados por sistemas do servidor
--    (saque, missões, fabricação).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local G = ReplicatedStorage:WaitForChild("Guardioes")
local Bolsa = require(G.Inventario.Bolsa)
local Materiais = require(G.Config.Materiais)
local BaseLogica = require(G.Base.Base)
local CfgBase = require(G.Config.Base)
local Sinal = require(G.Util.Sinal)
local Remotos = require(G.Rede.Remotos)
local ConfigServidor = require(script.Parent.Parent.ConfigServidor)
local Perfil = require(script.Parent.Parent.Dados.Perfil)

local EI = Remotos.EventoInventario

local InventorySystem = { Nome = "InventorySystem" }
InventorySystem.mudou = Sinal.novo() -- (p)

local teste: { [Player]: Bolsa.Bolsa } = {}
local evento: RemoteEvent
local playerData: any
local ctxSistemas: any = nil

local function temTransporte(perfil: any, id: string): boolean
	return perfil.transportes ~= nil and perfil.transportes[id] == true
end

local function bolsaSalva(p: Player): Bolsa.Bolsa
	local perfil = playerData.obter(p)
	if not perfil then
		return Bolsa.nova()
	end
	return { materiais = perfil.materiais, artefatos = perfil.artefatos }
end

local function bolsas(p: Player): { Bolsa.Bolsa }
	return { teste[p] or Bolsa.nova(), bolsaSalva(p) }
end

local function enviar(p: Player)
	local lista = {}
	local vistos: { [string]: boolean } = {}
	local bs = bolsas(p)
	for _, b in bs do
		for id in b.materiais do
			if not vistos[id] then
				vistos[id] = true
				local m = Materiais.porId[id]
				table.insert(lista, { id = id, nome = if m then m.nome else id, qtd = Bolsa.contar(bs, id) })
			end
		end
	end
	table.sort(lista, function(a, b)
		return a.nome < b.nome
	end)
	evento:FireClient(p, EI.MATERIAIS, lista)
end

local function avisar(p: Player)
	InventorySystem.mudou.disparar(p)
	enviar(p)
end

-- ------------------------------------------------------------------ API (servidor)
function InventorySystem.contar(p: Player, id: string): number
	return Bolsa.contar(bolsas(p), id)
end

-- artefatos do jogador: lista { guid, id, estagio, teste }
function InventorySystem.artefatos(p: Player): { any }
	local l = {}
	local t = teste[p]
	if t then
		for guid, a in t.artefatos do
			table.insert(l, { guid = guid, id = a.id, estagio = a.estagio, teste = true })
		end
	end
	for guid, a in bolsaSalva(p).artefatos do
		table.insert(l, { guid = guid, id = a.id, estagio = a.estagio, teste = false })
	end
	return l
end

function InventorySystem.possui(p: Player, guid: string): boolean
	local t = teste[p]
	return (t ~= nil and t.artefatos[guid] ~= nil) or bolsaSalva(p).artefatos[guid] ~= nil
end

function InventorySystem.darMateriais(p: Player, pedido: { [string]: number }, origem: string): { [string]: number }
	local entregue: { [string]: number } = {}
	local ok = playerData.atualizar(p, function(perfil)
		local b = { materiais = perfil.materiais, artefatos = perfil.artefatos }
		for id, q in pedido do
			local entrou = Bolsa.adicionarMaterial(b, id, q, Perfil.LIMITES.pilha)
			if entrou > 0 then
				entregue[id] = entrou
			end
		end
		return true
	end)
	if not ok then
		return {}
	end
	local _ = origem -- (Etapa D+) registro de origem para auditoria anti-abuso
	avisar(p)
	if next(entregue) then
		evento:FireClient(p, EI.SAQUE, entregue) -- aviso "+2 Fragmento de Faísca"
	end
	return entregue
end

function InventorySystem.darArtefato(p: Player, id: string, estagio: number): string?
	local guid = HttpService:GenerateGUID(false)
	local ok = playerData.atualizar(p, function(perfil)
		perfil.artefatos[guid] = { id = id, estagio = estagio }
		return true
	end)
	if not ok then
		return nil
	end
	avisar(p)
	return guid
end

-- Transação atômica: consome materiais, (opcional) muda o estágio de um artefato e (opcional) ENTREGA
-- materiais / um artefato novo — tudo na mesma gravação. (ok, faltando)
function InventorySystem.transacao(p: Player, t: { consumir: { [string]: number }?, artefato: string?, estagio: number?, darMateriais: { [string]: number }?, darArtefato: { id: string, estagio: number }?, darEquipamento: string?, darTransporte: string?, alterarPerfil: ((any) -> boolean?)? }): (boolean, { any })
	local bs = bolsas(p)
	local okPlano, plano, faltando = Bolsa.planejarConsumo(bs, t.consumir or {})
	if not okPlano then
		return false, faltando
	end
	local guid = t.artefato
	local tb = teste[p]
	local artefatoDeTeste = guid ~= nil and tb ~= nil and tb.artefatos[guid] ~= nil
	if guid and not artefatoDeTeste and not bolsaSalva(p).artefatos[guid] then
		return false, { { id = "artefato", tem = 0, precisa = 1 } }
	end
	-- 1) parte salva (transação do PlayerData: tudo ou nada)
	local motivoFalha = "gravacao"
	local ok = playerData.atualizar(p, function(perfil)
		local b = { materiais = perfil.materiais, artefatos = perfil.artefatos }
		Bolsa.aplicarConsumo(b, plano[2])
		if guid and not artefatoDeTeste and t.estagio then
			perfil.artefatos[guid].estagio = t.estagio
		end
		for id, q in t.darMateriais or {} do
			local _, sobra = Bolsa.adicionarMaterial(b, id, q, Perfil.LIMITES.pilha)
			if sobra > 0 then
				return false -- pilha cheia: desfaz tudo (nada consumido)
			end
		end
		if t.darArtefato then
			perfil.artefatos[HttpService:GenerateGUID(false)] = { id = t.darArtefato.id, estagio = t.darArtefato.estagio }
		end
		if t.darTransporte then
			if temTransporte(perfil, t.darTransporte) then
				return false -- já tem: não consome materiais à toa
			end
			perfil.transportes[t.darTransporte] = true
		end
		if t.darEquipamento then
			-- Depósito da base: quantos equipamentos cabem (nada é consumido se não couber)
			local n = 0
			for _ in perfil.equipamentos do
				n += 1
			end
			if n >= BaseLogica.capacidadeDoDeposito(perfil.base, CfgBase.espacos.Deposito) then
				motivoFalha = "depositoCheio"
				return false
			end
			perfil.equipamentos[HttpService:GenerateGUID(false)] = { id = t.darEquipamento }
		end
		-- mudança extra no perfil na MESMA gravação (ex.: progresso de restauração pago com estes materiais)
		if t.alterarPerfil and t.alterarPerfil(perfil) == false then
			return false
		end
		return true
	end)
	if not ok then
		return false, { { id = motivoFalha, tem = 0, precisa = 1 } }
	end
	-- 2) parte de teste (memória; não falha)
	if tb then
		Bolsa.aplicarConsumo(tb, plano[1])
		if guid and artefatoDeTeste and t.estagio then
			tb.artefatos[guid].estagio = t.estagio
		end
	end
	avisar(p)
	return true, {}
end

-- Tira materiais SÓ da parte salva (nunca da bolsa de teste): usado por quem leva itens para fora do perfil
-- (cofre da companhia), para concessões de teste nunca virarem itens persistidos em outro lugar.
function InventorySystem.retirarSalvo(p: Player, id: string, qtd: number): boolean
	local ok = playerData.atualizar(p, function(perfil)
		local tem = perfil.materiais[id] or 0
		if qtd <= 0 or tem < qtd then
			return false
		end
		perfil.materiais[id] = if tem == qtd then nil else tem - qtd
		return true
	end)
	if ok then
		avisar(p)
	end
	return ok
end

function InventorySystem.definirEquipado(p: Player, guid: string)
	if bolsaSalva(p).artefatos[guid] then
		playerData.atualizar(p, function(perfil)
			perfil.artefatoEquipado = guid
			return true
		end)
	end
end

function InventorySystem.equipadoSalvo(p: Player): string?
	local perfil = playerData.obter(p)
	return if perfil then perfil.artefatoEquipado else nil
end

-- ------------------------------------------------------------------ ciclo de vida
function InventorySystem.Init(ctx: any)
	ctxSistemas = ctx
	evento = Remotos.evento("Inventario")
end

function InventorySystem.Start()
	playerData = ctxSistemas.obter("PlayerDataSystem")
	local cfgTeste = ConfigServidor.concessoesDeTeste
	local function entrar(p: Player)
		local b = Bolsa.nova()
		if cfgTeste and cfgTeste.ativa then
			for _, a in cfgTeste.artefatos or {} do
				b.artefatos[HttpService:GenerateGUID(false)] = { id = a.id, estagio = a.estagio }
			end
			for id, q in cfgTeste.materiais or {} do
				b.materiais[id] = q
			end
		end
		teste[p] = b
		avisar(p)
	end
	for _, p in Players:GetPlayers() do
		entrar(p)
	end
	Players.PlayerAdded:Connect(entrar)
	Players.PlayerRemoving:Connect(function(p)
		teste[p] = nil
	end)
	playerData.carregado.conectar(function(p: Player)
		avisar(p) -- artefatos e materiais salvos chegam
	end)
end

return InventorySystem
