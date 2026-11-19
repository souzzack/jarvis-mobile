--!strict
-- NÃO EXECUTADO. Mecânica do CÃO-TROVÃO ALFA (GDD 6.3) — LÓGICA PURA.
--  * Chama a matilha em 70% e 40% de vida.
--  * De tempos em tempos entra em CORRIDA CARREGADA: fica imune; só um APARO (defesa no instante do golpe)
--    quebra a corrida e o derruba (janela de dano). Sem aparo, a corrida acaba sozinha.

export type Estado = { chamadasUsadas: number, emCorrida: boolean, corridaAte: number, proximaCorrida: number }

local A = {}
A.LIMIARES = { 0.70, 0.40 }

function A.novo(agora: number, intervalo: number): Estado
	return { chamadasUsadas = 0, emCorrida = false, corridaAte = 0, proximaCorrida = agora + intervalo }
end

function A.deveChamar(e: Estado, fracaoVida: number): boolean
	local l = A.LIMIARES[e.chamadasUsadas + 1]
	return l ~= nil and fracaoVida <= l
end

function A.registrarChamada(e: Estado)
	e.chamadasUsadas += 1
end

-- "IniciaCorrida" | "FimCorrida" | nil
function A.atualizar(e: Estado, agora: number, intervalo: number, duracao: number): string?
	if e.emCorrida then
		if agora >= e.corridaAte then
			e.emCorrida = false
			e.proximaCorrida = agora + intervalo
			return "FimCorrida"
		end
		return nil
	end
	if agora >= e.proximaCorrida then
		e.emCorrida = true
		e.corridaAte = agora + duracao
		return "IniciaCorrida"
	end
	return nil
end

-- um jogador aparou um golpe do Alfa: durante a corrida, quebra (true = derrubar agora)
function A.aparado(e: Estado, agora: number, intervalo: number): boolean
	if not e.emCorrida then
		return false
	end
	e.emCorrida = false
	e.proximaCorrida = agora + intervalo
	return true
end

return A
