# Guardiões do Multiverso: auditoria e inventário (Etapa A)

**Data:** 19/11/2026.
**Ponto de restauração:** commit `8adae7a`, que contém o projeto inteiro antes da reformulação, incluindo o Campo das Bolhas em andamento.

**Área de trabalho isolada:** `jogo-roblox/guardioes/`. Nenhum arquivo fora dela foi alterado por esta reformulação.

> **Sobre a branch.** O pedido diz "nova branch ou área de trabalho isolada". Esta sessão só tem permissão de enviar para `claude/intelligent-cerf-lfd2d7`. Por isso a reformulação mora numa **pasta própria** nessa mesma branch, e o histórico do git funciona como backup versionado.
>
> Se você quiser uma branch separada (por exemplo `guardioes/reformulacao`), basta autorizar que eu crio e envio.

---

## 1. Onde está cada coisa

O jogo existe em **dois lugares**, e só um deles está neste repositório.

| Lugar | O que tem | Acesso nesta sessão |
|---|---|---|
| **Place do Roblox (versão 20)** | O tycoon que roda: 6 terrenos de jogador, galpões, funcionários 3D, esteira com carrinho, economia, dados do jogador, HUD | **Nenhum.** O Studio não está disponível. O que sei vem do registro em `DIRECAO-ARTISTICA.md`, seção 0 (sessão do Studio de 15/11). |
| **Repositório** (`jogo-roblox/`) | Arte, mapas no visualizador web, modelos exportados, rascunhos Luau, documentos | Completo (154 arquivos, sem contar os backups). |

**Consequência prática.** Os sistemas de tycoon **não podem ser auditados nem migrados daqui**. Não há nenhum script de economia, dados, galpão ou HUD no repositório. O plano de migração (`04-MIGRACAO-TYCOON.md`) trata isso como pendência de Studio e descreve exatamente o que verificar lá.

## 2. Inventário do repositório

### 2.1 Arte e modelos (preservar integralmente)

| Item | Caminho | Estado | Reaproveitamento no RPG |
|---|---|---|---|
| **Ilha das Tempestades** (mapa completo, piloto) | `dimensoes/StormIsland/` + `dimensoes/nucleo/` + `visualizador.html` | Ciclo Mapa V1 fechado: 93 verdes, 0 amarelos, 0 vermelhos; 24 de 24 rotas | **Base da dimensão de lançamento.** Exporta GLB por categoria (botão "Baixar pacote"). |
| Oficina dos Inventores V2.3.5 | `dimensoes/StormIsland/Architecture/oficina.js` | **Congelada** (aprovada) | Estação de fabricação e melhorias da dimensão (Restauração). |
| Torre Meteorológica | `Architecture/torre.js` | Concluída | "Torre de energia": desbloqueio de mecanismos e arena do Guardião da Tormenta (proposta). |
| Caverna do Trovão + mina + bobina antiga | `Architecture/caverna.js` | Refeita no Mapa V1 | Mina, masmorra curta e segredo (bobina = equipamento secreto). |
| Observatório Abandonado | `Architecture/observatorio.js` | Refeito no Mapa V1 | Investigação, missões e o puzzle do telescópio. |
| Santuário da Tempestade (Sete Estrelas) | `Architecture/observatorio.js` | Refeito no Mapa V1 | Altar: habilidades e afinidade dimensional; ligado ao mistério da Fratura. |
| Vila, praça do Coletor, barracas, casas | `Architecture/vila.js` | Refeito no Mapa V1 | Vila: NPCs, comerciantes e quadro de missões. |
| Doca de chegada e portal | `Props/props.js` | Refeito no Mapa V1 | Portal entre dimensões e ponto de retorno. |
| Ponte, plataformas, mirante, ruínas, torres de transmissão | `pontes.js`, `props.js` | Refeitos no Mapa V1 | Acessos que podem começar quebrados (Restauração) e territórios de criaturas. |
| Ajudante **Axolote Nebular** (V7 a V12) | `pilotos/`, `exportacao/axolote-nebular-v12.glb`, `AXOLOTE-NEBULAR-V*.md` | Concluído | Criatura pacífica e companheiro; a Contemplação Celestial vira gatilho de segredo. |
| Fragmento Celestial (referência) | `referencias/fragmento-celestial.png` | Arte de referência | Visual natural para os **fragmentos do Coração do Atlas** da nova premissa. |
| Símbolo das Sete Estrelas | `simbolos/sete-estrelas.svg`, `luau-rascunho/SeteEstrelas.lua` | Concluído | Símbolo do Atlas e das seis dimensões no mistério da Fratura. |
| **Campo das Bolhas** (em andamento) | `dimensoes/Campo_das_Bolhas/` (58 MB) | Planta, terreno e Portal prontos; Gerador e Casas só em script. **Congelado** por esta reformulação. | Expansão posterior. **Não alterado.** |
| Folhas de validação e antes/depois | `referencias/*.jpg` | — | Documentação. |
| Backups do mapa (v2 a v2.3.5) | `dimensoes/v2*-backup/` | — | Manter. |

