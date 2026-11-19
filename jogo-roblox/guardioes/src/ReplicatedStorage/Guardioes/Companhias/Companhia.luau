--!strict
-- NÃO EXECUTADO. COMPANHIA (guilda de jogadores; não confundir com companheiros = criaturas) — LÓGICA PURA.
-- Todas as regras do GDD 10 moram aqui, testáveis fora do Studio. O servidor aplica cada operação dentro de
-- um UpdateAsync (atômico por companhia) e grava o registro (log) de toda ação.
--
-- Cargos: Lider > Oficial > Membro > Recruta.
-- Cofre: lotes { material, qtd, depositante, estado: "normal" | "livre" | "travado" }.
--   Líder retira tudo; Oficial até o limite diário (não toca em travado); Membro só lotes "livres" até o limite;
--   Recruta só deposita. Sair/ser expulso DEVOLVE os lotes da pessoa (nada é confiscado).
-- Liderança: transferência leva 48 h (cancelável). Dissolução: 2 confirmações + 72 h; devolve tudo a quem depositou.

export type Lote = { material: string, qtd: number, depositante: number, estado: string }
export type Registro = {
	id: string, nome: string, emblema: { forma: string, cor: string, simbolo: string },
	membros: { [string]: { cargo: string, desde: number } }, -- chave = tostring(userId)
	convites: { [string]: number }, -- userId → expira em
	cofre: { Lote },
	retiradas: { [string]: { dia: number, qtd: number } },
	log: { { t: number, quem: number, acao: string, detalhe: string? } },
	nivel: number, xp: number,
	transferencia: { para: number, ate: number }?,
	dissolucao: { confirmacoes: number, ate: number? }?,
	dissolvida: boolean,
	-- itens a devolver (saiu, expulso, dissolução), gravados NA MESMA escrita que os tirou do cofre; o servidor
	-- depois os move para a chave de devolução de cada pessoa. Nunca somem entre uma gravação e outra.
	aDevolver: { [string]: { [string]: number } },
	semanal: any?, -- objetivos da semana (Companhias/Semanal)
	emTransito: { [string]: { uid: string, itens: { [string]: number }, ate: number } }?, -- lotes a caminho da chave de devolução
	versao: number,
}
export type Devolucao = { [number]: { [string]: number } } -- userId → material → qtd

local C = {}

C.RANK = { Lider = 4, Oficial = 3, Membro = 2, Recruta = 1 }
C.PERM = {
	Lider = { convidar = true, expulsar = true, depositar = true, retirar = "tudo", limiteDiario = math.huge },
	Oficial = { convidar = true, expulsar = true, depositar = true, retirar = "naoTravado", limiteDiario = 50 },
	Membro = { convidar = false, expulsar = false, depositar = true, retirar = "livre", limiteDiario = 20 },
	Recruta = { convidar = false, expulsar = false, depositar = true, retirar = "nada", limiteDiario = 0 },
}
C.EMBLEMA = {
	forma = { "Escudo", "Circulo", "Estrela", "Losango" },
	cor = { "#4EA8FF", "#7EDC6A", "#FFCC33", "#B86BFF", "#E64650", "#E8F4FF" },
	simbolo = { "Raio", "Folha", "Estrela", "Olho", "Onda", "Engrenagem" },
}
C.LIMITE_MEMBROS = 30
C.TRANSFERENCIA_SEG = 48 * 3600
C.DISSOLUCAO_SEG = 72 * 3600
C.CONVITE_SEG = 24 * 3600
C.LOG_MAX = 200

local function k(uid: number): string
	return tostring(uid)
end

function C.cargo(c: Registro, uid: number): string?
	local m = c.membros[k(uid)]
	return if m then m.cargo else nil
end

local function anotar(c: Registro, t: number, quem: number, acao: string, detalhe: string?)
	table.insert(c.log, { t = t, quem = quem, acao = acao, detalhe = detalhe })
	while #c.log > C.LOG_MAX do
		table.remove(c.log, 1)
	end
end

function C.nomeValido(nome: any): boolean
	if type(nome) ~= "string" then
		return false
	end
	local n = utf8.len(nome)
	return n ~= nil and n >= 3 and n <= 20 and string.find(nome, "[%c<>\"'`\\{}]") == nil and string.find(nome, "^%s") == nil and string.find(nome, "%s$") == nil
