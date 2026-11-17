# Ilha das Tempestades V2: reconstrução cinematográfica

**Fases 1 a 3 entregues:** diagnóstico, terreno e Torre Meteorológica. Estas fases **aguardam aprovação**.

Vila, floresta, caverna, observatório, ponte, recursos e atmosfera continuam na versão V1 e **não foram mexidos**, como pedido.

Validação visual: `../../referencias/ilha-tempestades-v2-validacao.jpg`. São 12 vistas renderizadas no navegador pelo próprio visualizador.

## 1. Diagnóstico da V1 (por que reconstruir)

| Problema na V1 | Resposta na V2 |
|---|---|
| Nenhuma textura: só cor por vértice. Visual "plástico liso". | Texturas PBR procedurais (`nucleo/texturas.js`) com cor, normal e rugosidade, cada uma em 512². Os conjuntos são: rocha estratificada, musgo, terra, lajes, blocos de alvenaria, metal envelhecido e cobre oxidado. Há também uma faixa de runas. |
| Paredões verticais com cor esticada | Material **triplanar** (`nucleo/triplanar.js`): a textura é projetada pelos três eixos do mundo, então penhascos mostram rocha de verdade |
| Grade de 2 studs, cones nas montanhas | Grade de 1,5 stud. A forma do relevo vem de: <br>• picos assimétricos de ruído *ridged* com domínio torcido;<br>• sulcos de erosão;<br>• degraus geológicos (estratos) e fissuras. |
| Borda da ilha = "saia" esticada da malha | Malha de penhasco separada, com 40 anéis, plataformas e sulcos. Por baixo, uma base flutuante estratificada com agulhas pendentes. |
| Sem mapa de ambiente: metais e vidros sem reflexo | Mapa de ambiente PMREM gerado do céu. Também há névoa baixa em camadas. |
| Torre = 41 primitivas | Torre V2 com cerca de 900 peças antes da mesclagem e 7 materiais próprios (ver item 3) |

## 2. Terreno (STORM.TERRAIN.*)

| Modelo | Conteúdo |
|---|---|
| `TERRAIN.MAIN` | Campo de alturas em blocos de 40 células, com LOD em 2 níveis. Pesos por vértice:<br>• rocha (pela inclinação);<br>• musgo/grama;<br>• terra;<br>• trilha;<br>• umidade (escurece e deixa brilhante perto das trilhas e poças). |
| `TERRAIN.CLIFFS` | Penhascos verticais em volta do contorno, com estratos, plataformas e sulcos |
| `TERRAIN.BASE` | Fragmento rochoso sob a ilha, com agulhas pendentes |
| `TERRAIN.EDGE` | Elementos da borda:<br>• raízes pendentes;<br>• cristais engastados;<br>• 2 cachoeiras animadas;<br>• 16 fragmentos de rocha flutuantes com musgo. |
| `TERRAIN.SURFACE` | Elementos instanciados (uma chamada de desenho por tipo):<br>• cerca de 5 000 tufos de grama irregular;<br>• cerca de 2 000 seixos, concentrados perto das trilhas (desgaste);<br>• afloramentos fraturados (6 formas);<br>• poças nas trilhas planas;<br>• depósitos de cristal nas encostas altas. |

## 3. Torre Meteorológica V2 (STORM.ARCH.TOWER)

Altura de cerca de 177 studs sobre a colina, contando até a ponta do para-raios. De baixo para cima:

1. **Base octogonal.** É feita de pedra em fiadas (triplanar com blocos):
   - plintos e painéis rebaixados;
   - contrafortes com condutor de cobre e estaca de aterramento;
   - faixa de runas com brilho fraco.
2. **Escadaria monumental.** Os degraus descem até tocarem o terreno, cada um sobre uma fundação maciça (sem degrau flutuando). A escadaria leva a um portal com:
   - arco de aduelas;
   - cristal na chave do arco;
   - porta dupla de madeira com cintas e rebites, entreaberta.
