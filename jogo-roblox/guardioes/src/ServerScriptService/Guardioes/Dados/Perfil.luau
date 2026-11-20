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
	artefatos: { [string]: { id: string, estagio: number } }, -- guid → artefato (InventorySystem)
	materiais: { [string]: number }, -- id → quantidade (InventorySystem)
	artefatoEquipado: string?,
	nivel: number,
	xp: number,
	missoesProgresso: { [string]: { [string]: number } }, -- missão → objetivo → contagem
	receitas: { [string]: boolean }, -- receitas aprendidas (esboços Druida, códices…)
	pontosDescobertos: { [string]: boolean }, -- viagem rápida
	equipamentos: { [string]: { id: string } }, -- guid → armadura/acessório (EquipmentSystem)
	equipado: { [string]: string }, -- encaixe → guid
	transportes: { [string]: boolean }, -- transportes comuns possuídos (prancha de viagem…)
	transportePreferido: string?,
	reliquiaRecargaAte: number,
	-- Mistérios (complemento 03): investigações, enigmas resolvidos, recompensas já pagas (nunca pagam 2×),
	-- registros de lore, conhecimentos, receitas secretas, portais descobertos e fabricações secretas
	misterios: {
		versao: number,
		investigacoes: { [string]: any },
		enigmas: { [string]: boolean },
		recompensas: { [string]: boolean },
		registros: { [string]: boolean },
		conhecimentos: { [string]: boolean },
		receitas: { [string]: boolean },
		portais: { [string]: string },
		fabricados: { [string]: number },
		evolucoes: { [string]: boolean },
		marcas: { [string]: boolean }, -- marcas interdimensionais (ex.: ChaveIncompleta) para enigmas em outras dimensões
	}, -- os.time() em que a relíquia equipada fica pronta (salvo: sair não zera)
	companhia: string?, -- id da companhia (guilda); a verdade fica na store das companhias
	base: { espacos: { [string]: number }, jardimColhidoEm: number, trofeus: { [string]: boolean } },
	restauracoesProgresso: { [string]: { etapa: number, entregue: { [string]: number } } }, -- por estrutura
	legadoMagnata: any?,
	titulos: { [string]: boolean }, -- ex.: VeteranoDoMagnata (quem jogou o tycoon)
	criadoEm: number,
	atualizadoEm: number,
}

local Perfil = {}
Perfil.VERSAO = 2
Perfil.LIMITES = { companheiros = 60, artefatos = 300, habilidades = 200, pilha = 9999, tiposDeMaterial = 500, nivelMax = 60 }

local CONJUNTOS = { "livrosLidos", "segredos", "missoes", "restauracoes", "dimensoes", "enigmas", "receitas", "pontosDescobertos", "transportes", "titulos" }

Perfil.MISTERIOS_VERSAO = 1
Perfil.ESTADOS_INVESTIGACAO = { Undiscovered = true, Discovered = true, Investigating = true, ReadyToSolve = true, Completed = true }

function Perfil.misteriosNovo(): any
	return {
		versao = Perfil.MISTERIOS_VERSAO, investigacoes = {}, enigmas = {}, recompensas = {}, registros = {},
		conhecimentos = {}, receitas = {}, portais = {}, fabricados = {}, evolucoes = {}, marcas = {},
	}
end

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
		materiais = {},
		artefatoEquipado = nil,
		nivel = 1,
		xp = 0,
		missoesProgresso = {},
		receitas = {},
		restauracoesProgresso = {},
		pontosDescobertos = {},
		equipamentos = {},
		equipado = {},
		transportes = {},
		transportePreferido = nil,
		reliquiaRecargaAte = 0,
		misterios = Perfil.misteriosNovo(),
		companhia = nil,
		base = { espacos = {}, jardimColhidoEm = agora, trofeus = {} },
		legadoMagnata = nil,
		titulos = {},
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

-- Perfil v1 do tycoon (MagnataDados_v1, campo 'dados'): tem equipamentos e galpão do Magnata.
function Perfil.ehMagnataV1(v: any): boolean
	return type(v) == "table" and type(v.moedas) == "number" and type(v.equip) == "table" and type(v.galpao) == "table"
end

local function numero(v: any, max: number): number
	if type(v) ~= "number" or v ~= v or v < 0 then
		return 0
	end
	return math.floor(math.min(v, max))
end

-- Migração do tycoon (docs/04, seção 2): nada se perde.
--  * o perfil v1 inteiro fica em legadoMagnata (reversível à mão);
--  * moedas passam 1:1;
--  * o que foi investido em renda (galpão, equipamentos, renascimentos) vira o título VeteranoDoMagnata
--    e materiais iniciais proporcionais, com teto (não desequilibra o RPG).
function Perfil.migrarV1paraV2(v1: any, agora: number): Perfil
	local p = Perfil.novo(agora)
	p.legadoMagnata = Perfil.copiar(v1)
	if type(v1) ~= "table" then
		return p
	end
	p.moedas = numero(v1.moedas, 1e12 - 1)
	local itensGalpao = 0
	if type(v1.galpao) == "table" then
		for _, comprado in v1.galpao do
			if comprado == true then
				itensGalpao += 1
			end
		end
	end
	local niveisEquip = 0
	if type(v1.equip) == "table" then
		for _, nv in v1.equip do
			niveisEquip += math.max(0, numero(nv, 10) - 1)
		end
	end
	local renasc = numero(v1.renascimentos, 1000)
	local secretos = numero(v1.secretos, 1e6)
	local jogou = itensGalpao > 0 or niveisEquip > 0 or renasc > 0 or numero(v1.totalGanho, 1e15) > 0
	if jogou then
		p.titulos.VeteranoDoMagnata = true
		local faiscas = math.min(5 + niveisEquip * 2 + itensGalpao * 3, 60)
		local nucleos = math.min(renasc * 2 + (if secretos > 0 then 1 else 0), 10)
		p.materiais.FragmentoDeFaisca = faiscas
		if nucleos > 0 then
			p.materiais.NucleoDeTempestade = nucleos
		end
	end
	if renasc >= 3 then
		p.titulos.LendaDoMagnata = true
	end
	return p
