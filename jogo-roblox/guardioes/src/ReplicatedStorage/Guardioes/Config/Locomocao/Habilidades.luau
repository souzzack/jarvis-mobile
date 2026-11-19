--!strict
-- NÃO EXECUTADO. Habilidades de movimento (o que o personagem SABE fazer). Só dados.
-- Uma habilidade libera um perfil e/ou aplica modificadores a perfis. Origem: livro, raça, artefato, missão.
-- O servidor é o único que concede; o cliente só recebe a lista (veja MovementAbilitySystem).
--
-- mods: aplicados por Locomocao/PerfilEfetivo na ordem definir → somar → multiplicar.
--   perfis = lista de perfis afetados ("*" = todos os Motorizados)

export type Mod = { campo: string, definir: number?, somar: number?, multiplicar: number? }
export type Habilidade = {
	id: string,
	nome: string,
	descricao: string,
	liberaPerfil: string?,
	perfis: { string }?,
	mods: { Mod }?,
	liberaImpulso: number?,
	oculta: boolean?,
}

local lista: { Habilidade } = {
	{
		id = "VooMagico", nome = "Voo mágico", liberaPerfil = "VooMagico",
		descricao = "Aprendido no Grimório dos Céus. Decolar, pairar, voar e pousar.",
	},
	{
		id = "CorrentesAstrais", nome = "Correntes Astrais",
		descricao = "Tomo das Correntes Astrais: libera o impulso (voo acelerado) e curvas mais fechadas.",
		perfis = { "*" },
		liberaImpulso = 1.5, -- perfis sem impulso ganham velImpulso = velMax × 1,5
		mods = { { campo = "inclinacaoMax", somar = 6 } },
	},
	{
		id = "Leveza", nome = "Leveza",
		descricao = "Códice da Leveza: voar, pairar e acelerar gastam 20% menos energia.",
		perfis = { "*" },
		mods = {
			{ campo = "custoPorSeg", multiplicar = 0.8 },
			{ campo = "custoPairarPorSeg", multiplicar = 0.8 },
			{ campo = "custoImpulsoPorSeg", multiplicar = 0.8 },
		},
	},
	{
		id = "Planador", nome = "Planador", liberaPerfil = "Planador",
		descricao = "Abrir o planador em queda, a partir de lugares altos.",
	},
	{
		id = "AsasNaturais", nome = "Asas", liberaPerfil = "AsasNaturais",
		descricao = "Voo natural da raça Alada.",
	},
}

local porId: { [string]: Habilidade } = {}
for _, h in lista do
	porId[h.id] = h
end

return { lista = lista, porId = porId }
