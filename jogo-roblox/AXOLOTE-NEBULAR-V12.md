# Axolote Nebular v12: correção técnica da v11

Prévia: `jogo-roblox/pilotos/axolote-nebular-v12.html`
Cópia preservada: `axolote-nebular-v11.html` (sem alterações).
Exportação: `jogo-roblox/exportacao/axolote-nebular-v12.glb`

> **Só visualizador web.** Nada foi aplicado no Roblox Studio. A v12 é a mesma v11, com a mesma geometria, materiais, anéis, estados, Contemplação, Sete Estrelas e Despertar. As mudanças são correções pontuais.
>
> A gravação mencionada no pedido **não chegou a este ambiente**. Os únicos vídeos da sessão são os quatro clipes de referência do início. Por isso os bugs foram achados com um **teste de estresse** que mede cada articulação, a posição, o brilho e os efeitos a cada quadro, em transições repetidas e em interrupções no meio dos estados.

---

## 1. Bugs encontrados (medidos na v11, antes de corrigir)

| # | Bug | Medida | Causa no código |
|---|---|---|---|
| 1 | Anel Nebular dá um tranco ao entrar na Comemoração depois da Descoberta | 745°/s em um quadro | O alinhamento dos anéis usava a taxa de transição do estado (14/s) e se desfazia quase num quadro |
| 2 | Corpo gira bruscamente ao interromper a Comemoração com a Descoberta | 488°/s | O giro voltava ao múltiplo de 360° mais próximo invertendo o sentido de uma vez |
| 3 | Patas traseiras estalam ao entrar na Comemoração | 378°/s | Todos os parâmetros de pose usavam a taxa rápida (14/s) dos estados especiais |
| 4 | Pulsos de brilho aparecem e somem num quadro | 0 → 0,8 → 0 (Contemplação, Despertar, Descoberta) | Intensidade em degrau e zerada na saída do estado |
| 5 | Partículas sobrando depois que o estado acaba | 3 casos | Partículas criadas no quadro da troca recebiam a etiqueta do estado antigo |
| 6 | Pálpebras abrem num quadro ao interromper o Despertar | 1.174°/s | Os valores de revelação eram recalculados sem suavização |
| 7 | Corpo cai rápido ao interromper a Comemoração com a Descoberta | 2,6 m/s | A subida usava a taxa rápida |
| 8 | Coluna torce ao inverter o sentido da curva | 330°/s | A taxa de curva entrava na coluna sem filtro |
| 9 | Fase da cauda pulava quando a frequência mudava | Código: a fase era `t × frequência` | Encontrado lendo o código. Mudar a frequência no tempo t≈100 s desloca a fase inteira |
| 10 | Personagem cortado no celular durante o Deslocamento | Focinho até 28,7% fora da tela | O enquadramento usava só o rumo suavizado; ao virar rápido, o rumo real ia à frente |
| 11 | Zoom do mouse desligava o enquadramento automático | Código | O zoom do OrbitControls disparava o modo manual |
| 12 | Anéis de pulso continuavam depois de uma interrupção | Código | Não pertenciam a nenhum estado |

**Não confirmado e mantido:** as pálpebras chegam a 800–900°/s numa **piscada** (~0,2 s). É a velocidade de uma piscada real, não um defeito; o teste agora ignora as piscadas.

## 2. Arquivo modificado

Só `pilotos/axolote-nebular-v12.html`, uma cópia da v11 com correções localizadas. Todas as mudanças estão marcadas com `v12:` nos comentários. Arquivos novos: este relatório, o GLB e duas imagens em `referencias/`.

## 3. Correções

| Bug | Correção |
|---|---|
| 1, 3, 7 | **Taxa por parâmetro:** membros, cauda, brânquias e subida no máximo 6/s; anéis 3,2/s. Expressões e eventos seguem rápidos |
| 2 | Giro termina por **mola criticamente amortecida** que conserva a velocidade e segue no mesmo sentido |
| 4 | Pulsos com subida de 0,3 s e descida de 0,35 s; numa interrupção o brilho decai em ~0,4 s |
| 5, 12 | Partículas e anéis de pulso etiquetados com o estado certo e encerrados em 0,3 s na saída |
| 6 | Revelação do Despertar suavizada (some em ~0,3 s no início; completa em ~1 s se interrompido ou pulado) |
| 8 | Taxa de curva filtrada antes de entrar na coluna, no peito, na cabeça e na cauda |
| 9 | Fase da cauda integrada no tempo |
| 10 | Envelope da câmera com o rumo suavizado, o real e o antecipado (0,6 s de curva); a câmera afasta rápido e aproxima devagar; margem maior em tela em pé |
| 11 | Zoom próprio (botões **+** e **−**, roda do mouse e pinça) que **mantém** o enquadramento automático |