end

-- (perfil, situacao): "novo" | "ok" | "completado" | "migradoDoMagnata" | "migradoDoLegado" | "versaoFutura"
function Perfil.migrar(bruto: any, agora: number): (Perfil, string)
	if bruto == nil then
		return Perfil.novo(agora), "novo"
	end
	if Perfil.ehMagnataV1(bruto) and (type(bruto.versao) ~= "number" or bruto.versao < 2) then
		return Perfil.migrarV1paraV2(bruto, agora), "migradoDoMagnata"
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
	-- mistérios: subcampos novos também são completados (evolução do formato sem perder nada)
	if type(p.misterios) == "table" then
		for k, v in Perfil.misteriosNovo() do
			if p.misterios[k] == nil then
				p.misterios[k] = v
				completou = true
			end
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
	if type(p.materiais) ~= "table" or type(p.missoesProgresso) ~= "table" then
		return false, "estrutura"
	end
	local tipos = 0
	for id, q in p.materiais do
		tipos += 1
		if type(id) ~= "string" or type(q) ~= "number" or q < 0 or q ~= math.floor(q) or q > Perfil.LIMITES.pilha then
			return false, "material"
		end
	end
	if tipos > Perfil.LIMITES.tiposDeMaterial then
		return false, "limiteMateriais"
	end
	local a = 0
	for guid, art in p.artefatos do
		a += 1
		if type(guid) ~= "string" or type(art) ~= "table" or type(art.id) ~= "string" or type(art.estagio) ~= "number" then
			return false, "artefato"
		end
	end
	if a > Perfil.LIMITES.artefatos then
		return false, "limiteArtefatos"
	end
	if p.artefatoEquipado ~= nil and p.artefatos[p.artefatoEquipado] == nil then
		return false, "artefatoEquipado"
	end
	if type(p.restauracoesProgresso) ~= "table" then
		return false, "estrutura"
	end
	for id, r in p.restauracoesProgresso do
		if type(id) ~= "string" or type(r) ~= "table" or type(r.etapa) ~= "number" or r.etapa < 0 or type(r.entregue) ~= "table" then
			return false, "restauracao"
		end
	end
	if type(p.equipamentos) ~= "table" or type(p.equipado) ~= "table" then
		return false, "estrutura"
	end
	for _, item in p.equipamentos do
		local m = item.melhoria
		if m ~= nil and (type(m) ~= "number" or m < 0 or m > 10 or m ~= math.floor(m)) then
			return false, "melhoria"
		end
	end
	local usados: { [string]: boolean } = {}
	for encaixe, guid in p.equipado do
		if type(encaixe) ~= "string" or type(guid) ~= "string" or p.equipamentos[guid] == nil or usados[guid] then
			return false, "equipado" -- item inexistente ou o mesmo item em dois encaixes
		end
		usados[guid] = true
	end
	local b = p.base
	if type(b) ~= "table" or type(b.espacos) ~= "table" or type(b.trofeus) ~= "table" or type(b.jardimColhidoEm) ~= "number" then
		return false, "base"
	end
	for id, n in b.espacos do
		if type(id) ~= "string" or type(n) ~= "number" or n < 1 or n > 10 or n ~= math.floor(n) then
			return false, "base"
		end
	end
	if type(p.reliquiaRecargaAte) ~= "number" or p.reliquiaRecargaAte ~= p.reliquiaRecargaAte then
		return false, "reliquia"
	end
	local m = p.misterios
	if type(m) ~= "table" or type(m.versao) ~= "number" or m.versao > Perfil.MISTERIOS_VERSAO then
		return false, "misterios"
	end
	for _, campo in { "investigacoes", "enigmas", "recompensas", "registros", "conhecimentos", "receitas", "portais", "fabricados", "evolucoes", "marcas" } do
		if type(m[campo]) ~= "table" then
			return false, "misterios"
		end
	end
	for id, inv in m.investigacoes do
		if type(id) ~= "string" or type(inv) ~= "table" or not Perfil.ESTADOS_INVESTIGACAO[inv.estado] or type(inv.capitulo) ~= "number"
			or type(inv.pistas) ~= "table" or type(inv.objetivos) ~= "table" or type(inv.capitulosConcluidos) ~= "table" then
			return false, "investigacao"
		end
	end
	for id, estado in m.portais do
		if type(id) ~= "string" or (estado ~= "descoberto") then
			return false, "portal"
		end
	end
	for id, n in m.fabricados do
		if type(id) ~= "string" or type(n) ~= "number" or n < 0 or n ~= math.floor(n) then
			return false, "fabricados"
		end
	end
	if p.companhia ~= nil and (type(p.companhia) ~= "string" or #p.companhia > 64) then
		return false, "companhia"
	end
	if type(p.nivel) ~= "number" or p.nivel < 1 or p.nivel > Perfil.LIMITES.nivelMax or type(p.xp) ~= "number" or p.xp < 0 then
		return false, "nivel"
	end
	return true, nil
end

return Perfil
