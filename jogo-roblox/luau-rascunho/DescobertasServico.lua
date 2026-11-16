--!strict
-- RASCUNHO, NÃO TESTADO NO STUDIO.
-- Lugar sugerido: ServerScriptService.Magnata.Servicos.Descobertas (ModuleScript iniciado pelo bootstrap existente).
--
-- O cliente só PEDE o registro da descoberta. O servidor confere tudo antes de salvar:
--   1. o id existe na lista de descobertas permitidas;
--   2. o jogador tem o Axolote Nebular equipado;
--   3. o jogador ficou parado de verdade (o servidor mede a posição, não confia no cliente);
--   4. ainda não foi registrada (sem duplicar);
--   5. limite de pedidos por jogador.
-- Não concede moedas nem itens: recompensa só depois de revisar o balanceamento.
--
-- PONTOS A CONFIRMAR NA AUDITORIA DO PROJETO (não inventei os nomes):
--   * Como o projeto salva dados do jogador (o serviço de dados existente). Aqui: `Dados`.
--   * Como saber se o ajudante está equipado. Aqui: `Ajudantes.equipado(player)`.
--   * Onde ficam os RemoteEvents. Aqui: ReplicatedStorage.Magnata.Remotos.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Magnata = ReplicatedStorage:WaitForChild("Magnata")
local SeteEstrelas = require(Magnata.Dados.SeteEstrelas)

-- TODO: trocar pelos módulos reais do projeto depois da auditoria.
local Dados = require(script.Parent.Dados) :: any
local Ajudantes = require(script.Parent.Ajudantes) :: any

local PERMITIDAS = { [SeteEstrelas.ID_DESCOBERTA] = { exigeAjudante = "AxoloteNebular", paradoMin = 11 } }
local INTERVALO_PEDIDOS = 5 -- segundos entre pedidos do mesmo jogador

local Descobertas = {}
local ultimoPedido: { [Player]: number } = {}
local paradoDesde: { [Player]: number } = {}
local ultimaPos: { [Player]: Vector3 } = {}

-- O servidor acompanha quando cada jogador se mexeu pela última vez (amostra a cada 0,5 s).
local acumulado = 0
RunService.Heartbeat:Connect(function(dt)
	acumulado += dt
	if acumulado < 0.5 then return end
	acumulado = 0
	local agora = os.clock()
	for _, player in Players:GetPlayers() do
		local raiz = player.Character and player.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
		if raiz then
			local p = raiz.Position
			local antes = ultimaPos[player]
			if not antes or (p - antes).Magnitude > 0.5 then
				paradoDesde[player] = agora
			end
			ultimaPos[player] = p
		end
	end
end)

function Descobertas.registrar(player: Player, id: string): (boolean, string)
	local regra = PERMITIDAS[id]
	if not regra then return false, "id desconhecido" end

	local agora = os.clock()
	if ultimoPedido[player] and agora - ultimoPedido[player] < INTERVALO_PEDIDOS then
		return false, "pedidos demais"
	end
	ultimoPedido[player] = agora

	if not Ajudantes.equipado(player, regra.exigeAjudante) then return false, "ajudante não equipado" end
	if not paradoDesde[player] or agora - paradoDesde[player] < regra.paradoMin then return false, "jogador não estava parado" end

	local perfil = Dados.obter(player)
	if not perfil then return false, "dados não carregados" end
	perfil.descobertas = perfil.descobertas or {}
	if perfil.descobertas[id] then return false, "já registrada" end

	perfil.descobertas[id] = os.time() -- salvo pelo autosave do serviço de dados existente
	return true, "registrada"
end

local remoto = Magnata.Remotos:WaitForChild("PedirDescoberta") :: RemoteEvent
local avisar = Magnata.Remotos:WaitForChild("DescobertaRegistrada") :: RemoteEvent
remoto.OnServerEvent:Connect(function(player: Player, id: unknown)
	if typeof(id) ~= "string" then return end
	local ok = Descobertas.registrar(player, id)
	if ok then avisar:FireClient(player, id) end -- só então o cliente mostra o aviso e a entrada do diário
end)

Players.PlayerRemoving:Connect(function(player)
	ultimoPedido[player] = nil
	paradoDesde[player] = nil
	ultimaPos[player] = nil
end)

return Descobertas
