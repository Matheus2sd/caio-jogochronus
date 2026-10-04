# CHRONUS — Production Pass / Capítulo I

**Pronto para revisão humana.** Integração técnica COMPLETE; arte, animação e som TEMPORARY para aceite. Branch `production-pass-chapter1`, sem merge em main. Somente Capítulo I.

## Entrega integrada

- Ren: 26 clipes / 66 poses selecionadas. Humano: 8 clipes / 28 poses. Akio: 26 clipes / 36 poses próprias. Daigo: 11 clipes / 36 poses próprias, veterano e vivo na derrota.
- Primavera: 128 tiles 16×16, TileSet Godot, nove props, céu e quatro camadas de parallax independentes.
- Combate: seis VFX, fases visuais sincronizadas ao tempo já existente. Parry confirmado aciona o clipe real sem mudar janela de defesa/counter.
- Eco: seis objetos próprios, arquitetura fragmentada, ponte lembrada, partículas e entrada/saída. A ponte do Presente permanece partida.
- HUD/menus: molduras, barras e ícones próprios, curas por bandagem, talismã e indicador de memória; navegação nativa preservada.
- Áudio: 28 efeitos originais, 11 loops estéreo de 16 s, PCM16/48 kHz, trocas de contexto com fade, água somente na ponte e pool limitado a oito SFX.

## Evidência executada

Código/runtime testado: commit **b4a0961**, clonado da URL oficial em diretório novo, sem cache `.godot`, com a configuração versionada Godot 4.5. Godot 4.5.1 standard / Compatibility no Windows.

`tools/validate_chapter1.ps1 -Visual` terminou com **exit 0** tanto no checkout principal quanto no clone. Cobertura: importação, chapter_smoke, chapter_flow, chapter_traversal, chapter_playthrough, menu_smoke, progression_smoke, save_io, production_visuals, audio_smoke e visual_capture. O percurso contínuo usa movimento e dano reais até CAPÍTULO I — FIM.

`tools/validate_production_assets.py`: dimensões, quadros não vazios, alfa binário, margens sem corte na célula e linha de pés dos quatro personagens passaram. Encontrou e motivou a correção da âncora de um quadro de corrida de Ren.

`node tools/validate_audio.mjs`: 39 WAVs sem saturação, duração e emendas verificadas; variações de passos distintas e níveis de UI/passos abaixo do combate. `audio_smoke` verifica troca/interrupção de contexto, água, encerramento e pool.

`audio_capture.gd` gravou o Master real da Godot: 641536 frames estéreo a 48 kHz, pico **0.2680**. A gravação é uma montagem de eventos reais, não uma partida humana. [Mix e medições](audio/chapter1/README.md).

[Capturas reais em 640×360](screenshots/chapter1/README.md) incluem Ren, ataque/parry, humano, cenário/parallax, Eco/Akio, Daigo/derrota viva, HUD, menu, pausa, settings, morte e fim. Poses são encenadas em cenas reais; qualidade em movimento ainda requer partida humana.

Revisão independente de código encontrou parry sem clipe próprio. Teste RED/GREEN e revisão da correção concluídos; nenhuma outra regressão concreta identificada nessa revisão estática.

## Limites e próxima revisão

- TODO: partida humana completa, gamepad, legibilidade em telas físicas, Linux/macOS e escuta em caixas/fones.
- TEMPORARY: interframes/reusos documentados de Ren/Akio, variante H2, repetição de materiais/costuras, fonte final e composição musical. [Pendências específicas](../game/TODO_ASSETS.md).
- Avisos preexistentes do ambiente: certificados do Windows no sandbox e ObjectDB/recursos ao encerrar. Permanecem para diagnóstico; não foram tratados como aprovação artística nem omitidos da verificação.
- DOCX e pranchas oficiais preservados. `project.godot` local, alterado previamente pela Godot 4.6, permanece fora dos commits; o clone confirma funcionamento sem essa alteração.
- Sem caminhos pessoais em runtime/ferramentas versionadas, executáveis, caches ou logs no Git. Fontes e exports reproduzíveis no repositório; [pipeline](ASSET_PIPELINE.md).
