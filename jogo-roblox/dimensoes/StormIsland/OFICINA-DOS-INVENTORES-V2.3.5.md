# Oficina dos Inventores V2.3.5: integração, acabamento e desempenho

A oficina não foi reconstruída. A posição global continua a mesma: pivô (-84,04; 15,83; 98,04), rotação Y de 141,6°, escala 1. Nenhuma outra estrutura foi alterada.

- **Ponto de restauração:** `../v234-backup/`, com o estado exato da V2.3.4.
- **Imagens** (render do visualizador three.js, não do Roblox):
  - `../../referencias/v235-oficina-12-vistas.jpg`: as 12 vistas pedidas, mais a vista cinematográfica de perto do Condensador (V12b) e a planta com os colisores (V13).
  - `../../referencias/v235-oficina-antes-depois.jpg`: V2.3.4 em cima e V2.3.5 embaixo, com a mesma câmera. Mostra a fundação, a oficina na vila e a vista de cima.
- **Nada foi testado no Roblox Studio.** Os scripts Luau em `../../luau-rascunho/OficinaDosInventores/` são rascunhos.

## 1. Diagnóstico técnico (antes de mudar)

| Item | Resultado |
|---|---|
| Malhas | 44, nenhuma escondida ou instanciada |
| Colisores | 24 |
| Terreno sob a planta | de -2,47 a +0,3 local, abaixo do piso (1,8). Nada enterrado. O alicerce desce até o chão real. |
| Pé da escada | (-72,9; 84), 4,4 studs dentro do caminho P2. Está ligado à rede: dos 12 studs de largura do caminho, 7,6 continuam livres. Mantido. |
| Custo da oficina (vista Vila) | 64 chamadas, 53 mil triângulos |
| Circulação interna | 3 falhas, mas eram pontos de teste mal escolhidos (raspavam quinas). A passagem do depósito tinha só 0,1 stud de folga. |

**O peso da cena não está na oficina.** Em todas as vistas, a vegetação instanciada desenha 641.871 triângulos, porque o three.js r128 não descarta instâncias fora da câmera.

| Modelo | Triângulos |
|---|---|
| TERRAIN.SURFACE | 485 mil |
| TERRAIN.MAIN | 171 mil |
| VEG.UNDERGROWTH | 163 mil |
| TOWER | 69 mil |
| CLIFFS | 40 mil |
| WORKSHOP | 36 mil |

## 2. Melhorias propostas

| # | Melhoria | Situação |
|---|---|---|
| 1 | Interior com nível de detalhe: some acima de 125 studs e volta abaixo de 110 (histerese) | feito |
| 2 | Placa, papéis e manômetros num único atlas de canvas (3 texturas → 1, 3 materiais → 1) | feito |
| 3 | Integração com o terreno: 8 rochas, cascalho sob o beiral, 9 moitas baixas. Nada na escada nem nos caminhos. | feito |
| 4 | Telhado azul-escuro menos espelhado (rugosidade 0,88, reflexo 0,5) | feito |
| 5 | Janelas um pouco mais quentes (emissão 0,25 → 0,45) | feito |
| 6 | Caixotes do depósito 1 stud para a esquerda, para abrir a passagem | feito |
| 7 | Tabela de colisores gerada do visualizador, mais scripts Luau de preparação e animação | feito (rascunho) |
| 8 | Recorte da vegetação por blocos e distância. Estimativa: Vila 641 mil → 277 mil triângulos; Três quartos → 0; Jogador → 89 mil. | **proposto, aguarda autorização** (fora do escopo da oficina) |

Os detalhes do Condensador, as engrenagens, os anéis e as bobinas não foram simplificados.

## 3. Arquivos modificados

- `Architecture/oficina.js`:
  - grupo `InteriorLOD`;
  - atlas `OficinaAtlas`;
  - nova função `I.workshopIntegrate`;
  - telhado, vidro e caixotes.
