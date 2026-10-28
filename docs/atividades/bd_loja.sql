-- =============================================================================
-- MODELO LÓGICO — Banco de dados da loja (loja_virtual)
-- Disciplina: IBD951 — Banco de Dados e Aplicações
-- Professor: Ronan Adriel Zenatti — FATEC Jahu — 2º Semestre/2026
-- =============================================================================
--
-- ATENÇÃO: este arquivo NÃO é um script executável. Ele é a "planta" do banco:
-- só descreve QUAIS tabelas existem e QUAIS campos cada uma tem. Todas as linhas
-- são comentários (começam com --), então rodar este arquivo não cria nada.
--
-- O seu trabalho é transformar esta planta em SQL de verdade (DDL):
--   1. CREATE DATABASE loja_virtual (com CHARACTER SET e COLLATE corretos);
--   2. um CREATE TABLE para cada tabela abaixo, na ORDEM em que aparecem;
--   3. escolher o tipo de dado de cada campo e criar as constraints
--      (PRIMARY KEY, FOREIGN KEY, UNIQUE, CHECK, NOT NULL e DEFAULT),
--      seguindo as convenções de nomenclatura do Tópico 05.
--
-- Os tipos de dados e as constraints NÃO estão aqui de propósito: escolhê-los é
-- justamente o exercício. Tente montar sozinho(a) antes de comparar com o script
-- completo da Seção 11 do Tópico 05.
--
-- -----------------------------------------------------------------------------
-- COMO LER CADA LINHA:   tabela (campo, campo, campo, ...)
-- -----------------------------------------------------------------------------
--   PK            chave primária: o "número do RG" do registro, único em cada linha
--   FK -> tabela  chave estrangeira: o campo que "aponta" para a PK de outra tabela
--                 (como o número do CPF anotado na ficha de um pedido de padaria:
--                 a ficha não repete os dados da pessoa, só indica quem ela é)
--   UNIQUE        o valor não pode se repetir em duas linhas da mesma tabela
--   (opcional)    o campo pode ficar vazio (NULL); todo campo SEM essa marca é
--                 obrigatório (NOT NULL)
--
-- Campos de log (Regra 9): criado_em, atualizado_em e deletado_em aparecem em
-- TODAS as tabelas. criado_em e atualizado_em são preenchidos pelo próprio banco;
-- deletado_em é opcional e só recebe valor quando o registro é "apagado".
-- =============================================================================


-- -----------------------------------------------------------------------------
-- 1) clientes — quem compra (e, também, quem atende: ver pedidos.funcionario_id)
-- -----------------------------------------------------------------------------
-- clientes (id_cliente PK, nome, cpf UNIQUE, email UNIQUE, data_nascimento,
--           telefone (opcional), criado_em, atualizado_em, deletado_em (opcional))


-- -----------------------------------------------------------------------------
-- 2) categorias — "corredores" do mercado: agrupam os produtos
-- -----------------------------------------------------------------------------
-- categorias (id_categoria PK, nome UNIQUE, descricao (opcional), ativa,
--             criado_em, atualizado_em, deletado_em (opcional))


-- -----------------------------------------------------------------------------
-- 3) produtos — o que a loja vende (cada produto pertence a UMA categoria)
-- -----------------------------------------------------------------------------
-- produtos (id_produto PK, categoria_id FK -> categorias, nome,
--           descricao (opcional), preco, estoque, ativo,
--           criado_em, atualizado_em, deletado_em (opcional))


-- -----------------------------------------------------------------------------
-- 4) pedidos — a "comanda" da venda
--    Duas FKs apontam para a MESMA tabela (clientes), cada uma com um papel:
--    cliente_id = quem comprou  |  funcionario_id = quem atendeu
-- -----------------------------------------------------------------------------
-- pedidos (id_pedido PK, cliente_id FK -> clientes,
--          funcionario_id FK -> clientes (opcional), data_pedido, status,
--          valor_total, observacoes (opcional),
--          criado_em, atualizado_em, deletado_em (opcional))


-- -----------------------------------------------------------------------------
-- 5) itens_pedidos — cada linha da comanda (tabela associativa entre
--    pedidos e produtos: um pedido tem vários produtos, e um produto aparece
--    em vários pedidos). O mesmo produto não pode se repetir no mesmo pedido.
-- -----------------------------------------------------------------------------
-- itens_pedidos (id_item_pedido PK, pedido_id FK -> pedidos,
--                produto_id FK -> produtos, quantidade, preco_unitario, desconto,
--                criado_em, atualizado_em, deletado_em (opcional))
--                UNIQUE (pedido_id, produto_id)


-- =============================================================================
-- REGRAS DE NEGÓCIO (o que o banco deve garantir — vira DEFAULT, CHECK e ENUM)
-- =============================================================================
-- clientes
--   * cpf e telefone guardam apenas dígitos, sem pontos, traço ou parênteses.
--
-- categorias
--   * ativa: por padrão, toda categoria nova nasce ativa.
--
-- produtos
--   * preco nunca pode ser negativo (é dinheiro: use o tipo exato).
--   * estoque nunca pode ser negativo; por padrão, um produto novo nasce com 0.
--   * ativo: por padrão, todo produto novo nasce ativo.
--   * não é permitido excluir uma categoria que ainda tenha produtos.
--
-- pedidos
--   * status só aceita estes valores: pendente, confirmado, em_separacao,
--     enviado, entregue, cancelado. Por padrão, todo pedido nasce 'pendente'.
--   * valor_total nunca pode ser negativo; por padrão, começa em 0.00.
--   * não é permitido excluir um cliente que tenha pedidos feitos.
--   * se o funcionário que atendeu for excluído, os pedidos continuam existindo,
--     apenas ficam sem atendente registrado.
--
-- itens_pedidos
--   * quantidade deve ser maior que zero.
--   * preco_unitario nunca pode ser negativo: é o preço NO MOMENTO da compra
--     (uma "fotografia" do preço, que não muda se o produto ficar mais caro depois).
--   * desconto é um percentual entre 0 e 100; por padrão, 0.00.
--   * se um pedido for excluído, os seus itens são excluídos junto.
--   * não é permitido excluir um produto que já foi vendido em algum pedido.
--   * se a chave primária de uma tabela "pai" mudar, a mudança acompanha
--     automaticamente as chaves estrangeiras que apontam para ela.
-- =============================================================================
