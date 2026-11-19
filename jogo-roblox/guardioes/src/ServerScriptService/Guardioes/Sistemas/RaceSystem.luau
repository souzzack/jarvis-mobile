--!strict
-- NÃO EXECUTADO NO STUDIO. RaceSystem: escolha de raça (Sistema 6 do complemento).
--  * Quem ainda não tem raça salva recebe o pedido de escolha (janela no cliente). Nenhuma raça é obrigatória
--    para a história ou os segredos (docs/07, seção 6).
--  * Valores ainda são PROVISÓRIOS (o prompt pede não fechar números antes do balanceamento). Por isso a
--    troca é livre até o nível 5; depois disso, só pelo "Ritual de Origem" (missão futura — ganchos prontos).
--  * O efeito vem de quem já existe: habilidades de raça e restrições (MovementAbilitySystem), vida
--    (ProgressionSystem, ao ouvir 'mudou'), energia de voo (MovementSystem, ao renascer).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local G = ReplicatedStorage:WaitForChild("Guardioes")
local Racas = require(G.Config.Racas)
local LimiteDeTaxa = require(G.Util.LimiteDeTaxa)
local Remotos = require(G.Rede.Remotos)

local RA = Remotos.Raca
local ER = Remotos.EventoRaca
local NIVEL_TROCA_LIVRE = 5

local RaceSystem = { Nome = "RaceSystem" }

local evento: RemoteEvent
local playerData: any
local habilidades: any
local progressao: any
local ctxSistemas: any = nil
local baldes: { [Player]: LimiteDeTaxa.Balde } = {}

local function lista(): { any }
	local l = {}
	for _, r in Racas.lista do
		table.insert(l, { id = r.id, nome = r.nome, identidade = r.identidade, vantagens = r.vantagens, limitacoes = r.limitacoes })
	end
	return l
end

local function escolher(p: Player, id: any)
	if typeof(id) ~= "string" or not Racas.porId[id] then
		return
	end
	local perfil = playerData.obter(p)
	if not perfil then
		return
	end
	if perfil.raca ~= nil and progressao.nivel(p) > NIVEL_TROCA_LIVRE then
		evento:FireClient(p, ER.REJEITADO, "racaFixa")
		return
	end
	if habilidades.definirRaca(p, id) then
		evento:FireClient(p, ER.DEFINIDA, id, Racas.porId[id].nome)
	end
end

function RaceSystem.Init(ctx: any)
	ctxSistemas = ctx
	evento = Remotos.evento("Raca")
end

function RaceSystem.Start()
	playerData = ctxSistemas.obter("PlayerDataSystem")
	habilidades = ctxSistemas.obter("MovementAbilitySystem")
	progressao = ctxSistemas.obter("ProgressionSystem")
	playerData.carregado.conectar(function(p: Player, perfil: any)
		local podeTrocar = perfil.raca == nil or perfil.nivel <= NIVEL_TROCA_LIVRE
		evento:FireClient(p, ER.LISTA, lista(), perfil.raca, podeTrocar, perfil.raca == nil)
	end)
	evento.OnServerEvent:Connect(function(p: Player, tipo: any, id: any)
		local b = baldes[p]
		if not b then
			b = LimiteDeTaxa.novo(3, 0.5, os.clock())
			baldes[p] = b
		end
		if tipo == RA.ESCOLHER and LimiteDeTaxa.consumir(b, os.clock()) then
			escolher(p, id)
		end
	end)
	Players.PlayerRemoving:Connect(function(p)
		baldes[p] = nil
	end)
end

return RaceSystem
