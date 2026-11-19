--!strict
-- NÃO EXECUTADO. Equipamentos (armaduras e acessórios) — LÓGICA PURA.
-- Encaixes (GDD 7.4): Cabeca, Corpo, Pernas, Acessorio1, Acessorio2. (Arma = artefato equipado; Relíquia: futuro.)
-- Atributos efetivos = base do item × multiplicador da raridade (orçamento de poder, Config/Raridades).
-- Tetos globais impedem que uma combinação quebre o jogo.

export type Totais = { defesa: number, vidaBonus: number, janelaAparar: number, energiaVoo: number }

local Eq = {}

Eq.ENCAIXES = { "Cabeca", "Corpo", "Pernas", "Acessorio1", "Acessorio2" }
-- tipo do item → encaixes aceitos
Eq.ACEITA = {
	Cabeca = { Cabeca = true },
	Corpo = { Corpo = true },
	Pernas = { Pernas = true },
	Acessorio = { Acessorio1 = true, Acessorio2 = true },
}
Eq.TETOS = { defesa = 120, vidaBonus = 200, janelaAparar = 0.08, energiaVoo = 40 }

function Eq.podeEquipar(cfgItem: any, encaixe: string): (boolean, string)
	if not table.find(Eq.ENCAIXES, encaixe) then
		return false, "encaixeInvalido"
	end
	local aceitos = Eq.ACEITA[cfgItem.tipo]
	if not aceitos or not aceitos[encaixe] then
		return false, "encaixeErrado"
	end
	return true, "ok"
end

-- o mesmo item (GUID) não pode estar em dois encaixes; devolve o encaixe onde ele já está
function Eq.ondeEsta(equipado: { [string]: string }, guid: string): string?
	for encaixe, g in equipado do
		if g == guid then
			return encaixe
		end
	end
	return nil
end

-- soma os atributos dos itens equipados. itens: guid → { id }; catalogo: id → cfg; raridades: id → { multiplicador }
function Eq.totais(equipado: { [string]: string }, itens: { [string]: any }, catalogo: { [string]: any }, raridades: { [string]: any }): Totais
	local t: Totais = { defesa = 0, vidaBonus = 0, janelaAparar = 0, energiaVoo = 0 }
	for _, guid in equipado do
		local item = itens[guid]
		local cfg = item and catalogo[item.id]
		if cfg then
			local m = (raridades[cfg.raridade] and raridades[cfg.raridade].multiplicador) or 1
			local a = cfg.atributos
			t.defesa += (a.defesa or 0) * m
			t.vidaBonus += (a.vidaBonus or 0) * m
			t.energiaVoo += (a.energiaVoo or 0) * m
			t.janelaAparar += (a.janelaAparar or 0) -- tempo não escala com raridade (sentir o aparo igual)
		end
	end
	for campo, teto in Eq.TETOS do
		local v = (t :: any)[campo]
		;(t :: any)[campo] = math.min(teto, campo == "janelaAparar" and v or math.floor(v + 0.5))
	end
	return t
end

return Eq
