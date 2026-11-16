# Axolote Nebular v11: reconstrução técnica e polimento

Prévia: `jogo-roblox/pilotos/axolote-nebular-v11.html`
Cópia funcional preservada: a v10 (`axolote-nebular-v10.html`) não foi alterada.
Exportação: `jogo-roblox/exportacao/axolote-nebular-v11.glb` (gerado pela própria página, botão **Exportar GLB**; dentro do visualizador de artifacts o arquivo sai num `.zip`, porque `.glb` não está na lista de downloads permitidos).

> A gravação citada no pedido **não chegou a este ambiente**. Os únicos vídeos da sessão são os quatro clipes de referência do início. Por isso, a auditoria foi feita gravando a própria prévia v10: um quadro a cada ~0,4 s, passando por todos os estados.

---

## 1. Arquivos

| Arquivo | O que faz | Mudou na v11? |
|---|---|---|
| `pilotos/axolote-nebular-v11.html` | Tudo do personagem: escultura (SDF + surface nets), rig (20 ossos), materiais (shader nebular), controlador, efeitos, câmera, testes ao vivo e exportação | **Novo** (a partir da v10) |
| `exportacao/axolote-nebular-v11.glb` | Modelo com rig e animações para levar ao Blender ou Roblox Studio | **Novo** |
| `AXOLOTE-NEBULAR-V11.md` | Este documento | **Novo** |
| `referencias/axolote-v11-validacao.png`, `referencias/axolote-v11-glb.png` | Imagens de validação | **Novos** |
| `luau-rascunho/*.lua` | Rascunhos de Contemplação e Descobertas (servidor valida) | Sem mudança (continuam **não testados**) |

## 2. Auditoria: o que a gravação da v10 mostrou

### Confirmado
| Problema | Evidência | Causa |
|---|---|---|
| **Câmera "respirando"** (zoom entra e sai sozinho) | Na gravação, a distância muda até ~2× entre quadros vizinhos (ex.: quadros 37→38 e 43→44) | O zoom era recalculado a cada quadro a partir da **pose animada** (cauda, brânquias, subida, giro). A câmera era guiada pelas transformações do personagem |
| Recuo brusco da câmera na Contemplação | Personagem pequeno e depois grande de novo | A margem das Sete Estrelas entrava e saía do cálculo de uma vez |
| Partículas grandes ao passar perto da lente | Código: o tamanho do ponto cresce com `1/distância`, sem limite | Sem limite de tamanho nem desvanecimento perto da câmera |
| Controlador sem entrada/saída por estado | Lógica em blocos `if(estado)`; a limpeza da Contemplação e do Despertar ficava fora, em `onLeave` da prévia | Organização |

### Verificado e descartado
- **Duas animações na mesma articulação:** cada articulação tem um único ponto de escrita no código (coluna, peito, pescoço, cabeça, 5 da cauda, 8 dos membros, 4 pálpebras, 6 brânquias, 2 anéis, raiz). Agora há também um contador ao vivo.
- **Transformações acumulativas:** todas as rotações são definidas a partir da pose-base a cada quadro (`set`), nunca somadas.
- **Dependência de taxa de quadros:** já resolvida na v10 e medida de novo (seção 6).
- **Pivôs e escala:** pivô no centro de massa, cabeça presa ao fim do pescoço, escala só na revelação do Despertar.

### Regressão que eu mesmo causei e corrigi
Na primeira reorganização dos estados, a extração pegou por engano os blocos de **locomoção** do Deslocamento e do Trabalho, em vez dos blocos de **pose**. O teste da exportação acusou (`tgt is not defined`). Agora cada estado tem `steer` (para onde ir) e `update` (pose), separados.

## 3. Rosto

Mantém a reconstrução da v10, que já está medida: olho e órbita no mesmo elipsoide, simetria de 0,000 mm e nenhuma interseção; boca colada a menos de 2,5 mm da pele.

Expressões disponíveis e onde aparecem:

| Expressão | Pálpebras | Pupila | Olhar | Boca | Quando |
|---|---|---|---|---|---|
| Neutra | levemente baixas (serenidade) | 0,30 | sacadas curtas | serena | Idle |
| Curiosidade | mais abertas | 0,32 | para o alvo | levemente aberta | Idle (olhar lateral, inclinar, seguir fragmento), fim da Descoberta |
| Concentração | semicerradas | 0,22 | para baixo, no recurso | neutra | Trabalho |
| Surpresa | bem abertas | 0,36 | para cima | aberta em 2 etapas | Descoberta rara |
| Contemplação | baixas e calmas | 0,30 | para o céu | serena | Contemplação |
| Satisfação | inferior sobe | 0,30 | — | cantos sobem | Comemoração |

## 4. Controlador de animação

