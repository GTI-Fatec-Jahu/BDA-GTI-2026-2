-- =============================================================================
-- GABARITO SQL — Avaliação DBML: Biblioteca ou Clínica Veterinária (Tópicos 01 a 03)
-- Disciplina: IBD951 — Banco de Dados e Aplicações
-- Professor: Ronan Adriel Zenatti — FATEC Jahu — 2º Semestre/2026
-- SGBD: MariaDB 10.4+ (XAMPP)
-- =============================================================================
--
-- ⚠ MATERIAL DO PROFESSOR — o enunciado diz que o gabarito só é liberado DEPOIS
--   da avaliação. Não publique este arquivo antes disso.
--
-- Versão FÍSICA (SQL de verdade) dos dois cenários da avaliação. Cada cenário vira
-- um banco separado, então dá para rodar o arquivo inteiro de uma vez:
--
--   Cenário A (computador ímpar) -> leiabairro          (Biblioteca Comunitária)
--   Cenário B (computador par)   -> clinica_amigo_fiel  (Clínica Veterinária)
--
-- COMO EXECUTAR (XAMPP): phpMyAdmin > aba "Importar" > escolher este arquivo.
-- Ou no terminal:  C:\xampp\mysql\bin\mysql.exe -u root --default-character-set=utf8mb4 < arquivo.sql
-- ATENÇÃO: cada banco começa com DROP DATABASE IF EXISTS — se já existir um banco
-- com o mesmo nome, ele será APAGADO e recriado.
--
-- -----------------------------------------------------------------------------
-- REGRAS DA AVALIAÇÃO QUE ESTE SCRIPT RESPEITA
-- -----------------------------------------------------------------------------
--  * Exatamente 4 tabelas por cenário: as 3 do cenário + a tabela intermediária
--    que resolve o N:M (emprestimos / atendimentos).
--  * Cada tabela tem a SUA PRÓPRIA chave primária (PK), sem chave composta.
--  * Nenhuma UNIQUE envolve mais de uma coluna. Isso também é coerente com o
--    negócio: o mesmo leitor pode pegar o mesmo livro mais de uma vez, e o mesmo
--    pet pode receber o mesmo procedimento mais de uma vez (a vacina é anual).
--  * As 9 regras de nomenclatura do Tópico 05 (snake_case, minúsculas, tabelas no
--    plural, PK id_<singular>, FK <singular>_id, tipos adequados, campos de log
--    criado_em / atualizado_em / deletado_em em TODA tabela).
--
-- -----------------------------------------------------------------------------
-- ESCOLHA DOS TIPOS (Pergunta 2 da avaliação) — raciocínio resumido
-- -----------------------------------------------------------------------------
--  quantidade -> inteiro sem sinal. Exemplar e dose são contados "de unidade em
--                unidade" (não existe meio exemplar): DECIMAL aceitaria 2,5
--                livros. Tamanho: SMALLINT UNSIGNED (0 a 65.535) para exemplares
--                de um título; TINYINT UNSIGNED (0 a 255) para doses/sessões de
--                um atendimento — o menor caixote que comporta o dado (Regra 8).
--  cpf        -> CHAR(11), só dígitos. Tamanho SEMPRE igual e ninguém faz conta
--                com CPF. INT não comporta 11 dígitos (máx. ~4,29 bilhões) e
--                ainda perderia o zero à esquerda (012...); VARCHAR serviria,
--                mas gasta overhead de tamanho variável num dado de tamanho fixo.
--  cep        -> CHAR(8), só dígitos. Mesmo raciocínio: tamanho fixo, é
--                identificador (não se soma CEP) e INT perderia o zero à
--                esquerda (CEP 01310-100 viraria 1310100).
--  telefone   -> VARCHAR(11), só dígitos (DDD + 8 ou 9 dígitos: o fixo tem 10 e
--                o celular 11, então o tamanho NÃO é sempre igual -> não é CHAR).
-- =============================================================================

SET NAMES utf8mb4;


