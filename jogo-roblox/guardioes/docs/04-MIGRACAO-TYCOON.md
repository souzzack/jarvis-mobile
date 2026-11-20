# 04 · Plano de migração do tycoon (Magnata do Multiverso → Guardiões do Multiverso)

> **Princípio:** nada é apagado. O código do tycoon vive **só no place do Roblox (v20)** e não está neste repositório. Por isso a migração começa com uma auditoria **dentro do Studio** (seção 6). Este plano não presume o conteúdo exato daqueles scripts.

## 1. Regras da migração

1. **Backup antes de tudo:**
   - File → Save to File: guardar `Magnata-v20-ANTES-RPG.rbxl` fora do Roblox;
   - publicar uma **cópia** do place (não o original) para os testes do RPG.
2. **Coexistência por namespace.**
   - O tycoon usa `ReplicatedStorage.Magnata`.
   - O RPG usa `ReplicatedStorage.Guardioes`, `ServerScriptService.Guardioes` e `StarterPlayerScripts.Guardioes`.
   - Nenhum script novo lê ou escreve dentro de `Magnata`.
3. **Desligar sem apagar.**
   - Quando um sistema antigo sair do núcleo, o script recebe `Disabled = true` (ou vai para `ServerStorage.Magnata_Arquivo`) com uma nota de data.
   - Ele nunca é deletado.
4. **Uma mudança por vez**, cada uma com um ponto de restauração (um arquivo `.rbxl` salvo antes de começar).
5. **Mapas e modelos aprovados não mudam.** Isso vale para a Ilha das Tempestades, a Oficina, o cristal, as construções e o Campo das Bolhas.

## 2. Destino de cada sistema

| Sistema do tycoon | Destino no RPG | Quando | Como, sem destruir |
|---|---|---|---|
| Terrenos 1–6 | Parcelas da **Base pessoal** | Etapa H | O `PersonalBaseSystem` lê os mesmos marcadores de terreno; eles ganham o atributo `GuardioesParcela`. |
| Galpão de zinco | Construção inicial da base (oficina básica) | H | O modelo continua igual. Só recebe a função de estação de fabricação de nível 1. |
| Funcionários 3D (faísca de macacão, geleia rosa, robô de latão) | Criaturas pacíficas e NPCs da base | H | Os modelos são reaproveitados. A lógica de "gerar dinheiro" é desligada, e eles passam a usar animações de trabalho. |
| Esteira de mina com carrinho | Decoração e mina da base | H | A esteira continua como animação. A renda passiva sai. |
| Economia (moedas e upgrades de renda) | **Congelada.** As moedas viram moeda de comércio. | D | O saldo antigo migra 1:1 para `moedas`. Os upgrades de renda viram um **título de veterano** e materiais iniciais, e ninguém perde o valor que já tinha. |
| Dados do jogador | `PlayerDataSystem`, esquema v2 | D | A migração é versionada (seção 3). |
| `MagnataHUD` | Coexiste com o HUD do RPG | C → D | Uma chave `Guardioes.HudAtivo` decide qual HUD aparece. Durante os testes, os dois podem ficar ligados. |
| Portal e viagem entre ilhas | `DimensionSystem` | G | O portal visual é o mesmo; muda só a regra de quem pode passar. |

## 3. Dados do jogador: v1 → v2

O formato exato da v1 **precisa ser lido no Studio** (seção 6). O esquema v2 planejado é este:

```
v2 = {
  versao = 2,
  moedas, nivel, xp, atributos, maestria = { [arma] = n }, afinidade = { [dimensao] = n },
  itens = { [guid] = { id, raridade, nivelItem, melhoria, ... } }, materiais = { [id] = qtd },
  equipado, base = { parcela, nivel, construcoes }, restauracoes, descobertas, companhia,
  legadoMagnata = <cópia íntegra da v1>,     -- nunca apagado
  migradoEm = os.time(),
}
```

- **Quando migra:** na primeira carga de um perfil v1, dentro do `UpdateAsync` com a trava de sessão.
- **Como migra:** a função `migrarV1paraV2` é pura, e por isso pode ser testada fora do Studio com perfis de exemplo.
- **Ida e volta:**
  - um perfil já na v2 nunca volta à v1;
  - o campo `legadoMagnata` permite reverter manualmente se algo der errado.
- **Onde fica o perfil novo:** numa **DataStore nova** (`Guardioes_Perfis_v2`). A DataStore antiga fica só para leitura. Assim um erro do RPG não corrompe o save do tycoon.

## 4. Ordem das etapas

| Etapa | Entrega | Ponto de restauração |
|---|---|---|
| C (atual) | Protótipo de combate isolado (arena de teste) | `.rbxl` antes de sincronizar o Rojo |
| D | PlayerData v2 + migração, Progression, Inventory | `.rbxl` + cópia da DataStore de teste |
| E | Loot e o primeiro miniboss | `.rbxl` |
| F | Fabricação (a Oficina ganha função) | `.rbxl` |
| G | Missões e viagem entre dimensões | `.rbxl` |
| H | Restauração e base pessoal (terrenos, galpão e funcionários migram aqui) | `.rbxl` |
| I | Companhias e segredos (???) | `.rbxl` |

## 5. Critério para desligar o tycoon

O tycoon só sai do núcleo quando todas as condições abaixo forem atendidas:

