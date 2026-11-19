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
local Semanal = require(G.Companhias.Semanal)
local CfgSemanal = require(G.Config.ObjetivosSemanais)
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
-- progresso semanal acumulado em memória e gravado a cada CFG.semanalSeg (uma escrita por companhia, não uma por
-- inimigo). Se o servidor cair, perde-se no máximo esse intervalo de progresso — nunca recompensas já gravadas.
local pendentes: { [string]: { [string]: { [string]: number } } } = {} -- companhia → tipo → uid → qtd
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
-- mesmoDissolvida: só para as operações internas de devolução (a dissolução precisa devolver tudo)
local function mudar(id: string, op: ((Companhia.Registro, number) -> (boolean, string, any))?, mesmoDissolvida: boolean?): (Companhia.Registro?, Resultado)
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
			if c.dissolvida and not mesmoDissolvida then
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

-- Chave de devolução "dev_<userId>": { [material] = qtd, __tokens = { [token] = os.time() } }.
-- __tokens torna a entrega IDEMPOTENTE: o mesmo lote (mesmo token) nunca soma duas vezes, mesmo que dois
-- servidores ou uma nova tentativa depois de uma queda entreguem o mesmo lote.
local TOKEN_VALIDADE = 14 * 86400

local function somarDev(uid: number, itens: { [string]: number }, token: string?): boolean
	return atualizarChave(chaveDev(uid), function(atual)
		local t = if type(atual) == "table" then atual else {}
		local tokens = if type(t.__tokens) == "table" then t.__tokens else {}
		local agora = os.time()
		for k, quando in tokens do
			if type(quando) ~= "number" or agora - quando > TOKEN_VALIDADE then
				tokens[k] = nil -- poda
			end
		end
		if token then
			if tokens[token] then
				t.__tokens = tokens
				return t -- este lote já foi somado
			end
			tokens[token] = agora
		end
		for mat, q in itens do
			if type(mat) == "string" and mat ~= "__tokens" and type(q) == "number" and q > 0 then
				t[mat] = (t[mat] or 0) + q
			end
		end
		t.__tokens = tokens
		return t
	end)
end

-- entrega ao jogador online o que estiver na chave de devolução. RETIRA primeiro (atômico): duas chamadas ao
-- mesmo tempo nunca entregam o mesmo item; o que não couber na bolsa volta para a chave.
local reclamando: { [Player]: boolean } = {}
local function reclamar(p: Player)
	if reclamando[p] then
		return
	end
	reclamando[p] = true
	local pedido: { [string]: number } = {}
	local ok = atualizarChave(chaveDev(p.UserId), function(atual)
		table.clear(pedido)
		if type(atual) ~= "table" then
			return nil
		end
		local sobra = { __tokens = atual.__tokens }
		local tem = false
		for mat, q in atual do
			if type(mat) == "string" and mat ~= "__tokens" and type(q) == "number" and q > 0 then
				pedido[mat] = q
				tem = true
			end
		end
		return if tem then sobra else nil
	end)
	if ok and next(pedido) ~= nil then
		local entregue = inventario.darMateriais(p, pedido, "companhia")
		local resto: { [string]: number } = {}
		for mat, q in pedido do
			local falta = q - (entregue[mat] or 0)
			if falta > 0 then
				resto[mat] = falta
			end
		end
		if next(resto) then
			somarDev(p.UserId, resto, nil) -- bolsa cheia: volta para a chave
		end
	end
	reclamando[p] = nil
end

-- Move c.aDevolver para as chaves de cada pessoa, sem duplicar nem perder, mesmo com vários servidores:
--  1) numa gravação da companhia, o lote sai de aDevolver e vai para emTransito[token] (só um servidor ganha);
--  2) o lote é somado na chave da pessoa com o token (idempotente);
--  3) emTransito[token] é apagado. Se o servidor cair entre 2 e 3, outro servidor refaz 2 com o MESMO token
--     depois do prazo (nada soma duas vezes) e termina o 3.
local TRANSITO_SEG = 300
local despachando: { [string]: boolean } = {}

