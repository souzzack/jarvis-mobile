--!strict
-- NÃO EXECUTADO NO STUDIO. DiscoveryService: as MARCAS no mapa e as interações com elas.
--  * Marca = Part com o atributo "GuardioesMisterio" = id (Secrets.marcas) na pasta workspace.GuardioesMisterios.
--    Um ProximityPrompt por marca (tecla B), sem nome de objeto (nada revela o segredo).
--  * Toda interação: limite de pedidos + distância medida pelo SERVIDOR + regra da marca (pista, enigma,
--    portal). Pista com 'capacidade' só é registrada se o jogador tiver uma das fontes (criatura ativa perto com
--    a habilidade, livro lido ou equipamento) — sempre mais de uma fonte (nenhuma espécie é obrigatória).
--  * Criatura investigativa (seção 9): 1×/s, SÓ para jogadores a até 30 studs de uma marca com capacidade, a
--    criatura ativa com a habilidade e perto "reage" (evento para o cliente mostrar). Nada roda a cada frame.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local G = ReplicatedStorage:WaitForChild("Guardioes")
local LimiteDeTaxa = require(G.Util.LimiteDeTaxa)

local S = {}
local deps: any = nil
local pasta: Folder
local baldes: { [Player]: LimiteDeTaxa.Balde } = {}
local reagiu: { [Player]: { [string]: boolean } } = {} -- uma reação por marca por sessão

function S.iniciar(d: any)
	deps = d
end

local function raiz(p: Player): BasePart?
	local ch = p.Character
	return if ch then ch:FindFirstChild("HumanoidRootPart") :: BasePart? else nil
end

-- (tem, fonte). posicao: onde está a coisa investigada (a criatura precisa estar perto dela)
function S.temCapacidade(p: Player, capId: string, posicao: Vector3?): (boolean, string?)
	local cap = deps.registro.capacidades[capId]
	local perfil = deps.playerData.obter(p)
	if not cap or not perfil then
		return false, nil
	end
	local f = cap.fontes
	for _, h in f.companheiro or {} do
		if deps.companheiros.ativaTemHabilidade(p, h) then
			local _, _, r = deps.companheiros.ativa(p)
			if not posicao or (r and (r.Position - posicao).Magnitude <= cap.alcance) then
				return true, "companheiro"
			end
		end
	end
	for _, l in f.livros or {} do
		if perfil.livrosLidos[l] then
			return true, "livro"
		end
	end
	for _, guid in perfil.equipado do
		local it = perfil.equipamentos[guid]
		if it and table.find(f.equipamentos or {}, it.id) then
			return true, "equipamento"
		end
	end
	return false, nil
end

local function marcasNoMapa(): { [string]: BasePart }
	local l: { [string]: BasePart } = {}
	for _, d in pasta:GetDescendants() do
		local id = d:GetAttribute("GuardioesMisterio")
		if d:IsA("BasePart") and typeof(id) == "string" then
			l[id] = d
		end
	end
	return l
end

function S.parteDaMarca(id: string): BasePart?
	return marcasNoMapa()[id]
end

-- o jogador está perto de algum elemento deste enigma? (participação em cooperativos)
function S.pertoDoEnigma(p: Player, puzzleId: string): boolean
	local r = raiz(p)
	local cfg = deps.registro.puzzles[puzzleId]
	if not r or not cfg then
		return false
	end
	for id, parte in marcasNoMapa() do
		local m = deps.registro.marcas[id]
		if m and m.tipo == "enigma" and m.puzzle == puzzleId and ((r :: BasePart).Position - parte.Position).Magnitude <= (cfg.raio or 10) + 2 then
			return true
		end
	end
	return false
end

local function interagir(p: Player, marcaId: string, parte: BasePart)
	local b = baldes[p]
	if not b then
		b = LimiteDeTaxa.novo(4, 1.5, os.clock())
		baldes[p] = b
	end
	if not LimiteDeTaxa.consumir(b, os.clock()) then
		return
	end
	local m = deps.registro.marcas[marcaId]
	local r = raiz(p)
	if not m or not r then
		return
	end
	local raio = 12
	if m.tipo == "enigma" then
		raio = (deps.registro.puzzles[m.puzzle].raio or 10) + 2
	end
	if ((r :: BasePart).Position - parte.Position).Magnitude > raio then
		deps.aviso(p, "Chegue mais perto.")
		return
	end
	if m.tipo == "pista" then
		local inv = deps.registro.investigacao(m.investigacao)
		local pc
		for _, cap in inv.capitulos do
			if cap.pistas[m.pista] then
				pc = cap.pistas[m.pista]
			end
		end
		if pc.capacidade then
			local tem = S.temCapacidade(p, pc.capacidade, parte.Position)
			if not tem then
				deps.aviso(p, "Parece só uma parede. Talvez alguém (ou algo) perceba o que você não vê.")
				return
			end
		end
		local ok, motivo = deps.investigacoes.registrarPista(p, m.investigacao, m.pista)
		if ok then
			deps.descobriu(p, pc.nome)
		elseif motivo == "jaRegistrada" then
			deps.aviso(p, "Você já anotou isto no Atlas.")
		elseif motivo == "naoDescoberta" or motivo == "dependencia" then
			deps.aviso(p, "Há algo aqui, mas você ainda não sabe o que procurar.")
		elseif motivo == "pistaDeOutroCapitulo" or motivo == "capituloIndisponivel" then
			deps.aviso(p, "Ainda não é hora de entender isto.")
		end
	elseif m.tipo == "enigma" then
		local ctx = { capacidades = {}, dentro = true }
		local pz = deps.registro.puzzles[m.puzzle]
		if pz.capacidade then
			ctx.capacidades[pz.capacidade] = S.temCapacidade(p, pz.capacidade, parte.Position)
		end
		local resultado, motivo = deps.puzzles.agir(p, m.puzzle, m.elemento, ctx)
		deps.enigma(p, marcaId, resultado, motivo)
	elseif m.tipo == "portal" then
		deps.portais.examinar(p, m.portal)
	end
