# 18 · Relatório: Colosso das Ruínas e Espectro do Observatório (sem o Studio)

Data: 19/11/2026. **Nada foi executado** no Studio nem em runtime Luau.

Com esta rodada, os **4 minibosses e o Guardião** da Ilha (GDD 6.3) estão escritos. Cada um ensina uma habilidade:

| Chefe | O que ensina |
|---|---|
| Rainha | Prioridade de alvos (pilares) |
| Alfa | Aparo sob pressão |
| Colosso | Aparo repetido para abrir a defesa |
| Espectro | Usar o cenário (o telescópio) |
| Guardião | Juntar tudo |

## O que foi feito

| Chefe | Mecânica |
|---|---|
| **Colosso das Ruínas** | Couraça imune. Cada golpe dele **aparado** conta, e 3 aparos **abrem o núcleo** por 8 s (ferível); depois fecha e a contagem zera. **Pisoteio:** a cada cerca de 11 s, um anel telegrafado por 1,5 s e depois uma onda de 30 de dano até 14 studs (dá para esquivar). Saque: Núcleo Enferrujado (Druida) e **Essência de Vento** (agora com fonte real para o estágio 3 do Cajado) |
| **Espectro do Observatório** | Aparece **só à noite** (`Lighting.ClockTime` entre 18 e 6 h; em teste a regra vem desligada). Teleporta para **outra** lente a cada 9 s. Fica imune, exceto ao **reflexo do telescópio**, que exige o Observatório restaurado: 6 s ferível, 2 s atordoado, sem teleporte nesse tempo, com recarga de 15 s. Ao amanhecer, sem luta, some até a próxima noite. Saque: Lente Espectral (Druida) |

**Também:**
- `EnemySystem.teleportar`;
- avisos na tela (aparos, onda, lente, reflexo);
- 2 missões novas;
- troféus automáticos no Expositor.

## Arquivos criados

| Arquivo | Linhas |
|---|---|
| `src/ReplicatedStorage/Guardioes/Chefes/Colosso.luau` | 56 |
| `src/ReplicatedStorage/Guardioes/Chefes/Espectro.luau` | 57 |
| `src/ReplicatedStorage/Guardioes/Config/Inimigos/ColossoDasRuinas.luau` | 23 |
| `src/ReplicatedStorage/Guardioes/Config/Inimigos/EspectroDoObservatorio.luau` | 22 |
| `tests/Specs/ColossoEspectro.spec.luau` | 61 |

**Arquivos existentes com acréscimos:** `BossSystem` (mecânicas Nucleo e Lentes, retorno condicionado à noite, reset de dia), `EnemySystem` (teleportar), `HudDeChefe`, `Config/Materiais`, `Config/Loot`, `Config/Missoes`, `Remotos`, `Mensagens`, `ConfigServidor`, executores de teste, docs 10 e README.

## Verificado aqui

- Equilíbrio de blocos nos 134 arquivos: 0 problemas.
- `require`: ok.
- 5 casos novos conferidos à mão. Exemplos: o núcleo abre no 3º aparo e fecha aos 11 s; a onda é telegrafada aos 11 s e sai aos 12,5 s; o teleporte nunca repete a lente (1 → 2); o reflexo segura o teleporte até o fim da janela.

O Lune continua bloqueado pelo ambiente.

## Pendente

- **Esboços Druida do Alfa, do Colosso e do Espectro:** os materiais Druida deles já caem, mas os **itens** Druida que sairiam desses esboços são armas e armaduras, que precisam do **EquipmentSystem** (armaduras, encaixes). Hoje só existem artefatos. Por enquanto, a Juba sobe a Forja, a Essência alimenta o Cajado, e o Núcleo e a Lente ficam guardados para essas receitas.
- **Mapas reais:** posicionar as arenas (ruínas, observatório) quando houver Studio.
- **Studio:** roteiros R1 a R5 e E1 a E5, além dos anteriores.