- `Architecture/vila.js`: chama a integração e funde o interior num bloco próprio.
- `nucleo/visualizador.js`:
  - na exportação, o interior sai sempre visível;
  - novas câmeras "Bancadas" e "Fundação".
- Novos rascunhos Luau (`--!strict`) em `jogo-roblox/luau-rascunho/OficinaDosInventores/`:
  - `OficinaConfig.lua`
  - `OficinaColisores.lua`
  - `OficinaServidor.server.lua`
  - `OficinaCliente.client.lua`
  - `LEIA-ME.md`

## 4. Resumo das mudanças

- **Terreno.** A base agora assenta com rochas nos cantos, cascalho no pingo do beiral e moitas baixas junto às paredes. Todas as peças pousam no ponto mais baixo do chão sob elas. A escada e o caminho ficaram livres.
- **Acabamento.** O telhado parou de refletir o céu como espelho e as janelas brilham mais quentes. O resto foi preservado: metal azul-escuro, pedra, madeira, cobre, Condensador e o contraste quente/frio.
- **Desempenho.**
  - De longe, o interior inteiro deixa de ser desenhado.
  - De perto, ele é um bloco fundido por material.
  - As três texturas pequenas viraram uma.

## 5. Comparação de desempenho

Medido no navegador sem placa de vídeo (swiftshader), com os efeitos desligados e as mesmas câmeras. **O FPS daqui não é comparável** com os 47 FPS da sua captura, que é de outro aparelho e de outra vista. Os números de chamadas e triângulos são comparáveis.

**Só a oficina:**

| Situação | V2.3.4 | V2.3.5 |
|---|---|---|
| Longe | 64 chamadas, 53 mil triângulos | **46 chamadas, 30 mil triângulos** |
| Perto ou dentro | 60–64 chamadas, 52–53 mil triângulos | 66–70 chamadas, 54–55 mil triângulos |

De perto o custo subiu um pouco (+6 chamadas, +2 mil triângulos), por causa das rochas, das moitas e do bloco separado do interior.

**Cena inteira:**

| Vista | V2.3.4 | V2.3.5 |
|---|---|---|
| Três quartos | 946 / 1.379.029 | 928 / 1.355.771 |
| Vila | 765 / 1.562.309 | 747 / 1.539.051 |
| Torre | 666 / 1.503.353 | 667 / 1.500.221 |
| Aérea | 962 / 1.381.109 | 944 / 1.357.851 |
| Nível do jogador | 602 / 1.469.363 | 603 / 1.466.231 |

O grande ganho possível para a cena é o item 8 (vegetação), que depende da sua autorização.

## 6. Validação

- **Diagnóstico Estrutural:**
  - 88 verdes, 5 amarelos e 0 vermelhos;
  - os amarelos já existiam: ponte, árvores 25, 27 e 48, ruínas;
  - 0 interseções e 0 instâncias de vegetação dentro de estruturas.
- **Rotas:** 24 de 24 rotas da ilha passam.
- **Circulação interna:** 6 de 6, com o boneco de 5,2 studs e passo de 2,6. Percurso: porta → Condensador, bancadas, laboratório, depósito, canto do NPC e volta.
- **Exportação:** `Architecture.glb` traz a oficina com 49 malhas e 40.870 triângulos, sem erros de página.

## 7. Pendências que precisam do Roblox Studio

1. Importar `Architecture.glb` e conferir o caminho `Dimensions/StormIsland/Architecture/Oficina dos Inventores`, além dos nomes dos grupos animados e do `InteriorLOD`. O importador pode renomear nós.
2. Rodar `OficinaServidor`: os 24 colisores devem coincidir com as paredes, as bancadas e a escada.
3. Andar com um personagem real pela porta, pelos degraus e pelo depósito.
4. Conferir se o atlas (placa, papéis, manômetros) veio com as coordenadas de textura corretas.
5. Medir o FPS num aparelho real: celular e PC, de longe e de dentro.
6. Ver o nível de detalhe do interior (`LocalTransparencyModifier`) e as faíscas com `workspace:SetAttribute("TempestadeAtiva", true)`.
