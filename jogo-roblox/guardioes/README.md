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

## Código

```
src/ReplicatedStorage/Guardioes/      config, lógica pura de combate, rede (compartilhado)
src/ServerScriptService/Guardioes/    Main + Sistemas (CombatSystem, EnemySystem)
src/StarterPlayer/StarterPlayerScripts/Guardioes/   Main + Controladores (entrada e HUD)
tests/                                testes dos módulos puros (Studio ou Lune)
default.project.json                  mapa do Rojo
```

## Testar

1. **Sincronizar com o Rojo.** Numa **cópia** do place, rode `rojo serve` nesta pasta e conecte o plugin do Studio.
2. **Rodar os testes de lógica.** Na barra de comandos: `require(game.ServerStorage.GuardioesTestes.Studio)()`
3. **Jogar.** Dê Play e siga o [plano de testes](docs/05-PLANO-DE-TESTES-STUDIO.md).

Para rodar os testes fora do Studio: `lune run tests/rodar-lune.luau`.
