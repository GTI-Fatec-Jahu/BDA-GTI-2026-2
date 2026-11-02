-- =============================================================================
-- loja_virtual — ESTRUTURA + CARGA BASE + CARGA COMPLEMENTAR
-- Disciplina: IBD951 — Banco de Dados e Aplicações
-- Professor: Ronan Adriel Zenatti — FATEC Jahu — 2º Semestre/2026
-- SGBD: MariaDB 10.4+ (XAMPP)
--
-- Para uso nos: Tópicos 09 (Agregação), 10 (Inner Join), 11 (Outer Join) e 12 (Stored Procedures/Triggers)
-- Estado do banco ao final: 6 categorias, 6 clientes, 11 produtos, 13 pedidos, 24 itens de pedido
--
-- ATENÇÃO: este script começa com DROP DATABASE IF EXISTS loja_virtual;
-- ele APAGA tudo o que já existir nesse banco e recria do zero.
-- Rodar de novo = voltar ao estado inicial (útil para "resetar" o banco).
--
-- Como executar (no terminal do XAMPP):
--   mysql -u root -p < arquivo.sql
-- ou, já dentro do cliente mysql:  SOURCE caminho/do/arquivo.sql;
-- =============================================================================

-- =============================================================================
-- Schema: loja_virtual
-- Disciplina: IBD951 — Banco de Dados e Aplicações
-- Professor: Ronan Adriel Zenatti — FATEC Jahu
-- Descrição: DDL completo de um sistema de vendas simplificado
-- SGBD: MariaDB 10.4+ (XAMPP)
-- =============================================================================

DROP DATABASE IF EXISTS loja_virtual;

CREATE DATABASE loja_virtual
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE loja_virtual;

-- -----------------------------------------------------------------------------
-- Tabela: clientes
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS clientes (
    id_cliente       BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    nome             VARCHAR(255)     NOT NULL,
    cpf              CHAR(11)         NOT NULL COMMENT 'Apenas dígitos, sem formatação',
    email            VARCHAR(255)     NOT NULL,
    data_nascimento  DATE             NOT NULL,
    telefone         CHAR(11)             NULL COMMENT 'Apenas dígitos',
    criado_em        DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em    DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                              ON UPDATE CURRENT_TIMESTAMP,
    deletado_em      DATETIME             NULL,

    CONSTRAINT pk_cliente  PRIMARY KEY (id_cliente),
    CONSTRAINT uq_cpf      UNIQUE (cpf),
    CONSTRAINT uq_email    UNIQUE (email)

) COMMENT='Cadastro de clientes';

-- -----------------------------------------------------------------------------
-- Tabela: categorias
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS categorias (
    id_categoria  BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    nome          VARCHAR(255)     NOT NULL,
    descricao     TEXT                 NULL,
    ativa         TINYINT(1)       NOT NULL DEFAULT 1,
    criado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                            ON UPDATE CURRENT_TIMESTAMP,
    deletado_em   DATETIME             NULL,

    CONSTRAINT pk_categoria  PRIMARY KEY (id_categoria),
    CONSTRAINT uq_cat_nome   UNIQUE (nome)

);

-- -----------------------------------------------------------------------------
-- Tabela: produtos
-- Referencia categorias (N:1)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS produtos (
    id_produto    BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    categoria_id  BIGINT UNSIGNED  NOT NULL,
    nome          VARCHAR(255)     NOT NULL,
    descricao     TEXT                 NULL,
    preco         DECIMAL(10, 2)   NOT NULL,
    estoque       INT              NOT NULL DEFAULT 0,
    ativo         TINYINT(1)       NOT NULL DEFAULT 1,
    criado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                            ON UPDATE CURRENT_TIMESTAMP,
    deletado_em   DATETIME             NULL,

    CONSTRAINT pk_produto           PRIMARY KEY (id_produto),
    CONSTRAINT fk_produto_categoria FOREIGN KEY (categoria_id)
                                    REFERENCES categorias (id_categoria)
                                    ON DELETE RESTRICT
                                    ON UPDATE CASCADE,
    CONSTRAINT ck_preco             CHECK (preco >= 0),
    CONSTRAINT ck_estoque           CHECK (estoque >= 0)

);

