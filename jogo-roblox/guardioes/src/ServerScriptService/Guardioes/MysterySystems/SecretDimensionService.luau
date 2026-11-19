--!strict
-- NÃO EXECUTADO NO STUDIO. SecretDimensionService: passagens secretas para dimensões ocultas (seção 8).
--  * NÃO é um segundo sistema de viagem: descobre e abre a passagem; a VIAGEM é do DimensionSystem
--    (atravessarPara: gravação segura do perfil, trava liberada, TeleportAsync, retomada se falhar).
--  * Estados por jogador: oculto → selado → aberto (MysterySystems/PortalSecreto). "Descoberto" fica salvo;
--    "aberto" é calculado das condições a cada vez (nada a ficar desatualizado).
--  * Todas as dimensões ocultas têm placeId 0 nesta versão: abrir é possível no futuro, viajar responde
--    "em construção". Nunca há teleporte para um lugar que não existe.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local G = ReplicatedStorage:WaitForChild("Guardioes")
local PortalSecreto = require(G.MysterySystems.PortalSecreto)

local S = {}
local deps: any = nil

function S.iniciar(d: any)
	deps = d
end

local function cumpre(perfil: any, portal: any): boolean
	local c = portal.condicoes or {}
	for _, chave in c.capitulos or {} do
		local invId, n = string.match(chave, "^(.-)#(%d+)$")
		local prog = invId and perfil.misterios.investigacoes[invId]
		if not prog or not prog.capitulosConcluidos[n] then
			return false
		end
	end
	for _, e in c.enigmas or {} do
		if not perfil.misterios.enigmas[e] then
			return false
		end
	end
	return true
end

function S.estado(perfil: any, portalId: string): string
	local portal = deps.registro.portais[portalId]
	if not portal then
		return "oculto"
	end
	return PortalSecreto.estado(perfil.misterios.portais[portalId] == "descoberto", cumpre(perfil, portal))
end

-- examinar a marca do portal: descobre (salvo) e diz o estado; se aberto, tenta atravessar
function S.examinar(p: Player, portalId: string)
	local portal = deps.registro.portais[portalId]
	local perfil = deps.playerData.obter(p)
	if not portal or not perfil then
		return
	end
	if perfil.misterios.portais[portalId] ~= "descoberto" then
		local ok = deps.playerData.atualizar(p, function(pf)
			if pf.misterios.portais[portalId] then
				return false
			end
			pf.misterios.portais[portalId] = "descoberto"
			return true
		end)
		if ok then
			deps.descobriu(p, portal.nome)
		end
		perfil = deps.playerData.obter(p)
	end
	local estado = S.estado(perfil, portalId)
	local destino = deps.registro.dimensoes[portal.destino]
	local pode, motivo = PortalSecreto.podeAtravessar(estado, destino, 1, portal)
	if not pode then
		deps.aviso(p, if motivo == "portalSelado" then "A porta não tem moldura nem fechadura. Algo ainda falta para ela se abrir."
			elseif motivo == "emConstrucao" then "A porta vibra, mas o outro lado ainda não existe." else "Nada acontece.")
		return
	end
	deps.dimensoes.atravessarPara(p, destino)
end

-- lista para o diário: só portais DESCOBERTOS, com o estado (sem condições nem destino exato)
function S.paraDiario(perfil: any): { [string]: string }
	local l = {}
	for id in perfil.misterios.portais do
		l[id] = S.estado(perfil, id)
	end
	return l
end

return S
