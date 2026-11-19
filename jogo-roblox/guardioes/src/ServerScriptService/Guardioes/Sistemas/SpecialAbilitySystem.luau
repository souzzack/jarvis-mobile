--!strict
-- NÃO EXECUTADO NO STUDIO. Habilidades ESPECIAIS de armas e escudos (servidor).
-- Uma especial por forma de artefato (Config/Especiais; a do Arco ??? em ConfigSecreta). Tecla 1 / R1 / toque.
-- O servidor confere: forma ativa (ou uso em voo pelo estágio), recarga, estamina, se está livre para agir;
-- e aplica o efeito com a POSIÇÃO DO SERVIDOR (o cliente só faz o impulso visual do próprio corpo).
--   Investida: acerta tudo na linha à frente (alcance/arco) — "Corte em Voo" quando sai da prancha (estágio 4)
--   Bastião:   golpes de frente viram aparo por 1,5 s (CombatSystem.ativarBastiao)
--   Rajada:    golpe em volta + impulso para cima do próprio jogador
--   Disparo:   tiro longo e estreito (Arco ???)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local G = ReplicatedStorage:WaitForChild("Guardioes")
local Especiais = require(G.Config.Especiais)
local Especial = require(G.Combate.Especial)
local Alcance = require(G.Combate.Alcance)
local LimiteDeTaxa = require(G.Util.LimiteDeTaxa)
local Remotos = require(G.Rede.Remotos)
local Secreto = require(script.Parent.Parent.ConfigSecreta.ArcoDasAsasPerdidas)

local ES = Remotos.Especial
local EE = Remotos.EventoEspecial

local especiais: { [string]: any } = {}
for id, e in Especiais.porArtefato do
	especiais[id] = e
end
especiais[Secreto.artefato.id] = Secreto.especial

local SpecialAbilitySystem = { Nome = "SpecialAbilitySystem" }

local evento: RemoteEvent
local combate: any
local artefatos: any
local inimigos: any
local ctxSistemas: any = nil
local recargas: { [Player]: { [string]: number } } = {}
local baldes: { [Player]: LimiteDeTaxa.Balde } = {}

local function acertar(p: Player, hrp: BasePart, esp: any)
	local pos = hrp.Position
	local f = hrp.CFrame.LookVector
	local alcance = (esp.alcance or 0) + (esp.avanco or 0) * 0.5
	local acertos = 0
	for _, c in inimigos.proximos(pos, alcance + 4) do
		if math.abs(c.posicao.Y - pos.Y) <= 8 and Alcance.noArco(pos.X, pos.Z, f.X, f.Z, c.posicao.X, c.posicao.Z, alcance, esp.arcoGraus or 360, c.raio) then
			local r = inimigos.receberGolpe(c.id, { dano = esp.dano, postura = esp.postura or 0, bonusPostura = 0, multiplicador = 1, atacante = p })
			if r then
				acertos += 1
				evento:FireAllClients(EE.ACERTO, c.id, r.tipo, r.dano)
			end
		end
	end
	return acertos
end

local function usar(p: Player)
	local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not hrp then
		return
	end
	local artefatoId, estagio, forma, tipo = artefatos.equipado(p)
	local esp = artefatoId and especiais[artefatoId]
	if not esp then
		evento:FireClient(p, EE.REJEITADO, "semEspecial")
		return
	end
	local agora = os.clock()
	recargas[p] = recargas[p] or {}
	local pode, motivo, saindo = Especial.pode(esp, {
		formaAtiva = forma, tipoAtivo = tipo, estagio = estagio, agora = agora,
		recargaAte = recargas[p][esp.id] or 0, estamina = combate.estamina(p),
	})
	if not pode then
		evento:FireClient(p, EE.REJEITADO, motivo)
		return
	end
	if saindo then
		if not artefatos.forcarFormaDeCombate(p) then
			evento:FireClient(p, EE.REJEITADO, "transformando")
			return
		end
	else
		local livre, m = combate.livreParaEspecial(p)
		if not livre then
			evento:FireClient(p, EE.REJEITADO, m or "ocupado")
			return
		end
	end
	if not combate.gastarEstamina(p, esp.custoEstamina or 0) then
		evento:FireClient(p, EE.REJEITADO, "estamina")
		return
	end
	recargas[p][esp.id] = agora + esp.recarga
	if esp.tipo == "Bastiao" then
		combate.ativarBastiao(p, esp.duracao)
	else
		acertar(p, hrp, esp)
	end
	-- o dono faz o impulso do próprio corpo (avanço/subida); todos veem o efeito
	evento:FireClient(p, EE.USOU, esp.id, esp.tipo, esp.recarga, esp.avanco or 0, esp.impulsoVertical or 0, esp.duracao or 0)
	evento:FireAllClients(EE.EFEITO, p.UserId, esp.tipo)
end

function SpecialAbilitySystem.Init(ctx: any)
	ctxSistemas = ctx
	evento = Remotos.evento("Especial")
end

function SpecialAbilitySystem.Start()
	combate = ctxSistemas.obter("CombatSystem")
	artefatos = ctxSistemas.obter("MetamorphicArtifactSystem")
	inimigos = ctxSistemas.obter("EnemySystem")
	evento.OnServerEvent:Connect(function(p: Player, tipo: any)
		local b = baldes[p]
		if not b then
			b = LimiteDeTaxa.novo(3, 1, os.clock())
			baldes[p] = b
		end
		if tipo == ES.USAR and LimiteDeTaxa.consumir(b, os.clock()) then
			usar(p)
		end
	end)
	Players.PlayerRemoving:Connect(function(p)
		recargas[p], baldes[p] = nil, nil
	end)
end

return SpecialAbilitySystem
