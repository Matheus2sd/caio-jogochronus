# Portabilidade

Clone o repositório oficial e abra `game/project.godot` com Godot 4.5+ standard. Nenhum plugin, SDK pago ou .NET é necessário. Runtime usa somente arquivos versionados e APIs nativas da Godot.

Python 3 com Pillow e NumPy é necessário apenas para reconstruir assets: `python tools/process_assets.py`. Não é necessário para jogar. `python tools/read_docs.py` lê os DOCX com a biblioteca padrão. Originais não são alterados. Recortes, manifesto e scripts são fontes reproduzíveis; não há dependência de um editor de imagem proprietário.

Cache `.godot/`, executáveis em `tools/local/`, exports, logs e consultas `.local.txt` não são versionados. A Godot reimporta PNG/WAV na primeira abertura. Os assets processados são versionados; não é necessário recriá-los após clone.

Para validar em Windows, execute `./tools/validate_chapter1.ps1` na raiz; use `-Visual` para abrir a janela e gerar capturas em `tools/local/`. O script resolve a raiz pela própria localização, aceita Godot em `tools/local/`, no PATH ou no caminho indicado por `CHRONUS_GODOT`, e usa um perfil de teste isolado. Arquivos `.import` mantêm LF via `.gitattributes`, evitando alterações artificiais ao abrir na Godot no Windows.

Saves e configurações usam `user://`, diretório próprio da Godot em cada sistema. O jogo não usa caminhos pessoais nem depende da pasta de Downloads. Nomes de recursos respeitam capitalização para Linux. Compatibility permite OpenGL em máquinas sem Vulkan. A escala inteira pode produzir bordas em resoluções não múltiplas de 640×360. Áudio e gamepad precisam de validação nos três sistemas.

Git remoto: https://github.com/Matheus2sd/caio-jogochronus.git. Sem autenticação local, executar `gh auth login`, depois `gh auth setup-git`, `git fetch origin` e `git push -u origin main`. Nunca usar `--force`.
