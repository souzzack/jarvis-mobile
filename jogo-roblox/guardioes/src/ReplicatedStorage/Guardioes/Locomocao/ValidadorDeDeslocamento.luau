--!strict
-- NÃO EXECUTADO. Conferência de deslocamento no SERVIDOR. LÓGICA PURA (posições como números).
-- O cliente é dono da física do personagem (resposta imediata); o servidor amostra a posição ~10 vezes por
-- segundo e confere se o salto entre amostras cabe nos limites do estado/perfil atual, com folga de latência.
-- Uma violação isolada (lag) é tolerada; violações seguidas pedem correção (volta à última posição válida).

export type Amostra = { x: number, y: number, z: number, t: number }
export type Limites = { velHorizontal: number, velSubida: number, velQueda: number, alturaMax: number }
export type Registro = { ultimaValida: Amostra?, violacoesSeguidas: number, total: number }

local V = {}

function V.novoRegistro(): Registro
	return { ultimaValida = nil, violacoesSeguidas = 0, total = 0 }
end

-- (ok, motivo). 'fator' multiplica as velocidades (tolerância de picos de física); 'folga' em studs (latência).
function V.verificar(a: Amostra, b: Amostra, lim: Limites, fator: number, folga: number): (boolean, string)
	if b.y > lim.alturaMax then
		return false, "altitude"
	end
	local dt = b.t - a.t
	if dt <= 0 then
		return true, "mesmoInstante"
	end
	local dx, dz = b.x - a.x, b.z - a.z
	local h = math.sqrt(dx * dx + dz * dz)
	if h > lim.velHorizontal * fator * dt + folga then
		return false, "horizontal"
	end
	local dy = b.y - a.y
	if dy > lim.velSubida * fator * dt + folga then
		return false, "subida"
	end
	if -dy > lim.velQueda * fator * dt + folga then
		return false, "queda"
	end
	return true, "ok"
end

-- Registra a amostra. Retorna (corrigir?, amostra para onde voltar, motivo).
function V.registrar(r: Registro, b: Amostra, lim: Limites, fator: number, folga: number, violacoesParaCorrigir: number): (boolean, Amostra?, string)
	local a = r.ultimaValida
	if not a then
		r.ultimaValida = b
		return false, nil, "primeira"
	end
	local ok, motivo = V.verificar(a, b, lim, fator, folga)
	if ok then
		r.ultimaValida = b
		r.violacoesSeguidas = 0
		return false, nil, motivo
	end
	r.violacoesSeguidas += 1
	r.total += 1
	if r.violacoesSeguidas >= violacoesParaCorrigir then
		r.violacoesSeguidas = 0
		-- a última válida continua a referência: o tempo dela avança para não acumular tolerância falsa
		local volta = { x = a.x, y = a.y, z = a.z, t = b.t }
		r.ultimaValida = volta
		return true, volta, motivo
	end
	return false, nil, motivo
end

-- depois de um teleporte legítimo do servidor (portal, renascer), recomeça a referência
function V.reancorar(r: Registro, b: Amostra)
	r.ultimaValida = b
	r.violacoesSeguidas = 0
end

return V
