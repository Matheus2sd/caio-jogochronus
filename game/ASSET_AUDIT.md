# Auditoria completa — Production Pass / 2026-10-03

Baseline: `4fa08a0`, branch `production-pass-chapter1`. Inspeção de todos os arquivos em `game/assets/`, código consumidor e 13 pranchas aprovadas. `tools/audit_assets.py` mede tamanho, alfa, cores, duração e SHA-256 sem editar originais.

## Estado atual — 2026-10-03

| Pacote | Classificação atual | Evidência |
|---|---|---|
| Ren / humano / Akio / Daigo | KEEP na integração; TEMP_ONLY para aceite final | 26/8/26/11 clipes próprios, testes e capturas; corpo 52/48/56/58 px |
| Tiles / props / parallax | KEEP na integração; TEMP_ONLY artístico | 128 tiles, 9 props, cinco camadas, TileSet e runtime |
| VFX / Eco | KEEP na integração; TEMP_ONLY artístico | Seis efeitos + seis objetos de memória, transições e captura |
| HUD / menus | KEEP na integração; TEMP_ONLY artístico | Kit próprio, barras/ícones, navegação preservada e testada |
| Áudio | REPLACE realizado; TEMP_ONLY sonoro | 28 efeitos + 11 loops originais; 39 WAVs medidos, mix real capturado |
| Recursos antigos TEMP_ | TEMP_ONLY histórico | Preservados; não regenerar como produção atual |
| Fonte UI/composição musical/variante H2 | TODO de acabamento | Não BLOCKED; revisão humana e produção final ainda pendentes |

Todo o restante deste documento é o histórico da auditoria e milestones; descrições de recortes/tint/retângulos referem-se ao momento registrado, não ao runtime atual.

## Diagnóstico do baseline por pacote

| Pacote | Classificação | Evidência e ação |
|---|---|---|
| Ren | REBUILD | Oito poses recortadas, contorno perfurado pelo recorte do fundo escuro, death repete combate, movimento apenas alterna pose/balança 1 px. Refazer desenhos e sequências. |
| Humano H1/H2 | REBUILD | Guarda/hurt cortados nas laterais, fragmentos de poses vizinhas e espada solta; falta antecipação animada. Nova base e ficha de timings. |
| Akio | REBUILD | Oito poses; efeitos embutidos; não há sequência jogável completa. Corpo e movimento próprios, 56 px conforme AR02. |
| Daigo | REBUILD | Recorte usa variante jovem da prancha conflitante, riscos de legenda/borda incorporados; derrota é pose girada. Reconstruir pelo P0 + DOCX: largo, grisalho, barba, manto e apoio ajoelhado vivo. |
| Tiles | REBUILD | Oito amostras 16×16, repetição de pedra coberta de musgo no subsolo, sem transições ou TileSet editável. Criar atlas modular. |
| Props (6) | REBUILD | Recortes com restos de chão, tamanhos reamostrados e densidade desigual. Criar PNGs isolados, sem símbolos de clã inventados. |
| Presente/fundo arena | REPLACE | Imagem 640×220 esticada para 640×280; perspectiva e chão desenhados competem com plano jogável; uma só velocidade. Produzir camadas independentes. |
| Eco | REBUILD | Fundo próprio, porém o restante é tint e retângulos flutuantes. Reconstituir ponte e arquitetura em fragmentos localizados, manter terreno reconhecível. |
| VFX combate/Eco | REBUILD | Pastas só têm README; runtime desenha arcos e pequenos retângulos sem sequências exportadas. Produzir efeitos separados e sincronizados. |
| HUD/ícones/diálogo/menus | REBUILD | Só README; widgets nativos com barras retangulares e painel grande. Criar kit discreto preservando hierarquia e navegação. |
| SFX (9) | REPLACE | 22.05 kHz/16-bit mono, ruído/seno simples; eventos importantes ausentes. Produzir transientes e materiais distinguíveis. |
| Ambiente/música (2) | TEMP_ONLY | Dois loops mono de 8 s para todas as áreas, tocando desde menu. Substituir por ambiências situacionais e música seletiva; final musical continua sujeito a revisão. |
| Manifesto antigo e pipeline de recorte | KEEP | Preservar proveniência e reprodução do baseline; não executar sobre o novo pacote. Novo manifesto separado. |
| Recursos `.import` | KEEP | Configuração de importação; atualizar apenas derivados novos/removidos. Não são arte. |
| Referências/DOCX (fora de runtime) | KEEP | Fontes oficiais imutáveis; textos de pranchas não sobrepõem cânone. |

