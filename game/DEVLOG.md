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

## 2026-10-02 — Auditoria e organização

Confirmada raiz oficial. Estrutura inicial: docs, assets_referencia, game vazio. Git disponível; Python 3.14 com Pillow/NumPy; Git LFS disponível. Godot, ffmpeg e ImageMagick não encontrados no PATH. MCPs disponíveis incluem GitHub, imagem e navegador; nenhum MCP instalado.

Remoto confirmado vazio pelo conector (size 0) e ls-remote. Git inicializado em main, remote oficial configurado, fetch executado. GitHub CLI sem login; não foram inventadas credenciais. Windows sandbox falhou com erro 1385; comandos executados mediante escalonamento autorizado.

Fontes oficiais consultadas e pranchas principais inspecionadas. Plano, auditoria, pendências e decisões criados. Implementação ainda não testada, portanto não COMPLETE.