end

-- emblema só de peças pré-aprovadas (sem upload livre de imagem)
function C.emblemaValido(e: any): boolean
	return type(e) == "table" and table.find(C.EMBLEMA.forma, e.forma) ~= nil and table.find(C.EMBLEMA.cor, e.cor) ~= nil and table.find(C.EMBLEMA.simbolo, e.simbolo) ~= nil
end

function C.nova(id: string, nome: string, emblema: any, lider: number, agora: number): Registro
	local c: Registro = {
		id = id, nome = nome, emblema = { forma = emblema.forma, cor = emblema.cor, simbolo = emblema.simbolo },
		membros = { [k(lider)] = { cargo = "Lider", desde = agora } }, convites = {}, cofre = {}, retiradas = {}, log = {},
		nivel = 1, xp = 0, transferencia = nil, dissolucao = nil, dissolvida = false, aDevolver = {}, versao = 1,
	}
	anotar(c, agora, lider, "criou", nome)
	return c
end

local function contarMembros(c: Registro): number
	local n = 0
	for _ in c.membros do
		n += 1
	end
	return n
end

-- ---------------------------------------------------------------- membros
function C.convidar(c: Registro, por: number, alvo: number, agora: number): (boolean, string)
	local cg = C.cargo(c, por)
	if not cg or not C.PERM[cg].convidar then
		return false, "semPermissao"
	end
	if c.membros[k(alvo)] then
		return false, "jaMembro"
	end
	if contarMembros(c) >= C.LIMITE_MEMBROS then
		return false, "companhiaCheia"
	end
	c.convites[k(alvo)] = agora + C.CONVITE_SEG
	anotar(c, agora, por, "convidou", k(alvo))
	return true, "ok"
end

function C.aceitar(c: Registro, uid: number, agora: number): (boolean, string)
	local exp = c.convites[k(uid)]
	if not exp or agora > exp then
		return false, "semConvite"
	end
	if c.dissolvida then
		return false, "dissolvida"
	end
	c.convites[k(uid)] = nil
	c.membros[k(uid)] = { cargo = "Recruta", desde = agora }
	anotar(c, agora, uid, "entrou", nil)
	return true, "ok"
end

-- tira os lotes de alguém do cofre (devolução: sair, expulsão, dissolução)
local function retirarLotesDe(c: Registro, uid: number): { [string]: number }
	local dev: { [string]: number } = {}
	local fica: { Lote } = {}
	for _, l in c.cofre do
		if l.depositante == uid then
			dev[l.material] = (dev[l.material] or 0) + l.qtd
		else
			table.insert(fica, l)
		end
	end
	c.cofre = fica
	return dev
end

-- expulsar NÃO confisca: devolve o que a pessoa depositou
function C.expulsar(c: Registro, por: number, alvo: number, agora: number): (boolean, string, { [string]: number }?)
	local cp, ca = C.cargo(c, por), C.cargo(c, alvo)
	if not cp or not ca then
		return false, "naoMembro", nil
	end
	if por == alvo or not C.PERM[cp].expulsar or C.RANK[ca] >= C.RANK[cp] then
		return false, "semPermissao", nil
	end
	c.membros[k(alvo)] = nil
	c.retiradas[k(alvo)] = nil
	if c.transferencia and c.transferencia.para == alvo then
		c.transferencia = nil
	end
	anotar(c, agora, por, "expulsou", k(alvo))
	return true, "ok", retirarLotesDe(c, alvo)
end

function C.sair(c: Registro, uid: number, agora: number): (boolean, string, { [string]: number }?)
	local cg = C.cargo(c, uid)
	if not cg then
		return false, "naoMembro", nil
	end
	if cg == "Lider" then
		return false, "liderNaoSai", nil -- transfira a liderança ou dissolva
	end
	c.membros[k(uid)] = nil
	c.retiradas[k(uid)] = nil
	if c.transferencia and c.transferencia.para == uid then
		c.transferencia = nil
	end
	anotar(c, agora, uid, "saiu", nil)
	return true, "ok", retirarLotesDe(c, uid)
end

