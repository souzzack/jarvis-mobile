--!strict
-- NÃO EXECUTADO. Calcula o perfil de locomoção EFETIVO de um jogador: perfil base + habilidades aprendidas +
-- bônus de estágio de artefato + raça. LÓGICA PURA. Quem chama com dados confiáveis é o SERVIDOR; o resultado
-- é enviado ao cliente (o cliente nunca calcula o próprio perfil a partir do que ele "diz" que sabe).
--
-- Ordem dos mods: definir → somar → multiplicar. Tetos anti-inflação no fim (TETOS).

export type Mod = { campo: string, definir: number?, somar: number?, multiplicar: number? }
export type Fonte = { perfis: { string }?, mods: { Mod }?, liberaImpulso: number? }

local PE = {}

-- nenhum bônus empilhado passa destes múltiplos do valor base (proteção contra combinação quebrada)
local TETOS: { [string]: number } = { velMax = 1.35, velImpulso = 1.35, aceleracao = 1.5, velVerticalMax = 1.5, inclinacaoMax = 1.5 }
local PISOS: { [string]: number } = { custoPorSeg = 0.5, custoPairarPorSeg = 0.5, custoImpulsoPorSeg = 0.5 }

local function aplica(fonte: Fonte, perfil: any): boolean
	if not fonte.perfis then
		return false
	end
	for _, id in fonte.perfis :: { string } do
		-- "*" = voos do PRÓPRIO jogador; montarias mantêm o perfil da espécie
		if id == perfil.id or (id == "*" and perfil.tipo == "Motorizado" and not perfil.montaria) then
			return true
		end
	end
	return false
end

function PE.calcular(base: any, fontes: { Fonte }): any
	local p: { [string]: any } = table.clone(base)
	-- 1) liberar impulso (maior fator vence; não soma)
	local fatorImpulso = 0
	for _, f in fontes do
		if f.liberaImpulso and aplica(f, base) then
			fatorImpulso = math.max(fatorImpulso, f.liberaImpulso)
		end
	end
	if (p.velImpulso or 0) <= 0 and fatorImpulso > 0 then
		p.velImpulso = p.velMax * fatorImpulso
	end
	local valorBase: { [string]: number } = {}
	for k, v in p do
		if type(v) == "number" then
			valorBase[k] = v
		end
	end
	-- 2) definir, 3) somar, 4) multiplicar
	for _, fase in { "definir", "somar", "multiplicar" } do
		for _, f in fontes do
			if f.mods and aplica(f, base) then
				for _, mod in f.mods :: { Mod } do
					local atual = p[mod.campo]
					if type(atual) == "number" then
						if fase == "definir" and mod.definir ~= nil then
							p[mod.campo] = mod.definir
						elseif fase == "somar" and mod.somar ~= nil then
							p[mod.campo] = atual + mod.somar
						elseif fase == "multiplicar" and mod.multiplicar ~= nil then
							p[mod.campo] = atual * mod.multiplicar
						end
					end
				end
			end
		end
	end
	-- 5) tetos e pisos
	for campo, mult in TETOS do
		local b = valorBase[campo]
		if b and b > 0 and p[campo] > b * mult then
			p[campo] = b * mult
		end
	end
	for campo, mult in PISOS do
		local b = valorBase[campo]
		if b and p[campo] < b * mult then
			p[campo] = b * mult
		end
	end
	return p
end

return PE
