--!strict
-- NÃO EXECUTADO. Missões da Ilha das Tempestades (primeiro lote, T). Só dados.
-- Aceite automático quando os requisitos (Util/Requisitos) são cumpridos. Recompensas:
--   xp (jogador), materiais, marcoCriatura { especie, marco } (só vale se a criatura ativa for daquela espécie),
--   objetivoDimensional (Vínculo Dimensional da criatura ativa), e a própria missão concluída (que destrava
--   livros, estágios de artefato etc.).
-- Missões de história que dependem de restauração entram com o RestorationSystem (Etapa H).

local lista = {
	{
		id = "OHorizontePartido",
		nome = "O Horizonte Partido",
		descricao = "As Faíscas Errantes guardam pedaços de uma lâmina antiga. Derrote-as e veja o que a espada revela.",
		requisitos = {},
		objetivos = { { id = "faiscas", tipo = "derrotar", alvo = "FaiscaErrante", qtd = 5, descricao = "Faíscas derrotadas" } },
		recompensas = { xp = 120, materiais = { NucleoDeTempestade = 1 } },
	},
	{
		id = "PrimeiraCacaDoCao",
		nome = "Primeira caçada",
		descricao = "Lute ao lado do seu Cão-Trovão.",
		requisitos = {},
		objetivos = { { id = "caca", tipo = "derrotarComCriatura", alvo = "CaoTrovao", qtd = 1, descricao = "Vitória com o Cão-Trovão" } },
		recompensas = { xp = 40, marcoCriatura = { especie = "CaoTrovao", marco = "CaoPrimeiraCaca" } },
	},
	{
		id = "OlharAsEstrelas",
		nome = "Olhar as estrelas",
		descricao = "Leia o Grimório dos Céus com o Axolote Nebular por perto.",
		requisitos = {},
		objetivos = { { id = "ler", tipo = "ler", alvo = "GrimorioDosCeus", qtd = 1, descricao = "Grimório lido" } },
		recompensas = { xp = 60, marcoCriatura = { especie = "AxoloteNebular", marco = "AxoPrimeiraConstelacao" } },
	},
	{
		id = "VentoNasAsas",
		nome = "Vento nas asas",
		descricao = "Voe montado numa Raia-das-Nuvens.",
		requisitos = {},
		objetivos = { { id = "voo", tipo = "voar", alvo = "MontariaRaia", qtd = 1, descricao = "Voo na Raia" } },
		recompensas = { xp = 50, marcoCriatura = { especie = "RaiaDasNuvens", marco = "RaiaPrimeiroVooJunto" } },
	},
	{
		id = "TravessiaDaTormenta",
		nome = "Travessia da tormenta",
		descricao = "Atravesse a Planície planando com sua criatura.",
		requisitos = { habilidades = { "Planador" } },
		objetivos = { { id = "planar", tipo = "planar", alvo = "*", qtd = 3, descricao = "Planeios" } },
		recompensas = { xp = 60, objetivoDimensional = "TempSobreviverTormenta" },
	},
	{
		id = "AFornalhaDosInventores",
		nome = "A fornalha dos inventores",
		descricao = "Restaure a Oficina dos Inventores para voltar a fabricar.",
		requisitos = {},
		objetivos = { { id = "oficina", tipo = "restaurar", alvo = "OficinaDosInventores", qtd = 1, descricao = "Oficina restaurada" } },
		recompensas = { xp = 150 },
	},
	{
		id = "LigaDosInventores",
		nome = "A liga dos inventores",
		descricao = "Fabrique a primeira Liga Arcana na Oficina.",
		requisitos = { restauracoes = { "OficinaDosInventores" } },
		objetivos = { { id = "liga", tipo = "fabricar", alvo = "LigaArcana", qtd = 1, descricao = "Liga Arcana fabricada" } },
		recompensas = { xp = 80 },
	},
	{
		id = "ARainhaDaCaverna",
		nome = "A Rainha da caverna",
		descricao = "A Rainha-Bobina bloqueia os veios da mina. Quebre os pilares antes da descarga.",
		requisitos = {},
		objetivos = { { id = "rainha", tipo = "derrotar", alvo = "RainhaBobina", qtd = 1, descricao = "Rainha-Bobina derrotada" } },
		recompensas = { xp = 200 },
	},
	{
		id = "OAlfaDaMatilha",
		nome = "O Alfa da matilha",
		descricao = "O Alfa corre carregado e nada o fere. Apare o bote dele na hora certa.",
		requisitos = {},
		objetivos = { { id = "alfa", tipo = "derrotar", alvo = "CaoTrovaoAlfa", qtd = 1, descricao = "Alfa derrotado" } },
		recompensas = { xp = 200 },
	},
	{
		id = "FogoNaForja",
		nome = "Fogo na forja",
		descricao = "Leve a Forja da sua base ao nível 3 para fabricar equipamentos Druida.",
		requisitos = {},
		objetivos = { { id = "forja", tipo = "melhorarBase", alvo = "Forja3", qtd = 1, descricao = "Forja nível 3" } },
		recompensas = { xp = 150 },
	},
}

local porId: { [string]: any } = {}
for _, m in lista do
	porId[m.id] = m
end

return { lista = lista, porId = porId }
