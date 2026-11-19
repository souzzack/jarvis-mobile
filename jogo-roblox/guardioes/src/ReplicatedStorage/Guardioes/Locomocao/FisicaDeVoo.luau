--!strict
-- NÃO EXECUTADO. Integração do movimento aéreo (voo, prancha, plataforma, planador). LÓGICA PURA: só números.
-- Roda no CLIENTE (dono da física do personagem) a cada quadro, para resposta imediata; o servidor não integra
-- física, ele CONFERE o deslocamento (ValidadorDeDeslocamento) com os limites do mesmo perfil.
--
-- Eixos: X/Z horizontais, Y vertical. 'rumo' = atan2(vx, vz) em radianos (o cliente converte para CFrame).
-- Saídas visuais suaves: 'inclinacao' (rolagem nas curvas) e 'arfagem' (nariz para cima/baixo), em radianos.

export type Estado = { vx: number, vy: number, vz: number, rumo: number, inclinacao: number, arfagem: number }
export type Entrada = {
	dx: number, -- direção horizontal desejada (mundo), comprimento 0..1
	dz: number,
	vertical: number, -- -1 (descer) .. 1 (subir)
	impulso: boolean,
}
export type Ambiente = { correnteAscendente: number?, alturaSobreSolo: number? }

local F = {}

local SUAVIZACAO_VISUAL = 8 -- 1/s
local ARFAGEM_MAX = math.rad(40)

function F.novo(rumo: number?): Estado
	return { vx = 0, vy = 0, vz = 0, rumo = rumo or 0, inclinacao = 0, arfagem = 0 }
end

-- move (ax, az) em direção a (bx, bz) no máximo 'passo'
local function aproximar2(ax: number, az: number, bx: number, bz: number, passo: number): (number, number)
	local dx, dz = bx - ax, bz - az
	local d = math.sqrt(dx * dx + dz * dz)
	if d <= passo or d < 1e-9 then
		return bx, bz
	end
	return ax + dx / d * passo, az + dz / d * passo
end

local function aproximar1(a: number, b: number, passo: number): number
	if math.abs(b - a) <= passo then
		return b
	end
	return a + math.sign(b - a) * passo
end

-- menor diferença angular (b - a) em (-pi, pi]
function F.difAngulo(a: number, b: number): number
	local d = (b - a) % (2 * math.pi)
	if d > math.pi then
		d -= 2 * math.pi
	end
	return d
end

function F.velocidadeHorizontal(e: Estado): number
	return math.sqrt(e.vx * e.vx + e.vz * e.vz)
end

-- Avança 'dt' segundos. Retorna o custo de energia do passo e se o impulso está de fato ativo.
function F.passo(e: Estado, p: any, ent: Entrada, dt: number, amb: Ambiente?): (number, boolean)
	if dt <= 0 then
		return 0, false
	end
	local rumoAntes = e.rumo
	local mag = math.clamp(math.sqrt(ent.dx * ent.dx + ent.dz * ent.dz), 0, 1)
	local impulsoAtivo = ent.impulso and p.velImpulso > 0 and mag > 0.1
	local custo: number

	if p.tipo == "Planador" then
		-- sem motor: sempre para frente, curva limitada, perde altura; mergulhar troca altura por velocidade
		if mag > 0.1 then
			local alvoRumo = math.atan2(ent.dx, ent.dz)
			local giro = math.rad(p.taxaGiro or 90) * dt
			e.rumo += math.clamp(F.difAngulo(e.rumo, alvoRumo), -giro, giro)
		end
		local h = F.velocidadeHorizontal(e)
		local mergulho = math.clamp(-ent.vertical, 0, 1)
		local alvoH = (p.velMin or 0) + ((p.velMax - (p.velMin or 0)) * (0.5 + 0.5 * mergulho))
		h = aproximar1(h, alvoH, (if alvoH > h then p.aceleracao else p.desaceleracao) * dt)
		e.vx, e.vz = math.sin(e.rumo) * h, math.cos(e.rumo) * h
		local corrente = (amb and amb.correnteAscendente) or 0
		local alvoV = -(p.afundamento or 6) * (1 + 2 * mergulho) + corrente
		alvoV = math.clamp(alvoV, -p.velVerticalMax, p.velVerticalMax)
		e.vy = aproximar1(e.vy, alvoV, p.acelVertical * dt)
		custo = 0
	else
		local velAlvo = if impulsoAtivo then p.velImpulso else p.velMax
		local ax, az = 0, 0
		if mag > 1e-6 then
			local n = math.sqrt(ent.dx * ent.dx + ent.dz * ent.dz)
			ax, az = ent.dx / n * mag * velAlvo, ent.dz / n * mag * velAlvo
		end
		local hAtual = F.velocidadeHorizontal(e)
		local taxa = if math.sqrt(ax * ax + az * az) >= hAtual then p.aceleracao else p.desaceleracao
		e.vx, e.vz = aproximar2(e.vx, e.vz, ax, az, taxa * dt)
		local alvoV = math.clamp(ent.vertical, -1, 1) * p.velVerticalMax
		-- plataforma: não passa da altura máxima sobre o chão
		if p.alturaMaxSobreSolo and amb and amb.alturaSobreSolo and amb.alturaSobreSolo >= p.alturaMaxSobreSolo then
			alvoV = math.min(alvoV, 0)
		end
		e.vy = aproximar1(e.vy, alvoV, p.acelVertical * dt)
		local h = F.velocidadeHorizontal(e)
		if h > 1 then
			e.rumo = math.atan2(e.vx, e.vz)
		end
		if impulsoAtivo then
			custo = p.custoImpulsoPorSeg * dt
		elseif h < 2 then
			custo = p.custoPairarPorSeg * dt
		else
			custo = p.custoPorSeg * dt
		end
	end

	-- visual: rolagem proporcional à velocidade de giro; arfagem pela razão vertical/horizontal
	local giroPorSeg = F.difAngulo(rumoAntes, e.rumo) / dt
	local maxInc = math.rad(p.inclinacaoMax)
	local alvoInc = math.clamp(giroPorSeg * p.fatorInclinacao, -maxInc, maxInc)
	local k = math.min(1, dt * SUAVIZACAO_VISUAL)
	e.inclinacao += (alvoInc - e.inclinacao) * k
	local alvoArf = math.clamp(math.atan2(e.vy, math.max(F.velocidadeHorizontal(e), 4)), -ARFAGEM_MAX, ARFAGEM_MAX)
	e.arfagem += (alvoArf - e.arfagem) * k
	return custo, impulsoAtivo
end

-- Limites que o servidor usa para conferir este perfil (mesma fonte de verdade da física)
function F.limites(p: any): { velHorizontal: number, velSubida: number, velQueda: number }
	local h = math.max(p.velMax, p.velImpulso or 0)
	local subida = p.velVerticalMax
	local queda = p.velVerticalMax
	if p.tipo == "Planador" then
		subida = p.velVerticalMax
		queda = math.max(p.velVerticalMax, (p.afundamento or 6) * 3)
	end
	return { velHorizontal = h, velSubida = subida, velQueda = queda }
end

return F