local function entregarLote(id: string, token: string, uidTxt: string, itens: { [string]: number })
	local uid = tonumber(uidTxt)
	if not uid or not somarDev(uid, itens, token) then
		return -- fica em trânsito; outra tentativa depois do prazo
	end
	mudar(id, function(x)
		local et = (x :: any).emTransito
		if not et or not et[token] then
			return false, "ok", nil
		end
		et[token] = nil
		return true, "ok", nil
	end, true)
	local p = Players:GetPlayerByUserId(uid)
	if p then
		task.spawn(reclamar, p)
	end
end

local function despachar(id: string)
	local c = cache[id] :: any
	if not c or despachando[id] then
		return
	end
	despachando[id] = true
	-- 1) novos lotes
	local uids = {}
	for uidTxt in c.aDevolver or {} do
		table.insert(uids, uidTxt)
	end
	for _, uidTxt in uids do
		local token = HttpService:GenerateGUID(false)
		local lote: { [string]: number }? = nil
		local _, res = mudar(id, function(x, agora)
			lote = nil
			local itens = x.aDevolver[uidTxt]
			if not itens then
				return false, "ok", nil -- outro servidor já pegou
			end
			local xx = x :: any
			xx.emTransito = xx.emTransito or {}
			xx.emTransito[token] = { uid = uidTxt, itens = itens, ate = agora + TRANSITO_SEG }
			x.aDevolver[uidTxt] = nil
			lote = itens
			return true, "ok", nil
		end, true)
		if res.ok and lote then
			entregarLote(id, token, uidTxt, lote :: { [string]: number })
		end
	end
	-- 2) lotes presos (servidor caiu no meio): só um servidor reassume cada um, renovando o prazo
	local c2 = cache[id] :: any
	for token, t in (c2 and c2.emTransito) or {} do
		if type(t) == "table" and type(t.ate) == "number" and t.ate < os.time() then
			local lote = nil
			local _, res = mudar(id, function(x, agora)
				lote = nil
				local et = (x :: any).emTransito
				local e = et and et[token]
				if not e or e.ate >= agora then
					return false, "ok", nil
				end
				e.ate = agora + TRANSITO_SEG
				lote = e
				return true, "ok", nil
			end, true)
			if res.ok and lote then
				entregarLote(id, token, (lote :: any).uid, (lote :: any).itens)
			end
		end
	end
	despachando[id] = nil
end

-- ------------------------------------------------------------------ visão e avisos
local function contarMembros(c: Companhia.Registro): number
	local n = 0
	for _ in c.membros do
		n += 1
	end
	return n
end

-- objetivos da semana para o painel (se a semana virou e ninguém gravou ainda, mostra os novos zerados)
local function visaoSemanal(c: Companhia.Registro, p: Player): any
	local agora = os.time()
	local est = Semanal.preparar(c.semanal, c.id, agora, contarMembros(c), CfgSemanal)
	local lista = {}
	for _, o in est.objetivos do
		local cfg
		for _, x in CfgSemanal.lista do
			if x.id == o.id then
				cfg = x
			end
		end
		local contrib = est.contribuicao[o.id] or {}
		local pessoas = 0
		for _ in contrib do
			pessoas += 1
		end
		table.insert(lista, {
			nome = if cfg then cfg.nome else o.id, feito = o.feito, alvo = o.alvo, concluido = o.concluido,
			minha = contrib[tostring(p.UserId)] or 0, pessoas = pessoas, recompensa = if cfg then cfg.recompensa else {}, xp = if cfg then cfg.xp else 0,
		})
	end
	return { objetivos = lista, terminaEm = Semanal.fimDaSemana(est.semana) - agora, minContribuintes = CfgSemanal.minContribuintes }
end

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
		semanal = visaoSemanal(c, p),
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
	local et = (c :: any).emTransito
	if (c.aDevolver and next(c.aDevolver)) or (et and next(et)) then
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

-- conta progresso semanal (só em memória; gravado pelo ciclo)
function CompanySystem.registrarSemanal(p: Player, tipo: string, qtd: number)
	local id = CompanySystem.idDe(p)
	if not id or qtd <= 0 then
		return
	end
	local porTipo = pendentes[id] or {}
	pendentes[id] = porTipo
	local porUid = porTipo[tipo] or {}
	porTipo[tipo] = porUid
	local uid = tostring(p.UserId)
	porUid[uid] = (porUid[uid] or 0) + qtd
