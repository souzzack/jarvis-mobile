# Pós-processamento de um lote importado (resumo do que foi rodado em 20/11/2026)

1. `LoteIlhaDados.luau` (gerado dos GLBs e manifests do lote): nome da malha → posição final, material, cor autoral, textura, alfa, emissivo; modelos → pivô, rotY, colisores; centro de cada GLB.
2. No Studio, para cada `AuxScene` importada (identificada pelo prefixo A/P/R/V das malhas):
   - `WorldPivot = centro da caixa × giro 180°`; `PivotTo(centro da ilha (2000,150,0) + centro do GLB)`;
   - conferir cada peça pelo nome (A/P/R) ou pela posição mais próxima (V: o importador reaproveita malha e nome entre árvores da mesma forma);
   - âncora; sem colisão nas malhas; peças sem textura: Rocha → Slate #5b5e72, emissivo → Neon, demais pela cor autoral e material pelo nome;
   - cada modelo para `Dimensions/StormIsland/<Categoria>`, com `Id`, tag e a pasta `Colisores` do manifest.
3. Pisos caminháveis que não estão nos manifests (`superficies_caminhaveis.json` = `isl.walks`): retângulos, pontes (deck medido na malha), túnel e câmara da caverna (terreno escavado), praça do Coletor (perfil radial medido).
4. Terreno sob as construções: Grass → Cobblestone (sem grama decorativa atravessando pisos).