- **Migração:** a migração de dados passou nos testes com pelo menos 3 perfis reais copiados para a DataStore de teste;
- **Base pessoal:** existe e cobre os terrenos;
- **HUD:** o HUD do RPG cobre tudo o que o `MagnataHUD` mostrava (moedas, por exemplo);
- **Autorização:** você aprovou.

Mesmo depois disso, os scripts antigos ficam em `ServerStorage.Magnata_Arquivo`.

## 6. Auditoria no Studio (feita em 2026-11-19, na cópia "11202026_2", placeId 115368067307260)

- [x] **Scripts do tycoon** (47 no total, todos dentro do namespace `Magnata`):
  - `ServerScriptService.Magnata`: `Main` (Script) + 17 módulos em `Servicos` (Log, Rede, Dados, Progresso, Economia, Mineracao, Equipamentos, Habilidades, Ajudantes, Galpao, Portais, Bolhas, Eventos, Renascimento, Ranking, Monetizacao, Teste).
  - `StarterPlayerScripts.Magnata`: LocalScript + 9 módulos (Cientistas, Animacoes, Som, Estado, Coletor, Ajudantes, Mundo, Efeitos, UI).
  - `ReplicatedStorage.Magnata`: Config (12 módulos), Voxel, Stats, Modelos, Ativos, Assets, Remotes.
- [x] **DataStores do tycoon:** `MagnataDados_v1` (perfil, com trava de sessão em `UpdateAsync`, chave `j_<UserId>`) e `Ranking_<categoria>` (OrderedDataStore: dinheiro, renascimentos, secretos, colecao, progresso).
  - Formato v1 (ver `Dados.padrao()` no place): `{ versao=1, moedas, totalGanho, nivel, xp, pontos, equip={Coletor,Mochila,Botas,Escudo,Radar,Capturador}, inventario, habilidades, mundos, renascimentos, fragmentos, galpao, pets, petsEquipados, proxPet, colecao, secretos, especiesVistas, passes, boostAte, config, recibos, ultimaVez, criadoEm }`, gravado como `{ dados = <v1>, trava = { job, tempo }, salvoEm }`.
- [x] **Remotos do tycoon:** `Magnata.Remotes.Pedido` (RemoteFunction única, ações registradas com limite de frequência por ação e `pcall`; o cliente só manda a intenção, nunca valores) + 8 RemoteEvents só servidor → cliente (Estado, Extraido, Notificar, Anuncio, Golpe, Efeito, Chocou, Resumo). Nenhum `OnServerEvent`. A ação `Teste` só é registrada com `RunService:IsStudio()`.
- [x] **Nomes iguais aos do RPG:** nenhum (`Remotos`, `GuardioesInimigos`, `GuardioesParcelas` não existem no tycoon).
- [x] **Health:** nenhum script do tycoon mexe em `Humanoid.Health`.
- [x] **Velocidade — CONFLITO, corrigido:** `Progresso.aplicarPersonagem` reaplicava `WalkSpeed`/`JumpPower` das botas a cada alteração de dados (a renda passiva gera uma por segundo), o que derrubava a velocidade da montaria. Agora o `MountSystem` marca o personagem com o atributo `GuardioesMontado` e o tycoon não mexe na velocidade enquanto ele existir (testado: 40 se manteve com a renda rodando).
- [x] **Teleporte:** o tycoon teleporta pelos portais (`Portais.teleportar`) e na queda nas Bolhas. Por isso `VALIDAR_A_PE` no `MovementSystem` continua `false`.
- [x] **HUD:** criada a chave `HudAtivo` (atributo em `ReplicatedStorage.Guardioes`: `"Ambos"` padrão, `"Magnata"` ou `"Guardioes"`). Em `"Ambos"`, o `MagnataHUD` desce o painel de dinheiro para baixo da barra de botões e põe o menu em linha embaixo; medido no Play: 0 sobreposições.
- [x] **Lixo encontrado:** uma cópia do plugin do Rojo estava solta em `workspace.Rojo` (160 objetos replicados a todos). Movida, sem apagar, para `ServerStorage.Arquivo_NaoUsado`.
- [ ] Backup `.rbxl` (File → Save to File): a ferramenta do Studio usada nesta auditoria não salva em arquivo; fazer à mão.

> As mudanças nos scripts do tycoon (Progresso e UI) existem **só no place** (o tycoon não está neste repositório). Iluminação por zona (`Mundo.ambiente`) e câmera nas descobertas (`Animacoes`) continuam do tycoon; não conflitam hoje, mas entram na revisão quando o RPG tiver iluminação própria.

## 7. Atualização (base pessoal escrita, sem o Studio)

O `PersonalBaseSystem` já procura parcelas em `workspace.GuardioesParcelas` (Parts com o atributo `GuardioesParcela` = número).

**Para ligar os terrenos do tycoon:**
1. Fazer o backup `.rbxl`.
2. Mover (ou referenciar) as Parts de chão dos terrenos 1 a 6 para essa pasta e dar a cada uma o atributo.
3. Nenhum script do tycoon precisa ser apagado. A base nova constrói os espaços dela por cima da parcela, num Model separado (`Base_<UserId>`).

**Pendências:**
- Conferir no Studio se algum script do tycoon também constrói por cima do terreno. Se construir, desligar (não apagar) só aquela parte, como manda a seção 1.
- Reaproveitar o galpão e os funcionários como visual da base.
