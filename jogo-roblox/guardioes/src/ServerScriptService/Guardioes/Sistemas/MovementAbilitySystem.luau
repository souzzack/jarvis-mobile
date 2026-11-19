--!strict
-- NÃO EXECUTADO NO STUDIO. MovementAbilitySystem: o que cada personagem SABE fazer (habilidades de movimento)
-- e a raça. Fonte única da verdade no servidor; o cliente só recebe a lista para a interface.
--
-- Persistência: ainda não existe PlayerDataSystem. Contrato (docs/08): no Init do PlayerDataSystem, este sistema
-- passará a ler perfil.habilidades / perfil.raca e a gravar por PlayerData.atualizar(p, fn). Até lá, com
-- ConfigServidor.concessoesDeTeste.ativa, cada jogador recebe um pacote de TESTE que não é salvo.

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
	if not d or not Habilidades.porId[id] or d.habilidades[id] then
		return false
	end
	d.habilidades[id] = origem
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

function MovementAbilitySystem.Init(_ctx: any)
	evento = Remotos.evento("Locomocao")
end

function MovementAbilitySystem.Start()
	local teste = ConfigServidor.concessoesDeTeste
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
