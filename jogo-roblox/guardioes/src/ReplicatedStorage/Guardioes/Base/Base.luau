--!strict
-- NÃO EXECUTADO. Base pessoal, fase 1 (GDD 9: espaços predefinidos com níveis) — LÓGICA PURA.
-- Melhorar um espaço exige nível do jogador e materiais; a colheita do Jardim acumula com o tempo (inclusive
-- fora do jogo) até um TETO — não é renda infinita como a do tycoon antigo.

export type Falta = { tipo: string, id: string, tem: number, precisa: number }

local B = {}

function B.nivel(base: any, espacoId: string, cfgEspaco: any): number
	return base.espacos[espacoId] or cfgEspaco.nivelInicial or 1
end

-- quantos equipamentos o jogador pode ter (Depósito). Sem config de Depósito: sem limite prático.
function B.capacidadeDoDeposito(base: any, cfgDeposito: any?): number
	if not cfgDeposito or not cfgDeposito.capacidade then
		return math.huge
	end
	local n = math.clamp(B.nivel(base, "Deposito", cfgDeposito), 1, #cfgDeposito.capacidade)
	return cfgDeposito.capacidade[n]
end

-- (pode, faltando, consumir) para subir do nível atual para o próximo
function B.avaliarMelhoria(cfgEspaco: any, nivelAtual: number, nivelJogador: number, materiais: { [string]: number }): (boolean, { Falta }, { [string]: number })
	local proximo = cfgEspaco.niveis and cfgEspaco.niveis[nivelAtual + 1]
	if nivelAtual >= (cfgEspaco.max or 1) or not proximo then
		return false, { { tipo = "maximo", id = "nivel", tem = nivelAtual, precisa = nivelAtual } }, {}
	end
	local faltando: { Falta } = {}
	if nivelJogador < (proximo.nivelJogador or 1) then
		table.insert(faltando, { tipo = "nivelJogador", id = "nivel", tem = nivelJogador, precisa = proximo.nivelJogador })
	end
	local consumir: { [string]: number } = {}
	for id, q in proximo.materiais or {} do
		consumir[id] = q
		local tem = materiais[id] or 0
		if tem < q then
			table.insert(faltando, { tipo = "material", id = id, tem = tem, precisa = q })
		end
	end
	table.sort(faltando, function(a, b)
		return a.tipo .. a.id < b.tipo .. b.id
	end)
	return #faltando == 0, faltando, consumir
end

-- Jardim: (quantidade colhível, novo 'colhidoEm'). Guarda a sobra de tempo; no teto, zera o relógio.
function B.colheita(nivel: number, colhidoEm: number, agora: number, porNivelPorHora: number, teto: number): (number, number)
	if nivel <= 0 or porNivelPorHora <= 0 or agora <= colhidoEm then
		return 0, colhidoEm
	end
	local periodo = 3600 / (porNivelPorHora * nivel)
	local qtd = math.floor((agora - colhidoEm) / periodo)
	if qtd >= teto then
		return teto, agora
	end
	return qtd, colhidoEm + qtd * periodo
end

-- reparte a colheita entre os materiais do jardim, em ordem (o primeiro recebe a sobra)
function B.repartir(qtd: number, materiais: { string }): { [string]: number }
	local r: { [string]: number } = {}
	local n = #materiais
	if n == 0 or qtd <= 0 then
		return r
	end
	local base = qtd // n
	local sobra = qtd - base * n
	for i, id in materiais do
		local q = base + (if i <= sobra then 1 else 0)
		if q > 0 then
			r[id] = q
		end
	end
	return r
end

return B
