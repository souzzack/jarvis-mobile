--!strict
-- NÃO EXECUTADO. Raças jogáveis — nomes e valores PROVISÓRIOS (T), a decidir depois dos testes de balanceamento.
-- Regra: nenhuma raça é necessária para terminar a história ou achar os segredos principais. Quem não voa
-- naturalmente aprende voo pelo Grimório dos Céus ou usa artefatos/montarias/planador.
-- 'mods' usam o mesmo formato das habilidades (aplicados por PerfilEfetivo e, no futuro, pelo ProgressionSystem).

export type Raca = {
	id: string,
	nome: string,
	identidade: string,
	vantagens: { string },
	limitacoes: { string },
	habilidadesIniciais: { string },
	desbloqueaveis: { string },
	mods: { { campo: string, perfis: { string }?, somar: number?, multiplicar: number? } },
	restricoes: { string },
}

local lista: { Raca } = {
	{
		id = "Humano", nome = "Humano",
		identidade = "Roupas de viajante, acessórios de várias dimensões.",
		vantagens = { "Maestria de arma +10% mais rápida", "Usa qualquer transporte e artefato sem penalidade" },
		limitacoes = { "Não voa naturalmente" },
		habilidadesIniciais = {},
		desbloqueaveis = { "Versatil: troca de forma de artefato 15% mais rápida (missão de raça)" },
		mods = {},
		restricoes = {},
	},
	{
		id = "Alado", nome = "Alado",
		identidade = "Asas de penas com padrão por dimensão de origem.",
		vantagens = { "Voo natural desde o início (sem impulso até o Tomo das Correntes Astrais)" },
		limitacoes = { "Vida máxima -8%", "Não usa planador (as asas já cumprem a função)", "Armaduras pesadas: voo 15% mais lento" },
		habilidadesIniciais = { "AsasNaturais" },
		desbloqueaveis = { "Mergulho: queda controlada que vira golpe de investida" },
		mods = {},
		restricoes = { "SemPlanador" },
	},
	{
		id = "Elemental", nome = "Elemental",
		identidade = "Veios de energia no corpo com a cor do elemento escolhido.",
		vantagens = { "Resistência 15% ao elemento escolhido", "Habilidades do elemento custam menos" },
		limitacoes = { "Fraqueza 10% ao elemento oposto", "Elemento só muda por missão" },
		habilidadesIniciais = {},
		desbloqueaveis = { "Forma elemental curta (aura de dano por 6 s)" },
		mods = {},
		restricoes = {},
	},
	{
		id = "Astral", nome = "Astral",
		identidade = "Pele com brilho de constelação e olhos claros.",
		vantagens = { "Esquiva astral alcança 3 studs a mais", "Percebe pistas comuns por perto (nunca revela segredos ???)" },
		limitacoes = { "Energia de voo máxima -15%" },
		habilidadesIniciais = {},
		desbloqueaveis = { "Passo astral: atravessa barreiras finas de energia" },
		mods = { { campo = "energiaMax", multiplicar = 0.85 } },
		restricoes = {},
	},
}

local porId: { [string]: Raca } = {}
for _, r in lista do
	porId[r.id] = r
end

return { lista = lista, porId = porId }
