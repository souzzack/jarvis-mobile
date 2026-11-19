# 17 · Relatório: Guardião da Tormenta (sem o Studio)

Data: 19/11/2026. **Nada foi executado** no Studio nem em runtime Luau.

## O que foi feito

| Área | Entrega |
|---|---|
| **Guardião da Tormenta** | Guardião dimensional da Ilha (6000 de vida). **Fase 1:** lança, investida aérea e trovão. **Fase 2 (65%):** imune a golpes; os 4 para-raios carregam um por vez. Ativar o aceso joga o raio nele (480 de dano, atordoado por 3 s, janela de golpes). Ativar o errado dá um choque; deixar passar faz o raio cair em volta. **Fase 3 (30%):** padrões telegrafados no chão (centro, anel, cruz); a esquiva no instante evita |
| **Arena** | Topo da Torre restaurada: quem não restaurou é empurrado para fora (em teste, a trava está desligada por padrão) |
| **Recompensas** | Coração da Tormenta e Penas do Relâmpago Antigo (materiais Arcanos), 800 de XP, missão *O Guardião da Tormenta*, troféu. Na primeira vitória: **Códice Arcano** e o segredo de história *DiarioDoGuardiao* |
| **Receita Arcana** | **Espada do Horizonte (Arcano)** na Oficina restaurada: Coração + 2 Penas + 2 Glândulas (Rainha) + 2 Jubas (Alfa). Fecha o "Exemplo 4" do complemento (Guardião → materiais Arcanos → espada que vira prancha) |
| **BossSystem** | Terceira mecânica ("Tormenta"), além de Carga e Matilha; o reset com a arena vazia também limpa as áreas do chão |

## Arquivos criados

| Arquivo | Linhas |
|---|---|
| `src/ReplicatedStorage/Guardioes/Chefes/Tormenta.luau` | 102 |
| `src/ReplicatedStorage/Guardioes/Config/Inimigos/GuardiaoDaTormenta.luau` | 24 |
| `tests/Specs/Tormenta.spec.luau` | 75 |

**Arquivos existentes com acréscimos:** `BossSystem` (mecânica Tormenta, trava da arena, Códice e segredo), `HudDeChefe` (avisos de fase, para-raios e padrões), `Config/Materiais`, `Config/Loot`, `Config/Receitas`, `Config/Missoes`, `Remotos`, `Mensagens`, `ConfigServidor`, executores de teste, docs 10 e README.

## Verificado aqui

- Equilíbrio de blocos nos 129 arquivos: 0 problemas.
- `require` e ordem de carga: ok.
- 6 casos novos conferidos à mão. Exemplos: com sorteio 0,5, carrega o para-raios 3; a falha acontece em 16,5 s e a próxima carga fica para 22,5 s. Uma soma em ponto flutuante passou a usar tolerância.

O Lune continua bloqueado pelo ambiente.

## Pendente

- Roteiro G1 a G9 no Studio e os 140 casos automáticos.
- Ainda não feitos:
  - Colosso das Ruínas e Espectro do Observatório;
  - prancha comum e tela de transportes;
  - armaduras;
  - Companhias;
  - SecretDiscoverySystem;
  - portais entre places.
- Arte: Guardião, para-raios e áreas do chão ainda são provisórios.
