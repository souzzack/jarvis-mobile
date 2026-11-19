--!strict
-- NÃO EXECUTADO NO STUDIO. SecretDiscoverySystem: a cadeia ??? do Ato 1 (ConfigSecreta/SegredosAto1).
-- Herda o modelo de segurança de luau-rascunho/DescobertasServico.lua:
--  * o cliente só PEDE (ProximityPrompt ou mensagem); o servidor confere tudo: lista permitida, distância,
--    posição medida pelo SERVIDOR (parado de verdade), sem duplicar, limite de pedidos;
--  * nada é vendido; nada depende de sorte; a solução varia por jogador (semente + sal secreto);
--  * o cliente só recebe nomes e textos do que o jogador JÁ descobriu (o resto chega como "???").
-- Também registra marcos do Axolote que nenhum sistema registrava (AxoPrimeiraConstelacao, AxoSeteEstrelas e o
-- desafio AxoNoiteDeTormenta), o que fecha o ciclo da Contemplação (ver doc 22).
-- Lugares: Parts com o atributo "GuardioesSegredo" (Telescopio, Lente1..3, Santuario, Pilar1..6, Altar) na
-- pasta GuardioesSegredos. Perto da arena, marcadores de TESTE (os mapas reais não são tocados).

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local G = ReplicatedStorage:WaitForChild("Guardioes")
local Descoberta = require(G.Segredos.Descoberta)
local Materiais = require(G.Config.Materiais)
local LimiteDeTaxa = require(G.Util.LimiteDeTaxa)
local Remotos = require(G.Rede.Remotos)
local ConfigServidor = require(script.Parent.Parent.ConfigServidor)
local S = require(script.Parent.Parent.ConfigSecreta.SegredosAto1)
local Arco = require(script.Parent.Parent.ConfigSecreta.ArcoDasAsasPerdidas)

local SG = Remotos.Segredo
local ES = Remotos.EventoSegredo
local TESTE = ConfigServidor.concessoesDeTeste

local SecretDiscoverySystem = { Nome = "SecretDiscoverySystem" }

local evento: RemoteEvent
local ctxSistemas: any = nil
local playerData: any
local inventario: any
local companheiros: any
local restauracao: any
local dimensoes: any
local equipamento: any
local pasta: Folder
local baldes: { [Player]: LimiteDeTaxa.Balde } = {}
local seqLentes: { [Player]: Descoberta.Sequencia } = {}
local seqPilares: { [Player]: Descoberta.Sequencia } = {}
local contemplando: { [Player]: { desde: number, pos: Vector3, centro: Vector3 } } = {}
local ESTAGIOS = { Filhote = 1, Juvenil = 2, Adulto = 3 }
local etapaPorId: { [string]: any } = {}
for _, e in S.etapas do
	etapaPorId[e.id] = e
end

local function semente(p: Player, id: string): number
	return Descoberta.semente(p.UserId, S.sal .. id)
end

local function aviso(p: Player, texto: string)
	evento:FireClient(p, ES.AVISO, texto)
end

local function feito(perfil: any, id: string): boolean
	local e = etapaPorId[id]
	return perfil ~= nil and e ~= nil and perfil[e.conjunto][id] == true
end

local function chove(): boolean
	return TESTE.ativa and TESTE.ignorarChuva == true or Workspace:GetAttribute("GuardioesChuva") == true
end

