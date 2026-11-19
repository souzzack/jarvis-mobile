--!strict
-- NÃO EXECUTADO NO STUDIO. Ponto de entrada do cliente de Guardiões do Multiverso.
-- Coexistência: não mexe no MagnataHUD nem nos scripts antigos.

local Controladores = script.Parent:WaitForChild("Controladores")

type Controlador = { Nome: string, Init: (ctx: any) -> (), Start: () -> () }

local ORDEM = {
	"HudDeCombate", -- avisos compartilhados
	"ControleDeLocomocao", -- voo, planador (FlightController/GliderController)
	"ControleDeCombate",
	"CameraDeVoo", -- FlightCamera
	"EfeitosDeVoo", -- FlightEffects
	"HudDeLocomocao",
	"TransformacaoDeArtefato", -- ArtifactTransformationController
}
local carregados: { [string]: Controlador } = {}
local ctx = {}
function ctx.obter(nome: string): any
	local c = carregados[nome]
	assert(c, "controlador não carregado: " .. nome)
	return c
end

for _, nome in ORDEM do
	carregados[nome] = require(Controladores:WaitForChild(nome)) :: any
end
for _, nome in ORDEM do
	carregados[nome].Init(ctx)
end
for _, nome in ORDEM do
	task.spawn(carregados[nome].Start)
end