-- -----------------------------------------------------------------------------
-- Tabela: pedidos
-- Demonstra FKs semânticas: cliente_id e funcionario_id referenciam clientes
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS pedidos (
    id_pedido      BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    cliente_id     BIGINT UNSIGNED  NOT NULL,   -- pessoa no papel de comprador
    funcionario_id BIGINT UNSIGNED      NULL,   -- pessoa no papel de atendente
    data_pedido    DATE             NOT NULL,
    status         ENUM(
                       'pendente',
                       'confirmado',
                       'em_separacao',
                       'enviado',
                       'entregue',
                       'cancelado'
                   )                NOT NULL DEFAULT 'pendente',
    valor_total    DECIMAL(12, 2)   NOT NULL DEFAULT 0.00,
    observacoes    TEXT                 NULL,
    criado_em      DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em  DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                             ON UPDATE CURRENT_TIMESTAMP,
    deletado_em    DATETIME             NULL,

    CONSTRAINT pk_pedido             PRIMARY KEY (id_pedido),
    CONSTRAINT fk_pedido_cliente     FOREIGN KEY (cliente_id)
                                     REFERENCES clientes (id_cliente)
                                     ON DELETE RESTRICT
                                     ON UPDATE CASCADE,
    CONSTRAINT fk_pedido_funcionario FOREIGN KEY (funcionario_id)
                                     REFERENCES clientes (id_cliente)
                                     ON DELETE SET NULL
                                     ON UPDATE CASCADE,
    CONSTRAINT ck_valor_total        CHECK (valor_total >= 0)

);

-- -----------------------------------------------------------------------------
-- Tabela: itens_pedidos
-- Resolve o N:M entre pedidos e produtos
-- Armazena snapshot do preço no momento da compra
-- PK surrogate necessária para compatibilidade com deletado_em (Regra 9)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS itens_pedidos (
    id_item_pedido BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    pedido_id      BIGINT UNSIGNED  NOT NULL,
    produto_id     BIGINT UNSIGNED  NOT NULL,
    quantidade     INT UNSIGNED     NOT NULL,
    preco_unitario DECIMAL(10, 2)   NOT NULL COMMENT 'Preço no momento da compra',
    desconto       DECIMAL(5, 2)    NOT NULL DEFAULT 0.00 COMMENT 'Percentual de desconto',
    criado_em      DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em  DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                             ON UPDATE CURRENT_TIMESTAMP,
    deletado_em    DATETIME             NULL,

    CONSTRAINT pk_item_pedido   PRIMARY KEY (id_item_pedido),
    CONSTRAINT uq_item_pedido   UNIQUE (pedido_id, produto_id),
    CONSTRAINT fk_item_pedido   FOREIGN KEY (pedido_id)
                                REFERENCES pedidos (id_pedido)
                                ON DELETE CASCADE
                                ON UPDATE CASCADE,
    CONSTRAINT fk_item_produto  FOREIGN KEY (produto_id)
                                REFERENCES produtos (id_produto)
                                ON DELETE RESTRICT
                                ON UPDATE CASCADE,
    CONSTRAINT ck_item_qtd      CHECK (quantidade > 0),
    CONSTRAINT ck_item_preco    CHECK (preco_unitario >= 0),
    CONSTRAINT ck_item_desconto CHECK (desconto >= 0 AND desconto <= 100)

);

-- -----------------------------------------------------------------------------
-- Carga de dados base (Tópico 07, Seção 2)
-- -----------------------------------------------------------------------------
INSERT INTO categorias (nome, descricao) VALUES
    ('Padaria',    'Pães, bolos e salgados'),
    ('Bebidas',    NULL),
    ('Mercearia',  'Arroz, feijão, macarrão e enlatados'),
    ('Hortifruti', 'Frutas, legumes e verduras'),
    ('Limpeza',    'Produtos de limpeza e higiene'),
    ('Frios',      'Queijos, presuntos e embutidos');

