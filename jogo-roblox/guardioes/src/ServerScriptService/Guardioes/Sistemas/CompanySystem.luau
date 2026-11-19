--!strict
-- NÃO EXECUTADO NO STUDIO. CompanySystem: Companhias (guildas de jogadores, GDD 10). ≠ CompanionSystem (criaturas).
--  * Regras em Companhias/Companhia (lógica pura, testada). Aqui: gravação, rede e a ponte com o inventário.
--  * Store própria (ConfigServidor.companhias.nomeStore). Cada mudança = UpdateAsync na chave da companhia,
--    aplicando a operação pura numa CÓPIA (atômico por companhia, vários servidores ao mesmo tempo).
--  * Prazos (transferência 48 h, dissolução 72 h) são aplicados em toda gravação e num ciclo periódico.
--  * DataStore não tem transação entre chaves. Por isso:
--      depositar = tira da parte SALVA do perfil → grava no cofre → se o cofre falhar, devolve ao perfil;
--      retirar   = tira do cofre → entrega ao perfil → o que não couber vai para a chave de devolução;
--      sair/expulsão/dissolução = os lotes da pessoa vão para c.aDevolver NA MESMA gravação que os tirou do
--      cofre; depois passam para "dev_<userId>" e são entregues quando a pessoa estiver online.
--    Pior caso (servidor cair entre duas gravações): um item devolvido duas vezes, nunca perdido. Documentado.
--  * O perfil guarda só perfil.companhia (id). A verdade é a companhia: ao carregar, se a pessoa não é mais
--    membro (expulsa offline, dissolvida), o campo é limpo.
--  * Sem acesso a DataStore (Studio sem API): tudo em memória, com aviso.

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local G = ReplicatedStorage:WaitForChild("Guardioes")
local Companhia = require(G.Companhias.Companhia)
local Materiais = require(G.Config.Materiais)
local Saque = require(G.Loot.Saque)
local Loot = require(G.Config.Loot)
local LimiteDeTaxa = require(G.Util.LimiteDeTaxa)
local Remotos = require(G.Rede.Remotos)
local Perfil = require(script.Parent.Parent.Dados.Perfil)
local ConfigServidor = require(script.Parent.Parent.ConfigServidor)

local CO = Remotos.Companhia
local EV = Remotos.EventoCompanhia
local CFG = ConfigServidor.companhias

local CompanySystem = { Nome = "CompanySystem" }

local evento: RemoteEvent
local ctxSistemas: any = nil
local playerData: any
local inventario: any
local store: DataStore? = nil
local memoria: { [string]: any } = {}
local cache: { [string]: Companhia.Registro } = {}
local baldes: { [Player]: LimiteDeTaxa.Balde } = {}
local ocupado: { [Player]: boolean } = {}
local CHEFES: { [string]: boolean } = {}
for _, c in ConfigServidor.chefes do
	CHEFES[c.id] = true
end

-- ------------------------------------------------------------------ gravação
-- UpdateAsync (ou memória). fn recebe o valor atual e devolve o novo ou nil (= não gravar).
local function atualizarChave(chave: string, fn: (any) -> any): boolean
	if not store then
		local novo = fn(Perfil.copiar(memoria[chave]))
		if novo ~= nil then
			memoria[chave] = novo
		end
		return true
	end
	local ds = store :: DataStore
	for i = 1, 3 do
		local ok, erro = pcall(function()
			ds:UpdateAsync(chave, function(atual)
				return fn(atual)
			end)
		end)
		if ok then
			return true
		end
		warn("[Guardioes] companhia: DataStore falhou (" .. i .. "): " .. tostring(erro))
		task.wait(i)
	end
	return false
end

local function chaveDe(id: string): string
	return "c_" .. id
end

type Resultado = { ok: boolean, motivo: string, extra: any, prazo: string? }

