# 33 · Relatório: a Biblioteca do Vazio e o capítulo 6

Data: 20/11/2026. Testado no Studio, na cópia de teste "11202026_2" (placeId 115368067307260), salva como versão 5. O place original não foi tocado.

## O mapa (IMPLEMENTADO e TESTADO)

A Biblioteca é uma área deste place, `workspace.BibliotecaDoVazio`. Fica fechada, em (0, 600, -900), bem acima do mapa existente (que vai só até a altura 252), e a única entrada é a Porta sem Moldura. Tem quatro salas:

| Sala | Conteúdo |
|---|---|
| Átrio (48×48, 36 de altura) | Chegada, índice flutuante (modelo gerado), 8 colunas de mármore, portal de saída e estantes |
| Sala de Leitura | Mesa das sete estrelas (7 pontos de luz e uma vela), três atris (modelo gerado) com placas "Livro dos Ventos / das Estrelas / das Marés", a estante que se move e o nicho atrás dela |
| Galeria Suspensa (50 de altura) | Seis degraus de livros (2 studs cada) até uma borda a 14 studs, com a página do alto |
| Sala do Eco | Fosso de 8 studs com brilho violeta, ponte estreita, ilhota com a página e degraus para sair do fosso |

Os detalhes da construção:
- **Estantes:** são montadas em peças (cerca de 1.500), com livros de cores e alturas variadas. A estante gerada por IA parecia um armário sem livros e foi descartada.
- **Livros flutuantes:** 25 livros decorativos, sem colisão e sem `CanQuery`.
- **Arquivo dos modelos gerados:** `ServerStorage.BibliotecaAssets`.
- **Conferências:** a varredura de chão das salas não achou buracos, e o fosso é fechado dos quatro lados.

## O capítulo 6 (IMPLEMENTADO e TESTADO)

- **Pistas:** o índice que flutua e a mesa das sete estrelas. A mesa dá a ordem dos livros conforme a semente de cada jogador.
- **Enigma 1, Leitura das Estantes:** sequência de três livros. Lidos na ordem, a estante desce **só para quem leu**. O servidor publica os objetivos cumpridos no atributo `GuardioesObjetivosFeitos`, e o controlador `EstantesDaBiblioteca` abre a estante no cliente. Para os outros jogadores, ela continua fechada.
- **Enigma 2, Páginas de A.:** coleta de três páginas: a do nicho, a do alto e a da sala do eco.
- **Recompensa:** 3 Folhas de Registro, 500 XP, o registro `Arq05_ABiblioteca` e a marca `PaginasDeA`.
- **Porta sem Moldura:** agora leva de verdade à Biblioteca, porque passagens secretas aceitam destinos `noPlace`.

## Partida no Studio (Play)

O perfil começou com os capítulos 1 a 5 concluídos.
1. **Entrada:** examinei a porta, que foi descoberta e aberta, e cheguei à Biblioteca em (0, 603, -887).
2. **Livro antes das pistas:** "nada acontece".
3. **Pistas:** índice e mesa anotados. O Atlas mostrou a ordem deste jogador: estrelas, ventos, marés.
4. **Leitura:** estrelas "certo", ventos "certo", marés "completo".
   - No cliente, a estante desceu e perdeu a colisão.
   - No servidor, ela continuou no lugar, com colisão.
5. **Página do nicho:** passei pela abertura andando (`Humanoid:MoveTo`). Resultado: "1 de 3".
6. **Página do alto:** de baixo, a 11 studs, não respondeu. Subi os seis degraus só pulando e peguei: "2 de 3".
7. **Página do eco:** atravessei a ponte andando. Resultado: "completo".
8. **Conclusão:** o perfil foi para o capítulo 7, com o registro, a marca e XP (nível 3).
9. **Saída:** o portal da Biblioteca me levou ao hub.

**Console:** nenhum erro dos Guardiões. **Testes:** 234 passaram, 0 falharam.

## Problemas achados no teste e corrigidos

| Problema | Correção |
|---|---|
| A Porta sem Moldura tem 8 studs de altura, e o prompt era medido a partir do centro. Um jogador no chão ficava a 9,9 studs, fora do alcance de 9 | `Marcas.alturaDoPrompt`: em peças com mais de 5 studs de altura, o prompt fica 2,5 studs acima da base. Vale também para as torres do capítulo 3 |
| A linha de visão do prompt sai da câmera, e o portal de saída (atrás do jogador recém-chegado) bloqueava o índice | Portais com `CanQuery = false` (`Portal_Hub`, `Portal_CampoDasBolhas` e o da Biblioteca). A travessia mede distância e não depende disso |
| O modelo do índice cobria a marca | Os modelos decorativos ficaram só visuais (`CanQuery = false`) |
| O aviso da coleta dizia "Você guardou **o** página" | O enigma ganhou o campo `artigo` ("a" para páginas). O padrão continua "o" para os dentes |

## O que NÃO foi testado (PENDENTE)

- **Dois jogadores ao mesmo tempo:** não testei um jogador vendo a estante fechada enquanto o outro passa pela abertura. Pela lógica, quem não leu os livros esbarra na estante.
- **Save de verdade:** o Studio está sem DataStore.
- **Rótulo de área do tycoon:** dentro da Biblioteca, o HUD do tycoon mostra "Galpão Central", que é o padrão dele.
- **Voo:** não testei chegar voando até a página do alto, só pelos degraus.