**Rosto (sem mudar a cabeça):**
- Reflexo da íris de 1,25 para 0,95.
- Córnea com menos reflexo (opacidade 0,10 → 0,07; ambiente 2,2 → 1,4).
- Sorriso "feliz" mais contido.
- Piscada assimétrica: fecha em 70 ms e abre em 130 ms.
- Pálpebra de repouso um pouco mais aberta (16% → 11%).

## 4. Testes executados

**Estresse completo, versão final, 1300 × 860:** as 7 transições pedidas, **duas vezes cada**, mais 8 interrupções no meio dos estados (Comemoração→Descoberta, Descoberta→Comemoração, Trabalho→Deslocamento, Despertar→Deslocamento, Comemoração→Idle, Descoberta→Trabalho, Contemplação→Idle, Deslocamento→Comemoração).

| Medida | v11 | v12 |
|---|---|---|
| Transições e interrupções concluídas | 22/22 | 22/22 |
| Saltos acima do limite (fora das piscadas) | anel 745°/s, corpo 488°/s, patas 378°/s | **nenhum** |
| Saltos de brilho | 30 | **0** |
| Efeitos persistentes após a saída | 3 | **0** |
| Conflitos de articulação | 0 | 0 |
| Movimento mais rápido | anel 745°/s | o próprio giro da Comemoração, 384°/s |
| Folga mínima dos anéis | 9,8 cm | 10,6 cm |
| Boca × pele (pior caso) | 4,2 mm | 3,1 mm |

**Taxas de quadros e telas** (Idle → Deslocamento → Idle, Idle → Trabalho → Idle, Idle → Comemoração → Idle):

| Configuração | Saltos | Brilho | Persistentes | Margem mín. na tela |
|---|---|---|---|---|
| 60 fps fixos | 0 | 0 | 0 | 3,9% |
| 12 fps fixos | 0 | 0 | 0 | 3,9% |
| Celular 390 × 844 (antes da correção 10) | 0 | 0 | 0 | **−28,7%** (corte) |
| Celular 390 × 844 (final) | 0 | 0 | 0 | **8,7%** |
| Desktop 1300 × 860 (final) | 0 | 0 | 0 | 10,4% |
| Tablet 768 × 1024 (final) | 0 | 0 | 0 | 10,5% |

- **Rosto:** comparado de frente e de lado com a v11 (`referencias/axolote-v12-rosto-v11xv12.png`). Olhos simétricos (0,000 mm), nenhuma interseção, boca colada à pele.
- **GLB:** reexportado da v12 e reimportado: 23 malhas, 2 com pele, 20 ossos, 9 materiais e 7 animações tocando.

## 5. O que ainda permanece

- **Olho de perfil:** visto exatamente de lado, o olho parece escuro, porque aponta 48° para a frente e para fora, como no desenho do Conceito B. Mudar isso exigiria girar o olho e a órbita, ou seja, alterar a cabeça.
- **Brânquias sobre o olho:** em alguns ângulos uma brânquia cobre parte de um olho (até ~5% das amostras). É a posição natural delas. Em todo o teste completo, **um único quadro** mostrou um anel na frente do rosto.
- **Câmera:** com zoom muito próximo, o corte é escolha do usuário. Arrastar com o mouse desliga o enquadramento automático até escolher uma vista de novo.
- **Ambiente de teste:** WebGL por software (3–20 fps). Desempenho em celular real não foi medido.
- **Gravação:** a referência citada no pedido não chegou. Se ela mostra algo que estes testes não pegaram, preciso vê-la.

## 6. Roblox Studio

**As alterações estão apenas no visualizador web.** Nada foi importado, aplicado ou testado no Roblox Studio, que não está disponível neste ambiente. O GLB atualizado (`exportacao/axolote-nebular-v12.glb`) traz as animações do controlador corrigido. O plano de adaptação continua o de `AXOLOTE-NEBULAR-V11.md`, seção 8.
