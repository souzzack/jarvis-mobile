--!strict
-- NÃO EXECUTADO. MOTOR UNIVERSAL DE ENIGMAS (PuzzleService, seção 6) — LÓGICA PURA, orientada a dados.
-- Cada enigma é uma config { tipo, ... }; um COMPONENTE por tipo sabe criar o estado e julgar uma ação.
-- Nada de script por enigma: um enigma novo = uma entrada de config. Tipos:
--   Sequencia        elementos numa ordem (fixa ou pela semente do jogador); errar recomeça
--   Alinhamento      cada elemento gira entre N posições até todos ficarem na posição alvo
--   Coleta           reunir itens/pistas espalhados (qualquer ordem)
--   Ressonancia      ativar elementos com uma CAPACIDADE (o servidor diz se o jogador a tem: ctx.capacidades)
--   Exploracao       chegar a áreas (o SERVIDOR mede a posição: ctx.dentro)
--   Cooperativo      N jogadores diferentes ativam os elementos dentro de uma janela de tempo
--   Interdimensional precisa de marcas obtidas em outras dimensões (ctx.marcas)
-- Resultado de agir: "certo" | "errado" | "completo" | "invalida" | "semEfeito".
-- O cliente só mostra efeitos; distância, estado e conclusão são do servidor (que chama estas funções).

local E = {}

local function permutar(lista: { any }, semente: number): { any }
	local t = table.clone(lista)
	local s = semente % 4294967296
	for i = #t, 2, -1 do
		s = (s * 1664525 + 1013904223) % 4294967296
		local j = (s % i) + 1
		t[i], t[j] = t[j], t[i]
	end
	return t
end

local C: { [string]: any } = {}

C.Sequencia = {
	novo = function(cfg: any, semente: number): any
		local ordem = if cfg.ordem == "semente" then permutar(cfg.elementos, semente) else table.clone(cfg.ordem or cfg.elementos)
		return { ordem = ordem, pos = 0 }
	end,
	agir = function(st: any, cfg: any, acao: any, _ctx: any): string
		if not table.find(cfg.elementos, acao.elemento) then
			return "invalida"
		end
		if st.ordem[st.pos + 1] == acao.elemento then
			st.pos += 1
			return if st.pos == #st.ordem then "completo" else "certo"
		end
		if cfg.reiniciarAoErrar ~= false then
			st.pos = 0
		end
		return "errado"
	end,
}

C.Alinhamento = {
	novo = function(cfg: any, semente: number): any
		local alvo = {}
		local pos = {}
		local g = semente
		for i, el in cfg.elementos do
			g = (g * 1664525 + 1013904223) % 4294967296
			alvo[el] = if cfg.alvo then cfg.alvo[el] else (g % cfg.posicoes) + 1
			pos[el] = 1
			-- nunca começa resolvido
			if i == #cfg.elementos then
				local tudo = true
				for _, e2 in cfg.elementos do
					if pos[e2] ~= alvo[e2] then
						tudo = false
					end
				end
				if tudo then
					alvo[el] = (alvo[el] % cfg.posicoes) + 1
				end
			end
		end
		return { alvo = alvo, pos = pos }
	end,
	agir = function(st: any, cfg: any, acao: any, _ctx: any): string
		local el = acao.elemento
		if st.pos[el] == nil then
			return "invalida"
		end
		st.pos[el] = (st.pos[el] % cfg.posicoes) + 1
		for _, e2 in cfg.elementos do
			if st.pos[e2] ~= st.alvo[e2] then
				return "certo"
			end
		end
		return "completo"
	end,
}

C.Coleta = {
	novo = function(_cfg: any, _s: number): any
		return { tem = {} }
	end,
	agir = function(st: any, cfg: any, acao: any, _ctx: any): string
		if not table.find(cfg.itens, acao.item) then
			return "invalida"
		end
		if st.tem[acao.item] then
			return "semEfeito"
		end
		st.tem[acao.item] = true
		for _, it in cfg.itens do
			if not st.tem[it] then
				return "certo"
			end
		end
		return "completo"
	end,
}

C.Ressonancia = {
	novo = function(_cfg: any, _s: number): any
		return { ativos = {} }
	end,
	agir = function(st: any, cfg: any, acao: any, ctx: any): string
		if not table.find(cfg.elementos, acao.elemento) then
			return "invalida"
		end
		local caps = (ctx and ctx.capacidades) or {}
		if not caps[cfg.capacidade] then
			return "errado" -- sem a capacidade: o mecanismo não responde (nada é marcado)
		end
		if st.ativos[acao.elemento] then
			return "semEfeito"
		end
		st.ativos[acao.elemento] = true
		for _, el in cfg.elementos do
			if not st.ativos[el] then
				return "certo"
			end
		end
		return "completo"
	end,
}

