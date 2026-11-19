--!strict
-- NÃO EXECUTADO NO STUDIO. TransportSystem: transportes COMUNS e a tela de gerenciamento (Sistemas 8 e 14).
--  * Posse de transportes comuns (prancha de viagem) em perfil.transportes; nascem na fabricação.
--  * Libera no MovementSystem o perfil por POSSE (registrarAcessoPorPosse): o cliente nunca "liga" um perfil.
--  * LISTA para a tela: cada transporte com disponível/indisponível e o requisito em texto público, mais
--    velocidade e custo de energia do perfil EFETIVO (quando há perfil).
--  * PREFERIR(id): qual transporte a tecla de voo usa (Asas, Voo mágico ou Prancha de viagem). Salvo.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local G = ReplicatedStorage:WaitForChild("Guardioes")
local Transportes = require(G.Config.Transportes)
local Perfis = require(G.Config.Locomocao.Perfis)
local LimiteDeTaxa = require(G.Util.LimiteDeTaxa)
local Remotos = require(G.Rede.Remotos)

local TR = Remotos.Transporte
local ET = Remotos.EventoTransporte

local TransportSystem = { Nome = "TransportSystem" }

local evento: RemoteEvent
local playerData: any
local habilidades: any
local artefatos: any
local companheiros: any
local ctxSistemas: any = nil
local baldes: { [Player]: LimiteDeTaxa.Balde } = {}

local ARTEFATO_DO_PERFIL: { [string]: { id: string, estagio: number } } = {
	PranchaHorizonte = { id = "EspadaDoHorizonte", estagio = 2 },
	PlataformaFirmamento = { id = "EscudoDoFirmamento", estagio = 2 },
	VassouraVentos = { id = "CajadoDosVentosAntigos", estagio = 2 },
}

local function disponivel(p: Player, perfil: any, t: any): boolean
	if t.id == "AsasNaturais" or t.id == "VooMagico" or t.id == "Planador" then
		return habilidades.tem(p, t.id)
	elseif t.tipo == "Prancha" then
		return perfil.transportes[t.id] == true
	elseif t.tipo == "Artefato" then
		local alvo = ARTEFATO_DO_PERFIL[t.perfil]
		for _, a in artefatos.listaDe(p) do
			if a.id == alvo.id and a.estagio >= alvo.estagio then
				return true
			end
		end
		return false
	elseif t.tipo == "Montaria" then
		local c, esp = companheiros.ativa(p)
		return c ~= nil and esp ~= nil and esp.montaria ~= nil and c.estagio == "Adulto"
	end
	return false
end

local function enviar(p: Player)
	local perfil = playerData.obter(p)
	if not perfil then
		return
	end
	local lista = {}
	for _, t in Transportes.lista do
		local base = t.perfil and Perfis.porId[t.perfil]
		table.insert(lista, {
			id = t.id, nome = t.nome, tipo = t.tipo, disponivel = disponivel(p, perfil, t),
			requisito = t.requisito, preferivel = Transportes.preferiveis[t.id] == true,
			velMax = base and base.velMax, custo = base and base.custoPorSeg, impulso = base and base.velImpulso or 0,
		})
	end
	evento:FireClient(p, ET.LISTA, lista, perfil.transportePreferido)
end

function TransportSystem.possui(p: Player, id: string): boolean
	local perfil = playerData.obter(p)
	return perfil ~= nil and perfil.transportes[id] == true
end

function TransportSystem.Init(ctx: any)
	ctxSistemas = ctx
	evento = Remotos.evento("Transporte")
end

function TransportSystem.Start()
	playerData = ctxSistemas.obter("PlayerDataSystem")
	habilidades = ctxSistemas.obter("MovementAbilitySystem")
	artefatos = ctxSistemas.obter("MetamorphicArtifactSystem")
	companheiros = ctxSistemas.obter("CompanionSystem")
	local movimento = ctxSistemas.obter("MovementSystem")
	local inventario = ctxSistemas.obter("InventorySystem")
	movimento.registrarAcessoPorPosse("PranchaComum", function(p: Player)
		return TransportSystem.possui(p, "PranchaComum")
	end)
	playerData.carregado.conectar(function(p: Player)
		enviar(p)
	end)
	inventario.mudou.conectar(function(p: Player)
		enviar(p) -- prancha fabricada, artefato que evoluiu
	end)
	habilidades.mudou.conectar(function(p: Player)
		enviar(p)
	end)
	evento.OnServerEvent:Connect(function(p: Player, tipo: any, id: any)
		local b = baldes[p]
		if not b then
			b = LimiteDeTaxa.novo(4, 1, os.clock())
			baldes[p] = b
		end
		if not LimiteDeTaxa.consumir(b, os.clock()) then
			return
		end
		if tipo == TR.LISTAR then
			enviar(p)
		elseif tipo == TR.PREFERIR and typeof(id) == "string" and Transportes.preferiveis[id] then
			local perfil = playerData.obter(p)
			local t
			for _, x in Transportes.lista do
				if x.id == id then
					t = x
				end
			end
			if not perfil or not t or not disponivel(p, perfil, t) then
				evento:FireClient(p, ET.REJEITADO, "indisponivel")
				return
			end
			playerData.atualizar(p, function(pf)
				pf.transportePreferido = id
				return true
			end)
			enviar(p)
		end
	end)
	Players.PlayerRemoving:Connect(function(p)
		baldes[p] = nil
	end)
end

return TransportSystem
