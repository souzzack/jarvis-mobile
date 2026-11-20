# 37 · Etapa 03: validação da Oficina e plano de integração da Ilha (relatório 4, para revisão)

Data: 20/11/2026. Todos os itens foram **conferidos de novo nesta etapa**, sem confiar nos relatórios anteriores.

## 1. Estado atual (conferido de novo)

| Item | Resultado | Evidência |
|---|---|---|
| GLB exportado | **Sim** | `jogo-roblox/dimensoes/Exports/StormIsland/Workshop/STORM.ARCH.WORKSHOP.glb` |
| Tamanho | **3.703.524 bytes** | SHA-256 `b85692f263b0ff5a8f393fbd55513a514aac70b0c277c658842616c8af4b6af3` |
| Geometria válida | **Sim** | glTF 2.0; 49 malhas; 40.870 triângulos (a maior malha tem 6.568); 17 materiais; 9 texturas; nenhum vértice inválido. Caixa de 41,96 × 28,84 × 39,95 studs |
| Importado no Studio | **Sim**, pelo Importador 3D, feito por você | `Workspace.Dimensions.StormIsland.Architecture["Oficina dos Inventores"]`, na cópia "11202026_2" (placeId 115368067307260) |
| Erros na importação | Nenhuma mensagem de erro. **Quatro defeitos no resultado:** sem âncora, colisão em todas as malhas, cores lisas perdidas e giro de 180° em Y | Relatório 36, todos corrigidos |
| Oficina do tycoon | **Intacta**. Os modelos `ServerStorage.Oficina`, `Oficina2` e `Oficina3` não foram tocados | Busca no Workspace: a única "Oficina" no mapa é a importada |

## 2. Comparação visual com a V2.3.5 (`jogo-roblox/referencias/v235-oficina-12-vistas.jpg`)

As capturas são do Studio, salvas em `guardioes/docs/oficina-piloto/`, com os mesmos enquadramentos relativos ao modelo.

| Aspecto | Referência V2.3.5 | Studio | Resultado |
|---|---|---|---|
| Arquitetura | Edifício de 26 × 20, plinto, escada frontal, frontões laterais com óculo, chaminé | Igual: `07-V01-frente`, `09-V03`, `10-fundo` | ✓ |
| Proporções e escala | 1 unidade = 1 stud | 41,96 × 28,84 × 39,95, igual ao GLB. Personagem R15 de 5,99 studs; porta livre de 7,7 | ✓ |
| Telhado | Duas águas em chapa com juntas, cumeeira de cobre, calhas e condutores, 3 para-raios | Igual | ✓ |
| Portas | Porta em arco com bandeira de vidro e folhas | Igual. O vão de colisão foi corrigido para a altura do arco (relatório 36, seção 7) | ✓ |
| Janelas | Caixilhos, vidro e óculos redondos | Iguais. O vidro virou Glass com transparência 0,4 | ✓ |
| Detalhes internos | Condensador, bobinas, anéis, estantes, bancadas, gerador, manômetros, planetário | Todos presentes (`03`, `06`) | ✓ |
| Orientação | Frente para +Z local; rotação na ilha de 141,6° | Corrigida (o importador girou 180°). Erro de posição de 0,005 stud | ✓ |
| Texturas (madeira, reboco, telhado, cobre, ferro) | Mapas de cor e relevo | 28 peças com SurfaceAppearance (cor e relevo) e 5 com TextureID | ✓ |
| **Pedra do plinto e do alicerce** | Pedra cinza-escura em blocos (shader **triplanar**) | **Defeito encontrado nesta etapa:** saiu clara (`08`). Causa: o exportador troca o triplanar pela cor lisa `0x5b5e72`, gravada sem conversão de cor, e no relatório 36 eu a converti de linear para sRGB por engano. **Corrigido:** Slate `#5b5e72` (`09`) | ✓ (aproximação: Slate no lugar da textura triplanar) |
| Emissivos (luzes, núcleo, cristal, runas) | Brilham | Neon e Glass. O brilho das runas não tem equivalente | Parcial |
| Iluminação de cena | Noite de tempestade (luz roxa) | Luz diurna do tycoon, que é global e não foi alterada. Por isso o tom geral é diferente | Diferença de ambiente, não do modelo |
| Peças trocadas por blocos | — | **Nenhuma.** As 49 malhas originais estão lá; as caixas de colisão são invisíveis | ✓ |

## 3. Colisões