```
STATE_DEF[estado] = { prio, kf (transição), enter(c), steer(c,dt,alvo), update(c,metas,ctx), exit(c,próximo) }
```
- **Entrada:** prepara o estado (zera o percurso, mostra o recurso, guarda o ângulo de giro).
- **Execução:** `steer` decide o alvo de voo (locomoção) e `update` escreve só **metas** de pose. Uma única camada de pose escreve nos ossos, uma vez por quadro.
- **Saída:** restaura os temporários (luz do recurso, luz do núcleo, constelações, partículas do Despertar). As partículas do estado anterior se apagam em até 0,3 s.
- **Prioridade:** Despertar 5 > Descoberta 4 > Comemoração 3 > Trabalho 2 > Deslocamento = Contemplação 1 > Idle 0. Um pedido de prioridade menor é recusado e registrado. Os botões da prévia forçam a troca.
- **Transição:** interpolação exponencial por estado (5 a 14/s). O giro da Comemoração completa até o múltiplo de 360° mais próximo se for interrompido.
- **Flutuação base:** continua em todos os estados (meia amplitude no Deslocamento e na Contemplação).
- **Depuração:** botão **Depuração** mostra o estado, a prioridade, o tempo, a fase do Trabalho, a velocidade, o rumo, o alinhamento dos anéis, as expressões, as articulações escritas, os conflitos e as últimas trocas. Velocidade 1×, 0,5×, 0,25× ou 0,1× para inspecionar.

## 5. Câmera de apresentação

- **Não é guiada pela pose:** o enquadramento usa um **envelope fixo da pose-base** (focinho, ponta da cauda, nadadeira, brânquias, anéis, patas, com folga para subida), girado só pelo rumo do personagem. Cauda balançando, brânquias, flutuação e giro não mexem na câmera.
- Segue apenas a **locomoção** (centro de massa sem flutuação) com suavização.
- O **giro da Comemoração** e as **Sete Estrelas** entram como mudanças de plano lentas e deliberadas (o envelope do giro e o da constelação são misturados aos poucos).
- **Vistas:** Frontal, Lateral, Três quartos, Traseira, Rosto ampliado, Animação completa (órbita lenta) e Longe. A Silhueta continua como botão.
- O cálculo considera o campo de visão vertical e horizontal, então funciona em tela de celular. Se você girar a câmera com o mouse ou o dedo, ela para de se ajustar sozinha até você escolher uma vista de novo.

## 6. Testes executados

Rodados no Chromium (Playwright, WebGL por software, entre 3 e 20 fps conforme a carga da máquina), na página real. Os testes ficam ao vivo no painel da prévia, e o botão **Depuração** mostra o estado e permite câmera lenta.

### Sequências pedidas (versão publicada)

| Sequência | Voltou ao Idle | Vel. máx. | Giro máx. | Anéis | Boca × pele | Efeitos soltos | Conflitos de articulação | Rosto coberto | Margem mín. na tela |
|---|---|---|---|---|---|---|---|---|---|
| Idle → Deslocamento → Idle | sim | 0,90 m/s | 105°/s | 14,6 cm | 1,4 mm | 0 | 0 | 6/111 (só brânquia) | 3,0% |
| Idle → Trabalho → Idle | sim | 0,72 m/s | 110°/s | 14,6 cm | 2,3 mm | 0 | 0 | 0/117 | 6,6% |
| Idle → Comemoração → Idle | sim | 0,90 m/s | 384°/s (o giro) | 14,6 cm | 1,5 mm | 0 | 0 | 2/99 (só brânquia) | 9,2% |
| Idle → Contemplação → Deslocamento | sim | 0,90 m/s | 106°/s | 14,6 cm | 1,6 mm | 0 | 0 | 2/129 (só brânquia) | 5,9% |
| Despertar → Idle | sim | 2,16 m/s* | 0°/s | 14,6 cm | 1,4 mm | 0 | 0 | 0/102 | 8,6% |
| Deslocamento → Descoberta Rara → Idle | sim | 0,91 m/s | 106°/s | 14,6 cm | 2,6 mm | 0 | 0 | 3/120 (só brânquia) | 6,8% |

\* Primeiro quadro do Despertar, com o corpo ainda invisível.

- **Os anéis nunca cobriram o rosto** em nenhuma amostra. As poucas coberturas (até 5%) são as próprias brânquias, em certos ângulos.
- **Câmera:** o deslocamento da câmera que não vem do alvo ficou em até 1,7 m/s, e a mudança de distância em até 28% por segundo (quando o personagem vira). Não há mais o "respirar" visto na gravação da v10.
- **Taxas de quadros:** a mesma sequência de 22,5 s simulada a 20 fps e a 120 fps termina a 3,8 cm e 3,4° de diferença.
- **Exportação:** GLB gerado, reimportado e renderizado numa cena vazia, independente da prévia (`referencias/axolote-v11-glb.png`).
- **Celular (390 × 844):** personagem inteiro nas vistas Três quartos e Lateral, inclusive em movimento; botões abaixo da imagem; gráfico reduzido ativado automaticamente.

