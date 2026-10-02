# CHRONUS — Capítulo I / Primavera

Aventura de ação 2D em pixel art sobre Ren Kurokawa, memória e herança. Esta implementação cobre somente a juventude de Ren, o primeiro Eco com Akio e o duelo contra Daigo.

Estado: implementação em desenvolvimento; consulte `game/PROJECT_PLAN.md` para evidências e pendências. Os originais aprovados estão preservados em `docs/` e `assets_referencia/`.

## Abrir e jogar

Use Godot 4.5 ou posterior da série 4.x, edição standard (GDScript; não exige .NET). Importe `game/project.godot` no gerenciador de projetos e pressione F6/F5 conforme a cena/projeto. A configuração usa Compatibility, 640×360, filtro nearest e escala inteira.

Controles: A/D ou setas para mover; Ctrl para correr; Espaço para pular; Shift para esquivar; J ou mouse esquerdo para leve/contra-ataque; K ou mouse direito para forte; L para guarda/parry; H para cura; E para interagir; Esc para pausa. Controle: analógico/D-pad, A salto, B esquiva, X leve, Y forte, LB guarda, RB interação, D-pad cima cura, Start pausa, clique do analógico corrida.

## Estrutura

- `docs/`: fontes oficiais e decisões complementares.
- `assets_referencia/`: pranchas originais aprovadas, não spritesheets finais.
- `game/`: projeto, cenas, scripts e assets de runtime.
- `tools/`: extração reproduzível, geração de áudio temporário e validação.

Os recortes derivados usados em runtime são provisórios: preservam a aparência das pranchas, mas não substituem animação desenhada frame a frame. Consulte `game/ASSET_AUDIT.md` e `game/TODO_ASSETS.md`. Sons sintetizados são identificados por `TEMP_`.

Para continuar: leia `AGENTS.md`, documentos oficiais, `docs/DECISIONS.md` e o DEVLOG. Verifique `PORTABILITY.md` e execute os testes documentados antes de marcar tarefas como COMPLETE. Não ampliar para outros capítulos.
