-- =============================================================================
-- GABARITO SQL — Prática DBML: Partidas Esportivas — ChamaMaisUm (Tópicos 01 a 03)
-- Disciplina: IBD951 — Banco de Dados e Aplicações
-- Professor: Ronan Adriel Zenatti — FATEC Jahu — 2º Semestre/2026
-- SGBD: MariaDB 10.4+ (XAMPP)
-- =============================================================================
--
-- Versão FÍSICA (SQL de verdade) do diagrama de referência do gabarito
-- (Gabarito_Pratica_DBML_Partidas_Esportivas.md). Banco: chamamaisum.
--
-- COMO EXECUTAR (XAMPP): phpMyAdmin > aba "Importar" > escolher este arquivo.
-- Ou no terminal:  C:\xampp\mysql\bin\mysql.exe -u root --default-character-set=utf8mb4 < arquivo.sql
-- ATENÇÃO: o script começa com DROP DATABASE IF EXISTS chamamaisum — se o banco já
-- existir, ele será APAGADO e recriado.
--
-- -----------------------------------------------------------------------------
-- DECISÕES DE MODELAGEM (as mesmas do gabarito DBML)
-- -----------------------------------------------------------------------------
--  * vagas_disponiveis NÃO é coluna: é atributo DERIVADO
--    (total_vagas - inscrições com status 'confirmada'). Guardar esse número à mão
--    seria como o saldo escrito na parede da república: na primeira inscrição que
--    ninguém anotar, ele fica errado.
--  * "Criar do zero" e "completar o time" são a MESMA tabela (partidas): o que
--    muda é só a tela do aplicativo, não os dados guardados.
--  * O organizador ocupa uma vaga automaticamente: isso é regra da aplicação
--    (ao criar a partida, inserir a inscrição do organizador) — o SQL desta
--    etapa não tem gatilho (TRIGGER) para isso.
--  * locais: o endereço é atributo composto, decomposto em colunas. Dois locais
--    não podem ter o MESMO endereço COMPLETO -> UNIQUE sobre a COMBINAÇÃO das
--    colunas (como o cadastro de imóveis da prefeitura: a mesma rua pode ter
--    vários imóveis, mas cada endereço completo aparece uma vez só).
--  * numero é VARCHAR: aceita "S/N" e "120-A" (identificador, não se faz conta).
--  * cep é CHAR(8): tamanho fixo, só dígitos.
--  * Avaliação da partida e avaliação do local são tabelas SEPARADAS: o
--    participante pode avaliar só a partida, só o local, os dois ou nenhum.
--    O local avaliado é o de partidas.local_id, então local_id NÃO se repete.
--  * inscricoes: no DBML a chave era composta (partida_id, usuario_id). No SQL
--    seguimos o Tópico 05, Seção 6.6: PK própria + UNIQUE (partida_id, usuario_id).
--    Por causa do campo deletado_em, uma PK composta impediria reinscrever o mesmo
--    par depois de um soft delete. A UNIQUE mantém a regra "uma inscrição por
--    pessoa, por partida" — sem ela, o mesmo usuário ocuparia duas vagas.
--  * Gestão de acesso básica: tipo_usuario ENUM('administrador', 'usuario').
--
--  Convenções: as 9 regras do Tópico 05 (snake_case, minúsculas, tabelas no
--  plural, PK id_<singular>, FK <singular>_id ou papel semântico — organizador_id,
--  tipos adequados, campos de log em TODA tabela).
-- =============================================================================

SET NAMES utf8mb4;

DROP DATABASE IF EXISTS chamamaisum;

CREATE DATABASE chamamaisum
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE chamamaisum;

-- -----------------------------------------------------------------------------
-- Tabela: usuarios
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS usuarios (
    id_usuario      BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    nome            VARCHAR(255)     NOT NULL,
    email           VARCHAR(255)     NOT NULL,
    senha_hash      VARCHAR(255)     NOT NULL COMMENT 'Hash da senha — nunca a senha em texto puro',
    tipo_usuario    ENUM('administrador', 'usuario') NOT NULL DEFAULT 'usuario'
                                     COMMENT 'administrador mantém o catálogo e modera denúncias',
    criado_em       DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                              ON UPDATE CURRENT_TIMESTAMP,
    deletado_em     DATETIME             NULL,

    CONSTRAINT pk_usuario        PRIMARY KEY (id_usuario),
    CONSTRAINT uq_usuario_email  UNIQUE (email)
);

