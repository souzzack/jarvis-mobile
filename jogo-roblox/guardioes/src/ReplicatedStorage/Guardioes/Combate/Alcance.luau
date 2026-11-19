--!strict
-- NÃO EXECUTADO. Testes geométricos no plano XZ. LÓGICA PURA (só números).
-- O servidor converte Vector3/CFrame em números antes de chamar, então isto roda fora do Studio.

local Alcance = {}

-- O alvo (centro tx,tz e raio do corpo) está ao alcance e dentro do arco do golpe?
-- o: origem do atacante; f: direção para onde olha (não precisa estar normalizada)
function Alcance.noArco(ox: number, oz: number, fx: number, fz: number, tx: number, tz: number, alcance: number, arcoGraus: number, raioAlvo: number): boolean
	local dx, dz = tx - ox, tz - oz
	local d = math.sqrt(dx * dx + dz * dz)
	if d > alcance + raioAlvo then
		return false
	end
	if arcoGraus >= 360 or d <= raioAlvo then
		return true
	end
	local fl = math.sqrt(fx * fx + fz * fz)
	if fl < 1e-6 then
		return false
	end
	local c = (dx * fx + dz * fz) / (d * fl)
	c = math.clamp(c, -1, 1)
	local ang = math.acos(c)
	local folgaCorpo = math.asin(math.min(1, raioAlvo / d)) -- a largura do alvo conta
	return ang <= math.rad(arcoGraus / 2) + folgaCorpo
end

-- O atacante (ax,az) está na frente do defensor (d em dx,dz olhando para f)? Usado por defesa e aparar.
function Alcance.frontal(dx: number, dz: number, fx: number, fz: number, ax: number, az: number, arcoGraus: number): boolean
	local vx, vz = ax - dx, az - dz
	local vl = math.sqrt(vx * vx + vz * vz)
	local fl = math.sqrt(fx * fx + fz * fz)
	if vl < 1e-6 or fl < 1e-6 then
		return true -- colado: conta como frente
	end
	local c = math.clamp((vx * fx + vz * fz) / (vl * fl), -1, 1)
	return math.acos(c) <= math.rad(arcoGraus / 2)
end

-- distância no plano (para limites de rede e de percepção)
function Alcance.distancia(ax: number, az: number, bx: number, bz: number): number
	local dx, dz = bx - ax, bz - az
	return math.sqrt(dx * dx + dz * dz)
end

return Alcance