Nenhum pacote foi marcado BLOCKED: ferramentas locais de importação e Pillow estão disponíveis. A maioria exige reconstrução, não remendo. Assets anteriores ficam no lugar até substituição; então podem ser copiados para `_legacy_temp/` com `.gdignore`.

## Cobertura por arquivo no baseline

`*.import` são metadados associados a cada PNG/WAV abaixo (25 recursos). Os seis README e o manifesto foram lidos; o padrão de sprite criado nesta fase não é asset legado.

| Arquivo | Medida | Classificação |
|---|---|---|
| `audio/ambient/TEMP_ambient.wav` | 8.0 s, 22050 Hz, 16 bit, 1 canal | TEMP_ONLY |
| `audio/music/TEMP_music.wav` | 8.0 s, 22050 Hz, 16 bit, 1 canal | TEMP_ONLY |
| `audio/sfx/TEMP_break.wav` | 0.4 s, 22050 Hz, 16 bit, 1 canal | REPLACE |
| `audio/sfx/TEMP_echo.wav` | 1.2 s, 22050 Hz, 16 bit, 1 canal | REPLACE |
| `audio/sfx/TEMP_guard.wav` | 0.18 s, 22050 Hz, 16 bit, 1 canal | REPLACE |
| `audio/sfx/TEMP_heal.wav` | 0.8 s, 22050 Hz, 16 bit, 1 canal | REPLACE |
| `audio/sfx/TEMP_heavy.wav` | 0.28 s, 22050 Hz, 16 bit, 1 canal | REPLACE |
| `audio/sfx/TEMP_impact.wav` | 0.13 s, 22050 Hz, 16 bit, 1 canal | REPLACE |
| `audio/sfx/TEMP_parry.wav` | 0.38 s, 22050 Hz, 16 bit, 1 canal | REPLACE |
| `audio/sfx/TEMP_slash.wav` | 0.15 s, 22050 Hz, 16 bit, 1 canal | REPLACE |
| `audio/sfx/TEMP_step.wav` | 0.06 s, 22050 Hz, 16 bit, 1 canal | REPLACE |
| `characters/akio/TEMP_poses.png` | 768×96, alfa [0, 255], 7997 cores | REBUILD |
| `characters/daigo/TEMP_poses.png` | 768×96, alfa [0, 255], 9241 cores | REBUILD |
| `characters/ren/TEMP_poses.png` | 768×96, alfa [0, 255], 4447 cores | REBUILD |
| `enemies/human_base/TEMP_poses.png` | 768×96, alfa [0, 255], 6160 cores | REBUILD |
| `environments/backgrounds/TEMP_arena.png` | 640×220, alfa [255, 255], 65774 cores | REPLACE |
| `environments/echo/TEMP_background.png` | 640×220, alfa [255, 255], 45705 cores | REPLACE |
| `environments/present/TEMP_background.png` | 640×220, alfa [255, 255], 118417 cores | REPLACE |
| `environments/props/TEMP_fence.png` | 110×36, alfa [0, 255], 3611 cores | REBUILD |
| `environments/props/TEMP_gate.png` | 85×105, alfa [0, 255], 7333 cores | REBUILD |
| `environments/props/TEMP_house.png` | 170×156, alfa [0, 255], 20637 cores | REBUILD |
| `environments/props/TEMP_lantern.png` | 26×52, alfa [0, 255], 1121 cores | REBUILD |
| `environments/props/TEMP_pine.png` | 78×130, alfa [0, 255], 7906 cores | REBUILD |
| `environments/props/TEMP_tree.png` | 122×125, alfa [0, 255], 12153 cores | REBUILD |
| `environments/tilesets/TEMP_tiles.png` | 128×16, alfa [255, 255], 2034 cores | REBUILD |
| `manifest.json` | 7679 bytes | KEEP |
| `ui/dialogue/README.txt` | 79 bytes | REBUILD |
| `ui/hud/README.txt` | 79 bytes | REBUILD |
| `ui/icons/README.txt` | 79 bytes | REBUILD |
| `ui/menus/README.txt` | 79 bytes | REBUILD |
| `vfx/combat/README.txt` | 79 bytes | REBUILD |
| `vfx/echo/README.txt` | 79 bytes | REBUILD |

## Verificação inicial executada

COMPLETE técnico: `tools/validate_chapter1.ps1 -Visual` terminou com exit 0 antes de alterar runtime: importação, smoke, fluxo, travessia, percurso contínuo, menus, progressão, save e capturas. Avisos preexistentes de certificados e ObjectDB permanecem; não são prova de áudio/artes finais.