- **Colisores:** são 24 do manifest, com o nº 16 corrigido, mais 2 do telhado. Ficam em `…Oficina dos Inventores.Colisores`, invisíveis e ancorados.
- **Malhas:** as 49 são só visuais, sem colisão.

Testes no **Play**, com personagem R15 andando por `Humanoid:MoveTo` (coordenadas locais):

| Teste | Resultado |
|---|---|
| Chão externo, escada, patamar e porta | ✓ chegou ao patamar (z 12,7) e passou a porta (z 7,6) |
| Piso interno | ✓ altura 4,7 (sobre o plinto de 1,6) em todos os pontos |
| Corredor esquerdo (bancadas e estantes) | ✓ chegou a (−5,5; −4,4) |
| Corredor direito (gerador e painel) | ✓ chegou a (5,0; −3,9) |
| Atrás do Condensador | Bloqueado: sobram 0,9 stud até a parede do fundo. O Condensador fica encostado no fundo **no próprio projeto** |
| Paredes laterais | ✓ parou antes de atravessar (x = 10,3 e x = −8,8, nos móveis encostados) |
| Telhado (chegando de cima) | ✓ pousou sobre a chapa (relatório 36) |
| Saída | ✓ |

## 4. Organização (IMPLEMENTADO)

- **Modelo:** atributo `Id = STORM.ARCH.WORKSHOP` e tag `STORM.ARCH.WORKSHOP` (CollectionService). Também tem `IdVisualizador`, `VersaoVisualizador`, `PivoNaIlha` e `Origem`. O **nome** continua "Oficina dos Inventores", que é o nome que os scripts de rascunho procuram.
- **Peças:** as 49 foram renomeadas de `NodeNN` para `<Grupo>_<Material>` (ex.: `Telhado_ChapaTelhado`, `InteriorLOD_FerroEscovado`). O nome do importador ficou no atributo `NomeImportado`, e o material de origem nos atributos `MaterialGLB` e `NoGLB`.
- **Grupos animáveis:** intactos (`Planetario`, `Pistoes`, `EngrenagensCondensador`, `VolanteGerador`, `PonteiroManometro`, `InteriorLOD`).
- **Isolamento:** tudo dentro de `Workspace.Dimensions.StormIsland`, na área de teste em (2000, 150, 0), longe do mapa do tycoon.
- **Arquivos-fonte:** nenhum foi alterado.

## 5. Testes no Play

| Teste | Resultado |
|---|---|
| Integridade | ✓ 76 de 76 peças ancoradas e no lugar (49 malhas, 26 colisores e a âncora da luz). Os 6 grupos animáveis estão presentes |
| Colisões | ✓ (seção 3) |
| Materiais | ✓ conferidos visualmente (seção 2) |
| Escala R15 | ✓ R15 de 5,99 studs. Porta de 7,7; parede de 11; degraus de cerca de 0,6 |
| Output | ✓ nenhum erro novo. Testes: 234 passaram, 0 falharam. Só aparece o `rbxassetid://203785492`, que já existia (relatório 34) |
| **Desempenho** | **Impacto não mensurável no Studio**: 15,0 FPS olhando a Oficina, olhando para longe e olhando o tycoon. Esse é o limite do Studio sem foco. Memória de malhas: 8,1 MB. **PENDENTE:** medir com o Studio em foco ou num aparelho real |

A cópia de teste está salva na **versão 11**.

## 6. Plano técnico de integração da Ilha (PLANEJADO, nada criado)

### 6a. Valores de referência conferidos com os arquivos reais

| Item | Referência dada | Real (gerador `StormIsland/`) | Conclusão |
|---|---|---|---|
| Ilha | ~560 × 440 | Chão modelado: **600 × 504** (x −300…300, z −262…242). Os 560 × 440 do plano são a área de terra caminhável | Usar 600 × 504 como área de terreno |
| Caixa total | — | **628 × 590** (x −302…326, z −296…294), incluindo o paredão e o mirante em balanço | Cabe nos 700 × 650 reservados |
| Alturas | — | Chão de −49,5 (fenda) a **160,4** (picos). Topo da torre em **214,3**. O paredão desce até cerca de −290 | Com o centro em y = 150: mundo de cerca de −140 a 364 |
| Heightmap | — | **401 × 337 pixels, a 1,5 stud por pixel** (8 e 16 bits), mais o colormap | É a fonte do terreno |
| Spawn | — | (0, 9, 184), na doca | No mundo: (2000, 159, 184) |

