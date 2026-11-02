-- =============================================================================
-- loja_virtual — ESTRUTURA (5 tabelas VAZIAS)
-- Disciplina: IBD951 — Banco de Dados e Aplicações
-- Professor: Ronan Adriel Zenatti — FATEC Jahu — 2º Semestre/2026
-- SGBD: MariaDB 10.4+ (XAMPP)
--
-- Para uso nos: Tópico 06 (DML: INSERT, UPDATE, DELETE)
-- Estado do banco ao final: 5 tabelas criadas, todas vazias
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

-- Pronto! Agora siga o Tópico 06: os INSERT são feitos por você, passo a passo.
