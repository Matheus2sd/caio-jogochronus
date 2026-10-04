# Portabilidade

Clone o repositório oficial e abra `game/project.godot` com Godot 4.5+ standard. Nenhum plugin, SDK pago ou .NET é necessário. Runtime usa somente arquivos versionados e APIs nativas da Godot.

Para reproduzir exports de arte: Python 3 + Pillow, usando os scripts `tools/build_character.py`, `build_environment.py`, `build_parallax.py`, `build_echo.py`, `build_effects.py` e `build_ui.py`. Áudio: Node.js com módulos nativos, `node tools/build_audio.mjs`. Nada disso é necessário para jogar: PNG/WAV/TRES já são versionados. `tools/process_assets.py` (Pillow/NumPy) é o pipeline histórico de recortes; não executá-lo como rebuild de produção. `tools/read_docs.py` lê DOCX com biblioteca padrão. Consulte `docs/ASSET_PIPELINE.md`.

Cache `.godot/`, executáveis em `tools/local/`, exports, logs e consultas `.local.txt` não são versionados. A Godot reimporta PNG/WAV na primeira abertura. Os assets processados são versionados; não é necessário recriá-los após clone.

Para validar em Windows, execute `./tools/validate_chapter1.ps1` na raiz; use `-Visual` para abrir a janela e gerar capturas em `tools/local/`. O script resolve a raiz pela própria localização, aceita Godot em `tools/local/`, no PATH ou no caminho indicado por `CHRONUS_GODOT`, e usa um perfil de teste isolado. Arquivos `.import` mantêm LF via `.gitattributes`, evitando alterações artificiais ao abrir na Godot no Windows.

Saves e configurações usam `user://`, diretório próprio da Godot em cada sistema. O jogo não usa caminhos pessoais nem depende da pasta de Downloads. Nomes de recursos respeitam capitalização para Linux. Compatibility permite OpenGL em máquinas sem Vulkan. A escala inteira pode produzir bordas em resoluções não múltiplas de 640×360. Áudio e gamepad precisam de validação nos três sistemas.

Git remoto: https://github.com/Matheus2sd/caio-jogochronus.git. Sem autenticação local, executar `gh auth login`, depois `gh auth setup-git`, `git fetch origin` e `git push -u origin production-pass-chapter1`. Nunca usar `--force`.