-- -----------------------------------------------------------------------------
-- Tabela: modalidades — catálogo único mantido pelo administrador
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS modalidades (
    id_modalidade       BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
    nome                VARCHAR(100)      NOT NULL COMMENT 'Ex.: Futebol Society, Vôlei de Quadra, Basquete 3x3',
    jogadores_por_time  TINYINT UNSIGNED  NOT NULL COMMENT 'Quantidade pequena e limitada — Regra 8',
    criado_em           DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em       DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP
                                                   ON UPDATE CURRENT_TIMESTAMP,
    deletado_em         DATETIME              NULL,

    CONSTRAINT pk_modalidade          PRIMARY KEY (id_modalidade),
    CONSTRAINT uq_modalidade_nome     UNIQUE (nome),
    CONSTRAINT ck_modalidade_jogadores CHECK (jogadores_por_time > 0)
);

-- -----------------------------------------------------------------------------
-- Tabela: locais — o mesmo endereço completo não pode ser cadastrado duas vezes
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS locais (
    id_local        BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    nome            VARCHAR(255)     NOT NULL,
    logradouro      VARCHAR(255)     NOT NULL,
    numero          VARCHAR(10)      NOT NULL COMMENT 'Texto, não número — aceita "S/N" e "120-A"',
    bairro          VARCHAR(100)     NOT NULL,
    cidade          VARCHAR(100)     NOT NULL,
    cep             CHAR(8)          NOT NULL COMMENT 'Tamanho fixo, apenas dígitos — Regra 8',
    criado_em       DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                              ON UPDATE CURRENT_TIMESTAMP,
    deletado_em     DATETIME             NULL,

    CONSTRAINT pk_local           PRIMARY KEY (id_local),
    -- UNIQUE COMPOSTO: é a COMBINAÇÃO que não pode repetir (e não cada coluna sozinha)
    CONSTRAINT uq_local_endereco  UNIQUE (logradouro, numero, bairro, cidade, cep)
);

-- -----------------------------------------------------------------------------
-- Tabela: partidas
-- organizador_id: FK pelo PAPEL (Regra 7) — quem criou a partida
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS partidas (
    id_partida      BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
    modalidade_id   BIGINT UNSIGNED   NOT NULL,
    local_id        BIGINT UNSIGNED   NOT NULL,
    organizador_id  BIGINT UNSIGNED   NOT NULL,
    data_hora       DATETIME          NOT NULL,
    total_vagas     TINYINT UNSIGNED  NOT NULL,
    criado_em       DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em   DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP
                                               ON UPDATE CURRENT_TIMESTAMP,
    deletado_em     DATETIME              NULL,

    CONSTRAINT pk_partida              PRIMARY KEY (id_partida),
    CONSTRAINT fk_partida_modalidade   FOREIGN KEY (modalidade_id)
                                       REFERENCES modalidades (id_modalidade)
                                       ON DELETE RESTRICT
                                       ON UPDATE CASCADE,
    CONSTRAINT fk_partida_local        FOREIGN KEY (local_id)
                                       REFERENCES locais (id_local)
                                       ON DELETE RESTRICT
                                       ON UPDATE CASCADE,
    CONSTRAINT fk_partida_organizador  FOREIGN KEY (organizador_id)
                                       REFERENCES usuarios (id_usuario)
                                       ON DELETE RESTRICT
                                       ON UPDATE CASCADE,
    CONSTRAINT ck_partida_vagas        CHECK (total_vagas > 0)
);

