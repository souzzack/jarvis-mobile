# 20 · Relatório: melhorias de equipamento e transportes (sem o Studio)

Data: 19/11/2026. **Nada foi executado** no Studio nem em runtime Luau.

## O que foi feito

| Área | Entrega |
|---|---|
| **Melhoria +1 a +10** (GDD 7.2) | O multiplicador sobe em linha até o **teto da raridade**: metade do salto até a seguinte, então um Druida +10 = 1,46, que fica abaixo do Arcano (1,50). Melhorar nunca torna obrigatório trocar de raridade |
| Onde melhorar | **+1 a +5** na Oficina dos Inventores restaurada; **+6 a +10** na Forja da base nível 4 (GDD 8 e 9) |
| Custo | Fragmentos 2 × nível; Núcleo de Tempestade a partir do +4 (2 a partir do +8); itens Druida pedem também o material de origem (1 a cada 3 níveis). Consumo e nível na mesma transação |
| **Prancha de viagem** (Sistema 8B) | Transporte **comum** (não é artefato): flutua até 6 studs, velocidade 24, gasta 4/s, sem impulso. Fabricada na Forja nível 2. A **posse** libera o perfil no servidor (`registrarAcessoPorPosse`); o cliente não liga perfis |
| **Tela de transportes** (Sistema 14) | Tecla J ou aba: todos os meios com disponível ou requisito em texto público (o Arco ??? não aparece), velocidade e custo de energia. **Preferido** salvo, usado pela tecla de voo |
| Equilíbrio entre transportes | A prancha é barata e baixa, mas lenta; o voo é livre e mais caro; os artefatos são rápidos e exigem estágio; o planador é grátis mas não sobe sem corrente. Nenhum anula os outros (tabela no `07`, seção 8) |

## Arquivos criados

| Arquivo | Linhas |
|---|---|
| `src/ReplicatedStorage/Guardioes/Config/Transportes.luau` | 19 |
| `src/ReplicatedStorage/Guardioes/Equipamento/Melhoria.luau` | 39 |
| `src/ServerScriptService/Guardioes/Sistemas/TransportSystem.luau` | 138 |
| `src/StarterPlayer/StarterPlayerScripts/Guardioes/Controladores/JanelaDeTransportes.luau` | 139 |
| `tests/Specs/MelhoriaTransporte.spec.luau` | 61 |

**Arquivos existentes com acréscimos:**
- **Sistemas:** `EquipmentSystem` (MELHORAR, melhoria nos totais), `InventorySystem` (`darTransporte`), `CraftingSystem` (resultado "transporte", `estacoesPerto` público), `MovementSystem` (acesso por posse), `MetamorphicArtifactSystem` (`listaDe`).
- **Lógica e dados:** `Equipamento` (totais com melhoria), `Config/Equipamentos` (material de origem), `Config/Locomocao/Perfis` (PranchaComum), `Config/Receitas`, `Dados/Perfil` (transportes, preferido, validação de melhoria).
- **Rede e carga:** `Remotos`, `Mensagens`, `Main.server`, `Main.client`.
- **Cliente:** `ControleDeLocomocao` (preferido), `HudDeProgresso` (botão Melhorar).
- **Testes e docs:** executores de teste, docs 10 e README.

**Fora de `jogo-roblox/guardioes/`:** nada.

## Verificado aqui

- Equilíbrio de blocos nos 143 arquivos: 0 problemas.
- Todos os sistemas e controladores carregados; `require` e RemoteEvents conferidos.
- 6 casos novos conferidos à mão. Exemplos: Druida +5 = 1,44; custo do +8 com material de origem = 16 Fragmentos, 2 Núcleos e 3 do material; o Elmo +10 tem defesa 15.

O Lune continua bloqueado pelo ambiente.

## Pendente

- Companhias (guildas).
- SecretDiscoverySystem (???).
- Portais entre places.
- Relíquia; visual das armaduras e das melhorias.
- Roteiros U1 a U5 e T1 a T5 no Studio.