O centro provisório **(2000, 150, 0)** continua compatível: fica fora do mapa atual (o terreno do place vai até cerca de ±1022) e sem sobreposição.

### 6b. Terreno

- O `Terrain.glb` **não serve como malha**: a superfície tem uma malha de **53.560 triângulos** e o paredão uma de **40.320**, acima do limite por malha do Roblox. O terreno do visualizador também usa shader triplanar, que não é exportado.
- **Proposta:** gerar Terrain do Roblox **a partir do heightmap real** com `WriteVoxels`, em blocos, por script que eu consigo rodar sem o importador. Converter 1,5 stud por pixel para voxels de 4 studs, com ocupação suave. Materiais por faixa: grama, rocha nas encostas e picos, trilha nos caminhos `P1–P6` do `plano.js` e basalto no paredão.
- **Alternativa:** o Importador de Heightmap do Studio, que é manual e precisa de você.
- **Paredão:** Terrain (Rock e Basalt) gerado pelo contorno. A malha de 40 mil triângulos só serviria dividida.

### 6c. Construções: procedimento padrão (aprendido com a Oficina)

1. Exportar o modelo isolado pelo visualizador para `Exports/StormIsland/<Nome>/`.
2. Validar o GLB com o leitor Python e no `GLTFLoader`.
3. Importar pelo Importador 3D (**manual, feito por você**), com unidade em Stud.
4. Corrigir por script:
   - girar 180° em Y e posicionar pelo pivô da ilha;
   - ancorar;
   - malhas sem colisão e colisores do manifest;
   - cores lisas a partir do GLB, com **"Rocha" em Slate `#5b5e72`** (quase todas as estruturas têm de 1 a 3 malhas triplanares);
   - Neon nos emissivos;
   - nomes `<Grupo>_<Material>`.
5. Testar no Play e tirar capturas.

**Posição na ilha:** mundo = (2000, 150, 0) + coordenada da ilha. A Oficina vai de (2000, 150, 0) para o pivô dela na ilha, **(1915,96; 165,83; 98,04)**, quando o terreno existir.

Todas as malhas das construções têm menos de 10 mil triângulos (a maior é da Torre, com 9.592), então são importáveis.

### 6d. Ordem proposta, uma estrutura por vez, cada uma com relatório

1. **Terreno pelo heightmap**, depois de aprovado. Só depois disso a Oficina vai para o pivô dela na ilha.
2. **Doca de chegada** (`STORM.ARCH.ARRIVAL`): spawn e portal de volta.
3. **Torre Meteorológica** (69 mil triângulos, 110 malhas): peça central e arena do Guardião.
4. **Vila:** praça, 5 casas, barracas, torres de transmissão e cabos.
5. Caverna, Observatório, Santuário, Ponte, Plataformas, Mirante, Ruínas, vegetação e recursos.
6. **Chefes e marcadores:** posições do `marcadores.json` e arenas nos lugares do GDD. Aí o patch `SoloDaArena`, que está guardado, volta a ser útil.

## 7. Correções feitas nesta etapa

1. **Pedra do plinto e do alicerce:** 7 peças "Rocha" passaram de `#a1a3b2` para Slate `#5b5e72`, a cor autoral. O erro de conversão era meu (relatório 36).
2. **Nomes e IDs:** as 49 peças foram renomeadas, e o modelo ganhou atributo e tag `STORM.ARCH.WORKSHOP`.

## 8. Pendências

| # | Pendência | Quem |
|---|---|---|
| 1 | FPS real, com o Studio em foco ou num aparelho | Você (rodar o teste) ou eu, numa sessão com o Studio em foco |
| 2 | Brilho das runas (não tem equivalente direto no Roblox) | Decisão de arte |
| 3 | Corrigir o colisor 16 também na fonte (`oficina.js` / manifest) | Precisa da sua autorização para mexer nos arquivos-fonte |
| 4 | O `rbxassetid://203785492` no Output | Confirmar a origem (provavelmente o plugin Rojo) |
| 5 | Aprovar o terreno da ilha (seção 6b) | Decisão |

## 9. Próxima ação proposta

**Gerar o terreno da Ilha das Tempestades** em (2000, 150, 0) a partir do heightmap real (401 × 337, a 1,5 stud por pixel), usando `WriteVoxels`. Depois, **mover a Oficina para o pivô dela na ilha** e conferir o assentamento com o chão real (o documento V2.3.5 diz que o terreno sob a planta vai de −2,47 a +0,3 local). Nenhuma outra construção até esse passo ser aprovado.
