--!strict
-- NÃO EXECUTADO NO STUDIO. PlayerDataSystem: carregar e salvar o perfil v2 com segurança.
--  * DataStore NOVA (ConfigServidor.dados.nomeStore): o save do tycoon nunca é lido para escrita nem apagado.
--  * Trava de sessão dentro de UpdateAsync (Dados/TravaDeSessao): dois servidores nunca escrevem o mesmo perfil.
--  * atualizar(p, fn) é uma TRANSAÇÃO: fn roda numa cópia; só se der certo e o perfil continuar válido
--    (Dados/Perfil.validar) a cópia substitui o original. Erro no meio = nada muda.
--  * Autosave periódico, salvar ao sair, BindToClose. Perfil de versão futura = somente leitura.
--  * Sem acesso a DataStore (Studio sem API): só memória, com aviso claro. Nada é perdido do que já existe.

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local G = ReplicatedStorage:WaitForChild("Guardioes")
local Sinal = require(G.Util.Sinal)
local Perfil = require(script.Parent.Parent.Dados.Perfil)
local Trava = require(script.Parent.Parent.Dados.TravaDeSessao)
local ConfigServidor = require(script.Parent.Parent.ConfigServidor)

local CFG = ConfigServidor.dados

type Sessao = { perfil: any, somenteLeitura: boolean, sujo: boolean, salvando: boolean }

local PlayerDataSystem = { Nome = "PlayerDataSystem" }
PlayerDataSystem.carregado = Sinal.novo() -- (p, perfil)

local sessoes: { [Player]: Sessao } = {}
local store: DataStore? = nil
local somenteMemoria = false
local servidor = if game.JobId ~= "" then game.JobId else "studio-" .. tostring(math.random(1, 1e9))

local function chave(p: Player): string
	return "perfil_" .. p.UserId
end

local function tentar<T>(fn: () -> T, tentativas: number): (boolean, T?)
	for i = 1, tentativas do
		local ok, r = pcall(fn)
		if ok then
			return true, r
		end
		warn("[Guardioes] DataStore falhou (tentativa " .. i .. "): " .. tostring(r))
		task.wait(math.min(2 ^ i, 8))
	end
	return false, nil
end

local function carregar(p: Player)
	local agora = os.time()
	if somenteMemoria or not store then
		local perfil = Perfil.novo(agora)
		sessoes[p] = { perfil = perfil, somenteLeitura = true, sujo = false, salvando = false }
		PlayerDataSystem.carregado.disparar(p, perfil)
		return
	end
	local ds = store :: DataStore
	local bruto: any = nil
	local conseguiu = false
	for _ = 1, CFG.tentativasCarregar do
		local estado = "erro"
		local ok = tentar(function()
			ds:UpdateAsync(chave(p), function(atual)
				local novo, pegou, motivo = Trava.adquirir(atual, servidor, os.time(), CFG.travaSeg)
				estado = motivo
				if pegou and novo then
					bruto = novo.perfil
					return novo
				end
				return nil -- não escreve
			end)
			return true
		end, 3)
		if ok and estado == "ok" then
			conseguiu = true
			break
		end
		if not p.Parent then
			return
		end
		task.wait(3) -- outro servidor ainda está liberando
	end
	if not p.Parent then
		return
	end
	if not conseguiu then
		p:Kick("Não foi possível carregar seu progresso com segurança. Tente entrar de novo em alguns instantes.")
		return
	end
	local perfil, situacao = Perfil.migrar(bruto, agora)
	sessoes[p] = { perfil = perfil, somenteLeitura = situacao == "versaoFutura", sujo = situacao ~= "ok", salvando = false }
	if situacao == "versaoFutura" then
		warn("[Guardioes] perfil de versão mais nova que este servidor: somente leitura para " .. p.Name)
	end
	PlayerDataSystem.carregado.disparar(p, perfil)
end

local function salvar(p: Player, liberar: boolean)
	local s = sessoes[p]
	if not s or s.somenteLeitura or not store or not CFG.salvar then
		return
	end
	if s.salvando then
		return
	end
	-- grava mesmo sem mudança: o autosave também RENOVA a trava (senão ela expiraria com o jogador online)
	s.salvando = true
	local copia = Perfil.copiar(s.perfil)
	copia.atualizadoEm = os.time()
	local motivo = "erro"
	local ok = tentar(function()
		(store :: DataStore):UpdateAsync(chave(p), function(atual)
			local novo, gravou, m = Trava.salvar(atual, copia, servidor, os.time(), CFG.travaSeg, liberar)
			motivo = m
			return if gravou then novo else nil
		end)
		return true
	end, 3)
	s.salvando = false
	if ok and (motivo == "salvo" or motivo == "liberado") then
		s.sujo = false
	elseif motivo == "travaPerdida" then
		-- outro servidor assumiu: este não escreve mais (evita duplicar/voltar progresso)
		s.somenteLeitura = true
		warn("[Guardioes] trava perdida para " .. p.Name .. "; sessão virou somente leitura")
	end
end

-- ------------------------------------------------------------------ API
function PlayerDataSystem.pronto(p: Player): boolean
	return sessoes[p] ~= nil
end

-- leitura: devolve uma CÓPIA (quem quiser mudar usa atualizar)
function PlayerDataSystem.obter(p: Player): any?
	local s = sessoes[p]
	return if s then Perfil.copiar(s.perfil) else nil
end

-- transação: fn(copia) altera a cópia; retorna false para desistir. Devolve (ok, motivo).
function PlayerDataSystem.atualizar(p: Player, fn: (any) -> boolean?): (boolean, string?)
	local s = sessoes[p]
	if not s then
		return false, "naoCarregado"
	end
	local copia = Perfil.copiar(s.perfil)
	local ok, r = pcall(fn, copia)
	if not ok then
		warn("[Guardioes] transação falhou: " .. tostring(r))
		return false, "erro"
	end
	if r == false then
		return false, "desistiu"
	end
	local valido, problema = Perfil.validar(copia)
	if not valido then
		return false, problema
	end
	s.perfil = copia
	s.sujo = true
	return true, nil
end

function PlayerDataSystem.Init(_ctx: any)
	local ok, r = pcall(function()
		return DataStoreService:GetDataStore(CFG.nomeStore)
	end)
	if ok and r then
		store = r
		-- no Studio sem permissão de API, a primeira chamada falha: detecta cedo e cai para memória
		if RunService:IsStudio() then
			local teste = pcall(function()
				(r :: DataStore):GetAsync("__teste_acesso")
			end)
			if not teste then
				somenteMemoria = true
			end
		end
	else
		somenteMemoria = true
	end
	if somenteMemoria then
		warn("[Guardioes] DataStore indisponível: progresso SÓ EM MEMÓRIA nesta sessão (nada será salvo)")
	end
end

function PlayerDataSystem.Start()
	for _, p in Players:GetPlayers() do
		task.spawn(carregar, p)
	end
	Players.PlayerAdded:Connect(carregar)
	Players.PlayerRemoving:Connect(function(p)
		salvar(p, true)
		sessoes[p] = nil
	end)
	game:BindToClose(function()
		local pendentes = 0
		for p in sessoes do
			pendentes += 1
			task.spawn(function()
				salvar(p, true)
				pendentes -= 1
			end)
		end
		local limite = os.clock() + 25
		while pendentes > 0 and os.clock() < limite do
			task.wait(0.2)
		end
	end)
	task.spawn(function()
		while true do
			task.wait(CFG.autosaveSeg)
			for p in sessoes do
				task.spawn(salvar, p, false) -- também renova a trava
			end
		end
	end)
end

return PlayerDataSystem