-- Aplica prazos + uma operação pura. Grava se a operação deu certo OU se um prazo venceu.
-- A operação recebe (c, agora) e devolve (ok, motivo, extra).
local function mudar(id: string, op: ((Companhia.Registro, number) -> (boolean, string, any))?): (Companhia.Registro?, Resultado)
	local res: Resultado = { ok = false, motivo = "semCompanhia", extra = nil, prazo = nil }
	local final: Companhia.Registro? = nil
	local gravou = atualizarChave(chaveDe(id), function(atual)
		-- a função pode rodar mais de uma vez (conflito entre servidores): tudo é recalculado do zero
		res = { ok = false, motivo = "semCompanhia", extra = nil, prazo = nil }
		final = nil
		if type(atual) ~= "table" then
			return nil
		end
		local c = Perfil.copiar(atual) :: Companhia.Registro
		c.aDevolver = c.aDevolver or {}
		local agora = os.time()
		local prazo, dev = Companhia.atualizar(c, agora)
		if dev then
			for uid, itens in dev do
				Companhia.guardarDevolucao(c, uid, itens)
			end
		end
		res.prazo = prazo
		if op then
			if c.dissolvida then
				res.motivo = "dissolvida"
			else
				local ok, motivo, extra = op(c, agora)
				res.ok, res.motivo, res.extra = ok, motivo, extra
			end
		else
			res.ok, res.motivo = true, "ok"
		end
		final = c
		if (op and res.ok) or prazo ~= nil then
			c.versao += 1
			return c
		end
		return nil
	end)
	if not gravou then
		return nil, { ok = false, motivo = "gravacao", extra = nil, prazo = nil }
	end
	if final then
		cache[id] = final :: Companhia.Registro
	end
	return final, res
end

-- ------------------------------------------------------------------ devoluções
local function chaveDev(uid: number): string
	return "dev_" .. uid
end

local function somarDev(uid: number, itens: { [string]: number }): boolean
	return atualizarChave(chaveDev(uid), function(atual)
		local t = if type(atual) == "table" then atual else {}
		for m, q in itens do
			t[m] = (t[m] or 0) + q
		end
		return t
	end)
end

-- entrega ao jogador online o que estiver na chave de devolução (o que não couber continua guardado)
local function reclamar(p: Player)
	local pendente: any = nil
	if store then
		local ok, v = pcall(function()
			return (store :: DataStore):GetAsync(chaveDev(p.UserId))
		end)
		if not ok then
			return
		end
		pendente = v
	else
		pendente = memoria[chaveDev(p.UserId)]
	end
	if type(pendente) ~= "table" or next(pendente) == nil then
		return
	end
	local pedido: { [string]: number } = {}
	for m, q in pendente do
		if type(m) == "string" and type(q) == "number" and q > 0 then
			pedido[m] = q
		end
	end
	local entregue = inventario.darMateriais(p, pedido, "companhia")
	if next(entregue) == nil then
		return
	end
	atualizarChave(chaveDev(p.UserId), function(atual)
		local t = if type(atual) == "table" then atual else {}
		for m, q in entregue do
			local resta = (t[m] or 0) - q
			t[m] = if resta > 0 then resta else nil
		end
		return t
	end)
end

-- move c.aDevolver para as chaves de cada pessoa; quem estiver online aqui já recebe
local despachando: { [string]: boolean } = {}
local function despachar(id: string)
	local c = cache[id]
	if not c or not c.aDevolver or despachando[id] then
		return -- um despacho por companhia por vez (dois em paralelo devolveriam em dobro)
	end
	despachando[id] = true
	for uidTxt, itens in c.aDevolver do
		local uid = tonumber(uidTxt)
		if uid and somarDev(uid, itens) then
			mudar(id, function(x)
				x.aDevolver[uidTxt] = nil
				return true, "ok", nil
			end)
			local p = Players:GetPlayerByUserId(uid)
			if p then
				task.spawn(reclamar, p)
			end
		end
	end
	despachando[id] = nil
end

