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
- `tools/`: exportação reproduzível de arte, síntese sonora e validação.

O production pass usa sprites novos de Ren, Akio, Daigo e humano-base, tileset/props, parallax em camadas, arquitetura Eco, VFX e kit de HUD/menus. Áudio original sintetizado: 28 efeitos e 11 loops por contexto. Integração técnica testada; arte, animação e música permanecem **TEMPORARY** até revisão humana. Fontes, fichas e exports estão versionados. Recursos `TEMP_` antigos são históricos, não a apresentação atual.

Veja [plano atualizado](game/ASSET_REBUILD_PLAN.md), [pendências](game/TODO_ASSETS.md), [capturas Godot](docs/screenshots/chapter1/) e [mix de revisão](docs/audio/chapter1/README.md).

Para continuar: leia `AGENTS.md`, documentos oficiais, `docs/DECISIONS.md` e o DEVLOG. Verifique `PORTABILITY.md` e execute os testes documentados antes de marcar tarefas como COMPLETE. Não ampliar para outros capítulos.

Validação local no Windows: `./tools/validate_chapter1.ps1 -Visual` importa o projeto, executa testes de combate/fluxo/save em perfil isolado e captura menu e início do capítulo em `tools/local/`. Consulte `game/PROJECT_PLAN.md` para o que ainda requer partida manual e polimento.
