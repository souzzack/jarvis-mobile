--!strict
-- RASCUNHO, NÃO TESTADO NO STUDIO (o Studio não estava acessível quando isto foi escrito).
-- Lugar sugerido: ReplicatedStorage.Magnata.Oficina.OficinaConfig (ModuleScript compartilhado).
-- Constantes da Oficina dos Inventores V2.3.5, tiradas do modelo do visualizador (1 unidade = 1 stud, Y para cima, frente = +Z local).
-- Coordenadas "locais" são relativas ao pivô do modelo "Oficina dos Inventores" importado do GLB (Architecture.glb).

local OficinaConfig = {}

-- Caminho esperado depois de importar o pacote (Dimensions/StormIsland/Architecture/Architecture.glb pelo Importador 3D).
OficinaConfig.CAMINHO = { "Dimensions", "StormIsland", "Architecture", "Oficina dos Inventores" }

-- Medidas do edifício (studs)
OficinaConfig.LARGURA = 26
OficinaConfig.PROFUNDIDADE = 20
OficinaConfig.PISO_Y = 1.8 -- topo do tabuado
OficinaConfig.TOPO_PAREDES = 12.6
OficinaConfig.CUMEEIRA = 18.45

-- Nível de detalhe do interior: some acima de SUMIR e volta abaixo de VOLTAR (histerese, não pisca na fronteira)
OficinaConfig.INTERIOR_NOME = "InteriorLOD"
OficinaConfig.INTERIOR_SUMIR = 125
OficinaConfig.INTERIOR_VOLTAR = 110

-- Luz quente interna: uma PointLight, apagada longe (no navegador a luz pontual é a única dinâmica da oficina)
OficinaConfig.LUZ_LOCAL = Vector3.new(0, 10.1, 1)
OficinaConfig.LUZ_COR = Color3.fromRGB(255, 180, 104)
OficinaConfig.LUZ_BRILHO = 1.6
OficinaConfig.LUZ_ALCANCE = 34
OficinaConfig.LUZ_DISTANCIA_MAX = 150

-- Faíscas (Beam entre Attachments), em coordenadas locais da oficina
OficinaConfig.FAISCADOR = { Vector3.new(-0.82, 13.5, -4.6), Vector3.new(0.82, 13.5, -4.6) }
OficinaConfig.CONDUTOR_FIM = Vector3.new(0, 15.02, -4.5)
OficinaConfig.BOBINA_LAB_TOPO = Vector3.new(9.6, 7.75, 4.2)

-- Lugar reservado para o NPC STORM.NPC.02 (o NPC não existe nesta etapa)
OficinaConfig.PONTO_NPC = Vector3.new(9.4, 1.8, -4.8)

-- Grupos animados (nomes dos nós no GLB) e como cada um se move.
-- eixo: eixo LOCAL do pivô do grupo; vel: rad/s em tempo calmo; velTempestade: rad/s com tempestade ativa.
export type Animacao = { nome: string, tipo: "girar" | "pistao" | "ponteiro", eixo: Vector3?, vel: number?, velTempestade: number?, amplitude: number? }
OficinaConfig.ANIMACOES = {
	{ nome = "AnelContencao0", tipo = "girar", eixo = Vector3.yAxis, vel = 0.15, velTempestade = 0.5 },
	{ nome = "AnelContencao1", tipo = "girar", eixo = Vector3.yAxis, vel = -0.2, velTempestade = -0.65 },
	{ nome = "AnelContencao2", tipo = "girar", eixo = Vector3.yAxis, vel = 0.24, velTempestade = 0.8 },
	{ nome = "EngrenagensCondensador", tipo = "girar", eixo = Vector3.zAxis, vel = 0.8, velTempestade = 0.8 },
	{ nome = "VolanteGerador", tipo = "girar", eixo = Vector3.xAxis, vel = 0.8, velTempestade = 3 },
	{ nome = "Planetario", tipo = "girar", eixo = Vector3.yAxis, vel = 0.3, velTempestade = 0.3 },
	{ nome = "Pistoes", tipo = "pistao", amplitude = 0.35 },
	{ nome = "PonteiroManometro", tipo = "ponteiro", amplitude = 0.4 },
} :: { Animacao }

-- Peças que NÃO devem colidir nem projetar sombra (decoração interna; a colisão vem dos colisores invisíveis)
OficinaConfig.SEM_SOMBRA = { "InteriorLOD" }

-- Atributo de Workspace que liga a tempestade (pulso dos condutores, faíscas, velocidade dos anéis)
OficinaConfig.ATRIBUTO_TEMPESTADE = "TempestadeAtiva"

return OficinaConfig