-- só o líder muda cargos (nunca para Líder: isso é transferência)
function C.definirCargo(c: Registro, por: number, alvo: number, cargo: string, agora: number): (boolean, string)
	if C.cargo(c, por) ~= "Lider" or por == alvo then
		return false, "semPermissao"
	end
	if not C.cargo(c, alvo) then
		return false, "naoMembro"
	end
	if cargo ~= "Oficial" and cargo ~= "Membro" and cargo ~= "Recruta" then
		return false, "cargoInvalido"
	end
	c.membros[k(alvo)].cargo = cargo
	anotar(c, agora, por, "cargo", k(alvo) .. "=" .. cargo)
	return true, "ok"
end

-- ---------------------------------------------------------------- cofre
function C.depositar(c: Registro, uid: number, material: string, qtd: number, agora: number): (boolean, string)
	local cg = C.cargo(c, uid)
	if not cg or not C.PERM[cg].depositar then
		return false, "semPermissao"
	end
	if qtd <= 0 or qtd ~= math.floor(qtd) then
		return false, "quantidade"
	end
	for _, l in c.cofre do
		if l.material == material and l.depositante == uid and l.estado == "normal" then
			l.qtd += qtd
			anotar(c, agora, uid, "depositou", material .. "×" .. qtd)
			return true, "ok"
		end
	end
	table.insert(c.cofre, { material = material, qtd = qtd, depositante = uid, estado = "normal" })
	anotar(c, agora, uid, "depositou", material .. "×" .. qtd)
	return true, "ok"
end

-- o líder marca TODOS os lotes de um material como "livre" (membros podem retirar), "travado" ou "normal"
function C.marcar(c: Registro, por: number, material: string, estado: string, agora: number): (boolean, string)
	if C.cargo(c, por) ~= "Lider" then
		return false, "semPermissao"
	end
	if estado ~= "livre" and estado ~= "travado" and estado ~= "normal" then
		return false, "estadoInvalido"
	end
	local achou = false
	for _, l in c.cofre do
		if l.material == material then
			l.estado = estado
			achou = true
		end
	end
	if achou then
		anotar(c, agora, por, "marcou", material .. "=" .. estado)
	end
	return achou, if achou then "ok" else "semItem"
end

local function podeTirarDoLote(regra: string, l: Lote): boolean
	if regra == "tudo" then
		return true
	elseif regra == "naoTravado" then
		return l.estado ~= "travado"
	elseif regra == "livre" then
		return l.estado == "livre"
	end
	return false
end

-- retirar: (ok, motivo, retirado). 'dia' = os.time() // 86400 (limite diário por pessoa)
function C.retirar(c: Registro, uid: number, material: string, qtd: number, dia: number, agora: number): (boolean, string, number)
	local cg = C.cargo(c, uid)
	if not cg then
		return false, "naoMembro", 0
	end
	local perm = C.PERM[cg]
	if perm.retirar == "nada" then
		return false, "semPermissao", 0
	end
	if qtd <= 0 or qtd ~= math.floor(qtd) then
		return false, "quantidade", 0
	end
	local r = c.retiradas[k(uid)]
	if not r or r.dia ~= dia then
		r = { dia = dia, qtd = 0 }
		c.retiradas[k(uid)] = r
	end
	local saldo = perm.limiteDiario - r.qtd
	if saldo <= 0 then
		return false, "limiteDiario", 0
	end
	local pode = 0
	for _, l in c.cofre do
		if l.material == material and podeTirarDoLote(perm.retirar, l) then
			pode += l.qtd
		end
	end
	local tirar = math.min(qtd, pode, saldo)
	if tirar <= 0 then
		return false, "semItem", 0
	end
	local resta = tirar
	local fica: { Lote } = {}
	for _, l in c.cofre do
		if resta > 0 and l.material == material and podeTirarDoLote(perm.retirar, l) then
			local t = math.min(resta, l.qtd)
			l.qtd -= t
			resta -= t
		end
		if l.qtd > 0 then
			table.insert(fica, l)
		end
	end
	c.cofre = fica
	if perm.limiteDiario ~= math.huge then
		r.qtd += tirar
	end
	anotar(c, agora, uid, "retirou", material .. "×" .. tirar)
	return true, "ok", tirar
end

