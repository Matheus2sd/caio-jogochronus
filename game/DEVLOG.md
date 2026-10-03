# DEVLOG

## 2026-10-02 — Continuidade no novo computador e primeira validação Godot

- `git status`, `git remote -v`, `git fetch origin` e `git log --oneline -10` executados antes de editar. `main` estava limpa e sincronizada (`0/0`) com `origin/main`; commit `2713870` confirmado. O primeiro fetch precisou de permissão de escrita em `.git` no ambiente de execução, depois concluiu.
- Documentação oficial e `assets_referencia/` consultados. A ordem antiga “Godot somente na Fase 7” foi superada pela autorização atual do usuário, sem alterar o cânone ou iniciar o Capítulo II.
- Godot 4.5.1 stable standard baixada do release oficial para `tools/local/` (ignorado). SHA-256 do ZIP: `DEFCCC78669E644861B4247626B01AE362CD9F23975EDF19C8BFD2EB1F6A1783`. Executável e ZIP não entram no Git.
- Importação/editor headless de `game/project.godot` concluída. O sandbox negou escrita nos diretórios globais da Godot; as verificações de runtime foram repetidas com acesso normal a `user://`. `--headless --path game --quit-after 120` terminou com código 0, sem erro de parsing, GDScript ou recurso ausente.
- `game/tests/chapter_smoke.gd --test` verificou menu, Novo jogo, sprite e controle de Ren, salto, esquiva, ataque, guarda, parry, postura, cura, morte/respawn, Eco/Akio, retorno, Daigo e encerramento. `game/tests/chapter_flow.gd --test` percorreu por interação as passagens C101–C105, locks de inimigos, checkpoint, falha no Eco, retry de Daigo e marca única do capítulo. Deslocamento e derrotas foram acelerados pelos testes; partida manual ainda TODO.
- Godot em janela abriu no renderer OpenGL Compatibility (RTX 4070). `game/tests/visual_capture.gd --test` capturou menu e início de jogo em `tools/local/`; Ren estava visível. O teste encontrou uma faixa lisa no topo da fase. Corrigido o desenho do fundo para cobrir o espaço até o chão; captura repetida e verificada.
- Implementada a concessão única da marca de Capítulo I (`marks` e `chapter1_mark_awarded`) no save após Daigo. Teste falhou antes da correção e passou depois. Adicionada regra LF para arquivos `.import` visando evitar ruído de fim de linha no Windows.
- Aviso ainda observado ao encerrar testes: `ObjectDB instances leaked at exit`; algumas execuções reportam streams de áudio ativos. Testes de parada e liberação de streams no harness não eliminaram o aviso. Não houve erro crítico durante jogo; investigar antes de considerar a QA final encerrada.
- `game/tests/save_io.gd` validou gravação e leitura reais em perfil `user://` isolado: campanha nova, checkpoint, backup anterior, marca e opções. `tools/validate_chapter1.ps1 -Visual` executou importação, smoke, fluxo, save e captura visual com código 0; resolve os caminhos pela localização do script e redireciona `APPDATA`/`LOCALAPPDATA` para `tools/local/profile` apenas durante a execução.
- No sandbox, a Godot imprime `Failed to read the root certificate store` mesmo com testes passando; isso afeta a leitura da store de certificados do sistema no ambiente restrito, e nenhum recurso do capítulo depende de rede. O aviso de saída de áudio permanece como TODO.
- Revisão de código identificou que saves v1 já concluídos pulavam a nova marca. A retomada agora concede e persiste a marca ausente uma vez. `chapter_flow.gd` falhou antes da correção e passou depois; `save_io.gd` foi ampliado para chamar a conclusão real, recarregar o JSON, repetir a conclusão e migrar um save v1 completo em disco sem duplicação.
- Após o commit `cadcfb4`, foi gerada uma cópia limpa somente dos arquivos rastreados (`git archive HEAD`) em `tools/local/`. Usando a Godot portátil externa à cópia, a importação inicial dos 25 recursos e os testes smoke/fluxo/save passaram. Isto verifica independência do cache e do diretório de trabalho anterior; um `git clone` em outro computador ainda deve ser revalidado quando disponível.
- `chapter_traversal.gd` percorreu fisicamente todas as áreas do Capítulo I com Ren e Akio, usando corrida e saltos sem teleporte de posição. Inimigos foram derrotados programaticamente neste teste para separar colisões do teste de combate. Passou; partida humana contínua ainda TODO.
- `menu_smoke.gd` reproduziu o conflito de tecla ao tentar atribuir J ao salto. A tela de Controles agora pede trocar ações ou cancelar; testados botão real da UI, troca, cancelamento, tecla livre, pausa e retomada. Revisão detectou remapeamento ainda armado após sair da tela e Escape inoperante no conflito se Pausa fosse remapeada; ambos foram reproduzidos e corrigidos. O validador completo com captura visual passou após as correções. Remapeamento de gamepad continua TODO.
- `33be535` foi clonado da URL oficial em `tools/local/clone-check-33be535`, sem `.godot/` prévio. Godot 4.5.1 reimportou 25 recursos e passou smoke, fluxo, travessia, menus, save e captura visual nesse clone. Os avisos de objetos/recursos em uso ao sair permanecem TODO.
- A Progressão usa a marca registrada no save para L1–L3, com aplicação e remoção somente no ponto seguro; E1 informa o desbloqueio apenas no Capítulo IV. `progression_smoke.gd` falhou antes da tela existir e passou depois, verificando troca/reembolso, 24 de postura no contra-ataque L1, regeneração L2, forte de 15 stamina em L3 e leitura fora do descanso. Revisão encontrou a janela de parry fora dos estados que regeneram stamina: o teste foi reforçado, falhou e passou após a correção de L2. `save_io.gd` confirmou aplicação e reembolso no `user://` isolado. Captura GUI confirmou a grade 2×2 em 640×360 e levou à correção do contraste do cartão bloqueado.
- `chapter_playthrough.gd` percorreu do Novo Jogo a `CAPÍTULO I — FIM` em uma execução contínua, sem teleporte de posição nem alteração programática de vida dos inimigos. Usa ações de movimento, salto, ataque forte e Interagir; enfrenta os três humanos do tutorial, o adversário da memória, os dois após o Eco e Daigo com colisão e dano reais. Duas execuções diretas passaram, terminando com Ren em 52 de vida e duas curas; a cobertura foi incorporada ao validador. A cadência de combate e legibilidade ainda precisam de partida humana.
- O commit publicado `df551f5` foi clonado novamente da URL oficial em `tools/local/clone-check-df551f5`. Sem cache `.godot/`, a Godot 4.5.1 reimportou 25 recursos; o validador completo, inclusive percurso contínuo, persistência e captura em janela, terminou com código 0. Os avisos de saída da engine continuam registrados em `QUESTIONS.md`.

