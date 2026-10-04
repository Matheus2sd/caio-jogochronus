# Padrão de sprites — Production Pass v1

- Resolução lógica 640×360; pixel de arte inteiro; importação sem mipmaps e filtro nearest.
- Exportar PNG RGBA com fundo realmente transparente. Alfa de personagem binário 0/255; VFX podem usar transparência controlada. Sem matte branco/preto, textos de prancha ou sombras de chão incorporadas.
- Humano-base 48 px, Ren 52 px, Akio 56 px (guia AR02), Daigo 58 px em repouso. Célula 96×96 e pivô (48,80); cortes amplos 128×96 e pivô (64,80). Altura muda naturalmente ao agachar, saltar ou cair.
- Desenho voltado à direita; flip no runtime. Pés no pivô, espada e bainha dentro da célula. Não recentralizar cada quadro pela caixa total da espada.
- `chr_<nome>_<animacao>_v001.png`; uma linha por animação, células iguais. Ficha JSON define nomes, quadros, fps, loop e sincronismo. Fontes e prompts em `tools/art_sources/`.
- Idle 6 fps; walk 10; run 12; ações normalmente 12–16. Ataques usam fases vinculadas a windup/active/recovery reais, não fps para determinar dano. Parry continua 0,15/0,22 s conforme assistência.
- 8–12 cores por humano como alvo; clusters limpos, luz no metal, vermelho discreto de Ren/Akio. Preservar silhueta, não forçar limite se destruir identidade.
- Sem translação de um único recorte vendida como animação nova. Reuso/reversão de poses permitido quando registrado; interframes faltantes ficam TODO.
- Origem: referências aprovadas como direção; geração assistida cria desenhos novos; pós-processamento reproduzível autorizado (grade, alfa, paleta, normalização nearest) com ficha de ajustes. Não editar fontes oficiais.
- Critérios: arma legível sobre fundo claro/escuro, pivô estável, preparação/contato/recuperação distintos, continuidade de volume, contorno sem halos. COMPLETE técnico não equivale a aceite artístico final.

- Akio/Daigo usam células 192×96 e pivô (96,80): os cortes extensos extrapolam 128 px quando ancorados pelos pés. A altura do corpo permanece 56/58 px; somente a margem transparente cresce. Extração por componentes preserva lâminas fora da grade.

- Exports atuais de personagens usam paleta compartilhada de até 24 cores por personagem (o alvo 8–12 é artístico, não aprovação final). `validate_production_assets.py` verifica alfa binário, poses não vazias, margens e linha dos pés.
