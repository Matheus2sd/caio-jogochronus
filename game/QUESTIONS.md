# Questões e limites

- TODO: executar uma partida humana contínua, sem acelerar deslocamento ou vitórias, antes de declarar o Capítulo I completo.
- TODO: ampliar remapeamento para entradas de controle e confirmar a navegação com gamepad real; o conflito entre teclas já oferece troca ou cancelamento.
- COMPLETE: gravação, backup, marca única e migração de save v1 completo validados em `tools/local/profile` isolado. Os outros testes usam `--test` para preservar o save do usuário.
- TODO: investigar avisos de `ObjectDB instances leaked at exit` e, em algumas execuções headless, streams de áudio ainda em uso ao fechar a Godot. No sandbox, a Godot também informa que não conseguiu ler a lista de certificados raiz; o jogo não usa rede. Não houve erro de cena ou GDScript durante os testes de jogo.
- TODO: validar áudio, controle e interface em outros sistemas após a versão Windows.
- TODO artístico: recortes das pranchas são provisórios e não aprovam interframes nem mudanças de design. Ver `TODO_ASSETS.md`.
- EM ABERTO no cânone: topônimos, símbolo final do clã, fonte final e nomenclatura definitiva dos Ecos. A implementação não fixa essas decisões.
- Cânone preservado: Daigo sobrevive; não é mentor, líder nem servo; a memória não muda o passado; não há revelação antecipada do massacre.
