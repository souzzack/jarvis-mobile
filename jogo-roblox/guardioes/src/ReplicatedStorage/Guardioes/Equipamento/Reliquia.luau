--!strict
-- NÃO EXECUTADO. Relíquia (GDD 7.4: ativa, recarga longa; vem de Guardiões e segredos) — LÓGICA PURA.
-- A recarga usa o relógio do servidor (os.time) e fica SALVA no perfil: sair e voltar não zera a recarga.

local R = {}

export type Estado = { agora: number, recargaAte: number, vivo: boolean, atordoado: boolean }

function R.podeAtivar(cfgItem: any, e: Estado): (boolean, string)
	if not cfgItem or cfgItem.tipo ~= "Reliquia" or not cfgItem.ativa then
		return false, "semReliquia"
	end
	if not e.vivo then
		return false, "semReliquia"
	end
	if e.atordoado then
		return false, "atordoado"
	end
	if e.agora < e.recargaAte then
		return false, "recarga"
	end
	return true, "ok"
end

function R.proximaRecarga(cfgItem: any, agora: number): number
	return agora + cfgItem.ativa.recarga
end

-- segundos que faltam (0 = pronta)
function R.falta(recargaAte: number, agora: number): number
	return math.max(0, recargaAte - agora)
end

return R
