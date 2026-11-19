--!strict
-- NÃO EXECUTADO NO STUDIO. InvestigationService: progresso persistente das investigações.
-- Toda mudança é uma transação do PlayerData que roda a regra pura (MysterySystems/Investigacao) numa cópia e
-- confere o resultado (Investigacao.validar) antes de gravar. O cliente nunca envia pistas nem objetivos.
-- Capítulo concluído → recompensa pelo SecretRewardService (paga uma vez). Ao entrar, 'reconciliar' paga
-- recompensas de capítulos concluídos que ficaram sem pagar (queda entre as duas gravações).

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local G = ReplicatedStorage:WaitForChild("Guardioes")
local Investigacao = require(G.MysterySystems.Investigacao)

local S = {}
local deps: any = nil

function S.iniciar(d: any)
	deps = d
end

local function progressoDe(m: any, invId: string, cfg: any): any
	local p = m.investigacoes[invId]
	if not p then
		p = Investigacao.novo(cfg)
		m.investigacoes[invId] = p
	end
	return p
end

-- aplica 'fn(progressoDaInvestigacao, perfilCopia)' numa transação; (ok, motivo, extra)
local function mudar(p: Player, invId: string, fn: (any, any) -> (boolean, string, any?)): (boolean, string, any?)
	local cfg = deps.registro.investigacao(invId)
	if not cfg then
		return false, "investigacaoInexistente", nil
	end
	local motivo, extra = "erro", nil
	local ok = deps.playerData.atualizar(p, function(pf)
		local prog = progressoDe(pf.misterios, invId, cfg)
		local okFn, m, x = fn(prog, pf)
		motivo, extra = m, x
		if not okFn then
			return false
		end
		local valido, problema = Investigacao.validar(prog, cfg)
		if not valido then
			motivo = "invalido:" .. tostring(problema)
			return false
		end
		return true
	end)
	return ok, motivo, extra
end

function S.registrarPista(p: Player, invId: string, pistaId: string): (boolean, string)
	local cfg = deps.registro.investigacao(invId)
	-- dependências: outras investigações concluídas antes desta começar
	local perfil = deps.playerData.obter(p)
	if not perfil or not cfg then
		return false, "erro"
	end
	for _, req in cfg.requer or {} do
		local outra = perfil.misterios.investigacoes[req]
		if not outra or outra.estado ~= "Completed" then
			return false, "dependencia"
		end
	end
	local ok, motivo = mudar(p, invId, function(prog)
		local r, m = Investigacao.registrarPista(prog, cfg, pistaId)
		return r, m, nil
	end)
	return ok, motivo
end

-- objetivo cumprido (enigma resolvido): marca + conclui o capítulo se acabou + enigma resolvido, tudo junto
function S.cumprirObjetivo(p: Player, invId: string, objetivoId: string, puzzleId: string?): (boolean, string)
	local cfg = deps.registro.investigacao(invId)
	local ok, motivo, recompensa = mudar(p, invId, function(prog, pf)
		local r, m = Investigacao.registrarObjetivo(prog, cfg, objetivoId)
		if not r then
			return false, m, nil
		end
		if puzzleId then
			pf.misterios.enigmas[puzzleId] = true
		end
		local concluiu, _, rec = Investigacao.concluirCapitulo(prog, cfg)
		return true, if concluiu then "capituloConcluido" else "ok", rec
	end)
	if ok and recompensa then
		deps.recompensas.conceder(p, recompensa)
	end
	return ok, motivo
end

-- recompensas de capítulos concluídos que não foram pagas (o servidor caiu entre as gravações)
function S.reconciliar(p: Player)
	local perfil = deps.playerData.obter(p)
	if not perfil then
		return
	end
	for invId, prog in perfil.misterios.investigacoes do
		local cfg = deps.registro.investigacao(invId)
		if cfg then
			for chave in prog.capitulosConcluidos do
				local cap = cfg.capitulos[tonumber(chave) or 0]
				if cap and cap.recompensa and not perfil.misterios.recompensas[cap.recompensa] then
					deps.recompensas.conceder(p, cap.recompensa)
				end
			end
		end
	end
end

function S.progresso(perfil: any, invId: string): any?
	return perfil.misterios.investigacoes[invId]
end

return S