-- -----------------------------------------------------------------------------
-- Tabela: inscricoes — N:M entre usuarios e partidas
-- Cancelar = mudar status para 'cancelada' (a vaga volta a ficar disponível)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS inscricoes (
    id_inscricao    BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    partida_id      BIGINT UNSIGNED  NOT NULL,
    usuario_id      BIGINT UNSIGNED  NOT NULL,
    status          ENUM('confirmada', 'cancelada') NOT NULL DEFAULT 'confirmada',
    criado_em       DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                              ON UPDATE CURRENT_TIMESTAMP,
    deletado_em     DATETIME             NULL,

    CONSTRAINT pk_inscricao                 PRIMARY KEY (id_inscricao),
    CONSTRAINT uq_inscricao_partida_usuario UNIQUE (partida_id, usuario_id),
    CONSTRAINT fk_inscricao_partida         FOREIGN KEY (partida_id)
                                            REFERENCES partidas (id_partida)
                                            ON DELETE CASCADE
                                            ON UPDATE CASCADE,
    CONSTRAINT fk_inscricao_usuario         FOREIGN KEY (usuario_id)
                                            REFERENCES usuarios (id_usuario)
                                            ON DELETE RESTRICT
                                            ON UPDATE CASCADE
);

-- -----------------------------------------------------------------------------
-- Tabela: avaliacoes_partidas — opcional; no máximo uma por participante, por partida
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS avaliacoes_partidas (
    id_avaliacao_partida  BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
    partida_id            BIGINT UNSIGNED   NOT NULL,
    usuario_id            BIGINT UNSIGNED   NOT NULL,
    nota                  TINYINT UNSIGNED  NOT NULL COMMENT '1 a 5',
    comentario            TEXT                  NULL COMMENT 'Opcional — pode ficar em branco mesmo com nota',
    criado_em             DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em         DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP
                                                     ON UPDATE CURRENT_TIMESTAMP,
    deletado_em           DATETIME              NULL,

    CONSTRAINT pk_avaliacao_partida                 PRIMARY KEY (id_avaliacao_partida),
    CONSTRAINT uq_avaliacao_partida_partida_usuario UNIQUE (partida_id, usuario_id),
    CONSTRAINT fk_avaliacao_partida_partida         FOREIGN KEY (partida_id)
                                                    REFERENCES partidas (id_partida)
                                                    ON DELETE RESTRICT
                                                    ON UPDATE CASCADE,
    CONSTRAINT fk_avaliacao_partida_usuario         FOREIGN KEY (usuario_id)
                                                    REFERENCES usuarios (id_usuario)
                                                    ON DELETE RESTRICT
                                                    ON UPDATE CASCADE,
    CONSTRAINT ck_avaliacao_partida_nota            CHECK (nota BETWEEN 1 AND 5)
);

-- -----------------------------------------------------------------------------
-- Tabela: avaliacoes_locais — opcional e independente da avaliação da partida
-- Não repete local_id: o local é descoberto por partidas.local_id (uma só fonte da verdade)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS avaliacoes_locais (
    id_avaliacao_local  BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
    partida_id          BIGINT UNSIGNED   NOT NULL,
    usuario_id          BIGINT UNSIGNED   NOT NULL,
    nota                TINYINT UNSIGNED  NOT NULL COMMENT '1 a 5',
    descricao           TEXT                  NULL COMMENT 'Opcional',
    criado_em           DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em       DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP
                                                   ON UPDATE CURRENT_TIMESTAMP,
    deletado_em         DATETIME              NULL,

    CONSTRAINT pk_avaliacao_local                 PRIMARY KEY (id_avaliacao_local),
    CONSTRAINT uq_avaliacao_local_partida_usuario UNIQUE (partida_id, usuario_id),
    CONSTRAINT fk_avaliacao_local_partida         FOREIGN KEY (partida_id)
                                                  REFERENCES partidas (id_partida)
                                                  ON DELETE RESTRICT
                                                  ON UPDATE CASCADE,
    CONSTRAINT fk_avaliacao_local_usuario         FOREIGN KEY (usuario_id)
                                                  REFERENCES usuarios (id_usuario)
                                                  ON DELETE RESTRICT
                                                  ON UPDATE CASCADE,
    CONSTRAINT ck_avaliacao_local_nota            CHECK (nota BETWEEN 1 AND 5)
);
