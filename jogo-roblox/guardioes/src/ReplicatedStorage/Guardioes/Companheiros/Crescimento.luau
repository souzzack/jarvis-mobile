--!strict
-- NÃO EXECUTADO. CompanionGrowthSystem, parte pura: Filhote → Juvenil → Adulto.
-- O crescimento NUNCA depende só de tempo nem de compra: exige XP compartilhada, nível de vínculo, marcos da
-- espécie e (para adulto) um desafio próprio. É permanente: não existe função para regredir estágio.

export type Falta = { tipo: string, id: string, tem: number, precisa: number }

-- módulo puro e independente (roda no Lune): mesmos valores de DadosDaCriatura, sem importá-lo
local ESTAGIOS = { "Filhote", "Juvenil", "Adulto" }
local function nivelVinculo(c: any): number
	return math.min(10, math.floor(c.vinculo / 100))
end

local C = {}
C.ESTAGIOS = ESTAGIOS

function C.proximoEstagio(estagio: string): string?
	for i, e in ESTAGIOS do
		if e == estagio then
			return ESTAGIOS[i + 1]
		end
	end
	return nil
end

function C.avaliar(c: any, especie: any): (boolean, { Falta })
	local prox = C.proximoEstagio(c.estagio)
	local faltando: { Falta } = {}
	if not prox then
		return false, { { tipo = "maximo", id = c.estagio, tem = 0, precisa = 0 } }
	end
	local r = especie.estagios[prox].requisitos or {}
	if c.xp < (r.xp or 0) then
		table.insert(faltando, { tipo = "xp", id = "xp", tem = c.xp, precisa = r.xp })
	end
	local nv = nivelVinculo(c)
	if nv < (r.vinculo or 0) then
		table.insert(faltando, { tipo = "vinculo", id = "vinculo", tem = nv, precisa = r.vinculo })
	end
	for _, m in r.marcos or {} do
		if not c.marcos[m] then
			table.insert(faltando, { tipo = "marco", id = m, tem = 0, precisa = 1 })
		end
	end
	if r.desafio and not c.desafios[r.desafio] then
		table.insert(faltando, { tipo = "desafio", id = r.desafio, tem = 0, precisa = 1 })
	end
	return #faltando == 0, faltando
end

-- Evolui um estágio se tudo estiver cumprido. Atualiza a lista de habilidades da criatura.
function C.evoluir(c: any, especie: any): (boolean, { Falta })
	local ok, faltando = C.avaliar(c, especie)
	if not ok then
		return false, faltando
	end
	local prox = C.proximoEstagio(c.estagio) :: string
	c.estagio = prox
	c.habilidades = table.clone(especie.estagios[prox].habilidades)
	return true, faltando
end

-- pode servir de montaria? (espécie com montaria + estágio mínimo)
function C.podeMontar(c: any, especie: any): (boolean, string)
	if not especie.montaria then
		return false, "especieSemMontaria"
	end
	local min = especie.montaria.estagioMin or "Adulto"
	local idx: { [string]: number } = {}
	for i, e in ESTAGIOS do
		idx[e] = i
	end
	if (idx[c.estagio] or 0) < (idx[min] or 99) then
		return false, "jovemDemais"
	end
	return true, "ok"
end

return C