end

-- grava o progresso pendente de uma companhia; objetivos concluídos pagam XP e recompensas NA MESMA gravação
-- (as recompensas entram em aDevolver e seguem o mesmo caminho seguro das devoluções)
local function gravarSemanal(id: string)
	local lote = pendentes[id]
	if not lote then
		return
	end
	pendentes[id] = nil
	local concluidos: { string } = {}
	local _, res = mudar(id, function(c, agora)
		concluidos = {}
		local n = contarMembros(c)
		local est = Semanal.preparar(c.semanal, c.id, agora, n, CfgSemanal)
		est = Perfil.copiar(est) -- nunca altera o estado antigo dentro da tentativa
		for tipo, porUid in lote do
			for uid, q in porUid do
				if c.membros[uid] then -- quem saiu no meio não conta
					Semanal.registrar(est, tipo, uid, q)
				end
			end
		end
		for _, novo in Semanal.concluir(est, n, CfgSemanal) do
			for _, cfg in CfgSemanal.lista do
				if cfg.id == novo.id then
					Companhia.ganharXp(c, cfg.xp)
					for _, uid in novo.contribuintes do
						Companhia.guardarDevolucao(c, tonumber(uid) :: number, cfg.recompensa)
					end
					table.insert(concluidos, cfg.nome)
				end
			end
		end
		c.semanal = est
		return true, "ok", nil
	end)
	if not res.ok and res.motivo ~= "gravacao" then
		return -- companhia dissolvida ou inexistente: o progresso não tem para onde ir
	end
	if not res.ok then
		-- não gravou: devolve o lote para a próxima tentativa (somando ao que chegou nesse meio-tempo)
		local atual = pendentes[id] or {}
		for tipo, porUid in lote do
			atual[tipo] = atual[tipo] or {}
			for uid, q in porUid do
				atual[tipo][uid] = (atual[tipo][uid] or 0) + q
			end
		end
		pendentes[id] = atual
		return
	end
	publicar(id, res)
	local c = cache[id]
	if c then
		for _, nome in concluidos do
			for _, p in membrosOnline(c) do
				evento:FireClient(p, EV.AVISO, "Objetivo semanal concluído: " .. nome .. "!")
			end
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
				if c then
					task.spawn(despachar, id) -- devoluções da dissolução que ficaram para trás
				end
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

	-- objetivos semanais: derrotas (quem contribuiu o mínimo do saque), aparos e fabricações
	inimigos.morreu.conectar(function(ini: any, contribuicao: { [Player]: number })
		if not (ini and ini.cfg) then
			return
		end
		local tipo = if CHEFES[ini.cfg.id] then "DerrotarChefe" else "DerrotarComum"
		for _, p in Saque.elegiveis(contribuicao, Loot.minimoDeContribuicao) do
			CompanySystem.registrarSemanal(p, tipo, 1)
		end
	end)
	inimigos.aparado.conectar(function(_inimigoId: any, p: Player)
		CompanySystem.registrarSemanal(p, "Aparar", 1)
	end)
	ctxSistemas.obter("CraftingSystem").fabricou.conectar(function(p: Player)
		CompanySystem.registrarSemanal(p, "Fabricar", 1)
	end)
	task.spawn(function()
		while true do
			task.wait(CFG.semanalSeg)
			for id in pendentes do
				local ok, erro = pcall(gravarSemanal, id)
				if not ok then
					warn("[Guardioes] companhia (semanal): " .. tostring(erro))
				end
			end
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
			local ok, erro = pcall(function()
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
				for id, c in cache do
					local et = (c :: any).emTransito
					local pendente = (c.aDevolver and next(c.aDevolver)) or (et and next(et))
					if pendente then
						task.spawn(despachar, id) -- tenta de novo até não sobrar nada (inclusive dissolvidas)
					elseif not ids[id] then
						cache[id] = nil -- ninguém daqui e nada pendente: não guarda em memória
					end
				end
			end)
			if not ok then
				warn("[Guardioes] companhia (ciclo): " .. tostring(erro))
			end
		end
	end)

	Players.PlayerRemoving:Connect(function(p)
		baldes[p] = nil
		ocupado[p] = nil
		reclamando[p] = nil
	end)
end

return CompanySystem
