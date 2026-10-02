# Plano do Capítulo I

Estado verificado em 2026-10-02 no clone atual, com Godot 4.5.1 stable. COMPLETE significa execução e verificação sem erro crítico conhecido; não significa arte final nem uma partida humana completa.

| Estado | Entrega | Evidência / próximo passo |
|---|---|---|
| COMPLETE | Git e continuidade | `main` contém `2713870`; `git fetch origin` e divergência `0/0` com `origin/main` antes das mudanças desta sessão. |
| COMPLETE | Importação e abertura | Godot 4.5.1 importa `game/project.godot`; a cena principal abre em modo headless e em janela OpenGL Compatibility. |
| COMPLETE | Primeira milestone: menu e Ren controlável | `game/tests/chapter_smoke.gd` abre Novo jogo, encontra o sprite de Ren e verifica deslocamento; `game/tests/visual_capture.gd` captura a cena renderizada. |
| COMPLETE | Combate básico e recursos em teste automatizado | Smoke verifica salto, esquiva, ataque com dano, guarda com gasto de stamina, parry, quebra de postura, cura e morte/respawn. |
| COMPLETE | Lógica de percurso do Capítulo I em teste automatizado | `game/tests/chapter_flow.gd` verifica portões, inimigos, CP2, falha/recomeço no Eco, Akio, restauração de Ren, CP3, nova tentativa com Daigo sem repetir conversa, encerramento e marca única. O teste acelera deslocamento e derrota de inimigos; não substitui partida manual. |
| TEMPORARY | Arte, UI e áudio | Recortes e síntese `TEMP_` funcionam, mas precisam de animação, integração visual, revisão de leitura e produção final. Ver `TODO_ASSETS.md`. |
| TODO | Partida manual do começo ao fim | Jogar sem teleporte nem derrota programática, revisar ritmo, colisões, acessibilidade, gamepad, áudio e legibilidade de todas as áreas. |
| TODO | Menus e progressão completos | Há menu, pausa, controles, configurações e equipamento de consulta. A tela de Progressão, conflitos de remapeamento e cobertura completa de configurações oficiais ainda faltam. |
| COMPLETE | Persistência em disco isolada | `game/tests/save_io.gd` gravou e leu campanha, checkpoint, backup, marca e configurações em `tools/local/profile` via `user://`; também validou conclusão repetida e migração de save v1 completo sem duplicar a marca. |
| TODO | Importação após clone limpo | Repetir `tools/validate_chapter1.ps1` em um clone novo quando esta milestone estiver publicada. |
| TODO | Encerramento editorial e polimento | Revisar falas, gesto de Daigo sobrevivente, apresentação da marca e todos os assets finais antes de declarar o capítulo completo. |

Somente Capítulo I está em implementação. Não iniciar Capítulo II sem autorização.
