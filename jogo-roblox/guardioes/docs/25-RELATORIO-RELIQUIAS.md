# 25 · Relatório: relíquias (sem o Studio)

Data: 19/11/2026. **Nada foi executado** no Studio nem em runtime Luau.

Fecha o último encaixe do GDD 7.4: **Relíquia — ativa, com recarga longa; vem de Guardiões e segredos.**

## O que foi feito

| Área | Entrega |
|---|---|
| Encaixe | **Reliquia**, ao lado de Cabeça, Corpo, Pernas e os 2 Acessórios. Equipar e retirar pela Bolsa (I), como os outros itens |
| **Olho da Tormenta** (Arcano) | Do **Guardião da Tormenta**, na primeira vitória. Ativa: por **6 s**, os golpes recebidos causam **40% menos dano**. Recarga **2 min** |
| **Lasca da Sétima Estrela** (???) | Do **segredo do Ato 1**, na câmara sob o altar, junto do Artefato Desconhecido. Ativa: **enche energia de voo e estamina**. Recarga **3 min**. Fica só no servidor (`ConfigSecreta/ReliquiasSecretas`) até o jogador ter o item |
| Ativar | Tecla **Z**, **R3** no controle, ou toque no botão (canto inferior direito), que mostra a recarga |
| Regras | Não dão atributos passivos. São únicas (uma de cada). **Não ocupam o Depósito**: uma recompensa única nunca se perde por falta de espaço. Não se desmontam e não se melhoram |

## Segurança e equilíbrio

- **A recarga é única por jogador:** trocar de relíquia não zera.
- **A recarga fica salva no perfil** (`reliquiaRecargaAte`, no relógio do servidor): sair e voltar não zera.
- **A recarga é gravada antes do efeito.** Dois pedidos ao mesmo tempo resultam numa ativação só.
- **Teto da redução de dano:** 0,6 no `CombatSystem`, para nenhuma relíquia futura virar invencibilidade. A redução entra como multiplicador do dano, antes da defesa da armadura.
- **Proporção:** o efeito dura bem menos que a recarga (6 s ativo para 120 s de espera).
- **Catálogo ???:** é juntado ao catálogo **só no servidor**. A tabela do cliente não muda.

## Arquivos

**Criados:**

| Arquivo | Conteúdo |
|---|---|
| `src/ReplicatedStorage/Guardioes/Equipamento/Reliquia.luau` | Lógica pura: pode ativar, recarga |
| `src/ServerScriptService/Guardioes/ConfigSecreta/ReliquiasSecretas.luau` | Relíquias ??? (só servidor) |
| `src/StarterPlayer/StarterPlayerScripts/Guardioes/Controladores/ControleDeReliquia.luau` | Tecla Z e botão |
| `tests/Specs/Reliquia.spec.luau` | 6 casos |

**Com acréscimos:**
- **Lógica e dados:** `Equipamento` (encaixe e `contarNoDeposito`), `Config/Equipamentos` (Olho da Tormenta), `Dados/Perfil` (`reliquiaRecargaAte` e validação).
- **Sistemas:**
  - `InventorySystem` (`darReliquia`; o Depósito não conta relíquias);
  - `EquipmentSystem` (catálogo secreto, ATIVAR_RELIQUIA, `darReliquia`, sem melhorar ou desmontar relíquias);
  - `CombatSystem` (`reduzirDano`);
  - `BossSystem` (relíquia do Guardião);
  - `SecretDiscoverySystem` (relíquia da câmara);
  - `PersonalBaseSystem` (letreiro sem relíquias).
- **Rede, cliente e carga:** `Remotos`, `Mensagens`, `HudDeProgresso` (sem Desmontar em relíquia), `Main.client`.
- **Testes e docs:** executores de teste, doc 10 (seção 18), README.

**Fora de `jogo-roblox/guardioes/`:** nada.

## Verificado aqui

- **Equilíbrio de blocos:** 0 problemas nos 164 arquivos.
- **Teclas:** Z e R3 estavam livres; conferi todas as teclas usadas pelos controladores.
- **Mensagens:** nenhuma chave duplicada em `Mensagens`.

O Lune continua bloqueado, então os testes **não rodaram**.

## Pendente

- Visual: efeito do Escudo de Estática, da Lasca e os ícones.
- Mais relíquias, quando houver outros Guardiões e outras dimensões.
- Portais entre places.
- Roteiros E1 a E10 no Studio.
