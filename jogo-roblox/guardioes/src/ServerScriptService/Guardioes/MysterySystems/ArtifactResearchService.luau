--!strict
-- NÃO EXECUTADO NO STUDIO. ArtifactResearchService: pesquisa e fabricação SECRETA (seção 11).
--  * Liga descobertas → receitas → materiais → estação → equipamento. As receitas ??? NÃO estão em
--    Config/Receitas (pública); ficam no servidor e só aparecem no diário de quem as desbloqueou.
--  * FABRICAR exige: receita em perfil.misterios.receitas, estação perto (CraftingSystem.estacoesPerto), nível
--    e materiais. Consumo + resultado + contador "fabricado" na MESMA transação (InventorySystem): sem
--    duplicar, sem pagar sem receber.
--  * Pesquisas (7 etapas) mostram no diário só a etapa atual e as já cumpridas.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local G = ReplicatedStorage:WaitForChild("Guardioes")
local Pesquisa = require(G.MysterySystems.Pesquisa)

local S = {}
local deps: any = nil

function S.iniciar(d: any)
	deps = d
end

local function progressoPesquisa(p: Player, perfil: any): any
	local caps = {}
	for invId, prog in perfil.misterios.investigacoes do
		for n in prog.capitulosConcluidos do
			caps[invId .. "#" .. n] = true
		end
	end
	local pistas = {}
	for _, prog in perfil.misterios.investigacoes do
		for id in prog.pistas do
			pistas[id] = true
		end
	end
	local materiais = setmetatable({}, {
		__index = function(_, id)
			return deps.inventario.contar(p, id)
		end,
	})
	return {
		pistas = pistas, capitulos = caps, enigmas = perfil.misterios.enigmas, receitas = perfil.misterios.receitas,
		fabricados = perfil.misterios.fabricados, materiais = materiais, evolucoes = perfil.misterios.evolucoes,
	}
end

-- (ok, motivo, faltando?)
function S.fabricar(p: Player, receitaId: string): (boolean, string, { any }?)
	local r = deps.registro.receitas[receitaId]
	local perfil = deps.playerData.obter(p)
	if not r or not perfil then
		return false, "receitaDesconhecida", nil
	end
	local pode, faltando = Pesquisa.podeFabricar(r, {
		conhecida = perfil.misterios.receitas[receitaId] == true,
		estacoes = deps.fabricacao.estacoesPerto(p),
		nivelJogador = deps.progressao.nivel(p),
		contar = function(id: string): number
			return deps.inventario.contar(p, id)
		end,
	})
	if not pode then
		return false, if faltando[1] and faltando[1].tipo == "receita" then "receitaDesconhecida" else "faltaRequisito", faltando
	end
	local t: any = {
		consumir = r.materiais,
		alterarPerfil = function(pf)
			if not pf.misterios.receitas[receitaId] then
				return false
			end
			pf.misterios.fabricados[receitaId] = (pf.misterios.fabricados[receitaId] or 0) + 1
			return true
		end,
	}
	if r.resultado.tipo == "material" then
		t.darMateriais = { [r.resultado.id] = r.resultado.qtd }
	elseif r.resultado.tipo == "equipamento" then
		t.darEquipamento = r.resultado.id
	elseif r.resultado.tipo == "artefato" then
		t.darArtefato = { id = r.resultado.id, estagio = r.resultado.estagio or 1 }
	end
	local ok, falt = deps.inventario.transacao(p, t)
	if not ok then
		return false, (falt and falt[1] and falt[1].id) or "gravacao", falt
	end
	return true, "ok", nil
end

-- pesquisas para o diário: só as que já começaram (etapa 1 cumprida); etapas futuras sem nome
function S.paraDiario(p: Player, perfil: any): { any }
	local prog = progressoPesquisa(p, perfil)
	local l = {}
	for _, cfg in deps.registro.pesquisas do
		local atual = Pesquisa.etapaAtual(cfg, prog)
		if atual > 1 then
			local etapas = {}
			for i, e in cfg.etapas do
				table.insert(etapas, { nome = if i <= atual then e.nome else "???", feita = i < atual })
			end
			-- artefato ???: o nome só aparece quando a etapa que o revela (a receita) é alcançada
			local nome = cfg.nome
			if cfg.nomeOculto and atual <= (cfg.revelaNomeNaEtapa or 1) then
				nome = cfg.nomeOculto
			end
			table.insert(l, { nome = nome, etapa = atual, total = #cfg.etapas, etapas = etapas })
		end
	end
	return l
end

return S
