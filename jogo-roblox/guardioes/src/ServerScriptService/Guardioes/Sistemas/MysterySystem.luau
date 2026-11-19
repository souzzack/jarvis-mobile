--!strict
-- NÃO EXECUTADO NO STUDIO. MysterySystem: ponto de entrada dos MISTÉRIOS (complemento 03).
-- Os serviços ficam isolados em ServerScriptService/Guardioes/MysterySystems/ (SecretRegistry, DiscoveryService,
-- InvestigationService, PuzzleService, SecretDimensionService, ArtifactResearchService, DiscoveryJournalService,
-- SecretRewardService). Este arquivo só os LIGA aos sistemas existentes por interfaces (sem dependência
-- circular: os serviços recebem 'deps', nunca dão require uns nos outros) e cuida da rede.
-- Rede: um RemoteEvent "Misterio". O cliente só pede: ver o diário, fabricar uma receita secreta.
-- Tudo o mais (pistas, enigmas, portais) vem de ProximityPrompts validados no servidor.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local G = ReplicatedStorage:WaitForChild("Guardioes")
local Investigacao = require(G.MysterySystems.Investigacao)
local LimiteDeTaxa = require(G.Util.LimiteDeTaxa)
local Requisitos = require(G.Util.Requisitos)
local Remotos = require(G.Rede.Remotos)
local ConfigServidor = require(script.Parent.Parent.ConfigServidor)

local Pasta = script.Parent.Parent.MysterySystems
local Registro = require(Pasta.SecretRegistry)
local Recompensas = require(Pasta.SecretRewardService)
local Investigacoes = require(Pasta.InvestigationService)
local Enigmas = require(Pasta.PuzzleService)
local Descobertas = require(Pasta.DiscoveryService)
local Portais = require(Pasta.SecretDimensionService)
local PesquisaSvc = require(Pasta.ArtifactResearchService)
local Diario = require(Pasta.DiscoveryJournalService)

local MI = Remotos.Misterio
local EM = Remotos.EventoMisterio

local MysterySystem = { Nome = "MysterySystem" }

local evento: RemoteEvent
local ctxSistemas: any = nil
local baldes: { [Player]: LimiteDeTaxa.Balde } = {}

local function enviarDiario(p: Player)
	local v = Diario.montar(p)
	if v then
		evento:FireClient(p, EM.DIARIO, v)
	end
end

function MysterySystem.Init(ctx: any)
	ctxSistemas = ctx
	evento = Remotos.evento("Misterio")
end

function MysterySystem.Start()
	local playerData = ctxSistemas.obter("PlayerDataSystem")
	local deps: any = {
		registro = Registro,
		Investigacao = Investigacao,
		playerData = playerData,
		inventario = ctxSistemas.obter("InventorySystem"),
		progressao = ctxSistemas.obter("ProgressionSystem"),
		companheiros = ctxSistemas.obter("CompanionSystem"),
		fabricacao = ctxSistemas.obter("CraftingSystem"),
		dimensoes = ctxSistemas.obter("DimensionSystem"),
		recompensas = Recompensas,
		investigacoes = Investigacoes,
		puzzles = Enigmas,
		portais = Portais,
		pesquisa = PesquisaSvc,
		pertoDoEnigma = function(p: Player, puzzleId: string): boolean
			return Descobertas.pertoDoEnigma(p, puzzleId)
		end,
		aviso = function(p: Player, texto: string)
			evento:FireClient(p, EM.AVISO, texto)
		end,
		descobriu = function(p: Player, nome: string)
			evento:FireClient(p, EM.DESCOBERTA, nome)
			enviarDiario(p)
		end,
		-- progresso para Requisitos (restaurações, missões…), com o progresso FINGIDO só da arena de teste
		progressoRequisitos = function(p: Player, perfil: any): any
			local base = {
				missoes = perfil.missoes, restauracoes = perfil.restauracoes, segredos = perfil.segredos,
				dimensoes = perfil.dimensoes, enigmas = perfil.enigmas, livros = perfil.livrosLidos, habilidades = perfil.habilidades,
			}
			local teste = ConfigServidor.concessoesDeTeste
			if teste and teste.ativa and teste.progressoLivros then
				return Requisitos.unir(base, teste.progressoLivros)
			end
			return Requisitos.unir(base)
		end,
		enigma = function(p: Player, marcaId: string, resultado: string, motivo: string?, info: string?)
			-- só o resultado (certo/errado/completo) e o texto curto; nunca a ordem
			evento:FireClient(p, EM.ENIGMA, marcaId, resultado, motivo, info)
			if resultado == "completo" then
				enviarDiario(p)
			end
		end,
		reacao = function(p: Player, posicao: Vector3, animacao: string)
			evento:FireClient(p, EM.REACAO, posicao, animacao)
		end,
	}
	for _, s in { Recompensas, Investigacoes, Enigmas, Descobertas, Portais, PesquisaSvc, Diario } do
		s.iniciar(deps)
	end
	local teste = ConfigServidor.marcadoresDeTeste
	local salaDeTeste = if teste and teste.ativa and ConfigServidor.arenaDeTeste.ativa then teste.misterios else nil
	Descobertas.iniciarMapa(salaDeTeste, ConfigServidor.arenaDeTeste.centro)
	playerData.carregado.conectar(function(p: Player)
		task.spawn(function()
			Investigacoes.reconciliar(p) -- recompensa de capítulo que ficou sem pagar
			enviarDiario(p)
		end)
	end)
	ctxSistemas.obter("InventorySystem").mudou.conectar(function(p: Player)
		-- etapa "componentes" das pesquisas depende da bolsa; só reenvia se houver pesquisa começada
		local perfil = playerData.obter(p)
		if perfil and next(perfil.misterios.receitas) then
			enviarDiario(p)
		end
	end)
	evento.OnServerEvent:Connect(function(p: Player, tipo: any, a: any)
		local b = baldes[p]
		if not b then
			b = LimiteDeTaxa.novo(4, 1, os.clock())
			baldes[p] = b
		end
		if not LimiteDeTaxa.consumir(b, os.clock()) then
			return
		end
		if tipo == MI.VER_DIARIO then
			enviarDiario(p)
		elseif tipo == MI.FABRICAR_SECRETO and typeof(a) == "string" and #a <= 64 then
			local ok, motivo, faltando = PesquisaSvc.fabricar(p, a)
			if ok then
				evento:FireClient(p, EM.AVISO, "Fabricado com o conhecimento dos Arquivistas.")
				enviarDiario(p)
			else
				evento:FireClient(p, EM.REJEITADO, motivo, faltando)
			end
		end
	end)
	task.spawn(function()
		while true do
			task.wait(1)
			local ok, erro = pcall(Descobertas.passoDeReacao)
			if not ok then
				warn("[Guardioes] mistérios (reação): " .. tostring(erro))
			end
		end
	end)
	Players.PlayerRemoving:Connect(function(p)
		baldes[p] = nil
		Enigmas.sair(p)
		Descobertas.sair(p)
	end)
end

return MysterySystem
