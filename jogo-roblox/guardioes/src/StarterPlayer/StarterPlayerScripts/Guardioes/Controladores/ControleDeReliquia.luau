--!strict
-- NÃO EXECUTADO NO STUDIO. Relíquia equipada: tecla Z (R3 no controle) ou toque no botão.
-- O botão só aparece com uma relíquia no encaixe; mostra a recarga (o servidor manda quanto falta).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")

local G = ReplicatedStorage:WaitForChild("Guardioes")
local Remotos = require(G.Rede.Remotos)
local Mensagens = require(G.Util.Mensagens)

local EE = Remotos.EventoEquipamento
local jogador = Players.LocalPlayer

local ControleDeReliquia = { Nome = "ControleDeReliquia" }

local ctxSalvo: any = nil
local hud: any
local ev: RemoteEvent
local botao: TextButton
local nome: string? = nil
local prontaEm = 0 -- os.clock() local

local function atualizar()
	botao.Visible = nome ~= nil
	if not nome then
		return
	end
	local falta = prontaEm - os.clock()
	botao.Text = if falta > 0 then string.format("[Z] %s\n%d s", nome, math.ceil(falta)) else string.format("[Z] %s\npronta", nome)
	botao.BackgroundColor3 = if falta > 0 then Color3.fromRGB(40, 40, 56) else Color3.fromRGB(62, 52, 104)
end

local function ativar()
	if nome and os.clock() >= prontaEm then
		ev:FireServer(Remotos.Equipamento.ATIVAR_RELIQUIA)
	end
end

function ControleDeReliquia.Init(ctx: any)
	ctxSalvo = ctx
	ev = Remotos.evento("Equipamento")
	local tela = Instance.new("ScreenGui")
	tela.Name = "GuardioesReliquia"
	tela.ResetOnSpawn = false
	tela.Parent = jogador:WaitForChild("PlayerGui")
	botao = Instance.new("TextButton")
	botao.AnchorPoint = Vector2.new(1, 1)
	botao.Position, botao.Size = UDim2.new(1, -24, 1, -190), UDim2.fromOffset(150, 46)
	botao.BorderSizePixel = 0
	botao.TextColor3 = Color3.new(1, 1, 1)
	botao.Font = Enum.Font.GothamBold
	botao.TextSize = 12
	botao.TextWrapped = true
	botao.Visible = false
	botao.Parent = tela
	botao.Activated:Connect(ativar)
end

function ControleDeReliquia.Start()
	hud = ctxSalvo.obter("HudDeCombate")
	ev.OnClientEvent:Connect(function(tipo: number, a: any, b: any, _c: any, d: any)
		if tipo == EE.RELIQUIA then
			nome = if typeof(a) == "string" then a else nil
			prontaEm = os.clock() + (if typeof(b) == "number" then b else 0)
			if typeof(d) == "number" and d > 0 then
				hud.aviso(string.format("%s ativada (%d s)", tostring(a), d))
			end
			atualizar()
		elseif tipo == EE.RELIQUIA_NOVA and typeof(a) == "string" then
			hud.aviso("Relíquia nova: " .. a .. " — equipe na Bolsa (I)")
		end
	end)
	ContextActionService:BindAction("GuardioesReliquia", function(_n, s, _o)
		if s == Enum.UserInputState.Begin then
			ativar()
		end
		return Enum.ContextActionResult.Sink
	end, false, Enum.KeyCode.Z, Enum.KeyCode.ButtonR3)
	task.spawn(function()
		while true do
			task.wait(0.5)
			if nome then
				atualizar()
			end
		end
	end)
end

return ControleDeReliquia