Capturas anteriores: `docs/screenshots/chapter1/baseline_present.png`, `baseline_menu.png`, `baseline_assets.png`. Evidenciam Ren quase transparente, falta de animações, solo repetitivo e fundo disputando leitura. O teste automatizado de ausência de faixa lisa passou no baseline; o problema atual é composição/profundidade, não ausência completa de cobertura.

A reconstrução completa e o aceite visual ainda estão TODO. Ver `ASSET_REBUILD_PLAN.md`.

## Reinspecao apos os primeiros pacotes

A tabela acima descreve o baseline, nao o runtime atual. Ren/humano usam SpriteFrames novos; tiles/props/parallax substituidos e verificados. VFX possui seis sequencias exportadas e camada independente, validacao completa exit 0. Akio/Daigo ainda carregam TEMP_poses; Eco ainda usa tint/retangulos; HUD/menus ainda nativos; audio ainda TEMP mono. Pastas reais: game/assets/audio e game/tests; nao existem game/audio nem tests na raiz.

## Eco — substituição verificada

REBUILD integrado: seis PNGs em `environments/echo/echo_*_v001.png`, exportados de fonte nova com alfa binário e paleta reduzida. `echo_visual.gd` trata fragmentos/limiar/transição; geometria de colisão preservada. TEMP_background antigo mantido como referência histórica. Suite completa e captura: exit 0.

## Akio — pacote integrado

26 clipes/36 poses próprias em carvão, cinza e vermelho escuro, escala AR02 de 56 px. Resposta herdada segue o tempo real do combate. `validate_chapter1.ps1 -Visual` (agora inclui `production_visuals`) e captura Godot: exit 0; imagem inspecionada. COMPLETE técnico; TEMPORARY artístico: combos 2/3, salto, interação e giro reutilizam poses selecionadas da fonte, conforme manifesto. Próximo pacote: Daigo.

## Daigo — pacote integrado

11 clipes/36 poses novas do veterano P0, 58 px, derrota viva ajoelhada. Extração por componentes conectados evita cortar lâminas; aplicada também a Akio. Célula larga 192×96, pivô 96,80, sem alterar hitbox. Teste de derrota durante diálogo falhou antes da correção e passou depois; animação visual pode terminar com combate bloqueado. Suite completa -Visual: exit 0; reimportação, teste de apresentação e capturas após ajuste das lâminas: exit 0. COMPLETE técnico / TEMPORARY artístico. Push é apenas clipe disponível, não uma mecânica nova. Próximo: HUD/menus e áudio.

## HUD e menus — pacote integrado

Kit pixel original: molduras slate/dourado, barras separadas, ícones de bandagem/talismã/memória, HUD compacto e fundos do cenário novo. Widgets e navegação existentes preservados. Suite completa -Visual: exit 0; captura de menu, pausa, settings, morte, fim e HUD; menu_smoke repetido após acabamento: exit 0. COMPLETE técnico; TEMPORARY artístico, fonte final e revisão humana de legibilidade continuam TODO. Nenhuma barra de energia Eco nem habilidade extra foi adicionada. Próximo: áudio.

## Áudio — pacote integrado

28 efeitos originais + 11 loops estéreo de 16 s, PCM16/48 kHz; passos terra/madeira, movimento, combate, UI/cancelamento, Eco/Akio e Daigo. Ambientes/música por contexto com transição de volume e água somente na ponte. Pool de oito vozes e limiter no Master. `node tools/validate_audio.mjs`: 39 WAVs sem clipping, duração e emendas verificadas; passos/UI abaixo do combate. `audio_smoke` e suite completa -Visual: exit 0. `audio_capture.gd` gravou 641536 frames reais em 48 kHz, pico 0.2680, em `docs/audio/chapter1/runtime_mix_review.wav`. COMPLETE técnico; sons e música TEMPORARY, escuta em dispositivo e composição final TODO. Nenhum sample externo. Próximo: correção pontual do pivô de corrida de Ren, documentação consolidada e verificação de clone limpo.

## Fechamento técnico — clone limpo

Clone da branch remota em b4a0961 sem cache .godot e usando project.godot versionado 4.5: validador completo -Visual, verificador de sprites e verificador dos 39 WAVs passaram (exit 0). Pronto para revisão humana; pendências artísticas/sonoras e warnings de saída continuam explícitos. Nenhum merge em main; alteração local de project.godot preservada. Relatório em `docs/PRODUCTION_REVIEW.md`.