-- ------------------------------------------------------------------ diário (só o que já foi descoberto)
local function enviarDiario(p: Player)
	local perfil = playerData.obter(p)
	if not perfil then
		return
	end
	local lib: { [string]: boolean } = {}
	for _, e in S.etapas do
		if e.dimensao then
			lib[e.dimensao] = dimensoes.liberada(p, e.dimensao)
		end
	end
	local sit = Descoberta.situacao(S.etapas, { segredos = perfil.segredos, enigmas = perfil.enigmas }, lib)
	local lista = {}
	for i, s in sit do
		local e = S.etapas[i]
		if s.feita then
			table.insert(lista, { nome = e.nome, texto = e.texto, feita = true })
		elseif s.bloqueadaPorDimensao then
			table.insert(lista, { nome = "???", texto = e.dica, feita = false, outroMundo = true })
		elseif s.disponivel then
			table.insert(lista, { nome = "???", texto = e.dica, feita = false })
		else
			table.insert(lista, { nome = "???", texto = nil, feita = false })
		end
	end
	local artefato = nil
	if feito(perfil, "ArtefatoDesconhecido1") then
		artefato = Descoberta.revelar(S.artefatoDesconhecido, Descoberta.fracaoFeita(sit))
	end
	local margens = {}
	for _, id in S.livrosComMargem do
		if perfil.livrosLidos[id] then
			table.insert(margens, { livro = id, examinada = perfil.enigmas["Margem_" .. id] == true, texto = if perfil.enigmas["Margem_" .. id] then S.margens[id] else nil })
		end
	end
	evento:FireClient(p, ES.DIARIO, lista, artefato, margens)
end

-- grava um passo da cadeia (uma vez só) e avisa
local function concluir(p: Player, id: string, extra: ((any) -> ())?): boolean
	local e = etapaPorId[id]
	local novo = false
	local ok = playerData.atualizar(p, function(pf)
		if pf[e.conjunto][id] then
			return false
		end
		pf[e.conjunto][id] = true
		if extra then
			extra(pf)
		end
		novo = true
		return true
	end)
	if ok and novo then
		evento:FireClient(p, ES.DESCOBERTA, e.nome, e.texto)
		enviarDiario(p)
	end
	return ok and novo
end

-- ------------------------------------------------------------------ cada lugar
local function nomeDaEstrela(i: number): string
	return S.estrelas[i].mundo
end

