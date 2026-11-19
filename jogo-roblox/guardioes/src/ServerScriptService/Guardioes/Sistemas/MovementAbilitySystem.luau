--!strict
-- NÃO EXECUTADO NO STUDIO. MovementAbilitySystem: o que cada personagem SABE fazer (habilidades de movimento)
-- e a raça. Fonte única da verdade no servidor; o cliente só recebe a lista para a interface.
--
-- Persistência: lê perfil.habilidades / perfil.raca quando o PlayerDataSystem carrega e grava cada habilidade
-- nova por PlayerData.atualizar (transação). Concessões de TESTE (origem "teste") ficam só na memória e nunca
-- entram no perfil; aprender de verdade algo que era de teste troca a origem e salva.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local G = ReplicatedStorage:WaitForChild("Guardioes")
local Habilidades = require(G.Config.Locomocao.Habilidades)
local Racas = require(G.Config.Racas)
local Remotos = require(G.Rede.Remotos)
local Sinal = require(G.Util.Sinal)
local ConfigServidor = require(script.Parent.Parent.ConfigServidor)

local EL = Remotos.EventoLocomocao

type Dados = { habilidades: { [string]: string }, raca: string } -- habilidade → origem

local MovementAbilitySystem = { Nome = "MovementAbilitySystem" }
MovementAbilitySystem.mudou = Sinal.novo() -- (p)

local dados: { [Player]: Dados } = {}
local evento: RemoteEvent
local playerData: any
local ctxSistemas: any = nil

local function enviar(p: Player)
	local d = dados[p]
	if not d then
		return
	end
	local lista = {}
	for id in d.habilidades do
		local h = Habilidades.porId[id]
		if h and not h.oculta then
			table.insert(lista, id)
		end
	end
	table.sort(lista)
	evento:FireClient(p, EL.HABILIDADES, lista, d.raca)
end

function MovementAbilitySystem.tem(p: Player, id: string): boolean
	local d = dados[p]
	return d ~= nil and d.habilidades[id] ~= nil
end

function MovementAbilitySystem.raca(p: Player): any
	local d = dados[p]
	return Racas.porId[if d then d.raca else "Humano"]
end

function MovementAbilitySystem.lista(p: Player): { string }
	local d = dados[p]
	local l = {}
	if d then
		for id in d.habilidades do
			table.insert(l, id)
		end
	end
	return l
end

-- SÓ o servidor chama (livros, raça, missões, artefatos). Idempotente: aprender de novo não duplica nada.
function MovementAbilitySystem.conceder(p: Player, id: string, origem: string): boolean
	local d = dados[p]
	if not d or not Habilidades.porId[id] then
		return false
	end
	local atual = d.habilidades[id]
	if atual and not (atual == "teste" and origem ~= "teste") then
		return false
	end
	if origem ~= "teste" then
		local ok = playerData.atualizar(p, function(perfil)
			perfil.habilidades[id] = origem
			return true
		end)
		if not ok then
			return false
		end
	end
	d.habilidades[id] = origem
	MovementAbilitySystem.mudou.disparar(p)
	enviar(p)
	return true
end

-- aplica a raça na memória: tira as habilidades de raça antigas, põe as novas e as restrições
local function aplicarRaca(d: Dados, racaId: string)
	for id, origem in d.habilidades do
		if origem == "raca" then
			d.habilidades[id] = nil
		end
	end
	d.raca = racaId
	local raca = Racas.porId[racaId]
	if raca then
		for _, id in raca.habilidadesIniciais do
			d.habilidades[id] = "raca"
		end
		for _, r in raca.restricoes do
			if r == "SemPlanador" then
				d.habilidades["Planador"] = nil -- só em memória: se trocar de raça, volta a valer o que foi salvo
			end
		end
	end
end

-- RaceSystem chama depois de validar a escolha; grava perfil.raca (transação)
function MovementAbilitySystem.definirRaca(p: Player, racaId: string): boolean
	local d = dados[p]
	if not d or not Racas.porId[racaId] then
		return false
	end
	local ok = playerData.atualizar(p, function(perfil)
		perfil.raca = racaId
		return true
	end)
	if not ok then
		return false
	end
	-- recoloca as habilidades salvas (a restrição de uma raça antiga pode ter tirado alguma da memória)
	local perfil = playerData.obter(p)
	if perfil then
		for id, origem in perfil.habilidades do
			if Habilidades.porId[id] then
				d.habilidades[id] = origem
			end
		end
	end
	aplicarRaca(d, racaId)
	MovementAbilitySystem.mudou.disparar(p)
	enviar(p)
	return true
end

-- fontes de modificadores para PerfilEfetivo (habilidades com 'mods' ou 'liberaImpulso')
function MovementAbilitySystem.fontes(p: Player): { any }
	local f = {}
	local d = dados[p]
	if d then
		for id in d.habilidades do
			local h = Habilidades.porId[id]
			if h and (h.mods or h.liberaImpulso) then
				table.insert(f, h)
			end
		end
	end
	return f
end

function MovementAbilitySystem.Init(ctx: any)
	ctxSistemas = ctx
	evento = Remotos.evento("Locomocao")
end

function MovementAbilitySystem.Start()
	playerData = ctxSistemas.obter("PlayerDataSystem")
	local teste = ConfigServidor.concessoesDeTeste
	-- perfil salvo chega depois (assíncrono): soma as habilidades salvas e a raça escolhida
	local function somarPerfil(p: Player, perfil: any)
		local d = dados[p]
		if not d then
			return
		end
		for id, origem in perfil.habilidades do
			if Habilidades.porId[id] then
				d.habilidades[id] = origem
			end
		end
		if perfil.raca and Racas.porId[perfil.raca] then
			aplicarRaca(d, perfil.raca)
		end
		MovementAbilitySystem.mudou.disparar(p)
		enviar(p)
	end
	playerData.carregado.conectar(somarPerfil)
	local function entrar(p: Player)
		local d: Dados = { habilidades = {}, raca = "Humano" }
		if teste and teste.ativa then
			d.raca = teste.raca
			for _, id in teste.habilidades do
				d.habilidades[id] = "teste"
			end
		end
		local raca = Racas.porId[d.raca]
		if raca then
			for _, id in raca.habilidadesIniciais do
				d.habilidades[id] = "raca"
			end
			-- restrição de raça vence concessão (ex.: Alado não usa planador)
			for _, r in raca.restricoes do
				if r == "SemPlanador" then
					d.habilidades["Planador"] = nil
				end
			end
		end
		dados[p] = d
		local salvo = playerData.obter(p) -- se o perfil já carregou antes deste ponto
		if salvo then
			somarPerfil(p, salvo)
		end
		MovementAbilitySystem.mudou.disparar(p)
		enviar(p)
		p.CharacterAdded:Connect(function()
			enviar(p)
		end)
	end
	for _, p in Players:GetPlayers() do
		entrar(p)
	end
	Players.PlayerAdded:Connect(entrar)
	Players.PlayerRemoving:Connect(function(p)
		dados[p] = nil
	end)
end

return MovementAbilitySystem
