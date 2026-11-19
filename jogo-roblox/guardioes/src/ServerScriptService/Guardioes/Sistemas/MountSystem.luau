--!strict
-- NÃO EXECUTADO NO STUDIO. MountSystem (Etapa 8): montar a criatura ativa, terrestre ou voadora.
--
-- Verificações (todas no servidor): criatura ativa e adulta de espécie montável (Crescimento.podeMontar),
-- distância ≤ 12, espaço livre na caixa da espécie, jogador no chão sem outro modo/zona/atordoamento
-- (MovementSystem.montar → MaquinaDeLocomocao.montar). Desmontar só no chão.
--
-- Como funciona (protótipo): o corpo do jogador continua sendo o que se move (física do dono = resposta
-- imediata); a criatura é soldada embaixo dele, o Humanoid ganha a velocidade/salto da espécie e a altura da
-- sela. Montaria voadora usa o MESMO núcleo de voo, com o perfil da espécie (registrado aqui com montaria=true).
-- Interrupções: renascer, sair ou perder o estado Montado (reancorar, portal) devolvem tudo ao normal.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local G = ReplicatedStorage:WaitForChild("Guardioes")
local Crescimento = require(G.Companheiros.Crescimento)
local LimiteDeTaxa = require(G.Util.LimiteDeTaxa)
local Remotos = require(G.Rede.Remotos)

local MO = Remotos.Montaria
local EM = Remotos.EventoMontaria
local DISTANCIA_MAX = 12

type Montagem = { guid: string, solda: WeldConstraint, walk: number, hip: number, usaPulo: boolean, pulo: number, altura: number, voadora: boolean }

local MountSystem = { Nome = "MountSystem" }

local montagens: { [Player]: Montagem } = {}
local baldes: { [Player]: LimiteDeTaxa.Balde } = {}
local registrados: { [string]: boolean } = {}
local evento: RemoteEvent
local movimento: any
local companheiros: any
local ctxSistemas: any = nil

local sobreposicao = OverlapParams.new()
sobreposicao.FilterType = Enum.RaycastFilterType.Exclude
sobreposicao.RespectCanCollide = true

local function corpo(p: Player): (BasePart?, Humanoid?)
	local ch = p.Character
	if not ch then
		return nil, nil
	end
	return ch:FindFirstChild("HumanoidRootPart") :: BasePart?, ch:FindFirstChildOfClass("Humanoid")
end

local function rejeitar(p: Player, acao: number, motivo: string)
	evento:FireClient(p, EM.REJEITADO, acao, motivo)
end

-- devolve jogador e criatura ao normal (sem perguntar ao movimento: usado quando o estado já acabou)
local function soltar(p: Player, restaurarHumanoid: boolean)
	local m = montagens[p]
	if not m then
		return
	end
	montagens[p] = nil
	if m.solda.Parent then
		m.solda:Destroy()
	end
	local _, hum = corpo(p)
	if restaurarHumanoid and hum then
		hum.WalkSpeed, hum.HipHeight, hum.UseJumpPower, hum.JumpPower = m.walk, m.hip, m.usaPulo, m.pulo
	end
	local modelo = companheiros.definirMontada(p, false)
	local hrp = corpo(p)
	if modelo and hrp then
		modelo:PivotTo((hrp :: BasePart).CFrame * CFrame.new(3, 0, 2))
		for _, peca in modelo:GetDescendants() do
			if peca:IsA("BasePart") and peca.Name == "Corpo" then
				peca.Massless = false
			end
		end
	end
	evento:FireClient(p, EM.MONTADO, false, false)
end

