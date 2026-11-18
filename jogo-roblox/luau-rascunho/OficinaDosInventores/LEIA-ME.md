# Oficina dos Inventores: scripts Luau (rascunho)

**Não foram testados no Roblox Studio.** Foram escritos sem acesso ao Studio, a partir do modelo do visualizador three.js. Trate-os como ponto de partida.

## Onde colocar cada arquivo

| Arquivo | Tipo | Lugar |
|---|---|---|
| `OficinaConfig.lua` | ModuleScript | `ReplicatedStorage.Magnata.Oficina.OficinaConfig` |
| `OficinaColisores.lua` | ModuleScript | `ReplicatedStorage.Magnata.Oficina.OficinaColisores` |
| `OficinaServidor.server.lua` | Script | `ServerScriptService.Magnata.OficinaServidor` |
| `OficinaCliente.client.lua` | LocalScript | `StarterPlayer.StarterPlayerScripts.Magnata.OficinaCliente` |

## Passo a passo

1. **Importe o modelo.**
   - No visualizador, clique em "Baixar pacote (GLB + heightmap + marcadores)".
   - Importe `StormIsland/Architecture/Architecture.glb` pelo Importador 3D.
   - Deixe o modelo em `Workspace/Dimensions/StormIsland/Architecture/` com o nome **"Oficina dos Inventores"**.
2. **Crie as pastas e cole os quatro scripts** nos lugares da tabela acima.
3. **Dê Play.** O Output deve mostrar `[Oficina] preparada: 24 colisores, interior encontrado`.
4. **Teste a tempestade.** Na linha de comando, rode `workspace:SetAttribute("TempestadeAtiva", true)`. Os anéis devem acelerar e as faíscas devem aparecer.

## O que cada um faz

- **Servidor:**
  - ancora as peças;
  - desliga a colisão das malhas visuais;
  - cria 24 caixas invisíveis de colisão;
  - tira a sombra do interior;
  - cria a luz quente e os pontos de faísca e do NPC.
- **Cliente:**
  - gira os anéis, as engrenagens e o volante, e anima os pistões e o manômetro;
  - esconde o interior de longe (some a 125 studs e volta a 110);
  - apaga a luz longe;
  - solta faíscas só com a tempestade.

## Se algo não aparecer

O Output avisa o grupo que faltar, por exemplo: `grupo animado "Planetario" não encontrado`. Normalmente o importador mudou o nome do nó. Corrija o nome em `OficinaConfig.ANIMACOES` ou no modelo.

`OficinaColisores.lua` é gerado pelo visualizador. Se a oficina mudar, gere de novo em vez de editar à mão.
