--!strict
-- NÃO EXECUTADO. Usar consumível — LÓGICA PURA (o tempo e o estado vêm de fora).

local C = {}

export type Estado = { agora: number, emVoo: boolean, atordoado: boolean, vivo: boolean, recargas: { [string]: number } }

-- (pode, motivo). recargas: tipo de efeito → quando libera de novo
function C.podeUsar(cfg: any, e: Estado, quantidade: number): (boolean, string)
	if not cfg then
		return false, "naoPossui"
	end
	if quantidade < 1 then
		return false, "naoPossui"
	end
	if not e.vivo then
		return false, "naoPossui"
	end
	if e.atordoado then
		return false, "atordoado"
	end
	if e.emVoo and not cfg.emVoo then
		return false, "emVoo"
	end
	if (e.recargas[cfg.efeito.tipo] or 0) > e.agora then
		return false, "recarga"
	end
	return true, "ok"
end

function C.marcarRecarga(cfg: any, e: Estado)
	e.recargas[cfg.efeito.tipo] = e.agora + cfg.recarga
end

-- cura em pulsos de 0,5 s: valor por pulso (a soma dá exatamente o total)
function C.pulsosDeCura(valor: number, duracao: number): { number }
	local n = math.max(1, math.floor(duracao / 0.5 + 0.5))
	local t = {}
	local dado = 0
	for i = 1, n do
		local alvo = valor * i / n
		t[i] = alvo - dado
		dado = alvo
	end
	return t
end

return C
