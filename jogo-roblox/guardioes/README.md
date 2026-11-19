# Guardiões do Multiverso: Atlas das Dimensões

Esta é a área isolada da reformulação do jogo, que passa de tycoon ("Magnata do Multiverso") para RPG multiplayer.

- Nada fora desta pasta foi alterado.
- Os mapas, modelos e o Campo das Bolhas estão preservados.

> **Situação:** documentos completos; protótipo de combate **escrito e não executado** (sem Studio nem runtime Luau nesta sessão).

## Documentos

| # | Arquivo | Conteúdo |
|---|---|---|
| 00 | [docs/00-AUDITORIA.md](docs/00-AUDITORIA.md) | Inventário do que existe e o que é reaproveitado |
| 01 | [docs/01-GDD.md](docs/01-GDD.md) | Documento oficial de design |
| 02 | [docs/02-ARQUITETURA.md](docs/02-ARQUITETURA.md) | Os 14 sistemas, rede, persistência, desempenho e diretórios |
| 03 | [docs/03-PROTOTIPO-DE-COMBATE.md](docs/03-PROTOTIPO-DE-COMBATE.md) | O que o protótipo faz e como as peças se ligam |
| 04 | [docs/04-MIGRACAO-TYCOON.md](docs/04-MIGRACAO-TYCOON.md) | Migração sem destruir nada |
| 05 | [docs/05-PLANO-DE-TESTES-STUDIO.md](docs/05-PLANO-DE-TESTES-STUDIO.md) | Testes passo a passo no Studio |
| 06 | [docs/06-RELATORIO.md](docs/06-RELATORIO.md) | O que está concluído e o que falta |
| 07 | [docs/07-COMPLEMENTO-CRIATURAS-VOO-ARTEFATOS.md](docs/07-COMPLEMENTO-CRIATURAS-VOO-ARTEFATOS.md) | Complemento oficial: companheiros, evolução, Vínculo Dimensional, montarias, voo, raças, livros, transportes, artefatos |
| 08 | [docs/08-ARQUITETURA-ESTADOS-CONTRATOS.md](docs/08-ARQUITETURA-ESTADOS-CONTRATOS.md) | Os 20 módulos pedidos, estados e transições, contratos, rede, riscos |
| 09 | [docs/09-PLANO-ANIMACOES-EFEITOS.md](docs/09-PLANO-ANIMACOES-EFEITOS.md) | Animações de voo, transformações, criaturas e efeitos por qualidade |
| 10 | [docs/10-TESTES-COMPLEMENTO.md](docs/10-TESTES-COMPLEMENTO.md) | 47 casos automáticos novos e roteiros no Studio (voo, artefato, multiplayer, mapas) |
| 11 | [docs/11-RELATORIO-COMPLEMENTO.md](docs/11-RELATORIO-COMPLEMENTO.md) | Arquivos criados, verificações feitas e pendências |
| 12 | [docs/12-RELATORIO-ETAPAS-6-A-9.md](docs/12-RELATORIO-ETAPAS-6-A-9.md) | Companheiros, montarias, livros e salvamento: o que foi feito sem o Studio |

## Código

```
src/ReplicatedStorage/Guardioes/      config, lógica pura de combate, rede (compartilhado)
src/ServerScriptService/Guardioes/    Main + Sistemas (PlayerData, Enemy, Combat, MovementAbility, Movement, MetamorphicArtifact, Companion, Mount, MagicBook) + Dados + ConfigSecreta
src/StarterPlayer/StarterPlayerScripts/Guardioes/   Main + Controladores (combate, voo, câmera, efeitos, artefato, HUDs)
tests/                                testes dos módulos puros (Studio ou Lune)
default.project.json                  mapa do Rojo
```

## Testar

1. **Sincronizar com o Rojo.** Numa **cópia** do place, rode `rojo serve` nesta pasta e conecte o plugin do Studio.
2. **Rodar os testes de lógica.** Na barra de comandos: `require(game.ServerStorage.GuardioesTestes.Studio)()`
3. **Jogar.** Dê Play e siga o [plano de testes](docs/05-PLANO-DE-TESTES-STUDIO.md).

Para rodar os testes fora do Studio: `lune run tests/rodar-lune.luau`.