local function ordemDasLentes(p: Player): { number }
	local perm = Descoberta.permutacao(semente(p, "LentesNaOrdem"), #S.lentes)
	local ordem = {}
	for k, idx in perm do
		ordem[k] = S.lentes[idx] -- índice da estrela
	end
	return ordem
end

local function inicioDosPilares(p: Player): number
	return (semente(p, "PilaresDasSeteEstrelas") % #S.estrelas) + 1
end

local function observatorioPronto(p: Player): boolean
	return restauracao.restaurada(p, "Observatorio") or (TESTE.ativa and table.find(TESTE.progressoLivros.restauracoes, "Observatorio") ~= nil)
end

local function telescopio(p: Player)
	if not observatorioPronto(p) then
		aviso(p, "O telescópio está coberto de poeira e engrenagens soltas.")
		return
	end
	local o = ordemDasLentes(p)
	aviso(p, string.format(S.anotacao, nomeDaEstrela(o[1]), nomeDaEstrela(o[2]), nomeDaEstrela(o[3])))
end

local function lente(p: Player, n: number)
	local perfil = playerData.obter(p)
	if not perfil or feito(perfil, "LentesNaOrdem") then
		return
	end
	if not observatorioPronto(p) then
		aviso(p, "A lente está emperrada.")
		return
	end
	local seq = seqLentes[p]
	if not seq then
		seq = Descoberta.sequencia(ordemDasLentes(p))
		seqLentes[p] = seq
	end
	local r = Descoberta.ativar(seq, S.lentes[n])
	if r == "errado" then
		aviso(p, "A luz se espalha pelo vidro e some. As lentes voltam ao lugar.")
	elseif r == "certo" then
		aviso(p, "A lente gira e trava com um clique.")
	elseif r == "completo" then
		seqLentes[p] = nil
		concluir(p, "LentesNaOrdem")
	end
end

local function pilar(p: Player, n: number)
	local perfil = playerData.obter(p)
	if not perfil or feito(perfil, "PilaresDasSeteEstrelas") then
		return
	end
	if not feito(perfil, "SeteEstrelasSobChuva") then
		aviso(p, "O pilar está frio. Nada acontece.")
		return
	end
	local seq = seqPilares[p]
	if not seq then
		seq = Descoberta.sequencia(Descoberta.ordemCircular(inicioDosPilares(p), #S.estrelas))
		seqPilares[p] = seq
	end
	local r = Descoberta.ativar(seq, n)
	if r == "errado" then
		aviso(p, "Os pilares se apagam todos de uma vez.")
	elseif r == "certo" then
		aviso(p, "O pilar " .. S.estrelas[n].cor:lower() .. " acende.")
	elseif r == "completo" then
		seqPilares[p] = nil
		if concluir(p, "PilaresDasSeteEstrelas") then
			companheiros.registrarMarco(p, "AxoSeteEstrelas") -- só vale se o Axolote estiver ativo
		end
	end
end

local function contemplar(p: Player, parte: BasePart)
	local perfil = playerData.obter(p)
	local raiz = p.Character and p.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not perfil or not raiz then
		return
	end
	local c, esp = companheiros.ativa(p)
	local temAxolote = c ~= nil and esp ~= nil and c.especie == "AxoloteNebular" and (ESTAGIOS[c.estagio] or 0) >= ESTAGIOS[S.contemplacao.estagioMin]
	if not temAxolote and not (TESTE.ativa and TESTE.ignorarAxolote) then
		aviso(p, "O céu está bonito. Mas você sente que falta alguém para olhar com você.")
		return
	end
	contemplando[p] = { desde = os.clock(), pos = raiz.Position, centro = parte.Position }
	evento:FireClient(p, ES.CONTEMPLANDO, S.contemplacao.paradoSeg)
	aviso(p, "Fique parado e olhe para o céu…")
end

-- passo da contemplação (servidor mede a posição; o cliente não informa nada)
local function passoContemplacao()
	local agora = os.clock()
	for p, c in contemplando do
		local raiz = p.Character and p.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
		if not raiz or (raiz.Position - c.pos).Magnitude > S.contemplacao.tolerancia or (raiz.Position - c.centro).Magnitude > S.contemplacao.raio then
			contemplando[p] = nil
			evento:FireClient(p, ES.CONTEMPLANDO, 0)
			aviso(p, "A contemplação foi interrompida.")
		elseif agora - c.desde >= S.contemplacao.paradoSeg then
			contemplando[p] = nil
			evento:FireClient(p, ES.CONTEMPLANDO, 0)
			companheiros.registrarMarco(p, "AxoPrimeiraConstelacao")
			if chove() then
				local perfil = playerData.obter(p)
				local ja = feito(perfil, "SeteEstrelasSobChuva")
				if not ja then
					concluir(p, "SeteEstrelasSobChuva")
					companheiros.registrarDesafio(p, "AxoNoiteDeTormenta")
				end
				-- a constelação aparece sempre que se contempla sob chuva (é a dica dos pilares)
				local cores = {}
				for i, e in S.estrelas do
					cores[i] = e.hex
				end
				evento:FireClient(p, ES.CONSTELACAO, cores, inicioDosPilares(p))
				aviso(p, "Uma das seis estrelas brilha mais que as outras.")
			else
				aviso(p, "As estrelas piscam, tímidas. Talvez numa noite diferente…")
			end
		end
	end
end

local function altar(p: Player)
	local perfil = playerData.obter(p)
	if not perfil then
		return
	end
	if not feito(perfil, "PilaresDasSeteEstrelas") then
		aviso(p, "Um altar de pedra antiga. Seis pilares apagados o cercam.")
		return
	end
	if not feito(perfil, "ArtefatoDesconhecido1") then
		aviso(p, "A câmara sob o altar se abre.")
		if concluir(p, "ArtefatoDesconhecido1") then
			equipamento.darReliquia(p, "LascaDaSetimaEstrela") -- junto do artefato, uma lasca de luz
		end
		return
	end
	if feito(perfil, "ArcoForjado") then
		aviso(p, "O altar está em silêncio.")
		return
	end
	for _, r in etapaPorId.ArcoForjado.requer do
		if not feito(perfil, r) then
			aviso(p, "O artefato vibra, mas algo ainda falta.") -- não diz o quê (???)
			return
		end
	end
	-- ritual: materiais + o Arco na MESMA transação (nada consumido se falhar)
	local ok, faltando = inventario.transacao(p, {
		consumir = S.ritual.materiais,
		darArtefato = { id = Arco.artefato.id, estagio = 1 },
		alterarPerfil = function(pf)
			if pf.segredos.ArcoForjado then
				return false
			end
			pf.segredos.ArcoForjado = true
			return true
		end,
	})
	if not ok then
		local partes = {}
		for _, f in faltando do
			local m = Materiais.porId[f.id]
			table.insert(partes, string.format("%s %d/%d", if m then m.nome else f.id, f.tem, f.precisa))
		end
		aviso(p, "O ritual pede mais: " .. table.concat(partes, " · "))
		return
	end
	local e = etapaPorId.ArcoForjado
	evento:FireClient(p, ES.DESCOBERTA, e.nome, e.texto)
	enviarDiario(p)
end

-- ------------------------------------------------------------------ margens (pedido do diário)
local function examinarMargem(p: Player, livro: any)
	if typeof(livro) ~= "string" or not S.margens[livro] then
		return
	end
	local perfil = playerData.obter(p)
	if not perfil or not perfil.livrosLidos[livro] then
		return
	end
	local chave = "Margem_" .. livro
	local completou = false
	playerData.atualizar(p, function(pf)
		if pf.enigmas[chave] then
			return false
		end
		pf.enigmas[chave] = true
		local todas = true
		for _, id in S.livrosComMargem do
			if not pf.enigmas["Margem_" .. id] then
				todas = false
			end
		end
		completou = todas and not pf.segredos.MargensDosLivros
		return true
	end)
	aviso(p, S.margens[livro])
	if completou then
		concluir(p, "MargensDosLivros")
	else
		enviarDiario(p)
	end
end

-- ------------------------------------------------------------------ lugares e prompts
local function preparar(parte: BasePart)
	local id = parte:GetAttribute("GuardioesSegredo")
	if typeof(id) ~= "string" or parte:FindFirstChild("GuardioesSegredoPrompt") then
		return
	end
	local acao, fn: ((Player) -> ())? = "Examinar", nil
	if id == "Telescopio" then
		acao, fn = "Olhar", telescopio
	elseif id == "Santuario" then
		acao, fn = "Contemplar", function(p)
			contemplar(p, parte)
		end
	elseif id == "Altar" then
		fn = altar
	else
		local nLente = tonumber(string.match(id, "^Lente(%d)$"))
		local nPilar = tonumber(string.match(id, "^Pilar(%d)$"))
		if nLente and S.lentes[nLente] then
			acao, fn = "Girar", function(p)
				lente(p, nLente)
			end
		elseif nPilar and S.estrelas[nPilar] then
			acao, fn = "Tocar", function(p)
				pilar(p, nPilar)
			end
		end
	end
	if not fn then
		return
	end
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "GuardioesSegredoPrompt"
	prompt.ActionText = acao
	prompt.ObjectText = "" -- nenhum nome revela o segredo
	prompt.KeyboardKeyCode = Enum.KeyCode.B
	prompt.GamepadKeyCode = Enum.KeyCode.DPadUp
	prompt.HoldDuration = 0.3
	prompt.MaxActivationDistance = 9
	prompt.Parent = parte
	local acaoFn = fn :: (Player) -> ()
	prompt.Triggered:Connect(function(p: Player)
		local b = baldes[p]
		if not b then
			b = LimiteDeTaxa.novo(4, 1, os.clock())
			baldes[p] = b
		end
		if LimiteDeTaxa.consumir(b, os.clock()) then
			acaoFn(p)
		end
	end)
end

local function criarMarcadoresDeTeste()
	local m = ConfigServidor.marcadoresDeTeste
	if not (m and m.ativa and ConfigServidor.arenaDeTeste.ativa and m.segredos) then
		return
	end
	local centro = ConfigServidor.arenaDeTeste.centro
	local function marco(id: string, desloc: Vector3, cor: Color3, tamanho: Vector3)
		local part = Instance.new("Part")
		part.Name = "Segredo_" .. id
		part.Anchored = true
		part.Size = tamanho
		part.Color = cor
		part.Material = Enum.Material.Slate
		part.CFrame = CFrame.new(centro + desloc)
		part:SetAttribute("GuardioesSegredo", id)
		part.Parent = pasta
	end
	local sg = m.segredos
	marco("Telescopio", sg.telescopio, Color3.fromRGB(120, 110, 90), Vector3.new(2, 4, 2))
	for i, idx in S.lentes do
		marco("Lente" .. i, sg.lentes[i], Color3.fromHex(S.estrelas[idx].hex), Vector3.new(1.5, 1.5, 0.4))
	end
	marco("Santuario", sg.santuario, Color3.fromRGB(70, 90, 110), Vector3.new(8, 0.6, 8))
	for i, e in S.estrelas do
		local a = math.pi / 2 + (i - 1) * math.pi / 3 -- mesmo anel do símbolo
		marco("Pilar" .. i, sg.altar + Vector3.new(math.cos(a) * 10, 2, math.sin(a) * 10), Color3.fromHex(e.hex), Vector3.new(1.6, 5, 1.6))
	end
	marco("Altar", sg.altar, Color3.fromRGB(90, 84, 76), Vector3.new(4, 2, 4))
end

-- chuva: se nenhum sistema de clima cuidar do atributo, um ciclo simples (o visual da chuva é pendente)
local function cicloDeChuva()
	if Workspace:GetAttribute("GuardioesChuva") ~= nil then
		return -- outro sistema já cuida
	end
	task.spawn(function()
		while true do
			local t = os.time() % S.clima.cicloSeg
			Workspace:SetAttribute("GuardioesChuva", t < S.clima.chuvaSeg)
			task.wait(5)
		end
	end)
end

-- ------------------------------------------------------------------ ciclo de vida
function SecretDiscoverySystem.Init(ctx: any)
	ctxSistemas = ctx
	evento = Remotos.evento("Segredo")
end

function SecretDiscoverySystem.Start()
	playerData = ctxSistemas.obter("PlayerDataSystem")
	inventario = ctxSistemas.obter("InventorySystem")
	companheiros = ctxSistemas.obter("CompanionSystem")
	restauracao = ctxSistemas.obter("RestorationSystem")
	dimensoes = ctxSistemas.obter("DimensionSystem")
	equipamento = ctxSistemas.obter("EquipmentSystem")
	local magia = ctxSistemas.obter("MagicBookSystem")
	local existente = Workspace:FindFirstChild("GuardioesSegredos") :: Folder?
	if existente then
		pasta = existente
	else
		pasta = Instance.new("Folder")
		pasta.Name = "GuardioesSegredos"
		pasta.Parent = Workspace
	end
	criarMarcadoresDeTeste()
	for _, d in pasta:GetDescendants() do
		if d:IsA("BasePart") then
			preparar(d)
		end
	end
	pasta.DescendantAdded:Connect(function(d)
		if d:IsA("BasePart") then
			preparar(d)
		end
	end)
	cicloDeChuva()
	playerData.carregado.conectar(function(p: Player)
		enviarDiario(p)
	end)
	magia.lido.conectar(function(p: Player)
		enviarDiario(p) -- o Manuscrito revela a Parte 1; a margem do livro recém-lido fica disponível
	end)
	evento.OnServerEvent:Connect(function(p: Player, tipo: any, a: any)
		local b = baldes[p]
		if not b then
			b = LimiteDeTaxa.novo(4, 1, os.clock())
			baldes[p] = b
		end
		if not LimiteDeTaxa.consumir(b, os.clock()) then
			return
		end
		if tipo == SG.DIARIO then
			enviarDiario(p)
		elseif tipo == SG.EXAMINAR_MARGEM then
			examinarMargem(p, a)
		end
	end)
	task.spawn(function()
		while true do
			task.wait(0.5)
			local ok, erro = pcall(passoContemplacao)
			if not ok then
				warn("[Guardioes] segredo: " .. tostring(erro))
			end
		end
	end)
	Players.PlayerRemoving:Connect(function(p)
		baldes[p] = nil
		seqLentes[p] = nil
		seqPilares[p] = nil
		contemplando[p] = nil
	end)
end

return SecretDiscoverySystem