local function montar(p: Player)
	if montagens[p] then
		rejeitar(p, MO.MONTAR, "jaMontado")
		return
	end
	local c, esp, raiz = companheiros.ativa(p)
	local hrp, hum = corpo(p)
	if not c or not esp or not raiz then
		rejeitar(p, MO.MONTAR, "semCriatura")
		return
	end
	if not hrp or not hum then
		return
	end
	local pode, motivo = Crescimento.podeMontar(c, esp)
	if not pode then
		rejeitar(p, MO.MONTAR, motivo)
		return
	end
	if ((raiz :: BasePart).Position - (hrp :: BasePart).Position).Magnitude > DISTANCIA_MAX then
		rejeitar(p, MO.MONTAR, "longe")
		return
	end
	local caixa = esp.montaria.espacoNecessario or { 6, 6, 6 }
	sobreposicao.FilterDescendantsInstances = { p.Character :: Instance, (raiz :: BasePart).Parent :: Instance }
	local ocupado = Workspace:GetPartBoundsInBox(CFrame.new((raiz :: BasePart).Position + Vector3.new(0, caixa[2] / 2, 0)), Vector3.new(caixa[1], caixa[2], caixa[3]), sobreposicao)
	if #ocupado > 0 then
		rejeitar(p, MO.MONTAR, "semEspaco")
		return
	end
	local voadora = esp.montaria.tipo == "Voadora" and esp.montaria.perfilVoo ~= nil
	local perfilId: string? = nil
	if voadora then
		perfilId = esp.montaria.perfilVoo.id
		if not registrados[perfilId :: string] then
			local perfil = table.clone(esp.montaria.perfilVoo)
			perfil.montaria = true
			movimento.registrarPerfil(perfil)
			registrados[perfilId :: string] = true
		end
	end
	local ok, m2 = movimento.montar(p, c.guid, perfilId, esp.montaria.velMax)
	if not ok then
		rejeitar(p, MO.MONTAR, m2)
		return
	end
	local modelo = companheiros.definirMontada(p, true)
	if not modelo then
		movimento.desmontar(p)
		return
	end
	-- jogador "sobe" na sela: a altura do quadril cresce e a criatura fica soldada embaixo
	local r = raiz :: BasePart
	local altura = r.Size.Y
	local montagem: Montagem = {
		guid = c.guid, solda = Instance.new("WeldConstraint"), walk = hum.WalkSpeed, hip = hum.HipHeight,
		usaPulo = hum.UseJumpPower, pulo = hum.JumpPower, altura = altura, voadora = voadora,
	}
	hum.HipHeight += altura
	hum.WalkSpeed = esp.montaria.velMax
	hum.UseJumpPower = true
	hum.JumpPower = esp.montaria.salto or 0
	local h = hrp :: BasePart
	for _, peca in modelo:GetDescendants() do
		if peca:IsA("BasePart") then
			peca.Massless = true
		end
	end
	modelo:PivotTo(h.CFrame * CFrame.new(0, -(h.Size.Y / 2 + altura / 2 + 0.3), 0))
	montagem.solda.Part0, montagem.solda.Part1 = h, r
	montagem.solda.Parent = r
	montagens[p] = montagem
	evento:FireClient(p, EM.MONTADO, true, voadora)
end

local function desmontar(p: Player)
	if not montagens[p] then
		return
	end
	local ok, motivo = movimento.desmontar(p)
	if not ok then
		rejeitar(p, MO.DESMONTAR, motivo) -- "emVoo": pouse primeiro
		return
	end
	soltar(p, true)
end

function MountSystem.montado(p: Player): boolean
	return montagens[p] ~= nil
end

function MountSystem.Init(ctx: any)
	ctxSistemas = ctx
	evento = Remotos.evento("Montaria")
end

function MountSystem.Start()
	movimento = ctxSistemas.obter("MovementSystem")
	companheiros = ctxSistemas.obter("CompanionSystem")
	evento.OnServerEvent:Connect(function(p: Player, tipo: any)
		local b = baldes[p]
		if not b then
			b = LimiteDeTaxa.novo(4, 2, os.clock())
			baldes[p] = b
		end
		if not LimiteDeTaxa.consumir(b, os.clock()) then
			return
		end
		if tipo == MO.MONTAR then
			montar(p)
		elseif tipo == MO.DESMONTAR then
			desmontar(p)
		end
	end)
	-- trocar de criatura ativa desmonta (a criatura montada sumiria debaixo do jogador)
	companheiros.mudouAtiva.conectar(function(p: Player, guid: string?)
		local m = montagens[p]
		if m and m.guid ~= guid then
			movimento.reancorar(p)
			soltar(p, true)
		end
	end)
	Players.PlayerRemoving:Connect(function(p)
		montagens[p] = nil
		baldes[p] = nil
	end)
	for _, p in Players:GetPlayers() do
		p.CharacterAdded:Connect(function()
			soltar(p, false)
		end)
	end
	Players.PlayerAdded:Connect(function(p)
		p.CharacterAdded:Connect(function()
			soltar(p, false) -- personagem novo já nasce com o Humanoid padrão
		end)
	end)
	-- se o movimento perdeu o estado de montaria (reancorado, portal), limpa a montagem
	task.spawn(function()
		while true do
			task.wait(0.5)
			for p, m in montagens do
				if movimento.montado(p) ~= m.guid then
					soltar(p, true)
				end
			end
		end
	end)
end

return MountSystem
