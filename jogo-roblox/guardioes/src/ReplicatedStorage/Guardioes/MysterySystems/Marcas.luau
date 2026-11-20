--!strict
-- Regras de posição das marcas de mistério (lógica pura).

local Marcas = {}

-- Onde fica o prompt de uma marca, em studs a partir do CENTRO da peça (eixo Y local).
-- Peças altas (porta, torre, monólito) teriam o centro alto demais para quem está no chão: o prompt
-- fica perto da base, à altura do peito (2,5 studs acima da base). Peças baixas usam o próprio centro.
function Marcas.alturaDoPrompt(alturaDaPeca: number): number
	if alturaDaPeca <= 5 then
		return 0
	end
	return -alturaDaPeca / 2 + 2.5
end

return Marcas
