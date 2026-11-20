# 32 · Relatório: mistérios, capítulo 5 — a Mensagem Entre Dimensões

Data: 20/11/2026. **Testado no Studio**, na cópia de teste "11202026_2" (placeId 115368067307260), salva como versão 4. O place original não foi tocado.

## O que foi feito

| Peça | Entrega |
|---|---|
| Campo das Bolhas jogável | Virou uma **área deste place** (`noPlace = true`). Ninguém precisou criar um place novo. A viagem leva até uma Part de chegada (`GuardioesChegadaDimensao`) e a área vale num raio de 115 studs (`RaioDimensao`). O servidor descobre em qual dimensão o jogador está pela posição dele (`Portal.dimensaoPorPosicao`) |
| Portais | `Portal_Hub` fica perto da arena, no lugar do antigo portal de teste. `Portal_CampoDasBolhas` é invisível e fica junto do PortalVolta do tycoon nas Bolhas. Os dois usam o prompt "Atravessar" (B) |
| Capítulo 5 | Duas pistas: a metade da fechadura (Ilha 3) e a voz na bolha (Ilha 1). Depois, dois enigmas em sequência: a **Fechadura das Bolhas** (Interdimensional, só abre com a marca `ChaveIncompleta` do capítulo 4) e o **Eco das Bolhas** (três bolhas na Ilha 2, na ordem da semente de cada jogador) |
| Recompensa | 2 Folhas de Registro, 400 XP, o registro `Arq04_AMensagem` e a marca `MensagemEntreDimensoes` |
| Porta sem moldura | Agora abre depois do capítulo 5, e não do 6, porque o capítulo 6 acontece dentro da Biblioteca |
| Lore | Cânone **v4**: A. percebeu o Atlas "como um sino rachado" antes da Fratura, e os outros Arquivistas acharam normal. Não diz quem foi |
| Sala de teste | `DiscoveryService` só deixa de criar a sala dos capítulos 1 a 4 quando a Ilha tiver a marca `MarcaInscricao` de verdade. Antes, qualquer marca no mapa (como as das Bolhas) escondia a sala |

## Teste no Studio (Play, servidor e cliente)

- **Testes de lógica:** 231 passaram, 0 falharam.
- **Partida do capítulo 5:** o perfil começou no capítulo 5, com os capítulos 1 a 4 concluídos, a Chave Incompleta e o diário do Guardião. Os prompts foram acionados pelo cliente, com o servidor medindo a distância:
  1. **Ida pelo portal do hub:** "Campo das Bolhas", chegada em (-330, 53, 282) e a dimensão marcada como visitada.
  2. **Fechadura antes das pistas:** "nada acontece".
  3. **Pistas:** as duas anotadas no Atlas. O Atlas mostrou a voz com a ordem deste jogador (prisma, orvalho, mel).
  4. **Fechadura:** "completo", e o estado passou para Pronto para resolver.
  5. **Eco errado:** mel primeiro deu "errado". Em seguida, prisma deu "certo", orvalho "certo" e mel "completo".
  6. **Conclusão:** capítulo 6, Investigando, com o registro, a marca e o XP recebidos. O nível subiu de 1 para 3.
  7. **Volta pelo portal das Bolhas:** a lista mostrou "Campo das Bolhas = aqui" e "Ilha = ok", e a chegada foi no hub.
- **Console:** nenhum erro dos Guardiões. A sala de teste dos capítulos 1 a 4 continuou aparecendo (30 peças), e o portal de teste não se duplicou.

## Problemas achados no teste e corrigidos

- **Prompts de B que disputam a tecla:** a fechadura estava a 7 studs da bolha de pedra, e as três bolhas do eco a 5 studs uma da outra. O Roblox mostra só um prompt por tecla, então uma das marcas não respondia. Afastei a fechadura (13 studs) e as bolhas (8 studs entre si), no Play e no Edit.
- **Teleporte pelo cliente:** o validador de movimento barrou o teleporte, e isso está certo. No teste, movi o personagem pelo servidor, como a viagem faz.

## O que NÃO foi testado

- **Com mais de um jogador:** o capítulo é individual, mas não joguei com duas pessoas ao mesmo tempo nas Bolhas.
- **Save de verdade:** a cópia não tem acesso a DataStore no Studio, então tudo ficou em memória. A gravação do capítulo 5 no perfil só foi testada pelos specs.
- **Chegar a pé:** não testei entrar nas Bolhas pelo portal do tycoon e começar o capítulo assim. Deve funcionar, porque as marcas só olham o capítulo do jogador.
- **Visual das marcas:** as marcas são peças simples (bolha de pedra, bolha de vidro, fechadura de metal), no mesmo nível da sala de teste. Não são modelos finais.

## Próximo

- **Capítulo 6:** precisa do **mapa da Biblioteca do Vazio** (área no place ou place próprio) e do conteúdo do capítulo.
- **Capítulo 7:** a Lâmina do Não-Existente, o primeiro artefato ??? jogável.