-- ------------------------------------------------------------------ visão e avisos
local function visao(c: Companhia.Registro, p: Player): any
	local membros = {}
	for uid, m in c.membros do
		table.insert(membros, { uid = tonumber(uid), cargo = m.cargo, desde = m.desde })
	end
	table.sort(membros, function(a, b)
		local ra, rb = Companhia.RANK[a.cargo] or 0, Companhia.RANK[b.cargo] or 0
		return if ra ~= rb then ra > rb else a.desde < b.desde
	end)
	local cofre = {}
	for mat, t in Companhia.totaisDoCofre(c) do
		local cfg = Materiais.porId[mat]
		table.insert(cofre, { id = mat, nome = if cfg then cfg.nome else mat, qtd = t.qtd, livre = t.livre, travado = t.travado })
	end
	table.sort(cofre, function(a, b)
		return a.nome < b.nome
	end)
	local log = {}
	for i = #c.log, math.max(1, #c.log - 19), -1 do
		table.insert(log, c.log[i])
	end
	local meu = c.membros[tostring(p.UserId)]
	local r = c.retiradas[tostring(p.UserId)]
	local hoje = os.time() // 86400
	local cargo = if meu then meu.cargo else nil
	return {
		id = c.id, nome = c.nome, emblema = c.emblema, nivel = c.nivel, xp = c.xp, xpProximo = 1000 * c.nivel,
		meuCargo = cargo, membros = membros, cofre = cofre, log = log,
		retiradoHoje = if r and r.dia == hoje then r.qtd else 0,
		limiteDiario = if cargo and cargo ~= "Lider" then Companhia.PERM[cargo].limiteDiario else nil,
		transferencia = c.transferencia, dissolucao = c.dissolucao,
	}
end

local function membrosOnline(c: Companhia.Registro): { Player }
	local l = {}
	for uid in c.membros do
		local p = Players:GetPlayerByUserId(tonumber(uid) or 0)
		if p then
			table.insert(l, p)
		end
	end
	return l
end

local function definirNoPerfil(p: Player, id: string?)
	playerData.atualizar(p, function(pf)
		pf.companhia = id
		return true
	end)
end

-- envia o estado para todos os membros online deste servidor e trata prazos vencidos
local function publicar(id: string, res: Resultado?)
	local c = cache[id]
	if not c then
		return
	end
	if res and res.prazo == "Dissolvida" then
		for _, p in Players:GetPlayers() do
			local pf = playerData.obter(p)
			if pf and pf.companhia == id then
				definirNoPerfil(p, nil)
				evento:FireClient(p, EV.AVISO, "A companhia " .. c.nome .. " foi dissolvida. Seus depósitos voltaram para você.")
				evento:FireClient(p, EV.ESTADO, nil)
			end
		end
		if store then
			pcall(function()
				(store :: DataStore):RemoveAsync("nome_" .. string.lower(c.nome)) -- o nome fica livre de novo
			end)
		end
		memoria["nome_" .. string.lower(c.nome)] = nil
	elseif res and res.prazo == "Transferida" then
		for _, p in membrosOnline(c) do
			evento:FireClient(p, EV.AVISO, "A liderança da companhia foi transferida.")
		end
	end
	if not c.dissolvida then
		for _, p in membrosOnline(c) do
			evento:FireClient(p, EV.ESTADO, visao(c, p))
		end
	end
	if c.aDevolver and next(c.aDevolver) then
		task.spawn(despachar, id)
	end
end

-- ------------------------------------------------------------------ API (servidor)
function CompanySystem.idDe(p: Player): string?
	local pf = playerData.obter(p)
	return if pf then pf.companhia else nil
end

function CompanySystem.ganharXp(id: string, quanto: number)
	local _, res = mudar(id, function(c)
		local subiu = Companhia.ganharXp(c, quanto)
		return true, if subiu then "subiu" else "ok", nil
	end)
	publicar(id, res)
	if res.motivo == "subiu" and cache[id] then
		for _, p in membrosOnline(cache[id]) do
			evento:FireClient(p, EV.AVISO, "A companhia subiu para o nível " .. cache[id].nivel .. "!")
		end
	end
end

-- ------------------------------------------------------------------ pedidos do cliente
local function nomeAprovado(p: Player, nome: string): (boolean, string)
	if not Companhia.nomeValido(nome) then
		return false, "nomeCompanhiaInvalido"
	end
	local ok, filtrado = pcall(function()
		local r = TextService:FilterStringAsync(nome, p.UserId, Enum.TextFilterContext.PublicChat)
		return r:GetNonChatStringForBroadcastAsync()
	end)
	if not ok then
		return false, "gravacao"
	end
	if filtrado ~= nome then
		return false, "nomeFiltrado"
	end
	return true, "ok"
end