### Falhas encontradas pelos testes e corrigidas nesta versão
1. Extração errada dos blocos de estado (locomoção no lugar da pose). O teste da exportação acusou.
2. Teste de enquadramento contando as Sete Estrelas antes de acenderem (falso positivo de −28%). Agora só conta as estrelas visíveis.
3. Atraso da câmera em movimento: o focinho encostava na borda (−0,9%). Agora a câmera mira à frente, compensando a suavização.

### O que continua em aberto
- A gravação mencionada no pedido não chegou; se houver algum defeito específico nela, preciso vê-la.
- Desempenho num celular de verdade não foi medido.
- A boca e o olhar dependem de morph e shader, que não existem no Roblox; é preciso adaptar (seção 8).
- As cores do GLB são uma aproximação da nebulosa (mais claras que na prévia).

## 7. Desempenho

| Medida | Implementação |
|---|---|
| Partículas por distância | Ajudantes próximos: orçamento completo. Médios: 35%. Distantes: nenhuma |
| Anéis distantes | Malha simplificada (40 segmentos) e sem cristais |
| Animação eficiente | Distantes atualizam a cada 3 quadros; fora da tela, a cada 4 e sem efeitos |
| Luzes dinâmicas | Duas presas ao personagem principal (núcleo e recurso). Ajudantes extras não criam luzes |
| Celular | Gráfico reduzido liga sozinho em tela de toque ou com menos de 600 px: resolução 1×, sem sombras, sem bloom e 40% das partículas |
| Partículas na lente | Tamanho máximo de 48 px e desvanecimento a menos de 1,1 m da câmera |

Não medi em celular de verdade. O navegador de teste roda WebGL por software (~20 fps), que não representa um aparelho.

## 8. Roblox Studio: situação real

**Nada foi importado nem testado no Roblox Studio.** Este ambiente não tem o Studio. O que existe agora:

| Item | Situação |
|---|---|
| **Formato da geometria** | Campo de distância (SDF) transformado em malha. Na prévia, cerca de 170 mil triângulos; **no GLB, 10.408 no corpo e nadadeira** e 20.232 no total (com olhos, brânquias, anéis e boca) |
| **Rig** | 20 ossos (`root, spine, chest, neck, head, tail1–5, armL/R, foreL/R, pawL/R, thighL/R, shinL/R`), pesos de até 4 ossos por vértice. As peças rígidas (olhos, pálpebras, brânquias, boca, anéis) são filhas dos ossos |
| **Exportação** | **Feita e verificada**: GLB binário de 1,77 MB. Reimportado com o GLTFLoader, ele tem 23 malhas, 2 com pele, 20 ossos, 9 materiais e 7 animações tocando |
| **Materiais** | `Nebulosa` e `Membrana`: cores de vértice que **aproximam** o shader (a nebulosa animada e as estrelas que piscam não saem do three.js). `Olho`: textura da íris com a pupila. `OuroCeleste` e `Nebular`: metal. No Roblox, o caminho é pintar ou assar uma textura no Blender e usar SurfaceAppearance |
| **Animações exportadas** | Idle (6 s), Nado (6 s), Trabalho (7,5 s), Comemoração (2,8 s), DescobertaRara (3,6 s), Contemplação (8,2 s) e Despertar (7,2 s), amostradas do controlador real a 30 fps. Os ossos, as pálpebras (piscadas), as brânquias e os anéis estão nas animações. A raiz traz flutuação e giro, sem deslocamento pelo mundo |
| **O que não exporta** | Morphs da boca (o Roblox não tem): viram textura de boca ou osso no lábio. Olhar da íris (shader): vira offset de textura no cliente. Ondulação da borda da nadadeira (shader): vira osso extra. Partículas, feixe, pulsos e constelações flutuantes: refazer com ParticleEmitter, Beam, Trail e Attachments |
| **Importar no Studio** | Passos sugeridos, **a confirmar no Studio**: abrir o GLB no Blender e conferir escala (1 unidade = 1 m; no Roblox, 1 stud ≈ 0,28 m). Exportar FBX ou importar o glTF direto pelo 3D Importer, se a versão do Studio aceitar. Conferir o limite de triângulos por MeshPart. Importar as animações pelo Animation Editor; os IDs só existem depois de publicar |
| **Integração com ajudantes** | O controlador desta página vira um ModuleScript no cliente com a mesma tabela de estados (prioridade, entrada, execução, saída). O servidor decide o que mexe em economia (coleta, descoberta) e manda eventos; o cliente anima. Os rascunhos em `luau-rascunho/` seguem esse desenho e **não foram testados** |
