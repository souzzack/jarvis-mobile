--!strict
-- NÃO EXECUTADO. Esquema do perfil salvo (v2) — LÓGICA PURA (testável fora do Studio).
-- Nunca apaga dado antigo: um perfil de outra versão sem formato conhecido vira 'legadoMagnata' intacto.
-- Versão maior que a conhecida (servidor antigo lendo save novo) = somente leitura, para não estragar.

export type Perfil = {
	versao: number,
	moedas: number,
	raca: string?,
	habilidades: { [string]: string }, -- id → origem ("livro:GrimorioDosCeus", "raca", "missao:…")
	livrosLidos: { [string]: boolean },
	segredos: { [string]: boolean },
	missoes: { [string]: boolean },
	restauracoes: { [string]: boolean },
	dimensoes: { [string]: boolean },
	enigmas: { [string]: boolean },
	companheiros: { [string]: any }, -- guid → registro de Companheiros/DadosDaCriatura
	criaturaAtiva: string?,
	artefatos: { [string]: { id: string, estagio: number } }, -- guid → (formato final vem com o InventorySystem)
	legadoMagnata: any?,
	criadoEm: number,
	atualizadoEm: number,
}

local Perfil = {}
Perfil.VERSAO = 2
Perfil.LIMITES = { companheiros = 60, artefatos = 300, habilidades = 200 }

local CONJUNTOS = { "livrosLidos", "segredos", "missoes", "restauracoes", "dimensoes", "enigmas" }

function Perfil.novo(agora: number): Perfil
	return {
		versao = Perfil.VERSAO,
		moedas = 0,
		raca = nil,
		habilidades = {},
		livrosLidos = {},
		segredos = {},
		missoes = {},
		restauracoes = {},
		dimensoes = {},
		enigmas = {},
		companheiros = {},
		criaturaAtiva = nil,
		artefatos = {},
		legadoMagnata = nil,
		criadoEm = agora,
		atualizadoEm = agora,
	}
end

-- copia profunda (dados de DataStore: só tabelas, números, textos e booleanos)
function Perfil.copiar(v: any): any
	if type(v) ~= "table" then
		return v
	end
	local c = {}
	for k, x in v do
		c[k] = Perfil.copiar(x)
	end
	return c
end

-- (perfil, situacao): "novo" | "ok" | "completado" | "migradoDoLegado" | "versaoFutura"
function Perfil.migrar(bruto: any, agora: number): (Perfil, string)
	if bruto == nil then
		return Perfil.novo(agora), "novo"
	end
	if type(bruto) ~= "table" or type(bruto.versao) ~= "number" or bruto.versao < 2 then
		-- formato desconhecido/antigo: guarda INTEIRO e começa um perfil novo; moedas numéricas passam 1:1
		local p = Perfil.novo(agora)
		p.legadoMagnata = Perfil.copiar(bruto)
		if type(bruto) == "table" then
			local m = bruto.moedas or bruto.Moedas
			if type(m) == "number" and m >= 0 and m < 1e12 then
				p.moedas = math.floor(m)
			end
		end
		return p, "migradoDoLegado"
	end
	if bruto.versao > Perfil.VERSAO then
		return bruto :: any, "versaoFutura"
	end
	-- v2: completa campos que faltarem (perfis salvos antes de um campo existir)
	local p = Perfil.copiar(bruto)
	local base = Perfil.novo(agora)
	local completou = false
	for k, v in base :: any do
		if p[k] == nil and v ~= nil then
			p[k] = v
			completou = true
		end
	end
	return p, if completou then "completado" else "ok"
end

-- Validação antes de aceitar uma mudança (Perfil.atualizar no servidor). Retorna (ok, problema).
function Perfil.validar(p: any): (boolean, string?)
	if type(p) ~= "table" or p.versao ~= Perfil.VERSAO then
		return false, "versao"
	end
	if type(p.moedas) ~= "number" or p.moedas < 0 or p.moedas ~= p.moedas then
		return false, "moedas"
	end
	if type(p.habilidades) ~= "table" or type(p.companheiros) ~= "table" or type(p.artefatos) ~= "table" then
		return false, "estrutura"
	end
	for _, nome in CONJUNTOS do
		if type(p[nome]) ~= "table" then
			return false, nome
		end
	end
	local n = 0
	for guid, c in p.companheiros do
		n += 1
		if type(guid) ~= "string" or type(c) ~= "table" or c.guid ~= guid or type(c.especie) ~= "string" or type(c.xp) ~= "number" then
			return false, "companheiro"
		end
	end
	if n > Perfil.LIMITES.companheiros then
		return false, "limiteCompanheiros"
	end
	if p.criaturaAtiva ~= nil and p.companheiros[p.criaturaAtiva] == nil then
		return false, "criaturaAtiva"
	end
	local h = 0
	for id, origem in p.habilidades do
		h += 1
		if type(id) ~= "string" or type(origem) ~= "string" or origem == "teste" then
			return false, "habilidade" -- concessões de teste nunca entram no perfil salvo
		end
	end
	if h > Perfil.LIMITES.habilidades then
		return false, "limiteHabilidades"
	end
	return true, nil
end

return Perfil
