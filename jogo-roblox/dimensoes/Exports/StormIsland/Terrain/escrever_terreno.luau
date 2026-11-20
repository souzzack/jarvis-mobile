--!strict
-- Escreve o Terrain da Ilha das Tempestades no Studio (cópia de teste), a partir do módulo gerado de
-- terreno_voxels_4studs_v2.json (ServerStorage.StormIslandDados.TerrenoIlhaDados). Rodado pelo MCP em 20/11/2026.
-- Mundo = centro (2000, 150, 0) + coordenada da ilha. Voxels de 4 studs; ocupação fracionária na superfície;
-- 8 studs de cima com o material da superfície, o resto em basalto; fenda e fora do contorno ficam vazios.
-- AJUSTE = -2: o terreno suave mostra a superfície ~meio voxel acima da ocupação (medido: +2,0 em 7 pontos).
-- Conferência: altura do terreno × gerador nos 8 pontos de interesse (erro ≤ 0,1 em 7; 6,0 na boca da caverna).
local T = workspace.Terrain
T:SetMaterialColor(Enum.Material.Grass, Color3.fromHex("4a6a4c")) -- cores autorais do terreno.js (não usadas pelo tycoon)
T:SetMaterialColor(Enum.Material.Ground, Color3.fromHex("4a403a"))
T:SetMaterialColor(Enum.Material.Cobblestone, Color3.fromHex("8a8780"))
T:FillBlock(CFrame.new(2000, 94, -10), Vector3.new(608, 448, 520), Enum.Material.Air)
local d = require(game:GetService("ServerStorage").StormIslandDados.TerrenoIlhaDados:Clone()) :: any
local NX, NZ = d.nx, d.nz
local H, B = {}, {}
local k = 0
for v in string.gmatch(d.alturaX10, "[^,]+") do k += 1; H[k] = tonumber(v) end
k = 0
for v in string.gmatch(d.baixo, "[^,]+") do k += 1; B[k] = tonumber(v) end
local MAT = { G = Enum.Material.Grass, D = Enum.Material.Ground, P = Enum.Material.Cobblestone, R = Enum.Material.Rock, S = Enum.Material.Slate, L = Enum.Material.Rock }
local CX, CY, CZ, AJUSTE = 2000, 150, 0, -2
local function amostra(i, j)
	if i < 0 or j < 0 or i >= NX or j >= NZ then return nil end
	local n = j * NX + i + 1
	if H[n] <= -9999 then return nil end
	return H[n] / 10, B[n], string.sub(d.material, n, n)
end
local CNX, CNZ = NX - 1, NZ - 1
local cel = {}
for j = 0, CNZ - 1 do
	for i = 0, CNX - 1 do -- célula centrada entre as amostras (i,i+1) x (j,j+1)
		local sh, sb, n, mats, temP = 0, 0, 0, {}, false
		for _, o in { { 0, 0 }, { 1, 0 }, { 0, 1 }, { 1, 1 } } do
			local h, b, m = amostra(i + o[1], j + o[2])
			if h then sh += h; sb += b; n += 1; mats[m] = (mats[m] or 0) + 1; if m == "P" then temP = true end end
		end
		if n >= 2 then
			local melhor, mc = nil, 0
			for m, c in mats do if c > mc then melhor, mc = m, c end end
			cel[j * CNX + i] = { sh / n + AJUSTE, sb / n, if temP then "P" else melhor }
		end
	end
end
for tj = 0, CNZ - 1, 16 do
	for ti = 0, CNX - 1, 16 do
		local yMin, yMax = math.huge, -math.huge
		for j = tj, math.min(tj + 15, CNZ - 1) do
			for i = ti, math.min(ti + 15, CNX - 1) do
				local c = cel[j * CNX + i]
				if c then yMin = math.min(yMin, math.floor((CY + c[2]) / 4)); yMax = math.max(yMax, math.ceil((CY + c[1]) / 4) - 1) end
			end
		end
		if yMin <= yMax then
			local sx, sz, sy = math.min(16, CNX - ti), math.min(16, CNZ - tj), yMax - yMin + 1
			local mats, occ = {}, {}
			for x = 1, sx do
				mats[x], occ[x] = {}, {}
				for y = 1, sy do
					mats[x][y], occ[x][y] = {}, {}
					for z = 1, sz do mats[x][y][z] = Enum.Material.Air; occ[x][y][z] = 0 end
				end
			end
			for x = 1, sx do
				for z = 1, sz do
					local c = cel[(tj + z - 1) * CNX + (ti + x - 1)]
					if c then
						local topo, baixo = CY + c[1], CY + c[2]
						for y = 1, sy do
							local y0 = (yMin + y - 1) * 4
							local o = (math.min(topo, y0 + 4) - math.max(baixo, y0)) / 4
							if o > 0 then
								mats[x][y][z] = if y0 + 4 > topo - 8 then MAT[c[3]] else Enum.Material.Basalt
								occ[x][y][z] = math.min(o, 1)
							end
						end
					end
				end
			end
			T:WriteVoxels(Region3.new(Vector3.new(CX - 300 + ti * 4, yMin * 4, CZ - 264 + tj * 4), Vector3.new(CX - 300 + (ti + sx) * 4, (yMax + 1) * 4, CZ - 264 + (tj + sz) * 4)), 4, mats, occ)
		end
	end
end
