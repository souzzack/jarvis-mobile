--!strict
-- NÃO EXECUTADO. ATLAS DOS ARQUIVISTAS (diário, seção 5) — monta a VISÃO do diário. LÓGICA PURA.
-- Recebe o progresso do jogador e as configs do servidor e devolve SÓ o que ele descobriu:
--  * investigação não descoberta: não aparece (nem como "???");
--  * pistas: só as encontradas, com o texto já preenchido pelo servidor (textoDaPista);
--  * objetivos: só os visíveis; capítulos futuros: só "ainda não disponível", sem nome nem conteúdo;
--  * registros, conhecimentos e receitas: só os desbloqueados.
-- Nada de solução, ordem ou id interno de enigma vai para o cliente.

-- (sem require: o módulo Investigacao é passado por quem chama, para rodar igual no Studio e no Lune)

local D = {}

-- prog = perfil.misterios; cfgs = { investigacoes, registros, conhecimentos, receitas, portais };
-- textoDaPista(invId, pistaId, pistaCfg) → texto final (com a ordem do jogador já preenchida)
-- Investigacao = o módulo MysterySystems/Investigacao
function D.montar(prog: any, cfgs: any, textoDaPista: (string, string, any) -> string, Investigacao: any): any
	local invs = {}
	for invId, cfg in cfgs.investigacoes do
		local p = prog.investigacoes[invId]
		if p and p.estado ~= "Undiscovered" then
			local cap = cfg.capitulos[p.capitulo]
			local pistas = {}
			for nCap, c in cfg.capitulos do
				for pistaId, pc in c.pistas or {} do
					if p.pistas[pistaId] then
						-- em ordem de capítulo e depois de pista; o texto vem preenchido pelo servidor
						table.insert(pistas, { nome = pc.nome, texto = textoDaPista(invId, pistaId, pc), ordem = nCap * 100 + (pc.ordem or 0), capitulo = nCap })
					end
				end
			end
			table.sort(pistas, function(a, b)
				return a.ordem < b.ordem
			end)
			local futuros = 0
			for _, c in cfg.capitulos do
				if not c.lancado then
					futuros += 1
				end
			end
			table.insert(invs, {
				chave = invId, -- id estável (não revela solução)
				nome = cfg.nome, descricao = cfg.descricao, estado = p.estado,
				capitulo = if cap then { n = p.capitulo, nome = if cap.lancado then cap.nome else nil, disponivel = cap.lancado == true } else nil,
				pistas = pistas,
				objetivos = Investigacao.objetivosVisiveis(p, cfg),
				capitulosConcluidos = (function()
					local n = 0
					for _ in p.capitulosConcluidos do
						n += 1
					end
					return n
				end)(),
				capitulosFuturos = futuros,
			})
		end
	end
	table.sort(invs, function(a, b)
		return a.nome < b.nome
	end)
	local function lista(conjunto: { [string]: boolean }, cfg: { [string]: any }, campos: { string }): { any }
		local l = {}
		for id in conjunto do
			local c = cfg[id]
			if c then
				local item = { id = id }
				for _, k in campos do
					item[k] = c[k]
				end
				table.insert(l, item)
			end
		end
		table.sort(l, function(a, b)
			return (a.titulo or a.nome or a.id) < (b.titulo or b.nome or b.id)
		end)
		return l
	end
	local portais = {}
	for id, estado in prog.portais do
		local c = cfgs.portais[id]
		if c then
			table.insert(portais, { id = id, nome = c.nome, estado = estado })
		end
	end
	return {
		investigacoes = invs,
		registros = lista(prog.registros, cfgs.registros, { "titulo", "texto", "categoria" }),
		conhecimentos = lista(prog.conhecimentos, cfgs.conhecimentos, { "nome", "texto" }),
		receitas = lista(prog.receitas, cfgs.receitas, { "nome", "materiais", "estacao", "estacaoNivel" }),
		portais = portais,
	}
end

return D
