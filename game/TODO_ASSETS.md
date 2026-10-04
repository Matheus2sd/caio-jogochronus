# Acabamento pendente — Production Pass

Os pacotes abaixo já foram reconstruídos, integrados e tecnicamente testados. Não repetir geração sem defeito demonstrado. **TEMPORARY** indica aceite artístico/sonoro pendente; fontes e manifests registram reusos.

| Pacote | Estado | Pendência específica |
|---|---|---|
| Ren | TEMPORARY | Revisar fluidez dos combos 2/3 e ações que reutilizam poses; pivô de run quadro 4 corrigido por falha de margem |
| Humano H1/H2 | TEMPORARY | Variante visual H2 e revisão humana da antecipação |
| Akio | TEMPORARY | Interframes de salto/giro/interação e combos 2/3; corpo próprio de 56 px já integrado |
| Daigo | TEMPORARY | Ritmo/peso em partida humana; 11 clipes próprios, derrota viva e lâminas inteiras já integrados. Push disponível como clip, sem mecânica nova |
| Primavera/tiles/props | TEMPORARY | Variedade de superfícies e repetição da pedra, acabamento de costuras e transições entre materiais |
| Parallax | TEMPORARY | Rever continuidade/composição em movimento por todas as zonas; camadas e cobertura já testadas |
| VFX/Eco | TEMPORARY | Contraste de combate, partículas e entrada/saída em movimento; identidade espacial já integrada |
| HUD/menus | TEMPORARY | Fonte final, legibilidade em telas físicas, estados de foco/gamepad; kit novo e navegação testados |
| Efeitos/ambiência | TEMPORARY | Escuta em fones/caixas, materiais, fadiga e repetição dos loops; picos/mix/transições testados |
| Música | TEMPORARY | Substituir esboços sintéticos por composição final adequada; sem material externo |
| QA humana e plataformas | TODO | Partida início→fim, gamepad, acessibilidade, Linux/macOS; investigar warnings de saída |

Sem dependência externa BLOCKED. Nenhum aceite final artístico ou auditivo foi presumido. Os assets antigos `TEMP_` continuam preservados como referência histórica; não são a fonte de arte final. Inventário baseline em `ASSET_AUDIT.md`, estado de execução em `ASSET_REBUILD_PLAN.md`.

## Fechamento técnico — clone limpo

Clone da branch remota em b4a0961 sem cache .godot e usando project.godot versionado 4.5: validador completo -Visual, verificador de sprites e verificador dos 39 WAVs passaram (exit 0). Pronto para revisão humana; pendências artísticas/sonoras e warnings de saída continuam explícitos. Nenhum merge em main; alteração local de project.godot preservada. Relatório em `docs/PRODUCTION_REVIEW.md`.
