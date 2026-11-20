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

type Sessao = { perfil: any, somenteLeitura: boolean, sujo: boolean, salvando: boolean, saindo: boolean? }

local PlayerDataSystem = { Nome = "PlayerDataSystem" }
PlayerDataSystem.carregado = Sinal.novo() -- (p, perfil)

local sessoes: { [Player]: Sessao } = {}

-- Todos os sistemas se conectam ao 'carregado' no Start, que roda em paralelo. Quem conectar DEPOIS de um
-- jogador já ter carregado (Studio sem DataStore carrega na hora; um Start pode esperar por WaitForChild)
-- recebe o aviso desse jogador na conexão — senão ele ficaria sem bolsa, missões, base etc.
do
	local conectarOriginal = PlayerDataSystem.carregado.conectar
	PlayerDataSystem.carregado.conectar = function(fn)
		local conexao = conectarOriginal(fn)
		for p, s in sessoes do
			if p.Parent then
				task.spawn(fn, p, s.perfil)
			end
		end
		return conexao
	end
end
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

-- Save do tycoon (MagnataDados_v1, chave j_<UserId>, formato { dados, trava, salvoEm }).
-- Só GetAsync: o Guardiões nunca escreve nessa store. Falha na leitura = começa do zero, sem travar a entrada.
local legadoStore: DataStore? = nil
local function lerLegado(p: Player): any
	local cfg = CFG.legado
	if not cfg then
		return nil
	end
	if not legadoStore then
		local ok, s = pcall(function()
			return DataStoreService:GetDataStore(cfg.nomeStore)
		end)
		if not ok then
			return nil
		end
		legadoStore = s
	end
	local ok, registro = tentar(function()
		return (legadoStore :: DataStore):GetAsync(cfg.prefixoChave .. p.UserId)
	end, 2)
	if ok and type(registro) == "table" and type(registro.dados) == "table" then
		return registro.dados
	end
	return nil
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
	if bruto == nil then
		bruto = lerLegado(p) -- primeira vez nos Guardiões: traz o save do tycoon (só leitura)
	end
	local perfil, situacao = Perfil.migrar(bruto, agora)
	if situacao == "migradoDoMagnata" then
		print(("[Guardioes] perfil do Magnata migrado para %s: %d moedas%s"):format(p.Name, perfil.moedas, if perfil.titulos.VeteranoDoMagnata then ", título de veterano" else ""))
	end
	sessoes[p] = { perfil = perfil, somenteLeitura = situacao == "versaoFutura", sujo = situacao ~= "ok", salvando = false }
	if situacao == "versaoFutura" then
		warn("[Guardioes] perfil de versão mais nova que este servidor: somente leitura para " .. p.Name)
	end
	PlayerDataSystem.carregado.disparar(p, perfil)
end

local function salvar(p: Player, liberar: boolean): string
	local s = sessoes[p]
	if not s or s.somenteLeitura or not store or not CFG.salvar then
		return "semStore"
	end
	while s.salvando do
		task.wait(0.1) -- um autosave em andamento: espera (a saída por portal precisa do resultado)
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
	return if ok then motivo else "erro"
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

-- PORTAL (outro place): grava e LIBERA a trava antes do teleporte, para o servidor de destino carregar na hora.
-- Daqui em diante a sessão não aceita mudanças (nada se perde entre a gravação e a saída). (ok)
function PlayerDataSystem.liberarParaPortal(p: Player): boolean
	local s = sessoes[p]
	if not s or s.saindo then
		return false
	end
	s.saindo = true
	if somenteMemoria or not store or not CFG.salvar then
		return true -- sem DataStore não há trava (no Studio o teleporte nem acontece)
	end
	if s.somenteLeitura then
		s.saindo = false
		return false -- perfil de versão futura ou trava perdida: não sai por portal
	end
	local r = salvar(p, true)
	if r ~= "liberado" then
		s.saindo = false
		return false
	end
	s.somenteLeitura = true -- a trava agora é de quem vier depois
	return true
end

-- o teleporte falhou: pega a trava de volta e volta a aceitar mudanças (o perfil em memória é o que foi salvo)
function PlayerDataSystem.retomarAposPortal(p: Player): boolean
	local s = sessoes[p]
	if not s or not s.saindo then
		return false
	end
	if somenteMemoria or not store or not CFG.salvar then
		s.saindo = false
		return true
	end
	local estado = "erro"
	tentar(function()
		(store :: DataStore):UpdateAsync(chave(p), function(atual)
			local novo, pegou, motivo = Trava.adquirir(atual, servidor, os.time(), CFG.travaSeg)
			estado = motivo
			return if pegou then novo else nil
		end)
		return true
	end, 3)
	if estado ~= "ok" then
		-- outro servidor já pegou (o teleporte deu certo afinal, ou o jogador entrou por outro lado): fica só leitura
		return false
	end
	s.somenteLeitura = false
	s.saindo = false
	return true
end

-- transação: fn(copia) altera a cópia; retorna false para desistir. Devolve (ok, motivo).
function PlayerDataSystem.atualizar(p: Player, fn: (any) -> boolean?): (boolean, string?)
	local s = sessoes[p]
	if not s then
		return false, "naoCarregado"
	end
	if s.saindo then
		return false, "saindo" -- atravessando um portal: o perfil já foi entregue ao próximo servidor
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
