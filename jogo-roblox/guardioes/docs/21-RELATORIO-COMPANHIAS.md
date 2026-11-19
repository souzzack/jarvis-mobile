# 21 · Relatório: Companhias (sem o Studio)

Data: 19/11/2026. **Nada foi executado** no Studio nem em runtime Luau.

Companhias são as **guildas de jogadores** (GDD, seção 10). Não confundir com os **companheiros** (as criaturas do `CompanionSystem`).

## O que foi feito

| Área | Entrega |
|---|---|
| Criar | Nome de 3 a 20 letras, conferido também pelo filtro de texto do Roblox (`TextService`). Emblema montado **só com peças pré-aprovadas** (4 formas, 6 cores, 6 símbolos), sem upload de imagem. Nome único: uma chave por nome, reservada antes de criar |
| Convites | Só Líder e Oficial convidam, e só quem está no mesmo servidor. O convite expira em 24 h. Quem entra vira **Recruta**. Limite de 30 membros |
| Cargos | **Líder > Oficial > Membro > Recruta**. Só o líder muda cargos. Só se expulsa quem tem cargo abaixo |
| Cofre | Lotes guardados por depositante. **Recruta** só deposita. **Membro** retira só lotes "livres", até 20 por dia. **Oficial** retira tudo menos os lotes "travados", até 50 por dia. **Líder** retira sem limite e marca lotes como livre, travado ou normal |
| Nada é confiscado | Quem sai ou é expulso recebe de volta **o que depositou** e ainda está no cofre |
| Liderança | Transferência leva **48 h** e pode ser cancelada. O antigo líder vira Oficial |
| Dissolução | **Duas confirmações** e depois **72 h** (dá para cancelar). Cada pessoa recebe de volta o que depositou; o nome fica livre |
| Registro | As últimas 200 ações; o painel mostra 20 |
| Nível | XP quando membros derrotam chefes ou minibosses (120 por membro que contribuiu). O nível é só conveniência e cosmética, **nunca poder de combate** (GDD) |
| Painel | Tecla **U** ou aba. Sem companhia: criar e convites. Com companhia: membros, cofre, depositar, registro, transferência e dissolução. Cada botão só aparece para quem tem o cargo; o servidor confere de novo |

## Como os dados ficam seguros

- **Onde ficam os dados.** Cada companhia é uma chave numa store própria (`Guardioes_Companhias_v1`). O perfil do jogador guarda só o id (`perfil.companhia`).
- **Como uma mudança é gravada.** Toda mudança é **um `UpdateAsync`** que aplica a regra pura numa cópia. Isso a torna atômica por companhia, mesmo com vários servidores. Os prazos (48 h, 72 h) são aplicados em toda gravação e num ciclo de 60 s.
- **Sem transação entre chaves.** O DataStore do Roblox não tem transação entre o perfil e a companhia, então cada passo tem uma compensação:
  - **Depositar:** tira da parte **salva** do perfil (`InventorySystem.retirarSalvo`; concessões de teste nunca entram). Depois grava no cofre. Se o cofre falhar, devolve.
  - **Retirar:** tira do cofre e entrega na bolsa. O que não couber vai para uma **chave de devolução** (`dev_<userId>`), entregue depois.
  - **Sair, expulsão e dissolução:** os itens vão para `aDevolver` **na mesma gravação** que os tirou do cofre. Depois passam para a chave de devolução da pessoa, entregue quando ela estiver online.
  - **Pior caso**, se o servidor cair entre duas gravações: um item devolvido **duas vezes**, nunca perdido.
- **Vínculo no perfil.** A companhia é a fonte da verdade. Ao entrar, se a pessoa não é mais membro (expulsa offline ou dissolvida), `perfil.companhia` é limpo.
- **Uma ação por vez.** Cada jogador faz uma ação por vez, além do limite de taxa. Isso impede depósito e retirada cruzados.
- **Sem acesso a DataStore.** Tudo fica em memória, com aviso.

## Arquivos criados

| Arquivo | Conteúdo |
|---|---|
| `src/ReplicatedStorage/Guardioes/Companhias/Companhia.luau` | Regras em lógica pura |
| `src/ServerScriptService/Guardioes/Sistemas/CompanySystem.luau` | Gravação, rede, inventário, XP |
| `src/StarterPlayer/StarterPlayerScripts/Guardioes/Controladores/JanelaDaCompanhia.luau` | Painel (U) |
| `tests/Specs/Companhia.spec.luau` | 12 casos |

**Arquivos existentes com acréscimos:**
- **Dados:** `Dados/Perfil` (campo `companhia` e validação), `ConfigServidor` (`companhias`).
- **Sistemas:** `InventorySystem` (`retirarSalvo`).
- **Rede e textos:** `Remotos` (Companhia e EventoCompanhia), `Mensagens` (motivos).
- **Carga:** `Main.server`, `Main.client`.
- **Testes e docs:** executores de teste, doc 10 (seção 14), README.

**Fora de `jogo-roblox/guardioes/`:** nada. O Campo das Bolhas, a Ilha das Tempestades e a oficina original não foram tocados.

## Verificado aqui

- Equilíbrio de blocos nos 147 arquivos: 0 problemas.
- `require`, `ctx.obter` e nomes de RemoteEvent conferidos.
- Os 12 casos novos foram conferidos à mão contra o módulo. Exemplos:
  - o Membro tira 15 + 5 e depois recebe "limite diário";
  - a dissolução devolve 4 + 1 a um membro e 6 ao outro.

O Lune continua bloqueado pelo ambiente, então os testes **não rodaram**.

## Riscos e limites conhecidos

- **Mudanças entre servidores** chegam em até 60 s, pelo ciclo. Se for preciso tempo real, o próximo passo é o MessagingService.
- **Convites** só valem para jogadores no mesmo servidor.
- **Objetivos semanais cooperativos** ainda não existem. O nível usa só os chefes.
- **Prazos de 48 h e 72 h no Studio:** para testar, reduza-os numa **cópia** (roteiros K14 e K16).

## Pendente

- SecretDiscoverySystem (???).
- Portais entre places.
- Relíquia.
- Objetivos semanais das companhias.
- Bancada e Depósito da base.
- Roteiros K1 a K20 no Studio.