### 2.2 Código Luau existente (todos rascunhos, nenhum testado no Studio)

| Arquivo | Função | Avaliação para o RPG |
|---|---|---|
| `luau-rascunho/SeteEstrelas.lua` | Dados do símbolo (posições, cores por mundo) | **Reaproveitar direto.** Vira dado do `SecretDiscoverySystem`. |
| `luau-rascunho/DescobertasServico.lua` | Registro de descoberta validado no servidor (lista permitida, posição medida pelo servidor, sem duplicar, limite de pedidos) | **Reaproveitar o padrão.** É a semente do `SecretDiscoverySystem`; o modelo de segurança dele foi adotado na arquitetura. Depende de `Dados` e `Ajudantes`, que ainda não existem aqui. |
| `luau-rascunho/ContemplacaoCliente.lua` | Gatilho cliente da Contemplação Celestial | **Reaproveitar** como um gatilho de segredo (cliente pede, servidor valida). |
| `luau-rascunho/OficinaDosInventores/*` | Preparação da oficina importada (colisores, LOD do interior, animações, faíscas) | **Reaproveitar sem mudança.** Continua sendo a camada visual; o RPG acrescenta a *função* de fabricação por cima, num módulo separado. |

Todos usam o namespace `ReplicatedStorage.Magnata`. O RPG novo usa `ReplicatedStorage.Guardioes` e **não remove** `Magnata` (veja `04-MIGRACAO-TYCOON.md`).

### 2.3 Documentos

| Documento | Situação |
|---|---|
| `DIRECAO-ARTISTICA.md` | **Continua valendo** para arte, luz, desempenho e critérios de aprovação. |
| Tabela de raridades do guia antigo (`guia-de-estilo.md`, branch `claude/fervent-wright-sq1pub`): Comum, Raro, Épico, Lendário, Secreto | **Substituída** pela hierarquia oficial de 8 raridades (Comum → ???). As cores antigas são reaproveitadas onde coincidem. |
| `dimensoes/LEIA-ME.md`, relatórios do mapa | Continuam válidos para o visualizador. |

## 3. Ferramentas disponíveis neste ambiente

| Ferramenta | Situação | Uso |
|---|---|---|
| Roblox Studio | **Indisponível** | Nada é testado nele; tudo fica marcado como "não testado no Studio". |
| Runtime Luau (Lune, luau CLI) | **Não instalado.** A compilação do Lune pelo crates.io foi **bloqueada pela política de permissões** desta sessão, e o download pelo GitHub também. | O código Luau foi escrito sem ser executado. Os testes estão prontos para rodar no Studio ou no Lune quando houver permissão (`05-PLANO-DE-TESTES-STUDIO.md`). |
| Blender 5.3 (bpy) | Disponível (instalado para o Campo das Bolhas) | Modelos e exportação FBX/glTF no futuro (armas, criaturas). |
| three.js + Chromium (visualizador) | Disponível | Mapas; exporta GLB. |
| Node 22, Python 3.13 | Disponível | Validação de JSON/configs e checagens estáticas. |

## 4. Sistemas antigos de tycoon (conhecidos só pelo registro)

| Sistema (place v20) | Destino proposto |
|---|---|
| Terrenos 1–6 + galpão de zinco | **Base pessoal**: o terreno vira a parcela da base, e o galpão vira a construção inicial. |
| Funcionários 3D (faísca de macacão, geleia rosa, robô de latão) | **Criaturas pacíficas / NPCs da base** (trabalhadores da forja e do jardim). |
| Esteira em trilho de mina com carrinho | **Mina da base** e decoração de produção; perde a geração passiva de dinheiro. |
| Economia (moedas, upgrades de renda) | **Congelada**, não apagada. As moedas viram moeda de comércio (vendedores e taxas de fabricação), e a renda passiva sai do núcleo. |
| Dados do jogador | **Migração versionada** para o `PlayerDataSystem` (esquema v1 → v2), com o perfil antigo guardado. |
| HUD (`MagnataHUD`) | Mantido até o HUD do RPG ficar pronto; os dois coexistem atrás de uma chave de configuração. |

Detalhes em `04-MIGRACAO-TYCOON.md`.
