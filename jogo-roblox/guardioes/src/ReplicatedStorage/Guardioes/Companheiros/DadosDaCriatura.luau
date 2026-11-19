--!strict
-- NÃO EXECUTADO. CompanionData: o registro persistente de UMA criatura companheira. LÓGICA PURA.
-- (Companheiros = criaturas individuais. Companhias = guildas de jogadores, CompanySystem. Não confundir.)
-- Este registro vai inteiro para o perfil do jogador (PlayerDataSystem, esquema v2 → campo 'companheiros[guid]').

export type Criatura = {
	guid: string,
	especie: string,
	nome: string,
	estagio: string, -- "Filhote" | "Juvenil" | "Adulto"
	xp: number,
	vinculo: number, -- pontos; nível = floor(pontos / 100), de 0 a 10
	marcos: { [string]: boolean },
	desafios: { [string]: boolean },
	objetivosDimensionais: { [string]: boolean },
	afinidades: { [string]: number }, -- pontos por afinidade (Vínculo Dimensional)
	especializacao: string?,
	habilidades: { string },
	cosmetico: { variante: string, cor: string? },
	estado: string, -- "Acompanhando" | "Permanecendo" | "Guardada" | "Montada"
	ganhosDoDia: { dia: number, porAtividade: { [string]: number } },
	versao: number,
}

local D = {}

D.VERSAO = 1
D.ESTAGIOS = { "Filhote", "Juvenil", "Adulto" }
D.VINCULO_MAX = 10
-- teto diário de vínculo por tipo de atividade: repetir a mesma coisa o dia todo não "compra" vínculo
D.TETO_VINCULO_DIA = 120

function D.nova(guid: string, especie: string, nome: string): Criatura
	return {
		guid = guid, especie = especie, nome = nome, estagio = "Filhote",
		xp = 0, vinculo = 0, marcos = {}, desafios = {}, objetivosDimensionais = {}, afinidades = {},
		especializacao = nil, habilidades = {}, cosmetico = { variante = "Padrao" },
		estado = "Acompanhando", ganhosDoDia = { dia = 0, porAtividade = {} }, versao = D.VERSAO,
	}
end

-- nome: 1 a 20 caracteres, letras/números/espaço/hífen. O FILTRO DE TEXTO do Roblox (TextService) é obrigatório
-- no servidor antes de salvar/exibir: isto é só a checagem de formato.
function D.nomeValido(nome: any): boolean
	if type(nome) ~= "string" then
		return false
	end
	local n = utf8.len(nome)
	if not n or n < 1 or n > 20 then
		return false
	end
	-- sem caracteres de controle nem símbolos de marcação; sem espaço nas pontas (acentos são permitidos)
	if string.find(nome, "[%c<>\"'`\\{}]") then
		return false
	end
	return string.find(nome, "^%s") == nil and string.find(nome, "%s$") == nil
end

function D.nivelVinculo(c: Criatura): number
	return math.min(D.VINCULO_MAX, math.floor(c.vinculo / 100))
end

function D.ganharXp(c: Criatura, quanto: number)
	if quanto > 0 then
		c.xp += math.floor(quanto)
	end
end

-- 'dia' = número do dia (ex.: os.time() // 86400, calculado no servidor). Devolve o que foi de fato ganho.
function D.ganharVinculo(c: Criatura, atividade: string, quanto: number, dia: number): number
	if quanto <= 0 then
		return 0
	end
	if c.ganhosDoDia.dia ~= dia then
		c.ganhosDoDia = { dia = dia, porAtividade = {} }
	end
	local ja = c.ganhosDoDia.porAtividade[atividade] or 0
	local ganho = math.max(0, math.min(quanto, D.TETO_VINCULO_DIA - ja))
	c.ganhosDoDia.porAtividade[atividade] = ja + ganho
	c.vinculo = math.min(D.VINCULO_MAX * 100 + 99, c.vinculo + ganho)
	return ganho
end

function D.registrarMarco(c: Criatura, id: string): boolean
	if c.marcos[id] then
		return false
	end
	c.marcos[id] = true
	return true
end

function D.registrarDesafio(c: Criatura, id: string): boolean
	if c.desafios[id] then
		return false
	end
	c.desafios[id] = true
	return true
end

return D
