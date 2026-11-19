--!strict
-- NÃO EXECUTADO. Estado de forma de UM artefato metamórfico. LÓGICA PURA.
-- O artefato é sempre o MESMO item (mesmo GUID): trocar de forma só muda 'forma'. Nada é criado ou destruído,
-- então não há como duplicar item durante a transformação.
-- Durante a troca ('alvo' ~= nil) NENHUMA forma está ativa: sem dano de arma e sem perfil de voo.

export type Instancia = {
	guid: string,
	id: string,
	estagio: number,
	forma: string,
	alvo: string?, -- forma de destino enquanto transforma
	ate: number, -- fim da transformação
	recargaAte: number,
}
export type Evento = { tipo: string, forma: string }

local A = {}

function A.nova(guid: string, cfg: any, estagio: number?): Instancia
	return { guid = guid, id = cfg.id, estagio = estagio or 1, forma = cfg.formaInicial, alvo = nil, ate = -math.huge, recargaAte = -math.huge }
end

function A.formaLiberada(inst: Instancia, cfg: any, forma: string): (boolean, string)
	local f = cfg.formas[forma]
	if not f then
		return false, "formaInexistente"
	end
	if inst.estagio < f.estagioMin then
		return false, "bloqueada"
	end
	return true, "ok"
end

-- Pedido de troca. Não checa locomoção/energia: isso é do sistema, que conhece o personagem.
function A.transformar(inst: Instancia, cfg: any, forma: string, agora: number): (boolean, string)
	local ok, motivo = A.formaLiberada(inst, cfg, forma)
	if not ok then
		return false, motivo
	end
	if inst.alvo then
		return false, "transformando"
	end
	if inst.forma == forma then
		return false, "jaNaForma"
	end
	if agora < inst.recargaAte then
		return false, "recarga"
	end
	inst.alvo = forma
	inst.ate = agora + cfg.transformacao.duracao
	return true, "iniciado"
end

function A.atualizar(inst: Instancia, cfg: any, agora: number): Evento?
	if inst.alvo and agora >= inst.ate then
		inst.forma = inst.alvo :: string
		inst.alvo = nil
		inst.recargaAte = inst.ate + cfg.transformacao.recarga
		return { tipo = "Concluida", forma = inst.forma }
	end
	return nil
end

-- golpe forte ou atordoamento durante a troca: volta à forma anterior (que continua sendo 'forma') com meia recarga
function A.cancelar(inst: Instancia, cfg: any, agora: number): boolean
	if not inst.alvo then
		return false
	end
	inst.alvo = nil
	inst.recargaAte = agora + cfg.transformacao.recarga * 0.5
	return true
end

-- forma ativa (nil enquanto transforma)
function A.formaAtiva(inst: Instancia): string?
	if inst.alvo then
		return nil
	end
	return inst.forma
end

function A.tipoAtivo(inst: Instancia, cfg: any): string?
	local f = A.formaAtiva(inst)
	return if f then cfg.formas[f].tipo else nil
end

-- primeira forma de um tipo ("Combate", "Defesa", "Locomocao") — usada no retorno ao combate
function A.formaDoTipo(cfg: any, tipo: string): string?
	local melhor: string? = nil
	for nome, f in cfg.formas do
		if f.tipo == tipo and (melhor == nil or nome < melhor) then
			melhor = nome
		end
	end
	return melhor
end

return A
