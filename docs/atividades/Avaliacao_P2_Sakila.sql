/* =====================================================================
   AVALIAÇÃO P2 — INSERÇÕES, CONSULTAS E EXCLUSÕES NO sakila_pt
   Tópicos 06 a 08 e 10
   Disciplina: Banco de Dados e Aplicações (IBD951)
   Fatec Jahu — GTI — 2º Semestre/2026
   Valor: 4,0 pontos — em dupla

   ---------------------------------------------------------------------
   ONDE ESTÁ O ENUNCIADO COMPLETO
   ---------------------------------------------------------------------
   Portal da disciplina, página "Atividades e Avaliações":

     https://gti-fatec-jahu.github.io/BDA-GTI-2026-2/atividades/Avaliacao_P2_Sakila/

   ---------------------------------------------------------------------
   IDENTIFICAÇÃO DA DUPLA
   ---------------------------------------------------------------------
   Integrante 1: ______________________________________________
   Integrante 2: ______________________________________________
   Número do computador: _______
   ===================================================================== */

USE sakila_pt;


/* #####################################################################
   ATIVIDADE 1 — CADASTRO ENCADEADO: CIDADE E ENDEREÇO           1,5 pt
   Cadeia: paises -> cidades -> enderecos
   ##################################################################### */

/* ---------------------------------------------------------------------
   Passo 1 — Escolher 1 id: consulte o país 'Peru' (id_pais).
   --------------------------------------------------------------------- */





/* ---------------------------------------------------------------------
   Passo 2 — Inserir a cidade 'Cusco' vinculada ao id_pais do passo 1.
   --------------------------------------------------------------------- */





/* ---------------------------------------------------------------------
   Passo 3 — Inserir o endereço vinculado à cidade recém-criada,
   usando o último id gerado (LAST_INSERT_ID()).
   --------------------------------------------------------------------- */






/* #####################################################################
   ATIVIDADE 2 — CONSULTAS COM SELECT                            1,5 pt

   ESCOLHA 1 item da Parte 1 e 1 item da Parte 2 (0,75 pt cada).
   Marque com X os itens escolhidos e responda SOMENTE esses.

   Escolhido na Parte 1:  [ ] 1   [ ] 2
   Escolhido na Parte 2:  [ ] 3   [ ] 4

   Regras:
   - Somente: SELECT, FROM, WHERE, INNER JOIN, ORDER BY, LIMIT.
   - Sem funções e sem GROUP BY.
   - Itens 1 e 2: SEM INNER JOIN.  Item 3: 1 INNER JOIN.  Item 4: 2 INNER JOIN.
   ##################################################################### */

/* ---------------------------------------------------------------------
   PARTE 1 — TABELA ÚNICA (SEM INNER JOIN) — ESCOLHA 1
   --------------------------------------------------------------------- */

/* 1 — filmes NC-17 com duração de no máximo 60 minutos
   Mostrar: titulo, duracao, taxa_aluguel — ordenar por titulo. */





/* 2 — 5 primeiros clientes inativos
   Mostrar: primeiro_nome, ultimo_nome, email — ordenar por ultimo_nome. */





/* ---------------------------------------------------------------------
   PARTE 2 — RELACIONAIS (COM INNER JOIN) — ESCOLHA 1
   --------------------------------------------------------------------- */

/* 3 — cidades do país 'Peru' — cidades + paises
   Mostrar: cidades.cidade, paises.pais — ordenar pelo nome da cidade. */





/* 4 — clientes que moram na cidade 'Aurora'
       clientes + enderecos + cidades
   Mostrar: clientes.primeiro_nome, clientes.ultimo_nome,
            enderecos.logradouro, cidades.cidade
   Ordenar por clientes.primeiro_nome. */






/* #####################################################################
   ATIVIDADE 3 — EXCLUSÃO SEGURA DE REGISTROS (DELETE)           1,0 pt

   Faça a exclusão 3.1 (OBRIGATÓRIA) + ESCOLHA 1 entre 3.2 e 3.3
   (0,5 pt cada). Marque com X a escolhida:   [ ] 3.2   [ ] 3.3

   Em cada exclusão: (1) SELECT pela chave primária,
                     (2) DELETE pela chave primária,
                     (3) o mesmo SELECT de novo — não deve retornar nada.
   ##################################################################### */

/* ---------------------------------------------------------------------
   3.1 — Tabela idiomas (OBRIGATÓRIA)
   Excluir o idioma 'Italiano': id_idioma = 2
   --------------------------------------------------------------------- */





/* ---------------------------------------------------------------------
   3.2 — Tabela pagamentos
   Excluir o pagamento: id_pagamento = 14675
   --------------------------------------------------------------------- */





/* ---------------------------------------------------------------------
   3.3 — Tabela cidades
   Excluir a cidade 'Londres' (Canadá): id_cidade = 313
   --------------------------------------------------------------------- */






/* =====================================================================
   FIM DA AVALIAÇÃO — execute o arquivo inteiro antes de entregar e
   confira se nenhum erro interrompe a execução.
   ===================================================================== */
