-- NÃO EXECUTADO. Mistérios: pesquisa/fabricação secreta, passagens secretas, artefatos ???, capacidades
-- investigativas e o campo 'misterios' do perfil.

return function(T, M)
	local P = M.Pesquisa
	local PS = M.PortalSecreto
	local S = M.Secrets

	T.caso("receita secreta: sem receita não fabrica, mesmo com tudo", function()
		local r = S.receitas.TintaDoArquivista
		local cheio = function(_id)
			return 99
		end
		local ok, f = P.podeFabricar(r, { conhecida = false, estacoes = { Bancada = 3 }, contar = cheio, nivelJogador = 60 })
		T.falso(ok)
		T.igual(f[1].tipo, "receita")
		T.verdade(P.podeFabricar(r, { conhecida = true, estacoes = { Bancada = 1 }, contar = cheio, nivelJogador = 1 }))
		local ok2, f2 = P.podeFabricar(r, { conhecida = true, estacoes = {}, contar = function()
			return 0
		end })
		T.falso(ok2)
		T.verdade(#f2 >= 2, "falta estação e materiais")
	end)

	T.caso("pesquisa: etapa atual avança com o progresso", function()
		local cfg = S.pesquisas.PesquisaTinta
		T.igual(P.etapaAtual(cfg, {}), 1)
		local prog = { pistas = { InscricaoDoObservatorio = true }, capitulos = { ["OSegredoDoPrimeiroArquivista#1"] = true }, enigmas = { OSinal = true }, receitas = { TintaDoArquivista = true }, materiais = { FolhaDeRegistro = 1, CascaAntiga = 2 }, fabricados = {} }
		T.igual(P.etapaAtual(cfg, prog), 6, "falta fabricar")
		prog.fabricados.TintaDoArquivista = 1
		T.igual(P.etapaAtual(cfg, prog), 7, "a etapa 7 (novas formas) é futura")
		T.igual(#cfg.etapas, 7, "as 7 etapas do complemento")
	end)

	T.caso("passagem secreta: oculto → selado → aberto; sem place, nunca viaja", function()
		T.igual(PS.estado(false, true), "oculto")
		T.igual(PS.estado(true, false), "selado")
		T.igual(PS.estado(true, true), "aberto")
		local portal = M.HiddenDimensions.portais.PortaDaBiblioteca
		local dest = M.HiddenDimensions.dimensoes.BibliotecaDoVazio
		T.igual(select(2, PS.podeAtravessar("aberto", dest, 1, portal)), "emConstrucao")
		local comPlace = { placeId = 123 }
		T.verdade(PS.podeAtravessar("aberto", comPlace, 2, portal))
		T.igual(select(2, PS.podeAtravessar("aberto", comPlace, 9, portal)), "grupoGrande")
		T.igual(select(2, PS.podeAtravessar("selado", comPlace, 1, portal)), "portalSelado")
	end)

	T.caso("as 4 dimensões ocultas são só conceito (placeId 0); a Biblioteca é a primeira", function()
		local n = 0
		for _, d in M.HiddenDimensions.dimensoes do
			n += 1
			T.igual(d.placeId, 0, d.id)
		end
		T.igual(n, 4)
		T.igual(M.HiddenDimensions.dimensoes.BibliotecaDoVazio.ordemDeConstrucao, 1)
	end)

	T.caso("artefatos ???: arquitetura metamórfica, raridade Oculta, sem trocar os anteriores", function()
		local anteriores = { EspadaDoHorizonte = true, EscudoDoFirmamento = true, CajadoDosVentosAntigos = true, ArcoDasAsasPerdidas = true }
		local n = 0
		for id, a in M.SecretArtifacts do
			n += 1
			local art = a.artefato
			T.falso(anteriores[art.id], "não substitui " .. art.id)
			T.igual(art.raridade, "Oculta")
			T.verdade(art.formas[art.formaInicial] ~= nil, id .. ": forma inicial existe")
			local temLoc = false
			for _, f in art.formas do
				T.verdade(f.tipo == "Combate" or f.tipo == "Locomocao", id)
				if f.tipo == "Locomocao" then
					temLoc = true
					T.igual(f.perfil, a.perfil.id, id .. ": perfil da forma de locomoção definido")
				end
			end
			T.verdade(temLoc)
			T.igual(#a.pesquisa, 7, id .. ": 7 etapas de pesquisa")
			T.verdade(type(a.mecanicaExclusiva) == "string", id)
			-- teto de locomoção: nenhum passa do Arco das Asas Perdidas (o mais rápido) em velocidade máxima
			T.verdade(a.perfil.velMax <= 46, id .. ": velMax dentro do orçamento")
		end
		T.igual(n, 3)
		T.igual(M.Raridades.porId.Oculta.ordem, 8, "??? continua acima do Arcano")
	end)

	T.caso("capacidades investigativas: sempre mais de uma fonte (nenhuma espécie obrigatória)", function()
		for id, c in S.capacidades do
			local fontes = 0
			for _, lista in c.fontes do
				fontes += #lista
			end
			T.verdade(fontes >= 2, id)
			local tipos = 0
			for _ in c.fontes do
				tipos += 1
			end
			T.verdade(tipos >= 2, id .. ": fontes de tipos diferentes (criatura + livro/equipamento)")
		end
		-- a pista do protótipo que pede capacidade tem alternativa por livro
		local pc = M.InvestigationChapters.OSegredoDoPrimeiroArquivista.capitulos[1].pistas.SimboloOculto
		T.verdade(#S.capacidades[pc.capacidade].fontes.livros >= 1)
	end)

	T.caso("recompensas e marcas apontam para coisas que existem", function()
		for id, r in S.recompensas do
			for mat in r.materiais or {} do
				T.verdade(M.Materiais.porId[mat] ~= nil, id .. ": " .. mat)
			end
			for _, reg in r.registros or {} do
				T.verdade(S.registros[reg] ~= nil, reg)
			end
			for _, rc in r.receitas or {} do
				T.verdade(S.receitas[rc] ~= nil, rc)
			end
		end
		local inv = M.InvestigationChapters.OSegredoDoPrimeiroArquivista
		local function pistaExiste(id)
			for _, cap in inv.capitulos do
				if cap.pistas[id] then
					return true
				end
			end
			return false
		end
		for id, m in S.marcas do
			if m.tipo == "enigma" then
				T.verdade(table.find(M.Puzzles[m.puzzle].elementos, m.elemento) ~= nil, id)
			elseif m.tipo == "pista" then
				for _, pid in m.pistas or { m.pista } do
					T.verdade(pistaExiste(pid), id .. " → " .. pid)
				end
			end
		end
		-- todo enigma de objetivo de capítulo tem marcas para TODOS os seus elementos
		for _, cap in inv.capitulos do
			for _, o in cap.objetivos do
				if o.puzzle then
					for _, el in M.Puzzles[o.puzzle].elementos do
						local tem = false
						for _, m in S.marcas do
							if m.puzzle == o.puzzle and m.elemento == el then
								tem = true
							end
						end
						T.verdade(tem, o.puzzle .. ": marca de " .. el)
					end
				end
			end
		end
	end)

	T.caso("perfil: campo misterios novo, validado e completado em perfis antigos", function()
		local Perfil = M.Perfil
		local p = Perfil.novo(0)
		T.verdade(Perfil.validar(p))
		p.misterios.investigacoes.X = { estado = "Hackeado", capitulo = 1, pistas = {}, objetivos = {}, capitulosConcluidos = {} }
		T.igual(select(2, Perfil.validar(p)), "investigacao")
		local q = Perfil.novo(0)
		q.misterios.portais.Y = "aberto"
		T.igual(select(2, Perfil.validar(q)), "portal", "só 'descoberto' fica salvo; aberto é calculado")
		local antigo = Perfil.novo(0)
		antigo.misterios = nil
		local migrado = Perfil.migrar(antigo, 0)
		T.verdade(type(migrado.misterios) == "table" and type(migrado.misterios.recompensas) == "table")
		local parcial = Perfil.novo(0)
		parcial.misterios.evolucoes = nil
		local m2, sit = Perfil.migrar(parcial, 0)
		T.verdade(type(m2.misterios.evolucoes) == "table")
		T.igual(sit, "completado")
	end)
end
