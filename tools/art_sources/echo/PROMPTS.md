# Echo — fonte nova

Geração integrada image_gen, transparência solicitada. Referência de identidade: `assets_referencia/03_MUNDO_ECO_VFX/Mundo_Eco_Transformacao_Referencia.png`. Sem recortar a prancha. A exportação é determinística; a geração não.

Prompt de produção: original production sprite atlas for CHRONUS Chapter I Echo World; Japanese rural spring architecture remembered as blue/cyan/violet broken suspended fragments; exactly 3 columns x 2 rows isolated objects; transparent background, no text/borders/labels; orthographic side elevation, pixel art, indigo shadows, muted violet, restrained cyan seams. Row 1: incomplete weathered torii, suspended broken stone lantern, floating mossy stone/wood ruin. Row 2: remembered horizontal footbridge with rails and masonry beneath, fragmented violet cherry tree, memory crystal over low stone plinth. Complete silhouettes, transparent holes, no ground backdrop or characters; downsample to 80–180 px. Melancholic atmosphere, no science fiction.

`tools/build_echo.py` registra recortes, escala e alfa. Partículas, limiar e transição: geometria pixel original em `game/scripts/echo_visual.gd`. TEMPORARY: revisão artística final, densidade de partículas e transição em movimento ainda devem ser avaliadas em partida humana.
