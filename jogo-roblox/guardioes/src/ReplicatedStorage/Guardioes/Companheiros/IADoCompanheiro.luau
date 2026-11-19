--!strict
-- NÃO EXECUTADO. CompanionAI — decisão de UMA criatura num instante. LÓGICA PURA (só números).
-- O servidor chama a 10 Hz e transforma a decisão em movimento. A personalidade vem da espécie
-- (Config/Especies/*.comportamento), então duas espécies diante da mesma cena agem diferente.
-- 'aleatorio' (0..1) vem de fora para o teste ser determinístico.

export type P3 = { x: number, y: number, z: number }
export type Entrada = {
	comando: string, -- "Acompanhar" | "Permanecer" | "Retornar" | "Montada"
	dono: P3?,
	donoOlha: { x: number, z: number }?, -- direção para onde o dono olha (plano)
	criatura: P3,
	ancora: P3?, -- ponto do "Permanecer"
	inimigo: (P3 & { id: string })?, -- inimigo mais próximo do dono (ou da âncora)
	interesse: P3?, -- ponto de interesse mais próximo (cristal, toca, corrente)
	comportamento: any,
	aleatorio: number,
}
export type Decisao = { acao: string, alvo: P3?, alvoId: string?, velocidade: number }

local IA = {}
IA.DISTANCIA_TELEPORTE = 80
IA.ALCANCE_ATAQUE = 25
IA.RAIO_INTERESSE = 15

local ALTURA_POR_ESTILO: { [string]: number } = { Flutua = 1.5, Plana = 6, Saltita = 0, Trota = 0 }

local function dist(a: P3, b: P3): number
	local dx, dy, dz = a.x - b.x, a.y - b.y, a.z - b.z
	return math.sqrt(dx * dx + dy * dy + dz * dz)
end

-- posição de escolta: ao lado preferido e um pouco atrás do dono, na altura do estilo
function IA.posicaoDeEscolta(dono: P3, olha: { x: number, z: number }?, comp: any): P3
	local lx, lz = 0, -1
	if olha then
		local n = math.sqrt(olha.x * olha.x + olha.z * olha.z)
		if n > 1e-6 then
			lx, lz = olha.x / n, olha.z / n
		end
	end
	local rx, rz = -lz, lx -- direita do dono
	local d = comp.distanciaSeguir or 5
	local lado = 0
	if comp.ladoPreferido == "Direita" then
		lado = 1
	elseif comp.ladoPreferido == "Esquerda" then
		lado = -1
	end
	local altura = ALTURA_POR_ESTILO[comp.estilo] or 0
	if comp.ladoPreferido == "Acima" then
		altura += 4
	end
	local lateral = d * 0.8 * lado
	local tras = d * (if lado == 0 then 0.9 else 0.5)
	return { x = dono.x + rx * lateral - lx * tras, y = dono.y + altura, z = dono.z + rz * lateral - lz * tras }
end

function IA.decidir(e: Entrada): Decisao
	local comp = e.comportamento
	if e.comando == "Montada" then
		return { acao = "Montada", alvo = nil, alvoId = nil, velocidade = 0 }
	end
	-- Permanecer: fica na âncora; só os corajosos defendem o lugar
	if e.comando == "Permanecer" and e.ancora then
		if e.inimigo and comp.coragem >= 0.7 and dist(e.inimigo, e.ancora) <= 10 then
			return { acao = "Atacar", alvo = e.inimigo, alvoId = e.inimigo.id, velocidade = 1.3 }
		end
		if dist(e.criatura, e.ancora) > 1.5 then
			return { acao = "Seguir", alvo = e.ancora, alvoId = nil, velocidade = 1 }
		end
		return { acao = "Parado", alvo = nil, alvoId = nil, velocidade = 0 }
	end
	local dono = e.dono
	if not dono then
		return { acao = "Parado", alvo = nil, alvoId = nil, velocidade = 0 }
	end
	local dDono = dist(e.criatura, dono)
	if dDono > IA.DISTANCIA_TELEPORTE then
		return { acao = "Teleportar", alvo = IA.posicaoDeEscolta(dono, e.donoOlha, comp), alvoId = nil, velocidade = 0 }
	end
	local escolta = IA.posicaoDeEscolta(dono, e.donoOlha, comp)
	if e.comando == "Retornar" then
		return { acao = "Seguir", alvo = escolta, alvoId = nil, velocidade = 1.8 }
	end
	-- Acompanhar: combate conforme a coragem da espécie
	if e.inimigo and dist(e.inimigo, dono) <= IA.ALCANCE_ATAQUE then
		if comp.coragem >= 0.7 then
			return { acao = "Atacar", alvo = e.inimigo, alvoId = e.inimigo.id, velocidade = 1.4 }
		elseif comp.coragem < 0.3 then
			-- esconde do lado oposto ao inimigo
			local dx, dz = dono.x - e.inimigo.x, dono.z - e.inimigo.z
			local n = math.max(1e-6, math.sqrt(dx * dx + dz * dz))
			local alvo = { x = dono.x + dx / n * 4, y = escolta.y, z = dono.z + dz / n * 4 }
			return { acao = "Fugir", alvo = alvo, alvoId = nil, velocidade = 1.5 }
		end
	end
	-- curiosidade: às vezes investiga algo perto (nunca longe do dono)
	if e.interesse and dist(e.interesse, dono) <= IA.RAIO_INTERESSE and e.aleatorio < (comp.curiosidade or 0) * 0.25 then
		return { acao = "Investigar", alvo = e.interesse, alvoId = nil, velocidade = 0.8 }
	end
	local longe = dist(e.criatura, escolta)
	if longe < 1.5 then
		return { acao = "Parado", alvo = nil, alvoId = nil, velocidade = 0 }
	end
	local d = comp.distanciaSeguir or 5
	return { acao = "Seguir", alvo = escolta, alvoId = nil, velocidade = if longe > d * 3 then 1.6 else 1 }
end

return IA
