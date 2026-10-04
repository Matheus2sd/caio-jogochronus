# Production Pass — Capítulo I

**Objetivo:** reconstruir apresentação visual e sonora sobre o capítulo funcional, preservando a direção aprovada.
**Arquitetura:** manter Fighter, Chapter, Main e Save. Separar dados de animação e recursos de apresentação; a simulação continua determinando contato, invulnerabilidade e duração das ações. Nenhum Capítulo II.
**Ferramentas:** Godot 4.5.1, Python/Pillow, Node.js, geração de imagem integrada. Fontes, prompts, mapas de quadros e exportações versionados.

## Restrições

- Branch `production-pass-chapter1`, sem merge em main, sem force push; fetch antes de push.
- `game/project.godot` já estava modificado pelo usuário antes da fase; não incluir essa alteração nos commits.
- Referências e DOCX preservados. A solicitação de 2026-10-03 autoriza produção e integração imediatas e prevalece sobre a antiga separação de fases.
- 640×360; nearest; tiles 16×16; Ren 52 px, humano 48 px, Akio 56 px (AR02), Daigo 58 px. Pés em (48,80), (64,80) ou (96,80), conforme célula; corpos mantêm a escala.
- Daigo vivo na derrota, sem forma sobrenatural; Eco não reescreve o passado; sem barra de energia Eco.
- Reuso de quadros deve constar na ficha. Recursos gerados não recebem aprovação artística automática.
- Manter originais temporários até que substituição e testes do pacote tenham passado.

## Pacotes e critérios

Caixas marcadas significam integração técnica executada; todos os pacotes artísticos/sonoros permanecem TEMPORARY para revisão humana.

Cada pacote: produzir → revisar pixels/pivôs/contraste → integrar → executar `tools/validate_chapter1.ps1` → registrar evidência → commit específico. Estado COMPLETE só com execução comprovada.

1. [x] Auditoria: `tools/audit_assets.py`, `game/ASSET_AUDIT.md`, inventário por arquivo, capturas anteriores, este plano e padrão de sprite.
2. [x] Ren: novas fontes em `tools/art_sources/ren/`; exportações por animação em `game/assets/characters/ren/`; ficha JSON; integração em `game/scripts/fighter.gd`. Idle/walk/run/jump_start/jump/fall/land/turn/dodge/draw_sword/sheathe_sword/light_attack_1/2/3/heavy_attack/guard_start/guard/parry/counter_attack/hurt/posture_break/heal/death/interact/echo_interact. Testar sincronismo preparação/contato/recuperação e flip.
3. [x] Humano: oito animações, chapéu e manto reconhecíveis; telegraph sustentado durante todo windup real. H2 legível; sem alterar IA ou estatísticas.
4. [x] Presente: atlas 16×16, TileSet Godot e props separados; materiais da referência, costuras e superfícies legíveis. Manter plataformas físicas existentes.
5. [x] Parallax: céu, montanhas, floresta distante/média/próxima e foreground discreto; camadas independentes, repetição sem faixa superior, velocidades documentadas. Capturar início, meio e arena.
6. [x] VFX: slash/heavy_slash/impact/parry/posture_break/heal; transparência e duração curta; contato dirigido pela simulação, sem novas hitboxes.
7. [x] Eco: reconstrução parcial da ponte e arquitetura, fragmentos suspensos, repetição localizada, entrada/saída e transição de memória; manter contraste do combate.
8. [x] Akio: fonte própria, corpo mais robusto e ereto, carvão/cinza/vermelho escuro; conjunto jogável e resposta econômica; nunca recolorir Ren.
9. [x] Daigo: fonte própria baseada no P0 e DOCX; idle/walk/guard/attack_1/attack_2/heavy_attack/counter/push/hurt/posture_break/defeat. Derrota ajoelhada e espada de apoio.
10. [x] HUD: componentes separados para barras, cura, talismã, prompt e Eco; vida/stamina/postura distinguíveis também por forma; preservar campos usados nos testes.
11. [x] Menus: Theme e painéis coerentes, foco e navegação preservados; diálogo, pausa, settings, morte e fim. Sem fonte externa de licença desconhecida.
12. [x] Áudio: síntese original reproduzível de materiais e transientes, eventos de movimento/combate/UI/memória; ambientes e música seletivos por área. Música continua TEMPORARY até revisão auditiva/artística.
13. [x] Integração: regressão completa, captura em `docs/screenshots/chapter1/` de idle/run/ataque/parry/humano/presente/parallax/Eco/Akio/Daigo/HUD/arena; atualizar quatro documentos de continuidade, checar arquivos rastreados e push.

## Verificação

- Automatizada: importação, smoke, fluxo, travessia, playthrough com dano/movimento reais, menus, progressão, save isolado.
- Técnica de assets: alfa, dimensões/células, pivôs, quadros não vazios, ficheiros e origem; snapshots renderizados na Godot.
- Visual: inspecionar capturas a 640×360 e ampliação inteira. Teste lógico não certifica estética, fluidez percebida nem mixagem.
- Pendências finais: partida humana, áudio em dispositivo real, gamepad e outros sistemas permanecem explícitas se não executadas.

## Estado atual verificado

Pacotes 1–12 integrados e validados; commits de auditoria até `a2e34fa` registram a sequência. Fontes próprias, exports e capturas presentes. Não recriar os pacotes sem regressão ou defeito concreto.

Pacote 13 COMPLETE técnico: pivô de corrida de Ren corrigido; parry real ligado ao clipe sem mudar relógios; revisão independente concluída. Clone remoto de `b4a0961` sem `.godot`, com project.godot versionado 4.5, passou o validador completo -Visual e os verificadores de sprites/áudio (exit 0). Versão pronta para revisão humana; não equivale a aceite final artístico ou sonoro. Ver `docs/PRODUCTION_REVIEW.md`.

Música, som e arte continuam TEMPORARY para revisão humana. Pendências precisas em `TODO_ASSETS.md`. Histórico por milestone em `DEVLOG.md`; tabelas de baseline em `ASSET_AUDIT.md` são históricas.