local function criar(p: Player, nome: any, emblema: any): string
	local pf = playerData.obter(p)
	if not pf then
		return "gravacao"
	end
	if pf.companhia then
		return "jaMembro"
	end
	if typeof(nome) ~= "string" then
		return "nomeCompanhiaInvalido"
	end
	if not Companhia.emblemaValido(emblema) then
		return "emblemaInvalido"
	end
	local okNome, motivo = nomeAprovado(p, nome)
	if not okNome then
		return motivo
	end
	local id = HttpService:GenerateGUID(false)
	local livre = false
	if not atualizarChave("nome_" .. string.lower(nome), function(atual)
		livre = atual == nil
		return if livre then id else nil
	end) then
		return "gravacao"
	end
	if not livre then
		return "nomeEmUso"
	end
	local reg = Companhia.nova(id, nome, emblema, p.UserId, os.time())
	if not atualizarChave(chaveDe(id), function(atual)
		return if atual == nil then reg else nil
	end) then
		return "gravacao"
	end
	cache[id] = reg
	definirNoPerfil(p, id)
	publicar(id, nil)
	return "ok"
end

local function tratar(p: Player, tipo: number, a: any, b: any): string?
	if tipo == CO.CRIAR then
		local m = criar(p, a, b)
		return if m == "ok" then nil else m
	end
	if tipo == CO.ACEITAR or tipo == CO.RECUSAR then
		if typeof(a) ~= "string" or #a > 64 then
			return "semConvite"
		end
		local pf = playerData.obter(p)
		if not pf then
			return "gravacao"
		end
		if tipo == CO.RECUSAR then
			local _, res = mudar(a, function(c)
				local tinha = c.convites[tostring(p.UserId)] ~= nil
				c.convites[tostring(p.UserId)] = nil
				return tinha, "ok", nil
			end)
			local _ = res
			return nil
		end
		if pf.companhia then
			return "jaMembro"
		end
		local _, res = mudar(a, function(c, agora)
			local ok, motivo = Companhia.aceitar(c, p.UserId, agora)
			return ok, motivo, nil
		end)
		if not res.ok then
			return res.motivo
		end
		local okPerfil = playerData.atualizar(p, function(x)
			if x.companhia then
				return false
			end
			x.companhia = a
			return true
		end)
		if not okPerfil then
			-- desfaz a entrada (a pessoa não ficou presa numa companhia que o perfil não conhece)
			mudar(a, function(c, agora)
				local ok, motivo = Companhia.sair(c, p.UserId, agora)
				return ok, motivo, nil
			end)
			return "gravacao"
		end
		publicar(a, res)
		return nil
	end
	local id = CompanySystem.idDe(p)
	if not id then
		return "semCompanhia"
	end
	if tipo == CO.VER then
		local _, res = mudar(id, nil)
		publicar(id, res)
		return nil
	end
	local uid = p.UserId
	local _ign: any
	local res: Resultado
	if tipo == CO.CONVIDAR then
		local alvo = if typeof(a) == "number" then Players:GetPlayerByUserId(a) else nil
		if not alvo or alvo == p then
			return "naoMembro"
		end
		local pfa = playerData.obter(alvo)
		if not pfa or pfa.companhia then
			return "jaMembro"
		end
		_ign, res = mudar(id, function(c, agora)
			local ok, m = Companhia.convidar(c, uid, alvo.UserId, agora)
			return ok, m, nil
		end)
		if res.ok and cache[id] then
			local c = cache[id]
			evento:FireClient(alvo, EV.CONVITE, id, c.nome, c.emblema, p.DisplayName)
		end
	elseif tipo == CO.SAIR then
		_ign, res = mudar(id, function(c, agora)
			local ok, m, dev = Companhia.sair(c, uid, agora)
			Companhia.guardarDevolucao(c, uid, dev)
			return ok, m, nil
		end)
		if res.ok or res.motivo == "dissolvida" then
			definirNoPerfil(p, nil)
			evento:FireClient(p, EV.ESTADO, nil)
		end
	elseif tipo == CO.EXPULSAR then
		if typeof(a) ~= "number" then
			return "naoMembro"
		end
		_ign, res = mudar(id, function(c, agora)
			local ok, m, dev = Companhia.expulsar(c, uid, a, agora)
			Companhia.guardarDevolucao(c, a, dev)
			return ok, m, nil
		end)
		local alvo = Players:GetPlayerByUserId(a)
		if res.ok and alvo then
			definirNoPerfil(alvo, nil) -- offline: limpo quando carregar
			evento:FireClient(alvo, EV.ESTADO, nil)
			evento:FireClient(alvo, EV.AVISO, "Você saiu da companhia. Seus depósitos voltaram para você.")
		end
	elseif tipo == CO.CARGO then
		if typeof(a) ~= "number" or typeof(b) ~= "string" then
			return "cargoInvalido"
		end
		_ign, res = mudar(id, function(c, agora)
			local ok, m = Companhia.definirCargo(c, uid, a, b, agora)
			return ok, m, nil
		end)
	elseif tipo == CO.DEPOSITAR then
		if typeof(a) ~= "string" or not Materiais.porId[a] or typeof(b) ~= "number" or b < 1 or b > 999 or b ~= math.floor(b) then
			return "quantidade"
		end
		local cache_ = cache[id]
		local cargo = if cache_ then Companhia.cargo(cache_, uid) else nil
		if cache_ and not cargo then
			return "naoMembro"
		end
		if not inventario.retirarSalvo(p, a, b) then
			return "naoPossui" -- só a parte salva entra no cofre (concessões de teste nunca)
		end
		_ign, res = mudar(id, function(c, agora)
			local ok, m = Companhia.depositar(c, uid, a, b, agora)
			return ok, m, nil
		end)
		if not res.ok then
			inventario.darMateriais(p, { [a] = b }, "companhiaEstorno") -- desfaz
		end
	elseif tipo == CO.RETIRAR then
		if typeof(a) ~= "string" or not Materiais.porId[a] or typeof(b) ~= "number" or b < 1 or b > 999 or b ~= math.floor(b) then
			return "quantidade"
		end
		_ign, res = mudar(id, function(c, agora)
			local ok, m, tirado = Companhia.retirar(c, uid, a, b, agora // 86400, agora)
			return ok, m, tirado
		end)
		if res.ok and typeof(res.extra) == "number" and res.extra > 0 then
			local entregue = inventario.darMateriais(p, { [a] = res.extra }, "companhia")
			local sobra = res.extra - (entregue[a] or 0)
			if sobra > 0 then
				somarDev(uid, { [a] = sobra }) -- bolsa cheia: fica guardado para depois
				evento:FireClient(p, EV.AVISO, "Bolsa cheia: " .. sobra .. " ficaram guardados para você.")
			end
		end
	elseif tipo == CO.MARCAR then
		if typeof(a) ~= "string" or typeof(b) ~= "string" then
			return "quantidade"
		end
		_ign, res = mudar(id, function(c, agora)
			local ok, m = Companhia.marcar(c, uid, a, b, agora)
			return ok, m, nil
		end)
	elseif tipo == CO.TRANSFERIR then
		if typeof(a) ~= "number" then
			return "naoMembro"
		end
		_ign, res = mudar(id, function(c, agora)
			local ok, m = Companhia.iniciarTransferencia(c, uid, a, agora)
			return ok, m, nil
		end)
	elseif tipo == CO.CANCELAR_TRANSFERENCIA then
		_ign, res = mudar(id, function(c, agora)
			local ok = Companhia.cancelarTransferencia(c, uid, agora)
			return ok, if ok then "ok" else "semPermissao", nil
		end)
	elseif tipo == CO.DISSOLVER then
		_ign, res = mudar(id, function(c, agora)
			local ok, m = Companhia.pedirDissolucao(c, uid, agora)
			return ok, m, nil
		end)
		if res.ok then
			evento:FireClient(p, EV.AVISO, if res.motivo == "confirme" then "Confirme a dissolução: aperte de novo." else "Dissolução agendada para daqui a 72 h. Pode cancelar até lá.")
		end
	elseif tipo == CO.CANCELAR_DISSOLUCAO then
		_ign, res = mudar(id, function(c, agora)
			local ok = Companhia.cancelarDissolucao(c, uid, agora)
			return ok, if ok then "ok" else "semPermissao", nil
		end)
	else
		return nil
	end
	publicar(id, res)
	return if res.ok then nil else res.motivo
end

-- ------------------------------------------------------------------ ciclo de vida
function CompanySystem.Init(ctx: any)
	ctxSistemas = ctx
	evento = Remotos.evento("Companhia")
	local ok, s = pcall(function()
		return DataStoreService:GetDataStore(CFG.nomeStore)
	end)
	if ok and s then
		local acesso = pcall(function()
			(s :: DataStore):GetAsync("__teste_acesso")
		end)
		if acesso then
			store = s
		end
	end
	if not store then
		warn("[Guardioes] companhias SÓ EM MEMÓRIA nesta sessão (sem acesso a DataStore)")
	end
end

function CompanySystem.Start()
	playerData = ctxSistemas.obter("PlayerDataSystem")
	inventario = ctxSistemas.obter("InventorySystem")
	local inimigos = ctxSistemas.obter("EnemySystem")

	-- ao carregar: devoluções pendentes e conferência do vínculo
	playerData.carregado.conectar(function(p: Player, pf: any)
		task.spawn(function()
			reclamar(p)
			local id = pf.companhia
			if not id then
				return
			end
			local c, res = mudar(id, nil)
			if not c and res.motivo == "gravacao" then
				return -- sem resposta da store: não mexe no perfil
			end
			if not c or c.dissolvida or not c.membros[tostring(p.UserId)] then
				definirNoPerfil(p, nil)
				evento:FireClient(p, EV.ESTADO, nil)
				return
			end
			publicar(id, res)
		end)
	end)

	-- XP da companhia: cada membro que contribuiu para derrubar um chefe/miniboss
	inimigos.morreu.conectar(function(ini: any, contribuicao: { [Player]: number })
		if not (ini and ini.cfg and CHEFES[ini.cfg.id]) then
			return
		end
		local porCompanhia: { [string]: number } = {}
		for _, p in Saque.elegiveis(contribuicao, Loot.minimoDeContribuicao) do
			local id = CompanySystem.idDe(p)
			if id then
				porCompanhia[id] = (porCompanhia[id] or 0) + CFG.xpPorChefe
			end
		end
		for id, xp in porCompanhia do
			task.spawn(CompanySystem.ganharXp, id, xp)
		end
	end)

	evento.OnServerEvent:Connect(function(p: Player, tipo: any, a: any, b: any)
		local bal = baldes[p]
		if not bal then
			bal = LimiteDeTaxa.novo(3, 0.5, os.clock())
			baldes[p] = bal
		end
		if typeof(tipo) ~= "number" or not LimiteDeTaxa.consumir(bal, os.clock()) then
			return
		end
		if ocupado[p] then
			evento:FireClient(p, EV.REJEITADO, "companhiaOcupada")
			return
		end
		ocupado[p] = true -- uma ação por vez por jogador (depósitos/retiradas nunca se cruzam)
		local ok, motivo = pcall(tratar, p, tipo, a, b)
		ocupado[p] = nil
		if not ok then
			warn("[Guardioes] companhia: " .. tostring(motivo))
			evento:FireClient(p, EV.REJEITADO, "gravacao")
		elseif motivo then
			evento:FireClient(p, EV.REJEITADO, motivo)
		end
	end)

	-- prazos e mudanças vindas de outros servidores: relê as companhias com membros online aqui
	task.spawn(function()
		while true do
			task.wait(CFG.cicloSeg)
			local ids: { [string]: boolean } = {}
			for _, p in Players:GetPlayers() do
				local id = CompanySystem.idDe(p)
				if id then
					ids[id] = true
				end
			end
			for id in ids do
				local ok, erro = pcall(function()
					local _, res = mudar(id, nil)
					publicar(id, res)
				end)
				if not ok then
					warn("[Guardioes] companhia (ciclo): " .. tostring(erro))
				end
			end
			for id in cache do
				if not ids[id] then
					cache[id] = nil -- ninguém daqui: não guarda em memória
				end
			end
		end
	end)

	Players.PlayerRemoving:Connect(function(p)
		baldes[p] = nil
		ocupado[p] = nil
	end)
end

return CompanySystem
