--!strict
-- NÃO EXECUTADO NO STUDIO. SecretRewardService: o ÚNICO caminho para pagar recompensas de mistério.
-- Usa a transação atômica do InventorySystem (o "serviço central de recompensas" do projeto): materiais,
-- marca "recompensa paga", registros, conhecimentos e receitas entram NA MESMA gravação. Se a recompensa já foi
-- paga (perfil.misterios.recompensas[id]), nada acontece — nem com dois pedidos ao mesmo tempo.

local S = {}

local deps: any = nil

function S.iniciar(d: any)
	deps = d
end

-- (pago agora?, motivo)
function S.conceder(p: Player, recompensaId: string): (boolean, string)
	local cfg = deps.registro.recompensas[recompensaId]
	if not cfg then
		return false, "recompensaInexistente"
	end
	local ok, faltando = deps.inventario.transacao(p, {
		darMateriais = cfg.materiais,
		alterarPerfil = function(pf)
			local m = pf.misterios
			if m.recompensas[recompensaId] then
				return false -- já paga: desiste da gravação inteira (materiais incluídos)
			end
			m.recompensas[recompensaId] = true
			for _, id in cfg.registros or {} do
				m.registros[id] = true
			end
			for _, id in cfg.conhecimentos or {} do
				m.conhecimentos[id] = true
			end
			for _, id in cfg.receitas or {} do
				m.receitas[id] = true
			end
			return true
		end,
	})
	if not ok then
		local f = faltando and faltando[1]
		return false, if f then f.id else "gravacao"
	end
	if cfg.xp then
		deps.progressao.ganharXp(p, cfg.xp, "misterio:" .. recompensaId) -- depois da gravação; XP não duplica item
	end
	return true, "ok"
end

function S.paga(perfil: any, recompensaId: string): boolean
	return perfil.misterios.recompensas[recompensaId] == true
end

return S
