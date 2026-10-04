# Decisões de implementação — 2026-10-02

- A solicitação atual autoriza implementação imediata em Godot, prevalecendo sobre a antiga espera pela Fase 7. Originais mantidos intactos.
- Somente Capítulo I, com cinco áreas compactas que agrupam C101–C105. Duração alvo original de 28–35 minutos não é prometida para esta fatia.
- Corrida opcional e combo de três leves seguem o pedido atual, além da base GP01/02.
- Postura será apresentada como reserva de estabilidade que diminui até zero, seguindo o pedido atual. O dano de postura e recuperação mantêm as magnitudes oficiais; essa inversão de representação é explícita.
- Daigo permanece vivo, sem segunda forma sobrenatural. Falas C104 são usadas como texto de trabalho oficial.
- E01: passagem disputada, oponente armado anônimo, Akio jogável. Nada de massacre, ressurreição ou presente reescrito. Ponte física permanece quebrada. Ren conserva recursos ao retornar.
- Arte derivada diretamente das referências será marcada TEMPORARY até revisão final; nenhuma pose será anunciada como animação final.
- Fonte padrão incorporada na Godot; áudio sintetizado original provisório, sem download de obras externas.
- No novo computador, a instrução de 2026-10-02 autoriza baixar Godot 4.5.1 oficial para `tools/local/`, testar o projeto existente, corrigir falhas e publicar commits em `main`; substitui os bloqueios de Godot e autenticação anotados antes.
- A marca do Capítulo I é registrada uma única vez como `marks` + `chapter1_mark_awarded` no save. O menu de Progressão completo permanece pendente e não amplia o escopo para o Capítulo II.
- No remapeamento de teclado, uma tecla já usada abre confirmação para trocar as duas ações ou cancelar, conforme UI/UX oficial. A extensão para entradas de controle requer validação própria.
- A Progressão do Capítulo I mostra L1–L3 e E1 desde a pausa; aplicar/remover as três melhorias de Lâmina só é permitido junto a um ponto seguro sem ameaça. E1 permanece bloqueada pelo marco oficial do Capítulo IV. A primeira marca é entregue ao concluir o Capítulo I, portanto o encerramento a apresenta em consulta; a aplicação real em jogo futuro depende de um descanso posterior, sem iniciar o Capítulo II aqui.

## 2026-10-03 — Production Pass

- Pedido atual autoriza recriação do zero e integração incremental de arte/áudio sobre o capítulo existente. Substitui recortes como estratégia final e a antiga espera entre Fases 6/7. Somente Capítulo I.
- Branch production-pass-chapter1; sem merge automático em main. project.godot já estava alterado localmente antes da fase e fica fora dos commits.
- Referências são direção, não fonte para extrair novamente poses finais. P0 + DOCX prevalecem sobre variante jovem/armadura/textos incompatíveis de Daigo.
- Akio usa 56 px conforme AR02, distinto de Ren; 52 px das pranchas antigas é divergência documentada.
- Pipeline assistida de imagem e processamento de grade/alfa/paleta explicitamente autorizados. Fontes geradas são versionadas; executar exportador é determinístico, gerar novamente não é.

- Fechamento técnico: clipes de parry e derrota podem reagir visualmente sem mudar relógios de combate. Sons em 48 kHz PCM16, 28 efeitos e 11 loops originais; música permanece esboço TEMPORARY. A aprovação humana visual/auditiva não é inferida de testes.