function C.totaisDoCofre(c: Registro): { [string]: { qtd: number, livre: number, travado: number } }
	local t = {}
	for _, l in c.cofre do
		local x = t[l.material] or { qtd = 0, livre = 0, travado = 0 }
		x.qtd += l.qtd
		if l.estado == "livre" then
			x.livre += l.qtd
		elseif l.estado == "travado" then
			x.travado += l.qtd
		end
		t[l.material] = x
	end
	return t
end

-- ---------------------------------------------------------------- liderança e dissolução
function C.iniciarTransferencia(c: Registro, por: number, para: number, agora: number): (boolean, string)
	if C.cargo(c, por) ~= "Lider" then
		return false, "semPermissao"
	end
	if para == por or not C.cargo(c, para) then
		return false, "naoMembro"
	end
	c.transferencia = { para = para, ate = agora + C.TRANSFERENCIA_SEG }
	anotar(c, agora, por, "transferencia", k(para))
	return true, "ok"
end

function C.cancelarTransferencia(c: Registro, por: number, agora: number): boolean
	if C.cargo(c, por) ~= "Lider" or not c.transferencia then
		return false
	end
	c.transferencia = nil
	anotar(c, agora, por, "cancelouTransferencia", nil)
	return true
end

-- 1ª chamada: pede; 2ª: confirma e começa a contar 72 h
function C.pedirDissolucao(c: Registro, por: number, agora: number): (boolean, string)
	if C.cargo(c, por) ~= "Lider" then
		return false, "semPermissao"
	end
	if not c.dissolucao then
		c.dissolucao = { confirmacoes = 1, ate = nil }
		anotar(c, agora, por, "pediuDissolucao", nil)
		return true, "confirme"
	end
	if c.dissolucao.confirmacoes == 1 then
		c.dissolucao = { confirmacoes = 2, ate = agora + C.DISSOLUCAO_SEG }
		anotar(c, agora, por, "confirmouDissolucao", nil)
		return true, "agendada"
	end
	return false, "jaAgendada"
end

function C.cancelarDissolucao(c: Registro, por: number, agora: number): boolean
	if C.cargo(c, por) ~= "Lider" or not c.dissolucao then
		return false
	end
	c.dissolucao = nil
	anotar(c, agora, por, "cancelouDissolucao", nil)
	return true
end

-- avança os prazos. Devolve ("Transferida" | "Dissolvida" | nil, devolucoes)
function C.atualizar(c: Registro, agora: number): (string?, Devolucao?)
	if c.dissolvida then
		return nil, nil
	end
	if c.transferencia and agora >= c.transferencia.ate then
		local para = c.transferencia.para
		c.transferencia = nil
		if c.membros[k(para)] then
			for uid, m in c.membros do
				if m.cargo == "Lider" then
					c.membros[uid].cargo = "Oficial"
				end
			end
			c.membros[k(para)].cargo = "Lider"
			anotar(c, agora, para, "virouLider", nil)
			return "Transferida", nil
		end
	end
	if c.dissolucao and c.dissolucao.ate and agora >= c.dissolucao.ate then
		local dev: Devolucao = {}
		for _, l in c.cofre do
			dev[l.depositante] = dev[l.depositante] or {}
			dev[l.depositante][l.material] = (dev[l.depositante][l.material] or 0) + l.qtd
		end
		c.cofre = {}
		c.dissolvida = true
		anotar(c, agora, 0, "dissolvida", nil)
		return "Dissolvida", dev
	end
	return nil, nil
end

function C.guardarDevolucao(c: Registro, uid: number, itens: { [string]: number }?)
	if not itens or next(itens) == nil then
		return
	end
	local d = c.aDevolver[k(uid)] or {}
	for m, q in itens do
		d[m] = (d[m] or 0) + q
	end
	c.aDevolver[k(uid)] = d
end

-- nível: conveniência e cosmética (GDD), nunca poder de combate
function C.ganharXp(c: Registro, quanto: number): boolean
	if quanto <= 0 then
		return false
	end
	c.xp += quanto
	local subiu = false
	while c.xp >= 1000 * c.nivel do
		c.xp -= 1000 * c.nivel
		c.nivel += 1
		subiu = true
	end
	return subiu
end

return C