3. **Fuste.** Tem:
   - cornijas com mísulas;
   - 12 janelas em arco com vidro reforçado;
   - escada em espiral externa com 48 degraus e corrimão.
4. **Galeria de instrumentos** (y ≈ 62). Contém:
   - guarda-corpo;
   - barômetro com mostrador;
   - pluviômetro;
   - 3 antenas.
5. **Casa de máquinas.** Tem 3 conjuntos de engrenagens à mostra (animadas) e tubulação de cobre.
6. **Treliça de vigas I.** Tem:
   - contraventamento em X e chapas;
   - passarela;
   - **núcleo de energia**: coluna de cristal com hélice luminosa;
   - 3 bobinas de cobre, onde surgem os arcos elétricos com efeitos ligados.
7. **Plataforma de antenas.** Tem:
   - 2 pratos;
   - **cúpula de cobre oxidado** com nervuras e escotilhas;
   - lanterna;
   - anemômetro e cata-vento animados.
8. **Captador de tempestades.** É formado por:
   - mastro com anéis;
   - **3 anéis em cardã** com faixa de runas e nós de cobre (giram devagar com efeitos desligados e mais rápido na tempestade);
   - **cristal atmosférico** com núcleo;
   - 5 agulhas condutoras;
   - para-raios.
9. **4 condutores de cobre** descem do captador até o chão. Com efeitos ligados, pulsos de energia correm por eles.

### Materiais da torre (para recriar no Roblox)

| Material (nome no GLB) | Roblox sugerido |
|---|---|
| PedraTorre / PedraEntalhada | MaterialVariant de Brick/Slate com as texturas `blocos`/`rocha` exportadas em PNG |
| MetalEnvelhecido / MetalEscuroTorre | MaterialVariant de Metal (`metal`), Roughness alto |
| CobreOxidado / CondutorCobre | MaterialVariant de CorrodedMetal (`cobre`). O pulso vira **Beam** com textura animada entre Attachments. |
| VidroReforcado | Glass, Transparency 0,4 |
| CristalAtmosferico / NucleoEnergia | Glass e Neon. O Neon fica limitado aos núcleos, respeitando a regra de no máximo 10% de energia. |
| FaixaDeRunas | SurfaceAppearance com mapa de cor e emissivo, ou Decal |

### Peças animadas (modelos separados, não mesclados)

`CaptadorDeTempestades` (os 3 anéis), `Engrenagens0..2`, `Anemometro`, `CataVento`, `Condutor0..3` (pulso).

No Roblox, o giro é feito com TweenService ou HingeConstraint em script **cliente**.

## 4. O que NÃO se transfere automaticamente para o Roblox

- **Shaders triplanares, o pulso dos condutores e a cachoeira** são GLSL do navegador. No Roblox:
  - o triplanar é substituído por MaterialVariant (o Terrain do Roblox já projeta triplanar);
  - o pulso é refeito com Beam;
  - a cachoeira usa ParticleEmitter ou Beam com textura rolando.
- O **mapa de ambiente, a névoa em sprites e o bloom** viram Atmosphere, Clouds e Bloom do Lighting. A aparência será parecida, não idêntica.
- As **texturas procedurais** precisam ser exportadas em PNG e enviadas como imagens.
- **Nada disto foi testado no Roblox Studio.** O pacote de exportação (GLB por pasta, heightmaps de 8 e 16 bits e marcadores) continua disponível no visualizador.

## 5. Números atuais (render no navegador, com tudo ligado)

- Cerca de 1,2 a 1,4 milhão de triângulos por quadro, contando o passe de sombra.
- 550 a 930 chamadas de desenho, conforme a vista.
- No navegador de teste (CPU, sem GPU) roda a cerca de 20 fps. A otimização está prevista para a fase 9.

## 6. Próximas fases (só após aprovação)

4. Vila
5. Floresta
6. Caverna
7. Observatório e ponte
8. Recursos e atmosfera
9. Otimização
10. Validação final
