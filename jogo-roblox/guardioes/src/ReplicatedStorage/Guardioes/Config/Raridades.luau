--!strict
-- NÃO EXECUTADO. Hierarquia oficial de raridades (GDD, seção 7). Só dados.
-- 'multiplicador' = orçamento de poder sobre o atributo base do nível do item (saltos decrescentes, anti-inflação).
-- 'oculta' = a interface não mostra nome/efeitos antes da descoberta (só a raridade ???).

export type Raridade = {
	id: string,
	ordem: number,
	nome: string,
	cor: string, -- hex; ??? usa padrão animado no cliente
	multiplicador: number,
	secundarios: number,
	tracos: { string },
	oculta: boolean,
}

local lista: { Raridade } = {
	{ id = "Comum", ordem = 1, nome = "Comum", cor = "#B9C6D8", multiplicador = 1.00, secundarios = 0, tracos = {}, oculta = false },
	{ id = "Incomum", ordem = 2, nome = "Incomum", cor = "#7EDC6A", multiplicador = 1.08, secundarios = 1, tracos = {}, oculta = false },
	{ id = "Raro", ordem = 3, nome = "Raro", cor = "#4EA8FF", multiplicador = 1.16, secundarios = 2, tracos = {}, oculta = false },
	{ id = "Epico", ordem = 4, nome = "Épico", cor = "#B86BFF", multiplicador = 1.25, secundarios = 2, tracos = { "traco" }, oculta = false },
	{ id = "Lendario", ordem = 5, nome = "Lendário", cor = "#FFCC33", multiplicador = 1.34, secundarios = 3, tracos = { "tracoLendario" }, oculta = false },
	{ id = "Druida", ordem = 6, nome = "Druida", cor = "#3FBF7F", multiplicador = 1.42, secundarios = 3, tracos = { "efeitoDruida" }, oculta = false },
	{ id = "Arcano", ordem = 7, nome = "Arcano", cor = "#6F7BFF", multiplicador = 1.50, secundarios = 3, tracos = { "poderDimensional" }, oculta = false },
	{ id = "Oculta", ordem = 8, nome = "???", cor = "#120E26", multiplicador = 1.56, secundarios = 3, tracos = { "mecanicaExclusiva" }, oculta = true },
}

local porId: { [string]: Raridade } = {}
for _, r in lista do
	porId[r.id] = r
end

local Raridades = {}
Raridades.lista = lista
Raridades.porId = porId

-- teto de uma melhoria +10: cobre METADE do salto até a raridade seguinte no mesmo nível de item (GDD 7.2).
-- (A regra antiga "seguinte × 0,96" deixava o teto do Arcano, 1,4976, abaixo do próprio Arcano, 1,50.)
-- A ??? não tem seguinte: o teto é o próprio multiplicador.
function Raridades.tetoMelhoria(id: string): number
	local r = porId[id]
	assert(r, "raridade desconhecida: " .. id)
	local seguinte = lista[r.ordem + 1]
	if not seguinte then
		return r.multiplicador
	end
	return r.multiplicador + (seguinte.multiplicador - r.multiplicador) * 0.5
end

return Raridades
