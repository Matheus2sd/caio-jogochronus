# Produção artística pendente

Todos os recortes desta versão são TEMPORARY até limpeza e animação final.

Validação visual em 2026-10-02: Ren aparece em cena e o fundo provisório agora cobre a tela acima do chão. A grade provisória de Progressão cabe em 640×360 e mantém legível o cartão E1 bloqueado. Ainda é necessário revisar contraste de Ren sobre cenários detalhados, leitura dos golpes, pose de Daigo derrotado mas vivo e escala dos elementos de HUD em uma partida completa.

| Estado | Nome / sistema | Animações e frames aproximados | Tamanho | Referência / motivo |
|---|---|---|---|---|
| TODO | Ren jovem | idle 4, walk 6, run 8, jump_start/jump/fall/land 2 cada, dodge 6, turn 2 | corpo 52; célula 96×96 | Ren_Jovem; pranchas contêm poses isoladas |
| TODO | Ren espada | draw/sheathe 4, leves 3×6, forte 8, guard/parry 3, counter 6 | 96×96/128×96 | mesma fonte; faltam interframes |
| TODO | Ren reações | hurt 3, posture_break 4, heal 6, death 6, interact/echo_interact 4 | 96×96 | mesma fonte; poses reaproveitadas provisoriamente |
| TODO | Akio jovem | movimento 6–8/ação; golpes 6; parry/counter 4–6; reações 3–6 | corpo 52; 96×96 | Akio folhas 01/02; preservar economia gestual |
| TODO | Daigo | idle/guard 4, walk 6, cortes 6–8, hurt 3, derrota ajoelhada 6 | corpo 58; 96×96 | Daigo VISUAL; não usar morte ou fase sobrenatural |
| TODO | H1/H2 | patrol 6, attack 6, guard/hurt 3, break/death 5 | corpo 48; 96×96 | humano base; H2 precisa variação visual final |
| TODO | Tileset final | terra/grama/pedra/madeira/água, bordas e transições | 16×16 | tileset referência; recortes exigem costuras finais |
| TODO | VFX final | slash/heavy/impact/parry/break/heal/eco 4–8 | 32–128 px | Eco e pranchas de combate; implementação procedural provisória |
| TODO | UI final | barras/ícones/menus/diálogo | 640×360 | HUD referência; widgets nativos provisórios |
| TODO | Cartões finais de Progressão | 4 cartões L1/L2/L3/E1; estados disponível/equipado/bloqueado, 1 quadro por estado | grade 2×2 em 640×360; cartão até 235×75 | UI/UX v0.1 e referência HUD; substituir estilo nativo provisório sem alterar nomes/efeitos oficiais |
| TEMPORARY | Áudio | golpes, guarda, parry, cura, Eco; loops ambiente/música | WAV | síntese original; falta direção sonora final |

## Production Pass

A classificação e ordem atuais estão em ASSET_AUDIT.md e ASSET_REBUILD_PLAN.md. Recortar novamente as mesmas pranchas não satisfaz o rebuild. Novas fontes, exports, fichas e evidências devem acompanhar cada pacote.

- Ren: substituido runtime por 26 clips novos, 66 keyposes; TODO interframes exclusivos dos leves 2/3 e revisao de fluidez. Fontes em tools/art_sources/ren.