## 2026-10-02 — Auditoria e organização

Confirmada raiz oficial. Estrutura inicial: docs, assets_referencia, game vazio. Git disponível; Python 3.14 com Pillow/NumPy; Git LFS disponível. Godot, ffmpeg e ImageMagick não encontrados no PATH. MCPs disponíveis incluem GitHub, imagem e navegador; nenhum MCP instalado.

Remoto confirmado vazio pelo conector (size 0) e ls-remote. Git inicializado em main, remote oficial configurado, fetch executado. GitHub CLI sem login; não foram inventadas credenciais. Windows sandbox falhou com erro 1385; comandos executados mediante escalonamento autorizado.

Fontes oficiais consultadas e pranchas principais inspecionadas. Plano, auditoria, pendências e decisões criados. Implementação ainda não testada, portanto não COMPLETE.

## 2026-10-03 — Production Pass: auditoria

- Executados status/fetch/pull ff-only/log; operações Git precisaram de escalonamento de sandbox e então passaram. Branch production-pass-chapter1 criada em 4fa08a0. Alteração preexistente em project.godot preservada.
- Leitura de continuidade e inspeção das 13 pranchas. Auditoria completa, plano por 13 pacotes e padrão de sprite criados.
- Validador completo com captura visual executado antes de alterações de runtime: exit 0. Baseline salvo em docs/screenshots/chapter1/.

### Pacote Ren
- Criadas duas fontes novas por image_gen; exportador Pillow deterministico, 26 clips/66 poses selecionadas, SpriteFrames e controlador visual sincronizado com ataque. Corrigidos limites de recorte por espacos transparentes.
- COMPLETE tecnico: regressao completa -Visual (exit 0); production_visuals passou cobertura, avanco, contato, pivo e flip; capturas Godot revistas.
- TEMPORARY artistico: leves 2/3 reaproveitam poses; interframes dedicados e fluidez ainda precisam revisao. Nenhuma regra de dano/save alterada.

- Pacote humano: 8 clips/28 poses novas de chapeu de palha e manto; preparacao sustentada no windup real, guarda e queda proprias. Validador completo exit 0; H1/H2 compartilham a base, variacao final H2 permanece TODO.

- Ambiente Presente: 9 props novos e 128 tiles originais 16x16 com TileSet Godot; solo/terra/madeira/pedra/vegetacao/agua/ponte/telhado. Geometria preservada. Regressoes e captura visual passaram (exit 0); revisao artistica final continua TODO.

- Parallax: ceu + quatro camadas novas, fatores 0.12/0.28/0.48/0.72, repeticao espelhada sem blur, camera efetiva. Suite funcional passou; captura inicialmente detectou topo liso, corrigido elevando copa ao topo; reimportacao e capturas visual/producao passaram, imagem inspecionada.
