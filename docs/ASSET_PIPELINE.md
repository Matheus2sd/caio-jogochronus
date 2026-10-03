# Pipeline de assets — Production Pass

## Fontes e exportação

Referências em `assets_referencia/` e DOCX em `docs/` são imutáveis. Fontes novas e prompts ficam em `tools/art_sources/<pacote>/`. O gerador de imagem integrado cria novos desenhos; a geração não é determinística. A fonte PNG escolhida é versionada, tornando a exportação reproduzível sem rede ou credenciais.

Python 3 + Pillow exportam a partir dessas fontes. Scripts resolvem a raiz por `__file__`. Runtime só lê `res://assets/`; dados pessoais só usam `user://`. Nenhum caminho pessoal entra em recursos de runtime.

1. `python tools/audit_assets.py`: inventário e contact sheet em `tools/local/` (ignorado).
2. Produzir fonte nova com geração de imagem integrada, baseada nas pranchas e cânone. Guardar prompt e identificar referências; não extrair arte final das pranchas anteriores.
3. Conferir grade, poses e identidade antes de exportar. Registrar seleção de células e reaproveitamentos na ficha; exportar com nearest e alfa binário para personagens.
4. Integrar ficha/SpriteFrames/TileSet/Theme conforme pacote, preservando geometria de gameplay.
5. `./tools/validate_chapter1.ps1 -Visual`: importação e regressão funcional em perfil isolado. Conferir exit code e logs.
6. Guardar evidências selecionadas em `docs/screenshots/chapter1/`, atualizar DEVLOG/PROJECT_PLAN/TODO_ASSETS/QUESTIONS e commit por pacote.

## Arquivo anterior

`tools/process_assets.py` documenta e reproduz os recortes TEMP anteriores. Não faz parte do exportador novo. Não o executar para sobrescrever fontes de produção. O manifesto antigo permanece histórico.

## Critérios de liberação

Dimensões, transparência, pivôs, importação, presença das animações e caminho de recursos precisam passar. Avaliar a imagem real na Godot: forma do corpo, arma, ritmo, costuras e contraste. Som precisa de inspeção de clipping/loop e escuta; música sem revisão final permanece TEMPORARY. Não confundir um teste lógico verde com aprovação estética.

## Eco

`python tools/build_echo.py` exporta seis objetos a partir de `tools/art_sources/echo/echo_source.png`; recortes e escala registrados no script/manifesto. Ponte: 296×140, deck a 40 px do topo, desenhada em y=240 para manter superfície em y=280. Transições não mudam duração nem colisões. `production_capture.gd` salva entrada, memória e saída.
