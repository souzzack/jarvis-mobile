--!strict
-- NÃO EXECUTADO. Melhoria +1 a +10 de equipamentos (GDD 7.2) — LÓGICA PURA.
--  * Multiplicador cresce em linha da raridade até o TETO do +10 (= metade do salto até a raridade seguinte,
--    Raridades.tetoMelhoria): melhorar nunca torna obrigatório trocar de raridade, nem passa a seguinte.
--  * Onde: +1 a +5 na Oficina dos Inventores restaurada; +6 a +10 na Forja da base nível 4 (GDD 8 e 9).
--  * Custo crescente: Fragmentos 2×alvo; Núcleo de Tempestade a partir do +4 (2 a partir do +8); itens Druida
--    pedem também o material Druida de origem (1 a cada 3 níveis).

local Me = {}
Me.MAX = 10

function Me.multiplicador(base: number, teto: number, melhoria: number): number
	local k = math.clamp(melhoria, 0, Me.MAX)
	return base + (teto - base) * k / Me.MAX
end

-- onde fazer o próximo nível: { estacao, nivelEstacao, restauracao? }
function Me.onde(alvo: number): { estacao: string, nivelEstacao: number, restauracao: string? }
	if alvo <= 5 then
		return { estacao = "OficinaDosInventores", nivelEstacao = 1, restauracao = "OficinaDosInventores" }
	end
	return { estacao = "Forja", nivelEstacao = 4, restauracao = nil }
end

-- materiais para ir do nível atual para 'alvo'. materialDruida: id do material de origem (itens Druida)
function Me.custo(alvo: number, materialDruida: string?): { [string]: number }
	local c: { [string]: number } = { FragmentoDeFaisca = 2 * alvo }
	if alvo >= 8 then
		c.NucleoDeTempestade = 2
	elseif alvo >= 4 then
		c.NucleoDeTempestade = 1
	end
	if materialDruida then
		c[materialDruida] = math.ceil(alvo / 3)
	end
	return c
end

return Me