C.Exploracao = {
	novo = function(_cfg: any, _s: number): any
		return { alcancados = {} }
	end,
	agir = function(st: any, cfg: any, acao: any, ctx: any): string
		if not table.find(cfg.alvos, acao.alvo) then
			return "invalida"
		end
		if not (ctx and ctx.dentro) then
			return "errado" -- o servidor não viu o jogador lá
		end
		st.alcancados[acao.alvo] = true
		for _, a in cfg.alvos do
			if not st.alcancados[a] then
				return "certo"
			end
		end
		return "completo"
	end,
}

C.Cooperativo = {
	novo = function(_cfg: any, _s: number): any
		return { quem = {}, inicio = nil }
	end,
	agir = function(st: any, cfg: any, acao: any, _ctx: any): string
		if not table.find(cfg.elementos, acao.elemento) or type(acao.jogador) ~= "string" or type(acao.agora) ~= "number" then
			return "invalida"
		end
		if st.inicio and acao.agora - st.inicio > cfg.janela then
			st.quem, st.inicio = {}, nil -- passou da janela: recomeça
		end
		st.inicio = st.inicio or acao.agora
		st.quem[acao.elemento] = acao.jogador
		local distintos: { [string]: boolean } = {}
		for _, el in cfg.elementos do
			local j = st.quem[el]
			if not j then
				return "certo"
			end
			distintos[j] = true
		end
		local n = 0
		for _ in distintos do
			n += 1
		end
		if n < cfg.minJogadores then
			return "certo" -- todos os elementos ativos, mas pela mesma pessoa: ainda não
		end
		return "completo"
	end,
}

C.Interdimensional = {
	novo = function(_cfg: any, _s: number): any
		return {}
	end,
	agir = function(_st: any, cfg: any, _acao: any, ctx: any): string
		local marcas = (ctx and ctx.marcas) or {}
		for _, m in cfg.marcas do
			if not marcas[m] then
				return "errado"
			end
		end
		return "completo"
	end,
}

E.TIPOS = C

function E.novo(cfg: any, semente: number): any
	local comp = C[cfg.tipo]
	assert(comp, "tipo de enigma desconhecido: " .. tostring(cfg.tipo))
	local st = comp.novo(cfg, semente)
	st.resolvido = false
	return st
end

function E.agir(st: any, cfg: any, acao: any, ctx: any?): string
	if st.resolvido then
		return "semEfeito"
	end
	local comp = C[cfg.tipo]
	if not comp or type(acao) ~= "table" then
		return "invalida"
	end
	local r = comp.agir(st, cfg, acao, ctx)
	if r == "completo" then
		st.resolvido = true
	end
	return r
end

-- quem participou de um cooperativo (para a recompensa individual, conferida pelo servidor)
function E.participantes(st: any): { string }
	local l, visto = {}, {}
	for _, j in st.quem or {} do
		if not visto[j] then
			visto[j] = true
			table.insert(l, j)
		end
	end
	table.sort(l)
	return l
end

-- confere uma config (spec e carga do servidor): tipo conhecido e campos mínimos
function E.validarConfig(cfg: any): (boolean, string?)
	if type(cfg) ~= "table" or not C[cfg.tipo] then
		return false, "tipo"
	end
	local t = cfg.tipo
	if (t == "Sequencia" or t == "Alinhamento" or t == "Ressonancia" or t == "Cooperativo") and (type(cfg.elementos) ~= "table" or #cfg.elementos == 0) then
		return false, "elementos"
	end
	if t == "Alinhamento" and (type(cfg.posicoes) ~= "number" or cfg.posicoes < 2) then
		return false, "posicoes"
	end
	if t == "Coleta" and (type(cfg.itens) ~= "table" or #cfg.itens == 0) then
		return false, "itens"
	end
	if t == "Exploracao" and (type(cfg.alvos) ~= "table" or #cfg.alvos == 0) then
		return false, "alvos"
	end
	if t == "Ressonancia" and type(cfg.capacidade) ~= "string" then
		return false, "capacidade"
	end
	if t == "Cooperativo" and (type(cfg.minJogadores) ~= "number" or cfg.minJogadores < 2 or type(cfg.janela) ~= "number") then
		return false, "cooperativo"
	end
	if t == "Interdimensional" and (type(cfg.marcas) ~= "table" or #cfg.marcas == 0) then
		return false, "marcas"
	end
	if cfg.escopo ~= nil and cfg.escopo ~= "individual" and cfg.escopo ~= "cooperativo" then
		return false, "escopo"
	end
	return true, nil
end

return E
