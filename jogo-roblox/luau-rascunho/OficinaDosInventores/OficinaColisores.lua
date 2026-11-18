--!strict
-- GERADO a partir do visualizador (Oficina dos Inventores V2.3.5) — não edite à mão; regenere se o modelo mudar.
-- RASCUNHO, NÃO TESTADO NO STUDIO.
-- Lugar sugerido: ReplicatedStorage.Magnata.Oficina.OficinaColisores (ModuleScript).
-- Caixas de colisão em coordenadas LOCAIS ao pivô do modelo "Oficina dos Inventores": centro c, tamanho s (studs), giro ry (rad, em Y).
-- 0: plinto · 1–6: paredes (frente com vão da porta, fundo, laterais) · interior: bancadas, laboratório, depósito, canto do inventor, Condensador · alicerce, patamar e degraus.

export type Caixa = { c: { number }, s: { number }, ry: number }

local OficinaColisores = {}

OficinaColisores.CAIXAS = {
	{ c = { -10.7, 3.6, 1.3 }, s = { 2.6, 3.6, 7.2 }, ry = 0 },
	{ c = { -7.4, 3.6, 7.7 }, s = { 6.6, 3.6, 2.6 }, ry = 0 },
	{ c = { 9.6, 4.8, 4.2 }, s = { 2.6, 6, 2.6 }, ry = 0 },
	{ c = { 9, 3.1, -1.4 }, s = { 3.6, 2.6, 2.4 }, ry = 0 },
	{ c = { 11.5, 4.4, -3.6 }, s = { 1.2, 5.2, 4.4 }, ry = 0 },
	{ c = { -7.8, 5.1, -8.2 }, s = { 6.4, 6.6, 1.4 }, ry = 0 },
	{ c = { -11.2, 5.1, -5.4 }, s = { 1.4, 6.6, 4.2 }, ry = 0 },
	{ c = { -8.7, 2.9, -3.9 }, s = { 3, 2.2, 1.4 }, ry = 0 },
	{ c = { 7.6, 3.6, -7.4 }, s = { 3.4, 3.6, 2.4 }, ry = 0 },
	{ c = { 11.1, 3.4, -7.6 }, s = { 1.8, 3.2, 3.2 }, ry = 0 },
	{ c = { 0, 3.8, -4.6 }, s = { 7.2, 4, 7.2 }, ry = 0 },
	{ c = { 0, 7.8, -4.6 }, s = { 4, 8, 4 }, ry = 0 },
	{ c = { 0, 0.8, 0 }, s = { 27.6, 1.6, 21.6 }, ry = 0 },
	{ c = { -8.1, 7.1, 9.55 }, s = { 9.8, 11, 0.9 }, ry = 0 },
	{ c = { 8.1, 7.1, 9.55 }, s = { 9.8, 11, 0.9 }, ry = 0 },
	{ c = { 0, 14.7, 9.55 }, s = { 6.4, 3.4, 0.9 }, ry = 0 },
	{ c = { 0, 7.1, -9.55 }, s = { 26, 11, 0.9 }, ry = 0 },
	{ c = { -12.55, 7.1, 0 }, s = { 0.9, 11, 20 }, ry = 0 },
	{ c = { 12.55, 7.1, 0 }, s = { 0.9, 11, 20 }, ry = 0 },
	{ c = { 0, -2.008, 0 }, s = { 28.2, 4.016, 22.2 }, ry = 0 },
	{ c = { 0, 0.002, 12 }, s = { 9, 3.196, 2.4 }, ry = 0 },
	{ c = { 0, -0.306, 13.85 }, s = { 8, 2.639, 1.3 }, ry = 0 },
	{ c = { 0, -0.614, 15.15 }, s = { 8, 2.082, 1.3 }, ry = 0 },
	{ c = { 0, -0.861, 16.45 }, s = { 8, 1.404, 1.3 }, ry = 0 },
} :: { Caixa }

return OficinaColisores
