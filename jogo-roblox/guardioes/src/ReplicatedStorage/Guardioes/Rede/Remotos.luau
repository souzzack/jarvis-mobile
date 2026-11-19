--!strict
-- NÃO EXECUTADO. Um RemoteEvent por sistema, com o tipo da mensagem como primeiro argumento (poucas chamadas,
-- payload pequeno). O servidor cria a pasta; o cliente espera por ela.

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotos = {}

-- mensagens do combate (cliente → servidor)
Remotos.Combate = {
	ATACAR = 1, -- (alvoId: string?)
	PESADO = 2, -- (alvoId: string?)
	ESQUIVAR = 3, -- (dirX: number, dirZ: number)
	DEFESA_INICIO = 4,
	DEFESA_FIM = 5,
}

-- eventos do combate (servidor → cliente)
Remotos.EventoCombate = {
	RESULTADO_GOLPE = 1, -- (alvoId, tipo, dano) para todos: números de dano e efeitos
	REJEITADO = 2, -- (acao, motivo) só para quem pediu: o cliente desfaz a previsão
	ESTAMINA = 3, -- (valor, max) só para o dono, no máximo 5 vezes por segundo
	ESTADO = 4, -- (estado: string) correção do estado oficial
	RECEBEU_GOLPE = 5, -- (tipo, dano, origemId) para o jogador atingido
	TELEGRAFIA = 6, -- (inimigoId, ataque, duracao) para todos: aviso do ataque do inimigo
	INIMIGO_MORREU = 7, -- (inimigoId)
}

local NOMES = { "Combate" }

local pasta: Folder? = nil

local function obterPasta(): Folder
	if pasta then
		return pasta
	end
	local raiz = ReplicatedStorage:WaitForChild("Guardioes")
	if RunService:IsServer() then
		local p = raiz:FindFirstChild("Remotos") :: Folder?
		if not p then
			local nova = Instance.new("Folder")
			nova.Name = "Remotos"
			for _, nome in NOMES do
				local ev = Instance.new("RemoteEvent")
				ev.Name = nome
				ev.Parent = nova
			end
			nova.Parent = raiz
			p = nova
		end
		pasta = p
	else
		pasta = raiz:WaitForChild("Remotos") :: Folder
	end
	return pasta :: Folder
end

function Remotos.evento(nome: string): RemoteEvent
	return obterPasta():WaitForChild(nome) :: RemoteEvent
end

return Remotos
