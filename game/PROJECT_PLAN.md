# Capítulo I — estado atual

Production Pass, 2026-10-03. Branch `production-pass-chapter1`, sem merge em main. COMPLETE abaixo significa integração técnica verificada, não arte final nem partida humana.

| Estado | Entrega | Evidência |
|---|---|---|
| COMPLETE | Novo Jogo, movimento, combate, parry, postura, morte/retry | Validador oficial, `chapter_smoke` |
| COMPLETE | Eco/Akio, retorno a Ren, Daigo vivo e encerramento | `chapter_flow`, `chapter_traversal`, `chapter_playthrough` |
| COMPLETE | Menus, remapeamento, progressão L1–L3/E1 bloqueada, save | `menu_smoke`, `progression_smoke`, `save_io` |
| COMPLETE técnico / TEMPORARY artístico | Ren 26 clipes, humano 8, Akio 26, Daigo 11 | Fontes próprias, SpriteFrames, `production_visuals`, capturas reais |
| COMPLETE técnico / TEMPORARY artístico | Primavera, 128 tiles, 9 props, 5 camadas parallax | TileSet e capturas em 640×360 |
| COMPLETE técnico / TEMPORARY artístico | Seis VFX, arquitetura e transições Eco, HUD/menus | Runtime e capturas preservando o fluxo |
| COMPLETE técnico / TEMPORARY sonoro | 28 efeitos + 11 loops de contexto | `audio_smoke`, 39 WAVs medidos, captura Master pico 0.2680 |
| COMPLETE | Margens, alfa e pivôs dos sprites | `tools/validate_production_assets.py`; corrigido um pivô de corrida de Ren |
| TODO | Verificação final a partir de cópia limpa do commit | Executar sem `.godot` e sem alteração local de `project.godot` |
| TODO | Revisão humana visual/sonora e partida completa | Ver `TODO_ASSETS.md`; música não é composição final |

Regressão completa passou após cada pacote relevante com Godot 4.5.1. A última suite inclui importação, oito testes funcionais/de apresentação e áudio, mais captura de menu/início/progressão. `production_capture.gd` gera poses encenadas na Godot; `chapter_playthrough` percorre o capítulo por movimento e dano reais. Esses dois tipos de evidência não equivalem a uma partida humana.

`game/project.godot` tem alteração local preexistente da Godot 4.6. Ela permanece preservada e fora dos commits de produção. Recursos e caminhos são portáveis; saves/configurações usam `user://`.

Avisos preexistentes de certificados no sandbox e ObjectDB/recursos ao sair continuam registrados. Não houve falha de importação ou dos testes executados. Nenhum Capítulo II implementado.
