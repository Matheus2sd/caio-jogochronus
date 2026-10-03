# Plano do Capítulo I

Estado verificado em 2026-10-02 no clone atual, com Godot 4.5.1 stable. COMPLETE significa execução e verificação sem erro crítico conhecido; não significa arte final nem uma partida humana completa.

| Estado | Entrega | Evidência / próximo passo |
|---|---|---|
| COMPLETE | Git e continuidade | `main` contém `2713870`; `git fetch origin` e divergência `0/0` com `origin/main` antes das mudanças desta sessão. |
| COMPLETE | Importação e abertura | Godot 4.5.1 importa `game/project.godot`; a cena principal abre em modo headless e em janela OpenGL Compatibility. |
| COMPLETE | Primeira milestone: menu e Ren controlável | `game/tests/chapter_smoke.gd` abre Novo jogo, encontra o sprite de Ren e verifica deslocamento; `game/tests/visual_capture.gd` captura a cena renderizada. |
| COMPLETE | Combate básico e recursos em teste automatizado | Smoke verifica salto, esquiva, ataque com dano, guarda com gasto de stamina, parry, quebra de postura, cura e morte/respawn. |
| COMPLETE | Lógica de percurso do Capítulo I em teste automatizado | `game/tests/chapter_flow.gd` verifica portões, inimigos, CP2, falha/recomeço no Eco, Akio, restauração de Ren, CP3, nova tentativa com Daigo sem repetir conversa, encerramento e marca única. O teste acelera deslocamento e derrota de inimigos; não substitui partida manual. |
| COMPLETE | Travessia física automatizada | `game/tests/chapter_traversal.gd` percorre com movimento e salto reais todas as áreas de Ren e Akio, sem teleporte de posição; inimigos são derrotados programaticamente para isolar colisões e saídas. |
| COMPLETE | Percurso integrado automatizado com combate | `game/tests/chapter_playthrough.gd` chega do Novo Jogo a `CAPÍTULO I — FIM` numa execução, usando ações de movimento, salto, ataque e interação; inimigos e Daigo caem por dano de espada, sem alteração direta de HP nem teleporte. Passou duas vezes; continua sendo um controlador de teste, não partida humana. |
| COMPLETE | Pausa e remapeamento de teclado em teste automatizado | `game/tests/menu_smoke.gd` verifica pausa, configurações, botão de remapear, confirmação de troca, cancelamento, tecla livre, descarte ao sair, Escape com Pausa remapeada e retomada. |
| COMPLETE | Progressão L1–L3 em ponto seguro | `game/tests/progression_smoke.gd` verifica cartões, aplicação/reembolso, efeitos de combate, consulta fora do descanso e bloqueio de E1. A marca do Capítulo I é obtida somente no fim; o teste injeta uma marca para exercer a troca antes do fim. `save_io.gd` verifica persistência em disco. |
| TEMPORARY | Arte, UI e áudio | Recortes e síntese `TEMP_` funcionam, mas precisam de animação, integração visual, revisão de leitura e produção final. Ver `TODO_ASSETS.md`. |
| TODO | Partida humana do começo ao fim | O percurso automatizado sem teleporte nem derrota programática passou. Jogar manualmente para revisar ritmo, colisões, acessibilidade, gamepad, áudio e legibilidade de todas as áreas. |
| TODO | Menus e configurações completos | Há menu, pausa, Progressão, controles, configurações e equipamento de consulta. Cobertura completa das opções oficiais e remapeamento de gamepad ainda faltam. |
| COMPLETE | Persistência em disco isolada | `game/tests/save_io.gd` gravou e leu campanha, checkpoint, backup, marca e configurações em `tools/local/profile` via `user://`; também validou conclusão repetida e migração de save v1 completo sem duplicar a marca. |
| COMPLETE | Reimportação a partir de cópia limpa | `git archive` de `cadcfb4` sem `.godot/` foi extraído em `tools/local/`; o validador reimportou 25 recursos e passou smoke/fluxo/save. |
| COMPLETE | Importação após clone limpo | Clones da URL oficial em `tools/local/`: no estado publicado `df551f5`, Godot reimportou 25 recursos e passou todo o validador, inclusive percurso contínuo e captura visual. |
| TODO | Encerramento editorial e polimento | Revisar falas, gesto de Daigo sobrevivente, apresentação da marca e todos os assets finais antes de declarar o capítulo completo. |

Somente Capítulo I está em implementação. Não iniciar Capítulo II sem autorização.

## Production Pass — 2026-10-03

- COMPLETE: auditoria de assets e baseline automatizado, com capturas; ver ASSET_AUDIT.md.
- TODO: executar os 13 pacotes em ASSET_REBUILD_PLAN.md, mantendo testes por pacote.
- TEMPORARY: apresentação atual; o estado funcional anterior não certifica arte final.

- COMPLETE tecnico (Ren): 26 clips integrados, regressao e capturas passaram. TEMPORARY artistico: interframes de combo e revisao humana.

- Pacote humano: 8 clips/28 poses novas de chapeu de palha e manto; preparacao sustentada no windup real, guarda e queda proprias. Validador completo exit 0; H1/H2 compartilham a base, variacao final H2 permanece TODO.

- Ambiente Presente: 9 props novos e 128 tiles originais 16x16 com TileSet Godot; solo/terra/madeira/pedra/vegetacao/agua/ponte/telhado. Geometria preservada. Regressoes e captura visual passaram (exit 0); revisao artistica final continua TODO.

- Parallax: ceu + quatro camadas novas, fatores 0.12/0.28/0.48/0.72, repeticao espelhada sem blur, camera efetiva. Suite funcional passou; captura inicialmente detectou topo liso, corrigido elevando copa ao topo; reimportacao e capturas visual/producao passaram, imagem inspecionada.
