# Ren — geração integrada image_gen

Referência de identidade: assets_referencia/01_PERSONAGENS/REN_JOVEM/Ren_Jovem_Folha_Producao.png.

Fonte motion: nova folha transparente 8×8, corpo de Ren jovem, cabelo escuro parcialmente preso, faixa vermelha, túnica azul/cinza, espada e bainha. Linhas: idle, walk, run, salto/esquiva, ataque leve, forte, defesa/espada, reações/interações. Sem cenário, legenda ou VFX. Solicitados pixels limpos, poses inteiras, pivôs consistentes. Resultado real 1254×1254; células vazias finais rejeitadas.

Fonte actions: nova folha transparente 4×4 usando motion apenas como referência de identidade. Linhas: quatro guardas/deflexão; quatro poses de tratamento com faixa; quatro poses de queda até corpo horizontal sem gore; quatro poses de sacar/guardar espada. Sem fundo, textos ou sombras. Resultado real 1254×1254; limites de recorte revisados em character.json.

Modo: ferramenta integrada, sem API externa. Exportação determinística via tools/build_character.py ren. Reuso e células selecionadas estão no JSON; gerações não são reproduções determinísticas do modelo.
