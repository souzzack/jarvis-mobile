--!strict
-- NÃO EXECUTADO. DESCOBERTAS (segredos ???) — LÓGICA PURA, sem nenhum segredo dentro.
-- As soluções, textos e a cadeia ficam em ServerScriptService/Guardioes/ConfigSecreta (só servidor); aqui só
-- a mecânica genérica, testável fora do Studio:
--  * semente por jogador e segredo (GDD 7.3: a solução varia por jogador, para não copiar a resposta da internet);
--  * ordens derivadas da semente (permutação, ordem circular a partir de um ponto);
--  * sequência de ativação (errou = recomeça);
--  * texto revelado aos poucos ("???" no lugar das palavras ainda não descobertas);
--  * situação de cada etapa de uma cadeia (feita, disponível, bloqueada por outra dimensão).

local D = {}

-- FNV-1a de 32 bits (determinístico em qualquer servidor)
function D.hash(texto: string): number
	local h = 2166136261
	for i = 1, #texto do
		h = bit32.bxor(h, string.byte(texto, i))
		-- h × 16777619 passaria de 2^53 (o número do Luau perderia precisão). 16777619 = 2^24 + 403, e
		-- h × 2^24 (mod 2^32) = (h mod 256) × 2^24: tudo fica abaixo de 2^42, exato.
		h = ((h % 256) * 16777216 + h * 403) % 4294967296
	end
	return h
end

function D.semente(userId: number, segredoId: string): number
	return D.hash(tostring(userId) .. "|" .. segredoId)
end

-- gerador congruente linear (números exatos: 1664525 × 2^32 < 2^53)
function D.gerador(semente: number): () -> number
	local s = semente % 4294967296
	return function(): number
		s = (s * 1664525 + 1013904223) % 4294967296
		return s
	end
end

-- permutação de 1..n (Fisher-Yates com o gerador)
function D.permutacao(semente: number, n: number): { number }
	local t = {}
	for i = 1, n do
		t[i] = i
	end
	local g = D.gerador(semente)
	for i = n, 2, -1 do
		local j = (g() % i) + 1
		t[i], t[j] = t[j], t[i]
	end
	return t
end

-- ordem circular: começa em 'inicio' e dá a volta (ex.: 4,5,6,1,2,3)
function D.ordemCircular(inicio: number, n: number): { number }
	local t = {}
	for k = 0, n - 1 do
		t[k + 1] = ((inicio - 1 + k) % n) + 1
	end
	return t
end

export type Sequencia = { ordem: { any }, pos: number }

function D.sequencia(ordem: { any }): Sequencia
	return { ordem = ordem, pos = 0 }
end

-- "certo" | "errado" (recomeça do zero) | "completo"
function D.ativar(seq: Sequencia, x: any): string
	if seq.pos >= #seq.ordem then
		return "completo"
	end
	if seq.ordem[seq.pos + 1] == x then
		seq.pos += 1
		return if seq.pos == #seq.ordem then "completo" else "certo"
	end
	seq.pos = 0
	return "errado"
end

-- revela 'fracao' (0..1) das palavras do texto; as outras viram "???". A ordem de revelação é fixa por texto,
-- então cada passo só ACRESCENTA palavras (nada que já apareceu some).
function D.revelar(texto: string, fracao: number): string
	local palavras = {}
	for p in string.gmatch(texto, "%S+") do
		table.insert(palavras, p)
	end
	local n = #palavras
	local quantas = math.floor(n * math.clamp(fracao, 0, 1) + 1e-9)
	local ordem = D.permutacao(D.hash(texto), n)
	local mostrar: { [number]: boolean } = {}
	for i = 1, quantas do
		mostrar[ordem[i]] = true
	end
	local saida = {}
	for i, p in palavras do
		saida[i] = if mostrar[i] then p else "???"
	end
	return table.concat(saida, " ")
end

export type Etapa = { id: string, conjunto: string, requer: { string }?, dimensao: string? }
export type Situacao = { id: string, feita: boolean, disponivel: boolean, bloqueadaPorDimensao: boolean }

-- conjuntos = { segredos = {...}, enigmas = {...} } do perfil; dimensoes = dimensões liberadas
function D.situacao(etapas: { Etapa }, conjuntos: { [string]: { [string]: boolean } }, dimensoes: { [string]: boolean }): { Situacao }
	local feitas: { [string]: boolean } = {}
	for _, e in etapas do
		local c = conjuntos[e.conjunto]
		if c and c[e.id] then
			feitas[e.id] = true
		end
	end
	local lista = {}
	for _, e in etapas do
		local pre = true
		for _, r in e.requer or {} do
			if not feitas[r] then
				pre = false
			end
		end
		local semDimensao = e.dimensao ~= nil and not dimensoes[e.dimensao]
		table.insert(lista, {
			id = e.id, feita = feitas[e.id] == true,
			disponivel = pre and not semDimensao and not feitas[e.id],
			bloqueadaPorDimensao = semDimensao and not feitas[e.id],
		})
	end
	return lista
end

function D.fracaoFeita(lista: { Situacao }): number
	if #lista == 0 then
		return 0
	end
	local n = 0
	for _, s in lista do
		if s.feita then
			n += 1
		end
	end
	return n / #lista
end

-- o jogador ficou parado? (amostras de posição do SERVIDOR: { t, x, y, z })
function D.parado(amostras: { { number } }, desde: number, tolerancia: number): boolean
	local base: { number }? = nil
	for _, a in amostras do
		if a[1] >= desde then
			if not base then
				base = a
			else
				local b = base :: { number }
				local dx, dy, dz = a[2] - b[2], a[3] - b[3], a[4] - b[4]
				if dx * dx + dy * dy + dz * dz > tolerancia * tolerancia then
					return false
				end
			end
		end
	end
	return base ~= nil
end

return D
