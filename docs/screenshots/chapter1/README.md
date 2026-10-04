# Evidências de apresentação — Capítulo I

Capturas reais da Godot em resolução lógica 640×360, nearest. `game/tests/production_capture.gd` carrega cenas reais e encena poses para comparação; não é uma partida humana. A captura de parry passa por `receive_hit`, usando o sucesso real da defesa. O percurso contínuo com movimento/dano reais é coberto separadamente por `chapter_playthrough.gd`.

- `ren_idle`, `ren_run`, `ren_attack`, `parry`: Ren e combate.
- `human_telegraph`: humano-base em antecipação.
- `present_parallax_hud`: Primavera, camadas e HUD.
- `echo_entry`, `echo_akio`, `echo_exit`: limiar, ponte lembrada/Akio, saída.
- `daigo_arena`, `daigo_defeat`: veterano, arena e derrota viva.
- `production_menu`, `production_pause`, `production_settings`, `production_death`, `production_complete`: UI.
- `baseline_*`: comparação histórica anterior ao rebuild; não representam o runtime atual.
- `production_asset_validation.json`: alfa, margem da célula, dimensões e pivôs verificados; não é aceite artístico.

Arte ainda TEMPORARY para revisão humana. Som e relatório próprios estão em `docs/audio/chapter1/`.
