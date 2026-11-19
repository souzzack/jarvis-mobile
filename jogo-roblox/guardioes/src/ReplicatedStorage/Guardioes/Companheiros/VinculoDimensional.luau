--!strict
-- NÃO EXECUTADO. DimensionalBondSystem, parte pura.
-- Pontos de afinidade vêm de OBJETIVOS concluídos com a criatura (cada um conta uma vez por criatura), nunca de
-- tempo parado. A especialização exige criatura adulta, afinidade disponível e possível para a espécie, e pontos
-- >= limiar. Trocar a especialização exige o ritual de realinhamento (reversível de propósito).
-- Novas afinidades = novas entradas em Config/AfinidadesDimensionais; este código não muda.

local V = {}

-- Registra um objetivo concluído. Retorna (ok, motivo, afinidadeId).
function V.registrarObjetivo(c: any, afinidades: any, objetivoId: string): (boolean, string, string?)
	local afId = afinidades.objetivoParaAfinidade[objetivoId]
	if not afId then
		return false, "objetivoDesconhecido", nil
	end
	if c.objetivosDimensionais[objetivoId] then
		return false, "jaConcluido", afId
	end
	local af = afinidades.porId[afId]
	local pontos = 0
	for _, o in af.objetivos do
		if o.id == objetivoId then
			pontos = o.pontos
		end
	end
	c.objetivosDimensionais[objetivoId] = true
	c.afinidades[afId] = (c.afinidades[afId] or 0) + pontos
	return true, "ok", afId
end

local function possivel(especie: any, afId: string): boolean
	for _, id in especie.afinidadesPossiveis or {} do
		if id == afId then
			return true
		end
	end
	return false
end

function V.podeEspecializar(c: any, especie: any, afinidades: any, afId: string): (boolean, string)
	local af = afinidades.porId[afId]
	if not af then
		return false, "afinidadeDesconhecida"
	end
	if not af.disponivel then
		return false, "indisponivel"
	end
	if not possivel(especie, afId) then
		return false, "especieIncompativel"
	end
	if c.estagio ~= "Adulto" then
		return false, "naoAdulto"
	end
	if (c.afinidades[afId] or 0) < af.limiar then
		return false, "pontos"
	end
	if c.especializacao == afId then
		return false, "jaEspecializada"
	end
	return true, "ok"
end

-- Especializa. Se já houver outra especialização, exige 'ritualConcluido' (realinhamento).
function V.especializar(c: any, especie: any, afinidades: any, afId: string, ritualConcluido: boolean): (boolean, string)
	local ok, motivo = V.podeEspecializar(c, especie, afinidades, afId)
	if not ok then
		return false, motivo
	end
	if c.especializacao ~= nil and not ritualConcluido then
		return false, "precisaRitual"
	end
	c.especializacao = afId
	return true, "ok"
end

-- habilidades efetivas: as do estágio + as da especialização (a espécie continua a mesma)
function V.habilidadesEfetivas(c: any, afinidades: any): { string }
	local lista = table.clone(c.habilidades)
	if c.especializacao then
		local af = afinidades.porId[c.especializacao]
		if af then
			for _, h in af.habilidades do
				table.insert(lista, h)
			end
		end
	end
	return lista
end

return V
