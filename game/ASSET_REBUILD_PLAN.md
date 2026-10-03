# Production Pass — Capítulo I

**Objetivo:** reconstruir apresentação visual e sonora sobre o capítulo funcional, preservando a direção aprovada.
**Arquitetura:** manter Fighter, Chapter, Main e Save. Separar dados de animação e recursos de apresentação; a simulação continua determinando contato, invulnerabilidade e duração das ações. Nenhum Capítulo II.
**Ferramentas:** Godot 4.5.1, Python/Pillow, geração de imagem integrada. Fontes, prompts, mapas de quadros e exportações versionados.

## Restrições

- Branch `production-pass-chapter1`, sem merge em main, sem force push; fetch antes de push.
- `game/project.godot` já estava modificado pelo usuário antes da fase; não incluir essa alteração nos commits.
- Referências e DOCX preservados. A solicitação de 2026-10-03 autoriza produção e integração imediatas e prevalece sobre a antiga separação de fases.
- 640×360; nearest; tiles 16×16; Ren 52 px, humano 48 px, Akio 56 px (AR02), Daigo 58 px. Pés em (48,80) ou (64,80).
- Daigo vivo na derrota, sem forma sobrenatural; Eco não reescreve o passado; sem barra de energia Eco.
- Reuso de quadros deve constar na ficha. Recursos gerados não recebem aprovação artística automática.
- Manter originais temporários até que substituição e testes do pacote tenham passado.

## Pacotes e critérios

Cada pacote: produzir → revisar pixels/pivôs/contraste → integrar → executar `tools/validate_chapter1.ps1` → registrar evidência → commit específico. Estado COMPLETE só com execução comprovada.

1. [x] Auditoria: `tools/audit_assets.py`, `game/ASSET_AUDIT.md`, inventário por arquivo, capturas anteriores, este plano e padrão de sprite.
2. [ ] Ren: novas fontes em `tools/art_sources/ren/`; exportações por animação em `game/assets/characters/ren/`; ficha JSON; integração em `game/scripts/fighter.gd`. Idle/walk/run/jump_start/jump/fall/land/turn/dodge/draw_sword/sheathe_sword/light_attack_1/2/3/heavy_attack/guard_start/guard/parry/counter_attack/hurt/posture_break/heal/death/interact/echo_interact. Testar sincronismo preparação/contato/recuperação e flip.
3. [ ] Humano: oito animações, chapéu e manto reconhecíveis; telegraph sustentado durante todo windup real. H2 legível; sem alterar IA ou estatísticas.
4. [ ] Presente: atlas 16×16, TileSet Godot e props separados; materiais da referência, costuras e superfícies legíveis. Manter plataformas físicas existentes.
5. [ ] Parallax: céu, montanhas, floresta distante/média/próxima e foreground discreto; camadas independentes, repetição sem faixa superior, velocidades documentadas. Capturar início, meio e arena.
6. [ ] VFX: slash/heavy_slash/impact/parry/posture_break/heal; transparência e duração curta; contato dirigido pela simulação, sem novas hitboxes.
7. [ ] Eco: reconstrução parcial da ponte e arquitetura, fragmentos suspensos, repetição localizada, entrada/saída e transição de memória; manter contraste do combate.
8. [ ] Akio: fonte própria, corpo mais robusto e ereto, carvão/cinza/vermelho escuro; conjunto jogável e resposta econômica; nunca recolorir Ren.
9. [ ] Daigo: fonte própria baseada no P0 e DOCX; idle/walk/guard/attack_1/attack_2/heavy_attack/counter/push/hurt/posture_break/defeat. Derrota ajoelhada e espada de apoio.
10. [ ] HUD: componentes separados para barras, cura, talismã, prompt e Eco; vida/stamina/postura distinguíveis também por forma; preservar campos usados nos testes.
11. [ ] Menus: Theme e painéis coerentes, foco e navegação preservados; diálogo, pausa, settings, morte e fim. Sem fonte externa de licença desconhecida.
12. [ ] Áudio: síntese original reproduzível de materiais e transientes, eventos de movimento/combate/UI/memória; ambientes e música seletivos por área. Música continua TEMPORARY até revisão auditiva/artística.
13. [ ] Integração: regressão completa, captura em `docs/screenshots/chapter1/` de idle/run/ataque/parry/humano/presente/parallax/Eco/Akio/Daigo/HUD/arena; atualizar quatro documentos de continuidade, checar arquivos rastreados e push.

## Verificação

- Automatizada: importação, smoke, fluxo, travessia, playthrough com dano/movimento reais, menus, progressão, save isolado.
- Técnica de assets: alfa, dimensões/células, pivôs, quadros não vazios, ficheiros e origem; snapshots renderizados na Godot.
- Visual: inspecionar capturas a 640×360 e ampliação inteira. Teste lógico não certifica estética, fluidez percebida nem mixagem.
- Pendências finais: partida humana, áudio em dispositivo real, gamepad e outros sistemas permanecem explícitas se não executadas.

## Estado verificado na reinspecao

Commits ee481ab/0b1c716/e5d413b/32bb5c0/c914d00 confirmam auditoria, Ren, humano, Presente e parallax. VFX integrado e validado nesta continuacao. Esses pacotes tem integracao tecnica verificada, mas arte TEMPORARY e polimento especifico ainda listado. Proximo pacote pendente: Mundo Eco, seguido de Akio, Daigo, HUD, menus e audio.

## Pacote 7 executado

Eco reconstruído e integrado; testes completos e captura verificados. Próximo pacote: Akio (fonte nova já gerada, ainda não integrada). Aceite artístico final continua TODO.

## Akio — pacote integrado

26 clipes/36 poses próprias em carvão, cinza e vermelho escuro, escala AR02 de 56 px. Resposta herdada segue o tempo real do combate. `validate_chapter1.ps1 -Visual` (agora inclui `production_visuals`) e captura Godot: exit 0; imagem inspecionada. COMPLETE técnico; TEMPORARY artístico: combos 2/3, salto, interação e giro reutilizam poses selecionadas da fonte, conforme manifesto. Próximo pacote: Daigo.

## Daigo — pacote integrado

11 clipes/36 poses novas do veterano P0, 58 px, derrota viva ajoelhada. Extração por componentes conectados evita cortar lâminas; aplicada também a Akio. Célula larga 192×96, pivô 96,80, sem alterar hitbox. Teste de derrota durante diálogo falhou antes da correção e passou depois; animação visual pode terminar com combate bloqueado. Suite completa -Visual: exit 0; reimportação, teste de apresentação e capturas após ajuste das lâminas: exit 0. COMPLETE técnico / TEMPORARY artístico. Push é apenas clipe disponível, não uma mecânica nova. Próximo: HUD/menus e áudio.

## HUD e menus — pacote integrado

Kit pixel original: molduras slate/dourado, barras separadas, ícones de bandagem/talismã/memória, HUD compacto e fundos do cenário novo. Widgets e navegação existentes preservados. Suite completa -Visual: exit 0; captura de menu, pausa, settings, morte, fim e HUD; menu_smoke repetido após acabamento: exit 0. COMPLETE técnico; TEMPORARY artístico, fonte final e revisão humana de legibilidade continuam TODO. Nenhuma barra de energia Eco nem habilidade extra foi adicionada. Próximo: áudio.
