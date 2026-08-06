---
description: Processa uma aula nova ou alterada em docs/aulas/ — valida com o professor, remodela com gamificação e garante a publicação.
---

Processe o arquivo de aula indicado em `$ARGUMENTS` (caminho dentro de `docs/aulas/`;
se nenhum caminho for informado, olhe `git status`/`git diff` para identificar qual
arquivo em `docs/aulas/` é novo ou foi modificado recentemente e confirme com o
professor qual deles processar antes de continuar).

Siga **exatamente** o pipeline de 3 fases descrito em `CLAUDE.md` (seção "O pipeline:
processando uma aula nova ou alterada"):

1. **Validar** — leia o arquivo e o contexto das aulas vizinhas, e pergunte ao professor
   qualquer ambiguidade, lacuna, inconsistência de nomenclatura ou imagem ausente.
   Não edite nada nesta fase. Pare e espere a resposta antes de prosseguir.
2. **Remodelar** — aplique o gabarito de `templates/AULA_TEMPLATE.md`: mapa
   mental (Mermaid `mindmap`), flashcards (`??? question`), quiz (`<quiz>`), resumo e
   selo de conquista. Atualize `docs/index.md` (status da aula) e o `nav` em
   `mkdocs.yml`.
3. **Garantir publicação** — rode `mkdocs build`, confira que não há warnings novos de
   link/imagem quebrada introduzidos por este arquivo, e valide visualmente com
   `mkdocs serve` se possível.

Ao final, resuma para o professor: o que foi perguntado/decidido na Fase 1, o que foi
adicionado na Fase 2, e o resultado da validação da Fase 3. Não dê `git push` sem
confirmação explícita dele.
