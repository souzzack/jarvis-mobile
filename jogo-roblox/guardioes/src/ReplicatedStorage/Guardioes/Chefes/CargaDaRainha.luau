--!strict
-- NÃO EXECUTADO. Mecânica da Rainha-Bobina (GDD 6.3) — LÓGICA PURA.
-- A cada limiar de vida (75%, 50%, 25%) começa uma FASE DE CARGA: a Rainha fica imune e os pilares de cristal
-- acendem. Quebrar todos antes do tempo = ela cai atordoada (janela de dano). Se o tempo acabar = DESCARGA
-- (golpe em área em quem estiver na arena; dá para esquivar ou aparar).

export type Estado = { limiaresUsados: number, emCarga: boolean, ate: number, pilares: number }

local Q = {}
Q.LIMIARES = { 0.75, 0.50, 0.25 }

function Q.novo(): Estado
	return { limiaresUsados = 0, emCarga = false, ate = 0, pilares = 0 }
end

-- deve começar uma carga agora? (fração de vida atual). Um limiar por vez, em ordem; nunca durante outra carga.
function Q.deveCarregar(e: Estado, fracaoVida: number): boolean
	if e.emCarga then
		return false
	end
	local proximo = Q.LIMIARES[e.limiaresUsados + 1]
	return proximo ~= nil and fracaoVida <= proximo
end

function Q.iniciar(e: Estado, agora: number, duracao: number, pilares: number)
	e.limiaresUsados += 1
	e.emCarga = true
	e.ate = agora + duracao
	e.pilares = pilares
end

function Q.pilarQuebrado(e: Estado)
	if e.emCarga and e.pilares > 0 then
		e.pilares -= 1
	end
end

-- "Sucesso" (todos os pilares quebrados a tempo), "Descarga" (tempo acabou) ou nil (continua)
function Q.atualizar(e: Estado, agora: number): string?
	if not e.emCarga then
		return nil
	end
	if e.pilares <= 0 then
		e.emCarga = false
		return "Sucesso"
	end
	if agora >= e.ate then
		e.emCarga = false
		return "Descarga"
	end
	return nil
end

return Q