INSERT INTO clientes (nome, cpf, email, data_nascimento, telefone) VALUES
    ('Ana Souza',      '11122233344', 'ana.souza@email.com',      '1990-05-14', '14991234567'),
    ('Bruno Lima',     '22233344455', 'bruno.lima@email.com',     '1988-02-20', '14998887766'),
    ('Carla Mendes',   '33344455566', 'carla.mendes@email.com',   '1992-09-03', '14997654321'),
    ('Diego Alves',    '44455566677', 'diego.alves@email.com',    '1985-11-30', NULL),
    ('Elisa Rocha',    '55566677788', 'elisa.rocha@email.com',    '1995-07-09', NULL),
    ('Fábio Teixeira', '66677788899', 'fabio.teixeira@email.com', '1979-01-25', '14996543210');

INSERT INTO produtos (categoria_id, nome, descricao, preco, estoque) VALUES
    (1, 'Pão francês (kg)',      'Assado todos os dias às 6h',  14.90,  50),
    (1, 'Bolo de fubá',          NULL,                          18.00,  12),
    (3, 'Café torrado 500g',     'Torra média, moído na hora',  17.50,  40),
    (3, 'Arroz 5kg',             NULL,                          29.90,  30),
    (2, 'Refrigerante 2L',       NULL,                           9.99,  24),
    (2, 'Suco de laranja 1L',    'Integral, sem açúcar',         7.50,  18),
    (4, 'Banana prata (kg)',     NULL,                           6.90,  35),
    (4, 'Tomate (kg)',           NULL,                           8.90,   0),
    (5, 'Detergente 500ml',      NULL,                           2.99, 100),
    (6, 'Presunto fatiado (kg)', NULL,                          39.90,   8),
    (6, 'Queijo mussarela (kg)', NULL,                          44.90,   6);

INSERT INTO pedidos (cliente_id, data_pedido, status, valor_total, observacoes) VALUES
    (1, '2026-10-01', 'entregue',   47.30, NULL),
    (2, '2026-10-02', 'enviado',    49.88, 'Entregar após as 18h'),
    (1, '2026-10-05', 'confirmado', 22.50, NULL),
    (3, '2026-10-07', 'pendente',   25.76, NULL),
    (4, '2026-10-08', 'cancelado',  18.00, 'Cliente desistiu');

INSERT INTO itens_pedidos (pedido_id, produto_id, quantidade, preco_unitario) VALUES
    (1, 1, 2, 14.90),
    (1, 3, 1, 17.50),
    (2, 4, 1, 29.90),
    (2, 5, 2,  9.99),
    (3, 6, 3,  7.50),
    (4, 7, 2,  6.90),
    (4, 9, 4,  2.99),
    (5, 2, 1, 18.00);

-- -----------------------------------------------------------------------------
-- Carga complementar (Tópico 09, Seção 2)
-- -----------------------------------------------------------------------------
INSERT INTO pedidos (cliente_id, funcionario_id, data_pedido, status, valor_total, observacoes) VALUES
    (2, 5,    '2026-08-12', 'entregue',  74.60, NULL),
    (1, 5,    '2026-08-25', 'entregue',  44.99, NULL),
    (3, 6,    '2026-09-03', 'entregue',  44.97, NULL),
    (1, NULL, '2026-09-14', 'cancelado', 15.00, 'Pagamento recusado'),
    (2, 6,    '2026-09-20', 'entregue',  48.48, NULL),
    (4, NULL, '2026-09-28', 'entregue',  77.30, NULL),
    (1, 5,    '2026-10-10', 'enviado',   74.94, NULL),
    (3, NULL, '2026-10-12', 'pendente',  50.50, NULL);

INSERT INTO itens_pedidos (pedido_id, produto_id, quantidade, preco_unitario) VALUES
    ( 6, 1, 3, 14.90),
    ( 6, 4, 1, 29.90),
    ( 7, 3, 2, 17.50),
    ( 7, 5, 1,  9.99),
    ( 8, 2, 2, 18.00),
    ( 8, 9, 3,  2.99),
    ( 9, 6, 2,  7.50),
    (10, 1, 1, 14.90),
    (10, 7, 4,  6.90),
    (10, 9, 2,  2.99),
    (11, 4, 2, 29.90),
    (11, 3, 1, 17.50),
    (12, 5, 6,  9.99),
    (12, 6, 2,  7.50),
    (13, 7, 3,  6.90),
    (13, 1, 2, 14.90);
