# Questões e limites

- COMPLETE: percurso automatizado contínuo `chapter_playthrough.gd` chegou a `CAPÍTULO I — FIM` com deslocamento e golpes reais, sem teleporte nem derrota por código. TODO: executar uma partida humana contínua para julgar ritmo, dificuldade e leitura antes de declarar o Capítulo I completo.
- TODO: ampliar remapeamento para entradas de controle e confirmar a navegação com gamepad real; o conflito entre teclas já oferece troca ou cancelamento.
- COMPLETE: Progressão L1–L3 e bloqueio E1 verificados em teste automatizado; o teste injeta uma marca porque a primeira recompensa da campanha chega somente após o encerramento. TODO: validar a troca de marca por uma pessoa em descanso quando o fluxo de capítulos seguintes existir, sem implementar o Capítulo II agora.
- COMPLETE: gravação, backup, marca única e migração de save v1 completo validados em `tools/local/profile` isolado. Os outros testes usam `--test` para preservar o save do usuário.
- TODO: investigar avisos de `ObjectDB instances leaked at exit` e, em algumas execuções headless, streams de áudio ainda em uso ao fechar a Godot. No sandbox, a Godot também informa que não conseguiu ler a lista de certificados raiz; o jogo não usa rede. Não houve erro de cena ou GDScript durante os testes de jogo.
- TODO: validar áudio, controle e interface em outros sistemas após a versão Windows.
- TODO artístico: recortes das pranchas são provisórios e não aprovam interframes nem mudanças de design. Ver `TODO_ASSETS.md`.
- EM ABERTO no cânone: topônimos, símbolo final do clã, fonte final e nomenclatura definitiva dos Ecos. A implementação não fixa essas decisões.
- Cânone preservado: Daigo sobrevive; não é mentor, líder nem servo; a memória não muda o passado; não há revelação antecipada do massacre.

## Production Pass

- TODO: revisão artística das novas sequências e mixagem; testes de fluxo não certificam qualidade visual/sonora.
- Decisão de continuidade: usar Daigo do P0 e DOCX; ignorar variante jovem, títulos e segunda forma conflitantes da folha individual. Akio 56 px conforme AR02.

- Ren possui animacoes exportadas e testadas, mas combos 2/3 reutilizam keyposes. O aceite final continua artistico, nao inferido do teste funcional.

- Pacote humano: 8 clips/28 poses novas de chapeu de palha e manto; preparacao sustentada no windup real, guarda e queda proprias. Validador completo exit 0; H1/H2 compartilham a base, variacao final H2 permanece TODO.

- Ambiente Presente: 9 props novos e 128 tiles originais 16x16 com TileSet Godot; solo/terra/madeira/pedra/vegetacao/agua/ponte/telhado. Geometria preservada. Regressoes e captura visual passaram (exit 0); revisao artistica final continua TODO.

- Parallax: ceu + quatro camadas novas, fatores 0.12/0.28/0.48/0.72, repeticao espelhada sem blur, camera efetiva. Suite funcional passou; captura inicialmente detectou topo liso, corrigido elevando copa ao topo; reimportacao e capturas visual/producao passaram, imagem inspecionada.

- VFX: seis efeitos exportados, seis estagios cada; camada propria em runtime, acionada por contato real, sem alterar hitboxes. Regressoes completas e captura Godot passaram; reducao de flashes respeitada.

## Eco — verificação e limite

Testes confirmaram a memória atravessável e retorno ao Presente sem restaurar a ponte física. Capturas são poses encenadas na Godot, não substituem partida humana. Qualidade artística permanece aberta; nenhuma decisão narrativa nova.

## Akio — pacote integrado

26 clipes/36 poses próprias em carvão, cinza e vermelho escuro, escala AR02 de 56 px. Resposta herdada segue o tempo real do combate. `validate_chapter1.ps1 -Visual` (agora inclui `production_visuals`) e captura Godot: exit 0; imagem inspecionada. COMPLETE técnico; TEMPORARY artístico: combos 2/3, salto, interação e giro reutilizam poses selecionadas da fonte, conforme manifesto. Próximo pacote: Daigo.

## Daigo — pacote integrado

11 clipes/36 poses novas do veterano P0, 58 px, derrota viva ajoelhada. Extração por componentes conectados evita cortar lâminas; aplicada também a Akio. Célula larga 192×96, pivô 96,80, sem alterar hitbox. Teste de derrota durante diálogo falhou antes da correção e passou depois; animação visual pode terminar com combate bloqueado. Suite completa -Visual: exit 0; reimportação, teste de apresentação e capturas após ajuste das lâminas: exit 0. COMPLETE técnico / TEMPORARY artístico. Push é apenas clipe disponível, não uma mecânica nova. Próximo: HUD/menus e áudio.

## HUD e menus — pacote integrado

Kit pixel original: molduras slate/dourado, barras separadas, ícones de bandagem/talismã/memória, HUD compacto e fundos do cenário novo. Widgets e navegação existentes preservados. Suite completa -Visual: exit 0; captura de menu, pausa, settings, morte, fim e HUD; menu_smoke repetido após acabamento: exit 0. COMPLETE técnico; TEMPORARY artístico, fonte final e revisão humana de legibilidade continuam TODO. Nenhuma barra de energia Eco nem habilidade extra foi adicionada. Próximo: áudio.
