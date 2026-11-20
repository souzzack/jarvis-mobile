--!strict
-- NÃO EXECUTADO NO STUDIO. PuzzleService: estado de SESSÃO dos enigmas e validação de cada ação.
--  * individual: um estado por jogador e enigma (memória). O RESULTADO (resolvido) é persistente
--    (perfil.misterios.enigmas); um meio-caminho não é salvo: ao voltar, recomeça a sequência (de propósito).
--  * cooperativo: um estado de sessão por enigma no servidor, separado do progresso de cada jogador. Quando
--    completa, cada participante que AINDA está perto recebe o objetivo/recompensa individualmente.
--  * A ordem/alvo sai da semente do jogador (Segredos/Descoberta + sal secreto): copiar a resposta não serve.
-- Distância e frequência são conferidas pelo DiscoveryService antes de chegar aqui.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local G = ReplicatedStorage:WaitForChild("Guardioes")
local Enigma = require(G.MysterySystems.Enigma)
local Descoberta = require(G.Segredos.Descoberta)
local Requisitos = require(G.Util.Requisitos)

local S = {}
local deps: any = nil
local individuais: { [Player]: { [string]: any } } = {}
local cooperativos: { [string]: any } = {}

function S.iniciar(d: any)
	deps = d
end

function S.semente(p: Player, puzzleId: string): number
	return Descoberta.semente(p.UserId, deps.registro.sal .. puzzleId)
end

-- DICAS deste jogador para preencher {1} {2} {3} no texto das pistas (nunca enviadas como lista):
--  Sequencia: o nome de cada elemento na ordem; Alinhamento: "<elemento> voltado para o <direção>"
function S.dicasDe(p: Player, puzzleId: string): { string }
	local cfg = deps.registro.puzzles[puzzleId]
	local st = Enigma.novo(cfg, S.semente(p, puzzleId))
	local l = {}
	if cfg.tipo == "Sequencia" then
		for i, el in st.ordem do
			l[i] = (cfg.nomes and cfg.nomes[el]) or "?"
		end
	elseif cfg.tipo == "Alinhamento" then
		for i, el in cfg.elementos do
			local direcao = cfg.nomesPosicoes and cfg.nomesPosicoes[st.alvo[el]] or tostring(st.alvo[el])
			l[i] = string.format("%s voltado para o %s", (cfg.nomes and cfg.nomes[el]) or el, direcao)
		end
	end
	return l
end

local function estadoIndividual(p: Player, puzzleId: string, cfg: any): any
	local porJogador = individuais[p] or {}
	individuais[p] = porJogador
	local st = porJogador[puzzleId]
	if not st then
		st = Enigma.novo(cfg, S.semente(p, puzzleId))
		porJogador[puzzleId] = st
	end
	return st
end

-- marca o objetivo da investigação para um jogador (o enigma conta como resolvido junto)
local function resolverPara(p: Player, puzzleId: string, cfg: any): boolean
	if cfg.objetivo then
		local ok = deps.investigacoes.cumprirObjetivo(p, cfg.objetivo.investigacao, cfg.objetivo.id, puzzleId)
		return ok
	end
	return deps.playerData.atualizar(p, function(pf)
		if pf.misterios.enigmas[puzzleId] then
			return false
		end
		pf.misterios.enigmas[puzzleId] = true
		return true
	end)
end

-- (resultado, motivo, info?). ctx: { capacidades?, dentro?, marcas? } calculado pelo servidor.
-- info: texto curto para o jogador (no Alinhamento, para onde o cristal ficou apontando)
function S.agir(p: Player, puzzleId: string, elemento: string, ctx: any): (string, string?, string?)
	local cfg = deps.registro.puzzles[puzzleId]
	local perfil = deps.playerData.obter(p)
	if not cfg or not perfil then
		return "invalida", "erro", nil
	end
	if perfil.misterios.enigmas[puzzleId] then
		return "semEfeito", "jaResolvido", nil
	end
	-- pré-requisito: o objetivo do enigma precisa estar VISÍVEL na investigação (pistas reunidas)
	if cfg.objetivo then
		local inv = deps.registro.investigacao(cfg.objetivo.investigacao)
		local prog = perfil.misterios.investigacoes[cfg.objetivo.investigacao]
		if not prog then
			return "semEfeito", "nadaAcontece", nil
		end
		local visivel = false
		for _, o in deps.Investigacao.objetivosVisiveis(prog, inv) do
			if o.id == cfg.objetivo.id then
				visivel = true
			end
		end
		if not visivel then
			return "semEfeito", "nadaAcontece", nil -- sem as pistas, o mecanismo não reage
		end
	end
	-- requisitos de outros sistemas (ex.: Torre Meteorológica restaurada) — a mesma regra dos livros
	if cfg.requisitos then
		local okReq = Requisitos.avaliar(cfg.requisitos, deps.progressoRequisitos(p, perfil))
		if not okReq then
			return "semEfeito", "semRequisito", cfg.semRequisito
		end
	end
	if cfg.escopo == "cooperativo" then
		local st = cooperativos[puzzleId]
		if not st then
			st = Enigma.novo(cfg, 0)
			cooperativos[puzzleId] = st
		end
		local r = Enigma.agir(st, cfg, { elemento = elemento, jogador = tostring(p.UserId), agora = os.clock() }, ctx)
		if r == "completo" then
			for _, uid in Enigma.participantes(st) do
				local q = Players:GetPlayerByUserId(tonumber(uid) or 0)
				if q and deps.pertoDoEnigma(q, puzzleId) then -- participação conferida na hora de pagar
					resolverPara(q, puzzleId, cfg)
				end
			end
			cooperativos[puzzleId] = nil -- próxima equipe começa do zero
		end
		return r, nil, nil
	end
	local st = estadoIndividual(p, puzzleId, cfg)
	local acao = if cfg.tipo == "Coleta" then { item = elemento } elseif cfg.tipo == "Exploracao" then { alvo = elemento } else { elemento = elemento }
	local r = Enigma.agir(st, cfg, acao, ctx)
	local info = nil
	if cfg.tipo == "Alinhamento" and st.pos and st.pos[elemento] and cfg.nomesPosicoes then
		info = string.format("O %s agora aponta para o %s.", (cfg.nomes and cfg.nomes[elemento]) or elemento, cfg.nomesPosicoes[st.pos[elemento]])
	end
	if cfg.tipo == "Coleta" and r == "certo" then
		local n, total = 0, #cfg.itens
		for _ in st.tem do
			n += 1
		end
		-- artigo do item (cfg.artigo: "o" ou "a"; padrão "o"): "o dente", "a página"
		info = string.format("Você guardou %s %s (%d de %d).", cfg.artigo or "o", (cfg.nomes and cfg.nomes[elemento]) or "item", n, total)
	elseif cfg.tipo == "Coleta" and r == "semEfeito" then
		info = if cfg.artigo == "a" then "Você já guardou esta." else "Você já guardou este."
	end
	if r == "completo" then
		if not resolverPara(p, puzzleId, cfg) then
			st.resolvido = false -- não gravou: deixa tentar de novo (nada foi pago)
			return "errado", "gravacao", nil
		end
		individuais[p][puzzleId] = nil
	end
	return r, nil, info
end

function S.sair(p: Player)
	individuais[p] = nil
end

return S