-- #############################################################################
-- CENÁRIO A — LeiaBairro: Biblioteca Comunitária (computador ÍMPAR)
-- #############################################################################

DROP DATABASE IF EXISTS leiabairro;

CREATE DATABASE leiabairro
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE leiabairro;

-- Corredores da biblioteca: o nome não pode se repetir
CREATE TABLE IF NOT EXISTS categorias (
    id_categoria    BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    nome            VARCHAR(100)     NOT NULL COMMENT 'Ex.: Romance, Didático, Infantil',
    descricao       VARCHAR(255)         NULL,
    criado_em       DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                              ON UPDATE CURRENT_TIMESTAMP,
    deletado_em     DATETIME             NULL,

    CONSTRAINT pk_categoria       PRIMARY KEY (id_categoria),
    CONSTRAINT uq_categoria_nome  UNIQUE (nome)
);

-- 1:N — a FK categoria_id fica em LIVROS (o lado "muitos"): cada livro aponta para
-- UMA categoria, como a etiqueta de corredor colada em cada exemplar. Se a FK
-- ficasse em categorias, cada categoria só conseguiria apontar para UM livro.
CREATE TABLE IF NOT EXISTS livros (
    id_livro            BIGINT UNSIGNED    NOT NULL AUTO_INCREMENT,
    categoria_id        BIGINT UNSIGNED    NOT NULL,
    titulo              VARCHAR(255)       NOT NULL,
    autor               VARCHAR(255)       NOT NULL,
    isbn                CHAR(13)           NOT NULL COMMENT 'Código de 13 dígitos do verso do livro; identifica a edição',
    ano_publicacao      SMALLINT UNSIGNED  NOT NULL COMMENT 'SMALLINT e não YEAR: YEAR só vai de 1901 a 2155 e a biblioteca pode ter obras mais antigas',
    estado_conservacao  VARCHAR(30)        NOT NULL COMMENT 'Texto curto: ótimo, bom, desgastado...',
    quantidade          SMALLINT UNSIGNED  NOT NULL DEFAULT 1 COMMENT 'Exemplares que a biblioteca possui deste título',
    criado_em           DATETIME           NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em       DATETIME           NOT NULL DEFAULT CURRENT_TIMESTAMP
                                                    ON UPDATE CURRENT_TIMESTAMP,
    deletado_em         DATETIME               NULL,

    CONSTRAINT pk_livro            PRIMARY KEY (id_livro),
    CONSTRAINT uq_livro_isbn       UNIQUE (isbn),
    CONSTRAINT fk_livro_categoria  FOREIGN KEY (categoria_id)
                                   REFERENCES categorias (id_categoria)
                                   ON DELETE RESTRICT
                                   ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS leitores (
    id_leitor        BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    nome             VARCHAR(255)     NOT NULL,
    cpf              CHAR(11)         NOT NULL COMMENT 'Apenas dígitos, sem pontos e traço',
    email            VARCHAR(255)     NOT NULL,
    telefone         VARCHAR(11)      NOT NULL COMMENT 'Apenas dígitos, com DDD (10 ou 11 dígitos)',
    cep              CHAR(8)          NOT NULL COMMENT 'Apenas dígitos, sem hífen',
    data_nascimento  DATE             NOT NULL,
    criado_em        DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em    DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                               ON UPDATE CURRENT_TIMESTAMP,
    deletado_em      DATETIME             NULL,

    CONSTRAINT pk_leitor      PRIMARY KEY (id_leitor),
    CONSTRAINT uq_leitor_cpf  UNIQUE (cpf)
);

-- Tabela intermediária do N:M leitores <-> livros. Cada empréstimo é um registro
-- próprio (PK própria, sem UNIQUE entre leitor e livro): o mesmo leitor pode pegar
-- o mesmo livro mais de uma vez, em datas diferentes — como a ficha de retirada
-- da biblioteca, em que cada retirada é uma ficha nova.
CREATE TABLE IF NOT EXISTS emprestimos (
    id_emprestimo           BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    leitor_id               BIGINT UNSIGNED  NOT NULL,
    livro_id                BIGINT UNSIGNED  NOT NULL,
    data_emprestimo         DATE             NOT NULL DEFAULT (CURRENT_DATE) COMMENT 'Data em que o livro saiu',
    data_prevista_devolucao DATE             NOT NULL,
    data_devolucao          DATE                 NULL COMMENT 'NULL enquanto o livro não voltou',
    criado_em               DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em           DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                                      ON UPDATE CURRENT_TIMESTAMP,
    deletado_em             DATETIME             NULL,

    CONSTRAINT pk_emprestimo           PRIMARY KEY (id_emprestimo),
    CONSTRAINT fk_emprestimo_leitor    FOREIGN KEY (leitor_id)
                                       REFERENCES leitores (id_leitor)
                                       ON DELETE RESTRICT
                                       ON UPDATE CASCADE,
    CONSTRAINT fk_emprestimo_livro     FOREIGN KEY (livro_id)
                                       REFERENCES livros (id_livro)
                                       ON DELETE RESTRICT
                                       ON UPDATE CASCADE,
    CONSTRAINT ck_emprestimo_previsao  CHECK (data_prevista_devolucao >= data_emprestimo),
    CONSTRAINT ck_emprestimo_devolucao CHECK (data_devolucao IS NULL OR data_devolucao >= data_emprestimo)
);


-- #############################################################################
-- CENÁRIO B — Clínica Amigo Fiel: Clínica Veterinária (computador PAR)
-- #############################################################################

DROP DATABASE IF EXISTS clinica_amigo_fiel;

CREATE DATABASE clinica_amigo_fiel
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE clinica_amigo_fiel;

-- Tutor = o dono do bicho
CREATE TABLE IF NOT EXISTS tutores (
    id_tutor        BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    nome            VARCHAR(255)     NOT NULL,
    cpf             CHAR(11)         NOT NULL COMMENT 'Apenas dígitos, sem pontos e traço',
    telefone        VARCHAR(11)      NOT NULL COMMENT 'Apenas dígitos, com DDD (10 ou 11 dígitos)',
    email           VARCHAR(255)     NOT NULL,
    cep             CHAR(8)          NOT NULL COMMENT 'Apenas dígitos, sem hífen',
    criado_em       DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                              ON UPDATE CURRENT_TIMESTAMP,
    deletado_em     DATETIME             NULL,

    CONSTRAINT pk_tutor      PRIMARY KEY (id_tutor),
    CONSTRAINT uq_tutor_cpf  UNIQUE (cpf)
);

-- 1:N — a FK tutor_id fica em PETS (o lado "muitos"): cada pet pertence a UM tutor,
-- como o número da comanda anotado em cada item consumido leva de volta à comanda
-- da mesa. Se a FK ficasse em tutores, cada tutor só poderia ter UM pet.
CREATE TABLE IF NOT EXISTS pets (
    id_pet            BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    tutor_id          BIGINT UNSIGNED  NOT NULL,
    nome              VARCHAR(100)     NOT NULL,
    especie           VARCHAR(50)      NOT NULL COMMENT 'Texto curto: cão, gato...',
    raca              VARCHAR(100)         NULL COMMENT 'Opcional: nem todo pet tem raça definida',
    data_nascimento   DATE                 NULL COMMENT 'Opcional',
    criado_em         DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                                ON UPDATE CURRENT_TIMESTAMP,
    deletado_em       DATETIME             NULL,

    CONSTRAINT pk_pet        PRIMARY KEY (id_pet),
    CONSTRAINT fk_pet_tutor  FOREIGN KEY (tutor_id)
                             REFERENCES tutores (id_tutor)
                             ON DELETE RESTRICT
                             ON UPDATE CASCADE
);

-- Catálogo de procedimentos — o "valor de tabela" é o preço de prateleira
CREATE TABLE IF NOT EXISTS procedimentos (
    id_procedimento  BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    nome             VARCHAR(100)     NOT NULL COMMENT 'Ex.: Vacina antirrábica, Banho e tosa, Consulta clínica',
    descricao        TEXT                 NULL,
    valor_tabela     DECIMAL(8, 2)    NOT NULL COMMENT 'Valor de tabela em reais',
    criado_em        DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em    DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                               ON UPDATE CURRENT_TIMESTAMP,
    deletado_em      DATETIME             NULL,

    CONSTRAINT pk_procedimento        PRIMARY KEY (id_procedimento),
    CONSTRAINT uq_procedimento_nome   UNIQUE (nome),
    CONSTRAINT ck_procedimento_valor  CHECK (valor_tabela >= 0)
);

-- Tabela intermediária do N:M pets <-> procedimentos. Cada atendimento é um registro
-- próprio (PK própria, sem UNIQUE entre pet e procedimento): a vacina anual aparece
-- uma vez por ano para o mesmo pet. valor_cobrado é o que de fato foi pago (pode
-- ter desconto) — por isso NÃO é redundância do valor_tabela do catálogo.
CREATE TABLE IF NOT EXISTS atendimentos (
    id_atendimento    BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
    pet_id            BIGINT UNSIGNED   NOT NULL,
    procedimento_id   BIGINT UNSIGNED   NOT NULL,
    data_hora         DATETIME          NOT NULL,
    quantidade        TINYINT UNSIGNED  NOT NULL DEFAULT 1 COMMENT 'Número de doses ou sessões aplicadas',
    valor_cobrado     DECIMAL(8, 2)     NOT NULL COMMENT 'Valor realmente cobrado (pode diferir do valor de tabela)',
    observacoes       TEXT                  NULL,
    criado_em         DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em     DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP
                                                 ON UPDATE CURRENT_TIMESTAMP,
    deletado_em       DATETIME              NULL,

    CONSTRAINT pk_atendimento              PRIMARY KEY (id_atendimento),
    CONSTRAINT fk_atendimento_pet          FOREIGN KEY (pet_id)
                                           REFERENCES pets (id_pet)
                                           ON DELETE RESTRICT
                                           ON UPDATE CASCADE,
    CONSTRAINT fk_atendimento_procedimento FOREIGN KEY (procedimento_id)
                                           REFERENCES procedimentos (id_procedimento)
                                           ON DELETE RESTRICT
                                           ON UPDATE CASCADE,
    CONSTRAINT ck_atendimento_quantidade   CHECK (quantidade > 0),
    CONSTRAINT ck_atendimento_valor        CHECK (valor_cobrado >= 0)
);


-- =============================================================================
-- PERGUNTA 3 (especialização) — como ficaria no SQL, SEM alterar os bancos acima
-- =============================================================================
-- A avaliação pede só a explicação. Para conferência do professor, o esboço abaixo
-- mostra a Estratégia 2 (Tópico 03): a PK da subclasse é, ao mesmo tempo, FK para a
-- tabela geral. Está COMENTADO de propósito (não faz parte das 4 tabelas exigidas).
--
-- Cenário A — tabela geral: livros | especializadas: livros_didaticos (campo
-- exclusivo: disciplina) e livros_infantis (campo exclusivo: faixa_etaria):
--
--   CREATE TABLE livros_didaticos (
--       id_livro     BIGINT UNSIGNED NOT NULL,        -- PK e FK ao mesmo tempo
--       disciplina   VARCHAR(100)    NOT NULL,
--       ...campos de log...,
--       CONSTRAINT pk_livro_didatico  PRIMARY KEY (id_livro),
--       CONSTRAINT fk_livro_didatico_livro FOREIGN KEY (id_livro) REFERENCES livros (id_livro)
--   );
--
-- Cenário B — tabela geral: procedimentos | especializadas: vacinas (campo exclusivo:
-- intervalo_reforco_dias) e banhos_tosas (campo exclusivo: tipo_tosa), cada uma com
-- id_procedimento como PK e FK para procedimentos.