end

local function preparar(parte: BasePart)
	local id = parte:GetAttribute("GuardioesMisterio")
	if typeof(id) ~= "string" or not deps.registro.marcas[id] or parte:FindFirstChild("GuardioesMisterioPrompt") then
		return
	end
	local pr = Instance.new("ProximityPrompt")
	pr.Name = "GuardioesMisterioPrompt"
	pr.ActionText = deps.registro.marcas[id].acao or "Examinar"
	pr.ObjectText = ""
	pr.KeyboardKeyCode = Enum.KeyCode.B
	pr.GamepadKeyCode = Enum.KeyCode.DPadUp
	pr.HoldDuration = 0.3
	pr.MaxActivationDistance = 9
	pr.Parent = parte
	pr.Triggered:Connect(function(p: Player)
		interagir(p, id, parte)
	end)
end

-- sala de TESTE abstrata (seção 7: nada de mapa novo; só marcadores neutros perto da arena)
local function salaDeTeste(cfgTeste: any, centro: Vector3)
	local function bloco(id: string, desloc: Vector3, tamanho: Vector3, cor: string)
		local part = Instance.new("Part")
		part.Name = "Misterio_" .. id
		part.Anchored = true
		part.Size = tamanho
		part.Color = Color3.fromHex(cor)
		part.Material = Enum.Material.SmoothPlastic
		part.CFrame = CFrame.new(centro + cfgTeste.origem + desloc)
		part:SetAttribute("GuardioesMisterio", id)
		part.Parent = pasta
	end
	bloco("MarcaInscricao", Vector3.new(0, 2, 0), Vector3.new(4, 4, 0.6), "#8C8577")
	bloco("MarcaSimbolo", Vector3.new(8, 2, 0), Vector3.new(4, 4, 0.6), "#6E6A63")
	bloco("MarcaDiario", Vector3.new(-8, 1, 0), Vector3.new(2, 2, 2), "#6B4F2E")
	bloco("MarcoPedra", Vector3.new(-8, 2, 14), Vector3.new(2, 4, 2), "#9A9A9A")
	bloco("MarcoCobre", Vector3.new(0, 2, 14), Vector3.new(2, 4, 2), "#B87333")
	bloco("MarcoCristal", Vector3.new(8, 2, 14), Vector3.new(2, 4, 2), "#9FE8FF")
	bloco("PortaSemMoldura", Vector3.new(0, 4, 26), Vector3.new(6, 8, 0.4), "#2A2440")
end

function S.iniciarMapa(cfgTeste: any?, centro: Vector3?)
	local existente = Workspace:FindFirstChild("GuardioesMisterios") :: Folder?
	if existente then
		pasta = existente
	else
		pasta = Instance.new("Folder")
		pasta.Name = "GuardioesMisterios"
		pasta.Parent = Workspace
	end
	if cfgTeste and centro and next(marcasNoMapa()) == nil then
		salaDeTeste(cfgTeste, centro)
	end
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
end

-- reação da criatura: barato (1×/s, só marcas com capacidade e só jogadores perto delas)
function S.passoDeReacao()
	local marcas = {}
	for id, parte in marcasNoMapa() do
		local m = deps.registro.marcas[id]
		if m and m.tipo == "pista" then
			local inv = deps.registro.investigacao(m.investigacao)
			for _, cap in inv.capitulos do
				local pc = cap.pistas[m.pista]
				if pc and pc.capacidade then
					table.insert(marcas, { id = id, parte = parte, capacidade = pc.capacidade })
				end
			end
		end
	end
	if #marcas == 0 then
		return
	end
	for _, p in Players:GetPlayers() do
		local r = raiz(p)
		if r then
			for _, mk in marcas do
				local ja = reagiu[p] and reagiu[p][mk.id]
				if not ja and ((r :: BasePart).Position - mk.parte.Position).Magnitude <= 30 then
					local tem, fonte = S.temCapacidade(p, mk.capacidade, mk.parte.Position)
					if tem and fonte == "companheiro" then
						reagiu[p] = reagiu[p] or {}
						reagiu[p][mk.id] = true
						deps.reacao(p, mk.parte.Position, deps.registro.capacidades[mk.capacidade].animacao)
					end
				end
			end
		end
	end
end

function S.sair(p: Player)
	baldes[p] = nil
	reagiu[p] = nil
end

return S
