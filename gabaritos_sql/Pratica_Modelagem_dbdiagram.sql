-- =============================================================================
-- GABARITO SQL — Prática: Modelagem com dbdiagram.io (Tópicos 01 a 03)
-- Disciplina: IBD951 — Banco de Dados e Aplicações
-- Professor: Ronan Adriel Zenatti — FATEC Jahu — 2º Semestre/2026
-- SGBD: MariaDB 10.4+ (XAMPP)
-- =============================================================================
--
-- Este arquivo é a versão FÍSICA (SQL de verdade) dos 7 modelos do gabarito
-- DBML (Pratica_Modelagem_dbdiagram_Gabarito.md). Cada exercício vira um banco
-- de dados separado, então dá para rodar o arquivo inteiro de uma vez:
--
--   1) agendapet    2) treinozen    3) ondacast    4) caronaviva
--   5) rachaconta   6) playhub      7) trampoja
--
-- COMO EXECUTAR (XAMPP): phpMyAdmin > aba "Importar" > escolher este arquivo.
-- Ou no terminal:  C:\xampp\mysql\bin\mysql.exe -u root --default-character-set=utf8mb4 < arquivo.sql
-- ATENÇÃO: cada banco começa com DROP DATABASE IF EXISTS — se você já tem um banco
-- com o mesmo nome, ele será APAGADO e recriado (é "demolir e reconstruir a obra").
--
-- -----------------------------------------------------------------------------
-- CONVENÇÕES APLICADAS (as 9 regras do Tópico 05, Seção 2)
-- -----------------------------------------------------------------------------
--  1-2) snake_case e minúsculas para tudo que é nome criado por nós.
--  3)   Palavras reservadas do SQL em MAIÚSCULAS.
--  4)   Tabelas no plural.
--  5)   PK = id_ + nome da tabela no singular (BIGINT UNSIGNED AUTO_INCREMENT).
--  6)   FK = nome da tabela referenciada no singular + _id.
--  7)   FK pelo PAPEL quando a mesma tabela é referenciada com funções
--       diferentes (criador_id, pagador_id, avaliador_id, avaliado_id...).
--  8)   Tipo e tamanho adequados ao dado (DECIMAL para dinheiro, CHAR para
--       tamanho fixo, TINYINT para quantidades pequenas...).
--  9)   Toda tabela tem criado_em, atualizado_em e deletado_em.
--
-- DECISÕES DE TRADUÇÃO DBML -> SQL (valem para os 7 bancos):
--
--  * Tabela de junção N:M com PK PRÓPRIA + UNIQUE nas duas FKs.
--    No DBML a chave era composta pelas duas FKs. No SQL seguimos o Tópico 05,
--    Seção 6.6: com o campo deletado_em ("apagar sem apagar de verdade"), uma
--    PK composta impediria reinserir o mesmo par depois de um soft delete. A
--    UNIQUE (fk1, fk2) preserva a regra "o par não se repete". É como a comanda
--    de mesa do restaurante: ela tem número próprio, mas o mesmo prato não
--    aparece duas vezes na mesma comanda.
--
--  * Subclasses (especialização, Estratégia 2 do Tópico 03): a PK da subclasse
--    é, ao mesmo tempo, FK para a superclasse. Não há PK própria — a linha da
--    subclasse "é" a linha da superclasse com ficha técnica extra, como o
--    Detran: o mesmo veículo, com uma ficha adicional.
--
--  * ENUM do DBML vira ENUM inline do MariaDB.
--
--  * atualizado_em usa DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP:
--    o próprio banco carimba a hora da última alteração (no DBML essa parte
--    ficava só em nota, porque o dbdiagram.io não a representa).
--
--  * ON DELETE: RESTRICT por padrão (cartório: não encerra o contrato enquanto
--    houver conta vinculada); CASCADE só onde o filho não existe sem o pai
--    (itens de um agendamento, linhas de junção, subclasses).
--    ON UPDATE CASCADE em todas.
--
--  * CHECK (válido no MariaDB desde a 10.2.1) protege regras de negócio simples:
--    valores não negativos, notas dentro da escala, datas coerentes.
--
--  * Colunas "derivadas" (saldo do RachaConta, por exemplo) NÃO são criadas.
-- =============================================================================

SET NAMES utf8mb4;


-- #############################################################################
-- 1) AGENDAPET — agendamento de serviços para o pet
-- #############################################################################

DROP DATABASE IF EXISTS agendapet;

CREATE DATABASE agendapet
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE agendapet;

-- Quem usa o app (dono do pet ou administrador da petshop)
CREATE TABLE IF NOT EXISTS usuarios (
    id_usuario      BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    nome            VARCHAR(255)     NOT NULL,
    email           VARCHAR(255)     NOT NULL,
    senha_hash      VARCHAR(255)     NOT NULL COMMENT 'Hash da senha — nunca a senha em texto puro',
    tipo_usuario    ENUM('administrador', 'usuario') NOT NULL DEFAULT 'usuario',
    criado_em       DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                              ON UPDATE CURRENT_TIMESTAMP,
    deletado_em     DATETIME             NULL,

    CONSTRAINT pk_usuario        PRIMARY KEY (id_usuario),
    CONSTRAINT uq_usuario_email  UNIQUE (email)
);

-- 1:N — um usuário tem vários pets; cada pet tem um único dono
CREATE TABLE IF NOT EXISTS pets (
    id_pet            BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    usuario_id        BIGINT UNSIGNED  NOT NULL,
    nome              VARCHAR(100)     NOT NULL,
    especie           VARCHAR(50)      NOT NULL COMMENT 'Ex.: cachorro, gato',
    raca              VARCHAR(100)         NULL,
    data_nascimento   DATE                 NULL,
    criado_em         DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                                ON UPDATE CURRENT_TIMESTAMP,
    deletado_em       DATETIME             NULL,

    CONSTRAINT pk_pet          PRIMARY KEY (id_pet),
    CONSTRAINT fk_pet_usuario  FOREIGN KEY (usuario_id)
                               REFERENCES usuarios (id_usuario)
                               ON DELETE RESTRICT
                               ON UPDATE CASCADE
);

-- Catálogo único de serviços (banho, tosa, vacina...)
CREATE TABLE IF NOT EXISTS servicos (
    id_servico        BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
    nome              VARCHAR(100)      NOT NULL,
    preco_base        DECIMAL(8, 2)     NOT NULL,
    duracao_minutos   SMALLINT UNSIGNED NOT NULL,
    criado_em         DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em     DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP
                                                 ON UPDATE CURRENT_TIMESTAMP,
    deletado_em       DATETIME              NULL,

    CONSTRAINT pk_servico          PRIMARY KEY (id_servico),
    CONSTRAINT uq_servico_nome     UNIQUE (nome),
    CONSTRAINT ck_servico_preco    CHECK (preco_base >= 0),
    CONSTRAINT ck_servico_duracao  CHECK (duracao_minutos > 0)
);

-- 1:N a partir de pets — quem recebe o serviço é o pet; o dono é alcançado por pets.usuario_id
CREATE TABLE IF NOT EXISTS agendamentos (
    id_agendamento  BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    pet_id          BIGINT UNSIGNED  NOT NULL,
    data_hora       DATETIME         NOT NULL,
    criado_em       DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                              ON UPDATE CURRENT_TIMESTAMP,
    deletado_em     DATETIME             NULL,

    CONSTRAINT pk_agendamento      PRIMARY KEY (id_agendamento),
    CONSTRAINT fk_agendamento_pet  FOREIGN KEY (pet_id)
                                   REFERENCES pets (id_pet)
                                   ON DELETE RESTRICT
                                   ON UPDATE CASCADE
);

-- N:M agendamentos <-> servicos, com o atributo do próprio relacionamento (preco_cobrado)
CREATE TABLE IF NOT EXISTS itens_agendamento (
    id_item_agendamento  BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    agendamento_id       BIGINT UNSIGNED  NOT NULL,
    servico_id           BIGINT UNSIGNED  NOT NULL,
    preco_cobrado        DECIMAL(8, 2)    NOT NULL COMMENT 'Snapshot do preço no momento do agendamento',
    criado_em            DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em        DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                                   ON UPDATE CURRENT_TIMESTAMP,
    deletado_em          DATETIME             NULL,

    CONSTRAINT pk_item_agendamento               PRIMARY KEY (id_item_agendamento),
    CONSTRAINT uq_item_agendamento_agend_serv    UNIQUE (agendamento_id, servico_id),
    CONSTRAINT fk_item_agendamento_agendamento   FOREIGN KEY (agendamento_id)
                                                 REFERENCES agendamentos (id_agendamento)
                                                 ON DELETE CASCADE
                                                 ON UPDATE CASCADE,
    CONSTRAINT fk_item_agendamento_servico       FOREIGN KEY (servico_id)
                                                 REFERENCES servicos (id_servico)
                                                 ON DELETE RESTRICT
                                                 ON UPDATE CASCADE,
    CONSTRAINT ck_item_agendamento_preco         CHECK (preco_cobrado >= 0)
);


-- #############################################################################
-- 2) TREINOZEN — gestão de treinos e rotina fitness
-- #############################################################################

DROP DATABASE IF EXISTS treinozen;

CREATE DATABASE treinozen
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE treinozen;

CREATE TABLE IF NOT EXISTS usuarios (
    id_usuario      BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    nome            VARCHAR(255)     NOT NULL,
    email           VARCHAR(255)     NOT NULL,
    senha_hash      VARCHAR(255)     NOT NULL COMMENT 'Hash da senha — nunca a senha em texto puro',
    tipo_usuario    ENUM('administrador', 'usuario') NOT NULL DEFAULT 'usuario',
    criado_em       DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                              ON UPDATE CURRENT_TIMESTAMP,
    deletado_em     DATETIME             NULL,

    CONSTRAINT pk_usuario        PRIMARY KEY (id_usuario),
    CONSTRAINT uq_usuario_email  UNIQUE (email)
);

-- Catálogo único de exercícios (o "pacote de orégano" que várias receitas usam)
CREATE TABLE IF NOT EXISTS exercicios (
    id_exercicio    BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    nome            VARCHAR(255)     NOT NULL,
    grupo_muscular  VARCHAR(100)     NOT NULL,
    instrucoes      TEXT                 NULL,
    criado_em       DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                              ON UPDATE CURRENT_TIMESTAMP,
    deletado_em     DATETIME             NULL,

    CONSTRAINT pk_exercicio       PRIMARY KEY (id_exercicio),
    CONSTRAINT uq_exercicio_nome  UNIQUE (nome)
);

-- 1:N — cada rotina de treino pertence a um usuário
CREATE TABLE IF NOT EXISTS treinos (
    id_treino       BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    usuario_id      BIGINT UNSIGNED  NOT NULL,
    nome            VARCHAR(255)     NOT NULL,
    criado_em       DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                              ON UPDATE CURRENT_TIMESTAMP,
    deletado_em     DATETIME             NULL,

    CONSTRAINT pk_treino          PRIMARY KEY (id_treino),
    CONSTRAINT fk_treino_usuario  FOREIGN KEY (usuario_id)
                                  REFERENCES usuarios (id_usuario)
                                  ON DELETE RESTRICT
                                  ON UPDATE CASCADE
);

-- N:M treinos <-> exercicios, com ordem, séries, repetições e carga planejadas
CREATE TABLE IF NOT EXISTS itens_treino (
    id_item_treino  BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
    treino_id       BIGINT UNSIGNED   NOT NULL,
    exercicio_id    BIGINT UNSIGNED   NOT NULL,
    ordem           TINYINT UNSIGNED  NOT NULL COMMENT 'Ordem de execução dentro do treino',
    series          TINYINT UNSIGNED  NOT NULL,
    repeticoes      TINYINT UNSIGNED  NOT NULL,
    carga_kg        DECIMAL(5, 2)     NOT NULL,
    criado_em       DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em   DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP
                                               ON UPDATE CURRENT_TIMESTAMP,
    deletado_em     DATETIME              NULL,

    CONSTRAINT pk_item_treino                PRIMARY KEY (id_item_treino),
    CONSTRAINT uq_item_treino_treino_exerc   UNIQUE (treino_id, exercicio_id),
    CONSTRAINT fk_item_treino_treino         FOREIGN KEY (treino_id)
                                             REFERENCES treinos (id_treino)
                                             ON DELETE CASCADE
                                             ON UPDATE CASCADE,
    CONSTRAINT fk_item_treino_exercicio      FOREIGN KEY (exercicio_id)
                                             REFERENCES exercicios (id_exercicio)
                                             ON DELETE RESTRICT
                                             ON UPDATE CASCADE,
    CONSTRAINT ck_item_treino_ordem          CHECK (ordem > 0),
    CONSTRAINT ck_item_treino_series         CHECK (series > 0),
    CONSTRAINT ck_item_treino_repeticoes     CHECK (repeticoes > 0),
    CONSTRAINT ck_item_treino_carga          CHECK (carga_kg >= 0)
);

-- Cada vez que o usuário realmente treina. NÃO repete usuario_id: o usuário já é
-- alcançado por execucoes_treino.treino_id -> treinos.usuario_id (uma só fonte da verdade)
CREATE TABLE IF NOT EXISTS execucoes_treino (
    id_execucao_treino  BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
    treino_id           BIGINT UNSIGNED   NOT NULL,
    executado_em        DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP,
    duracao_minutos     INT UNSIGNED      NOT NULL,
    esforco_percebido   TINYINT UNSIGNED  NOT NULL COMMENT 'Escala de 1 a 10',
    criado_em           DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em       DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP
                                                   ON UPDATE CURRENT_TIMESTAMP,
    deletado_em         DATETIME              NULL,

    CONSTRAINT pk_execucao_treino           PRIMARY KEY (id_execucao_treino),
    CONSTRAINT fk_execucao_treino_treino    FOREIGN KEY (treino_id)
                                            REFERENCES treinos (id_treino)
                                            ON DELETE RESTRICT
                                            ON UPDATE CASCADE,
    CONSTRAINT ck_execucao_treino_duracao   CHECK (duracao_minutos > 0),
    CONSTRAINT ck_execucao_treino_esforco   CHECK (esforco_percebido BETWEEN 1 AND 10)
);


-- #############################################################################
-- 3) ONDACAST — streaming de podcasts e audiolivros
-- #############################################################################

DROP DATABASE IF EXISTS ondacast;

CREATE DATABASE ondacast
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE ondacast;

CREATE TABLE IF NOT EXISTS usuarios (
    id_usuario      BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    nome            VARCHAR(255)     NOT NULL,
    email           VARCHAR(255)     NOT NULL,
    senha_hash      VARCHAR(255)     NOT NULL COMMENT 'Hash da senha — nunca a senha em texto puro',
    tipo_usuario    ENUM('administrador', 'usuario') NOT NULL DEFAULT 'usuario',
    criado_em       DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                              ON UPDATE CURRENT_TIMESTAMP,
    deletado_em     DATETIME             NULL,

    CONSTRAINT pk_usuario        PRIMARY KEY (id_usuario),
    CONSTRAINT uq_usuario_email  UNIQUE (email)
);

CREATE TABLE IF NOT EXISTS planos (
    id_plano                  BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    nome                      VARCHAR(100)     NOT NULL,
    preco_mensal              DECIMAL(8, 2)    NOT NULL,
    limite_downloads_offline  INT UNSIGNED     NOT NULL,
    criado_em                 DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em             DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                                        ON UPDATE CURRENT_TIMESTAMP,
    deletado_em               DATETIME             NULL,

    CONSTRAINT pk_plano         PRIMARY KEY (id_plano),
    CONSTRAINT uq_plano_nome    UNIQUE (nome),
    CONSTRAINT ck_plano_preco   CHECK (preco_mensal >= 0)
);

-- Histórico de assinaturas (não o estado atual): o plano vigente é a assinatura
-- do usuário com data_fim IS NULL. Como a conta de internet: a operadora guarda
-- todos os planos que você já teve. "Um plano por vez" é regra da aplicação.
CREATE TABLE IF NOT EXISTS assinaturas (
    id_assinatura   BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    usuario_id      BIGINT UNSIGNED  NOT NULL,
    plano_id        BIGINT UNSIGNED  NOT NULL,
    data_inicio     DATE             NOT NULL,
    data_fim        DATE                 NULL COMMENT 'NULL enquanto a assinatura estiver ativa',
    criado_em       DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                              ON UPDATE CURRENT_TIMESTAMP,
    deletado_em     DATETIME             NULL,

    CONSTRAINT pk_assinatura          PRIMARY KEY (id_assinatura),
    CONSTRAINT fk_assinatura_usuario  FOREIGN KEY (usuario_id)
                                      REFERENCES usuarios (id_usuario)
                                      ON DELETE RESTRICT
                                      ON UPDATE CASCADE,
    CONSTRAINT fk_assinatura_plano    FOREIGN KEY (plano_id)
                                      REFERENCES planos (id_plano)
                                      ON DELETE RESTRICT
                                      ON UPDATE CASCADE,
    CONSTRAINT ck_assinatura_datas    CHECK (data_fim IS NULL OR data_fim >= data_inicio)
);

CREATE TABLE IF NOT EXISTS podcasts (
    id_podcast      BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    titulo          VARCHAR(255)     NOT NULL,
    categoria       VARCHAR(100)     NOT NULL,
    apresentador    VARCHAR(255)     NOT NULL,
    criado_em       DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                              ON UPDATE CURRENT_TIMESTAMP,
    deletado_em     DATETIME             NULL,

    CONSTRAINT pk_podcast  PRIMARY KEY (id_podcast)
);

CREATE TABLE IF NOT EXISTS audiolivros (
    id_audiolivro       BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    titulo              VARCHAR(255)     NOT NULL,
    autor               VARCHAR(255)     NOT NULL,
    narrador_principal  VARCHAR(255)     NOT NULL,
    criado_em           DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em       DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                                  ON UPDATE CURRENT_TIMESTAMP,
    deletado_em         DATETIME             NULL,

    CONSTRAINT pk_audiolivro  PRIMARY KEY (id_audiolivro)
);

-- SUPERCLASSE: o que todo áudio tem em comum (episódio OU capítulo)
CREATE TABLE IF NOT EXISTS conteudos (
    id_conteudo       BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    titulo            VARCHAR(255)     NOT NULL,
    duracao_segundos  INT UNSIGNED     NOT NULL,
    data_publicacao   DATE             NOT NULL,
    criado_em         DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                                ON UPDATE CURRENT_TIMESTAMP,
    deletado_em       DATETIME             NULL,

    CONSTRAINT pk_conteudo          PRIMARY KEY (id_conteudo),
    CONSTRAINT ck_conteudo_duracao  CHECK (duracao_segundos > 0)
);

-- SUBCLASSE: a PK é, ao mesmo tempo, FK única para a superclasse (Estratégia 2).
-- Observação: a regra "todo conteúdo é episódio OU capítulo, nunca os dois" (hierarquia
-- Total Exclusiva) não é garantida só pelo desenho das tabelas; reforça-se na
-- aplicação ou com uma coluna discriminadora extra em conteudos.
CREATE TABLE IF NOT EXISTS episodios_podcast (
    id_conteudo             BIGINT UNSIGNED  NOT NULL,
    podcast_id              BIGINT UNSIGNED  NOT NULL,
    numero_episodio         INT UNSIGNED     NOT NULL,
    transcricao_disponivel  BOOLEAN          NOT NULL DEFAULT 0,
    criado_em               DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em           DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                                      ON UPDATE CURRENT_TIMESTAMP,
    deletado_em             DATETIME             NULL,

    CONSTRAINT pk_episodio_podcast           PRIMARY KEY (id_conteudo),
    CONSTRAINT fk_episodio_podcast_conteudo  FOREIGN KEY (id_conteudo)
                                             REFERENCES conteudos (id_conteudo)
                                             ON DELETE CASCADE
                                             ON UPDATE CASCADE,
    CONSTRAINT fk_episodio_podcast_podcast   FOREIGN KEY (podcast_id)
                                             REFERENCES podcasts (id_podcast)
                                             ON DELETE RESTRICT
                                             ON UPDATE CASCADE,
    CONSTRAINT ck_episodio_podcast_numero    CHECK (numero_episodio > 0)
);

CREATE TABLE IF NOT EXISTS capitulos_audiolivro (
    id_conteudo      BIGINT UNSIGNED  NOT NULL,
    audiolivro_id    BIGINT UNSIGNED  NOT NULL,
    numero_capitulo  INT UNSIGNED     NOT NULL,
    narrador         VARCHAR(255)     NOT NULL,
    criado_em        DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em    DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                               ON UPDATE CURRENT_TIMESTAMP,
    deletado_em      DATETIME             NULL,

    CONSTRAINT pk_capitulo_audiolivro            PRIMARY KEY (id_conteudo),
    CONSTRAINT fk_capitulo_audiolivro_conteudo   FOREIGN KEY (id_conteudo)
                                                 REFERENCES conteudos (id_conteudo)
                                                 ON DELETE CASCADE
                                                 ON UPDATE CASCADE,
    CONSTRAINT fk_capitulo_audiolivro_audiolivro FOREIGN KEY (audiolivro_id)
                                                 REFERENCES audiolivros (id_audiolivro)
                                                 ON DELETE RESTRICT
                                                 ON UPDATE CASCADE,
    CONSTRAINT ck_capitulo_audiolivro_numero     CHECK (numero_capitulo > 0)
);

CREATE TABLE IF NOT EXISTS playlists (
    id_playlist     BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    usuario_id      BIGINT UNSIGNED  NOT NULL,
    nome            VARCHAR(255)     NOT NULL,
    criado_em       DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                              ON UPDATE CURRENT_TIMESTAMP,
    deletado_em     DATETIME             NULL,

    CONSTRAINT pk_playlist          PRIMARY KEY (id_playlist),
    CONSTRAINT fk_playlist_usuario  FOREIGN KEY (usuario_id)
                                    REFERENCES usuarios (id_usuario)
                                    ON DELETE RESTRICT
                                    ON UPDATE CASCADE
);

-- N:M playlists <-> conteudos. Aponta para a SUPERCLASSE: é isso que permite
-- misturar episódios e capítulos na mesma playlist, em qualquer ordem.
CREATE TABLE IF NOT EXISTS itens_playlist (
    id_item_playlist  BIGINT UNSIGNED    NOT NULL AUTO_INCREMENT,
    playlist_id       BIGINT UNSIGNED    NOT NULL,
    conteudo_id       BIGINT UNSIGNED    NOT NULL,
    ordem             SMALLINT UNSIGNED  NOT NULL,
    criado_em         DATETIME           NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em     DATETIME           NOT NULL DEFAULT CURRENT_TIMESTAMP
                                                  ON UPDATE CURRENT_TIMESTAMP,
    deletado_em       DATETIME               NULL,

    CONSTRAINT pk_item_playlist                PRIMARY KEY (id_item_playlist),
    CONSTRAINT uq_item_playlist_playl_conteudo UNIQUE (playlist_id, conteudo_id),
    CONSTRAINT fk_item_playlist_playlist       FOREIGN KEY (playlist_id)
                                               REFERENCES playlists (id_playlist)
                                               ON DELETE CASCADE
                                               ON UPDATE CASCADE,
    CONSTRAINT fk_item_playlist_conteudo       FOREIGN KEY (conteudo_id)
                                               REFERENCES conteudos (id_conteudo)
                                               ON DELETE RESTRICT
                                               ON UPDATE CASCADE,
    CONSTRAINT ck_item_playlist_ordem          CHECK (ordem > 0)
);


-- #############################################################################
-- 4) CARONAVIVA — caronas urbanas compartilhadas
-- #############################################################################

DROP DATABASE IF EXISTS caronaviva;

CREATE DATABASE caronaviva
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE caronaviva;

-- SUPERCLASSE — também é a tabela de login (a pessoa é o usuário; não há tabela usuarios paralela)
CREATE TABLE IF NOT EXISTS pessoas (
    id_pessoa       BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    nome            VARCHAR(255)     NOT NULL,
    cpf             CHAR(11)         NOT NULL COMMENT 'Apenas dígitos, sem formatação',
    email           VARCHAR(255)     NOT NULL,
    telefone        VARCHAR(20)      NOT NULL,
    senha_hash      VARCHAR(255)     NOT NULL COMMENT 'Hash da senha — nunca a senha em texto puro',
    tipo_usuario    ENUM('administrador', 'usuario') NOT NULL DEFAULT 'usuario',
    criado_em       DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                              ON UPDATE CURRENT_TIMESTAMP,
    deletado_em     DATETIME             NULL,

    CONSTRAINT pk_pessoa        PRIMARY KEY (id_pessoa),
    CONSTRAINT uq_pessoa_cpf    UNIQUE (cpf),
    CONSTRAINT uq_pessoa_email  UNIQUE (email)
);

-- SUBCLASSE (parcial e sobreposta: a pessoa pode ser motorista, passageira, as duas ou nenhuma)
-- cnh e placa têm tamanho SEMPRE igual -> CHAR (Tabela de Tipos da atividade)
CREATE TABLE IF NOT EXISTS motoristas (
    id_pessoa       BIGINT UNSIGNED  NOT NULL,
    cnh             CHAR(11)         NOT NULL COMMENT 'Apenas dígitos',
    placa_veiculo   CHAR(7)          NOT NULL,
    modelo_veiculo  VARCHAR(100)     NOT NULL,
    criado_em       DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                              ON UPDATE CURRENT_TIMESTAMP,
    deletado_em     DATETIME             NULL,

    CONSTRAINT pk_motorista         PRIMARY KEY (id_pessoa),
    CONSTRAINT uq_motorista_cnh     UNIQUE (cnh),
    CONSTRAINT uq_motorista_placa   UNIQUE (placa_veiculo),
    CONSTRAINT fk_motorista_pessoa  FOREIGN KEY (id_pessoa)
                                    REFERENCES pessoas (id_pessoa)
                                    ON DELETE CASCADE
                                    ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS passageiros (
    id_pessoa                  BIGINT UNSIGNED  NOT NULL,
    endereco_padrao_embarque   VARCHAR(255)         NULL,
    criado_em                  DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em              DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                                         ON UPDATE CURRENT_TIMESTAMP,
    deletado_em                DATETIME             NULL,

    CONSTRAINT pk_passageiro         PRIMARY KEY (id_pessoa),
    CONSTRAINT fk_passageiro_pessoa  FOREIGN KEY (id_pessoa)
                                     REFERENCES pessoas (id_pessoa)
                                     ON DELETE CASCADE
                                     ON UPDATE CASCADE
);

-- Só motorista oferece carona: a FK aponta para motoristas, não para pessoas
CREATE TABLE IF NOT EXISTS caronas (
    id_carona          BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
    motorista_id       BIGINT UNSIGNED   NOT NULL,
    origem             VARCHAR(255)      NOT NULL,
    destino            VARCHAR(255)      NOT NULL,
    data_hora_saida    DATETIME          NOT NULL,
    vagas_disponiveis  TINYINT UNSIGNED  NOT NULL,
    valor_por_vaga     DECIMAL(8, 2)     NOT NULL,
    criado_em          DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em      DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP
                                                  ON UPDATE CURRENT_TIMESTAMP,
    deletado_em        DATETIME              NULL,

    CONSTRAINT pk_carona            PRIMARY KEY (id_carona),
    CONSTRAINT fk_carona_motorista  FOREIGN KEY (motorista_id)
                                    REFERENCES motoristas (id_pessoa)
                                    ON DELETE RESTRICT
                                    ON UPDATE CASCADE,
    CONSTRAINT ck_carona_valor      CHECK (valor_por_vaga >= 0)
);

-- N:M caronas <-> passageiros
CREATE TABLE IF NOT EXISTS reservas_carona (
    id_reserva_carona  BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    carona_id          BIGINT UNSIGNED  NOT NULL,
    passageiro_id      BIGINT UNSIGNED  NOT NULL,
    status             ENUM('solicitada', 'confirmada', 'cancelada', 'concluida')
                                        NOT NULL DEFAULT 'solicitada',
    criado_em          DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em      DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                                 ON UPDATE CURRENT_TIMESTAMP,
    deletado_em        DATETIME             NULL,

    CONSTRAINT pk_reserva_carona               PRIMARY KEY (id_reserva_carona),
    CONSTRAINT uq_reserva_carona_carona_pass   UNIQUE (carona_id, passageiro_id),
    CONSTRAINT fk_reserva_carona_carona        FOREIGN KEY (carona_id)
                                               REFERENCES caronas (id_carona)
                                               ON DELETE CASCADE
                                               ON UPDATE CASCADE,
    CONSTRAINT fk_reserva_carona_passageiro    FOREIGN KEY (passageiro_id)
                                               REFERENCES passageiros (id_pessoa)
                                               ON DELETE RESTRICT
                                               ON UPDATE CASCADE
);

-- Avaliação mútua: avaliador_id e avaliado_id apontam para a MESMA tabela
-- (pessoas) em papéis diferentes -> Regra 7 (nunca pessoa1_id / pessoa2_id)
CREATE TABLE IF NOT EXISTS avaliacoes (
    id_avaliacao    BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
    carona_id       BIGINT UNSIGNED   NOT NULL,
    avaliador_id    BIGINT UNSIGNED   NOT NULL,
    avaliado_id     BIGINT UNSIGNED   NOT NULL,
    nota            TINYINT UNSIGNED  NOT NULL COMMENT '1 a 5',
    comentario      TEXT                  NULL,
    criado_em       DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em   DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP
                                               ON UPDATE CURRENT_TIMESTAMP,
    deletado_em     DATETIME              NULL,

    CONSTRAINT pk_avaliacao            PRIMARY KEY (id_avaliacao),
    CONSTRAINT fk_avaliacao_carona     FOREIGN KEY (carona_id)
                                       REFERENCES caronas (id_carona)
                                       ON DELETE RESTRICT
                                       ON UPDATE CASCADE,
    CONSTRAINT fk_avaliacao_avaliador  FOREIGN KEY (avaliador_id)
                                       REFERENCES pessoas (id_pessoa)
                                       ON DELETE RESTRICT
                                       ON UPDATE CASCADE,
    CONSTRAINT fk_avaliacao_avaliado   FOREIGN KEY (avaliado_id)
                                       REFERENCES pessoas (id_pessoa)
                                       ON DELETE RESTRICT
                                       ON UPDATE CASCADE,
    CONSTRAINT ck_avaliacao_nota       CHECK (nota BETWEEN 1 AND 5)
);


-- #############################################################################
-- 5) RACHACONTA — divisão de contas entre amigos
-- #############################################################################

DROP DATABASE IF EXISTS rachaconta;

CREATE DATABASE rachaconta
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE rachaconta;

CREATE TABLE IF NOT EXISTS usuarios (
    id_usuario      BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    nome            VARCHAR(255)     NOT NULL,
    email           VARCHAR(255)     NOT NULL,
    senha_hash      VARCHAR(255)     NOT NULL COMMENT 'Hash da senha — nunca a senha em texto puro',
    tipo_usuario    ENUM('administrador', 'usuario') NOT NULL DEFAULT 'usuario',
    criado_em       DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                              ON UPDATE CURRENT_TIMESTAMP,
    deletado_em     DATETIME             NULL,

    CONSTRAINT pk_usuario        PRIMARY KEY (id_usuario),
    CONSTRAINT uq_usuario_email  UNIQUE (email)
);

-- criador_id: papel "criador" (Regra 7), não um usuario_id genérico
CREATE TABLE IF NOT EXISTS grupos (
    id_grupo        BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    criador_id      BIGINT UNSIGNED  NOT NULL,
    nome            VARCHAR(255)     NOT NULL,
    criado_em       DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                              ON UPDATE CURRENT_TIMESTAMP,
    deletado_em     DATETIME             NULL,

    CONSTRAINT pk_grupo          PRIMARY KEY (id_grupo),
    CONSTRAINT fk_grupo_criador  FOREIGN KEY (criador_id)
                                 REFERENCES usuarios (id_usuario)
                                 ON DELETE RESTRICT
                                 ON UPDATE CASCADE
);

-- N:M usuarios <-> grupos: "quem está no grupo"
CREATE TABLE IF NOT EXISTS membros_grupo (
    id_membro_grupo  BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    grupo_id         BIGINT UNSIGNED  NOT NULL,
    usuario_id       BIGINT UNSIGNED  NOT NULL,
    entrou_em        DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    criado_em        DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em    DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                               ON UPDATE CURRENT_TIMESTAMP,
    deletado_em      DATETIME             NULL,

    CONSTRAINT pk_membro_grupo               PRIMARY KEY (id_membro_grupo),
    CONSTRAINT uq_membro_grupo_grupo_usuario UNIQUE (grupo_id, usuario_id),
    CONSTRAINT fk_membro_grupo_grupo         FOREIGN KEY (grupo_id)
                                             REFERENCES grupos (id_grupo)
                                             ON DELETE CASCADE
                                             ON UPDATE CASCADE,
    CONSTRAINT fk_membro_grupo_usuario       FOREIGN KEY (usuario_id)
                                             REFERENCES usuarios (id_usuario)
                                             ON DELETE RESTRICT
                                             ON UPDATE CASCADE
);

-- pagador_id: papel "pagador" (Regra 7).
-- NÃO existe coluna "saldo" em lugar nenhum: o saldo é atributo DERIVADO,
-- calculado a partir de despesas.valor_total (quem pagou) e
-- participantes_despesa.valor_devido (quem deve). Anotar saldo à mão ficaria
-- desatualizado na primeira despesa nova — como o total do bar, que só se soma no fim.
CREATE TABLE IF NOT EXISTS despesas (
    id_despesa      BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    grupo_id        BIGINT UNSIGNED  NOT NULL,
    pagador_id      BIGINT UNSIGNED  NOT NULL,
    descricao       VARCHAR(255)     NOT NULL,
    valor_total     DECIMAL(10, 2)   NOT NULL,
    data_despesa    DATE             NOT NULL,
    criado_em       DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                              ON UPDATE CURRENT_TIMESTAMP,
    deletado_em     DATETIME             NULL,

    CONSTRAINT pk_despesa          PRIMARY KEY (id_despesa),
    CONSTRAINT fk_despesa_grupo    FOREIGN KEY (grupo_id)
                                   REFERENCES grupos (id_grupo)
                                   ON DELETE RESTRICT
                                   ON UPDATE CASCADE,
    CONSTRAINT fk_despesa_pagador  FOREIGN KEY (pagador_id)
                                   REFERENCES usuarios (id_usuario)
                                   ON DELETE RESTRICT
                                   ON UPDATE CASCADE,
    CONSTRAINT ck_despesa_valor    CHECK (valor_total > 0)
);

-- N:M despesas <-> usuarios: "quem participa DESTA despesa" (subconjunto dos membros)
CREATE TABLE IF NOT EXISTS participantes_despesa (
    id_participante_despesa  BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    despesa_id               BIGINT UNSIGNED  NOT NULL,
    usuario_id               BIGINT UNSIGNED  NOT NULL,
    valor_devido             DECIMAL(10, 2)   NOT NULL,
    criado_em                DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em            DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                                       ON UPDATE CURRENT_TIMESTAMP,
    deletado_em              DATETIME             NULL,

    CONSTRAINT pk_participante_despesa              PRIMARY KEY (id_participante_despesa),
    CONSTRAINT uq_participante_despesa_desp_usuario UNIQUE (despesa_id, usuario_id),
    CONSTRAINT fk_participante_despesa_despesa      FOREIGN KEY (despesa_id)
                                                    REFERENCES despesas (id_despesa)
                                                    ON DELETE CASCADE
                                                    ON UPDATE CASCADE,
    CONSTRAINT fk_participante_despesa_usuario      FOREIGN KEY (usuario_id)
                                                    REFERENCES usuarios (id_usuario)
                                                    ON DELETE RESTRICT
                                                    ON UPDATE CASCADE,
    CONSTRAINT ck_participante_despesa_valor        CHECK (valor_devido >= 0)
);


-- #############################################################################
-- 6) PLAYHUB — marketplace de jogos digitais (com RBAC)
-- #############################################################################

DROP DATABASE IF EXISTS playhub;

CREATE DATABASE playhub
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE playhub;

-- Sem coluna tipo_usuario: o controle de acesso é 100% via papeis/permissoes (RBAC)
CREATE TABLE IF NOT EXISTS usuarios (
    id_usuario      BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    nome_exibicao   VARCHAR(255)     NOT NULL,
    email           VARCHAR(255)     NOT NULL,
    senha_hash      VARCHAR(255)     NOT NULL COMMENT 'Hash da senha — nunca a senha em texto puro',
    criado_em       DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                              ON UPDATE CURRENT_TIMESTAMP,
    deletado_em     DATETIME             NULL,

    CONSTRAINT pk_usuario        PRIMARY KEY (id_usuario),
    CONSTRAINT uq_usuario_email  UNIQUE (email)
);

-- RBAC — "chaveiros" (papéis): administrador, desenvolvedor, suporte, jogador...
CREATE TABLE IF NOT EXISTS papeis (
    id_papel        BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    nome            VARCHAR(100)     NOT NULL COMMENT 'Ex.: administrador, desenvolvedor, suporte, jogador',
    criado_em       DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                              ON UPDATE CURRENT_TIMESTAMP,
    deletado_em     DATETIME             NULL,

    CONSTRAINT pk_papel       PRIMARY KEY (id_papel),
    CONSTRAINT uq_papel_nome  UNIQUE (nome)
);

-- RBAC — "chaves" (permissões): cada uma abre um tipo de porta
CREATE TABLE IF NOT EXISTS permissoes (
    id_permissao    BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    codigo          VARCHAR(100)     NOT NULL COMMENT 'Ex.: gerenciar_catalogo_proprio, processar_reembolso',
    descricao       VARCHAR(255)     NOT NULL,
    criado_em       DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                              ON UPDATE CURRENT_TIMESTAMP,
    deletado_em     DATETIME             NULL,

    CONSTRAINT pk_permissao         PRIMARY KEY (id_permissao),
    CONSTRAINT uq_permissao_codigo  UNIQUE (codigo)
);

-- RBAC N:M — um papel agrupa várias permissões (o chaveiro reúne várias chaves)
CREATE TABLE IF NOT EXISTS papeis_permissoes (
    id_papel_permissao  BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    papel_id            BIGINT UNSIGNED  NOT NULL,
    permissao_id        BIGINT UNSIGNED  NOT NULL,
    criado_em           DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em       DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                                  ON UPDATE CURRENT_TIMESTAMP,
    deletado_em         DATETIME             NULL,

    CONSTRAINT pk_papel_permissao               PRIMARY KEY (id_papel_permissao),
    CONSTRAINT uq_papel_permissao_papel_perm    UNIQUE (papel_id, permissao_id),
    CONSTRAINT fk_papel_permissao_papel         FOREIGN KEY (papel_id)
                                                REFERENCES papeis (id_papel)
                                                ON DELETE CASCADE
                                                ON UPDATE CASCADE,
    CONSTRAINT fk_papel_permissao_permissao     FOREIGN KEY (permissao_id)
                                                REFERENCES permissoes (id_permissao)
                                                ON DELETE CASCADE
                                                ON UPDATE CASCADE
);

-- RBAC N:M — um usuário pode acumular mais de um papel (o zelador que cobre a portaria)
CREATE TABLE IF NOT EXISTS usuarios_papeis (
    id_usuario_papel  BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    usuario_id        BIGINT UNSIGNED  NOT NULL,
    papel_id          BIGINT UNSIGNED  NOT NULL,
    atribuido_em      DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    criado_em         DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                                ON UPDATE CURRENT_TIMESTAMP,
    deletado_em       DATETIME             NULL,

    CONSTRAINT pk_usuario_papel               PRIMARY KEY (id_usuario_papel),
    CONSTRAINT uq_usuario_papel_usuario_papel UNIQUE (usuario_id, papel_id),
    CONSTRAINT fk_usuario_papel_usuario       FOREIGN KEY (usuario_id)
                                              REFERENCES usuarios (id_usuario)
                                              ON DELETE CASCADE
                                              ON UPDATE CASCADE,
    CONSTRAINT fk_usuario_papel_papel         FOREIGN KEY (papel_id)
                                              REFERENCES papeis (id_papel)
                                              ON DELETE RESTRICT
                                              ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS desenvolvedoras (
    id_desenvolvedora  BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    nome_estudio       VARCHAR(255)     NOT NULL,
    pais_sede          VARCHAR(100)     NOT NULL,
    criado_em          DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em      DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                                 ON UPDATE CURRENT_TIMESTAMP,
    deletado_em        DATETIME             NULL,

    CONSTRAINT pk_desenvolvedora  PRIMARY KEY (id_desenvolvedora)
);

-- SUPERCLASSE: todo produto vendido é um jogo-base OU uma DLC (Total Exclusiva)
CREATE TABLE IF NOT EXISTS produtos (
    id_produto         BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    desenvolvedora_id  BIGINT UNSIGNED  NOT NULL,
    titulo             VARCHAR(255)     NOT NULL,
    preco_base         DECIMAL(10, 2)   NOT NULL,
    data_lancamento    DATE             NOT NULL,
    criado_em          DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em      DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                                 ON UPDATE CURRENT_TIMESTAMP,
    deletado_em        DATETIME             NULL,

    CONSTRAINT pk_produto                PRIMARY KEY (id_produto),
    CONSTRAINT fk_produto_desenvolvedora FOREIGN KEY (desenvolvedora_id)
                                         REFERENCES desenvolvedoras (id_desenvolvedora)
                                         ON DELETE RESTRICT
                                         ON UPDATE CASCADE,
    CONSTRAINT ck_produto_preco          CHECK (preco_base >= 0)
);

CREATE TABLE IF NOT EXISTS jogos (
    id_produto            BIGINT UNSIGNED  NOT NULL,
    classificacao_etaria  VARCHAR(10)      NOT NULL,
    tamanho_download_gb   DECIMAL(6, 2)    NOT NULL,
    criado_em             DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em         DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                                    ON UPDATE CURRENT_TIMESTAMP,
    deletado_em           DATETIME             NULL,

    CONSTRAINT pk_jogo          PRIMARY KEY (id_produto),
    CONSTRAINT fk_jogo_produto  FOREIGN KEY (id_produto)
                                REFERENCES produtos (id_produto)
                                ON DELETE CASCADE
                                ON UPDATE CASCADE,
    CONSTRAINT ck_jogo_tamanho  CHECK (tamanho_download_gb >= 0)
);

-- jogo_base_id aponta para JOGOS (não para PRODUTOS): o próprio desenho do banco
-- impede uma DLC de ter outra DLC como "jogo-base"
CREATE TABLE IF NOT EXISTS dlcs (
    id_produto      BIGINT UNSIGNED  NOT NULL,
    jogo_base_id    BIGINT UNSIGNED  NOT NULL,
    criado_em       DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                              ON UPDATE CURRENT_TIMESTAMP,
    deletado_em     DATETIME             NULL,

    CONSTRAINT pk_dlc            PRIMARY KEY (id_produto),
    CONSTRAINT fk_dlc_produto    FOREIGN KEY (id_produto)
                                 REFERENCES produtos (id_produto)
                                 ON DELETE CASCADE
                                 ON UPDATE CASCADE,
    CONSTRAINT fk_dlc_jogo_base  FOREIGN KEY (jogo_base_id)
                                 REFERENCES jogos (id_produto)
                                 ON DELETE RESTRICT
                                 ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS compras (
    id_compra       BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    usuario_id      BIGINT UNSIGNED  NOT NULL,
    produto_id      BIGINT UNSIGNED  NOT NULL,
    valor_pago      DECIMAL(10, 2)   NOT NULL COMMENT 'Snapshot do preço na compra — não muda com o preco_base atual',
    data_compra     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    criado_em       DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                              ON UPDATE CURRENT_TIMESTAMP,
    deletado_em     DATETIME             NULL,

    CONSTRAINT pk_compra          PRIMARY KEY (id_compra),
    CONSTRAINT fk_compra_usuario  FOREIGN KEY (usuario_id)
                                  REFERENCES usuarios (id_usuario)
                                  ON DELETE RESTRICT
                                  ON UPDATE CASCADE,
    CONSTRAINT fk_compra_produto  FOREIGN KEY (produto_id)
                                  REFERENCES produtos (id_produto)
                                  ON DELETE RESTRICT
                                  ON UPDATE CASCADE,
    CONSTRAINT ck_compra_valor    CHECK (valor_pago >= 0)
);

-- Conquistas pertencem a um JOGO (não a uma DLC): a FK aponta para jogos
CREATE TABLE IF NOT EXISTS conquistas (
    id_conquista    BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
    jogo_id         BIGINT UNSIGNED   NOT NULL,
    nome            VARCHAR(255)      NOT NULL,
    descricao       TEXT                  NULL,
    pontos          TINYINT UNSIGNED  NOT NULL,
    criado_em       DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em   DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP
                                               ON UPDATE CURRENT_TIMESTAMP,
    deletado_em     DATETIME              NULL,

    CONSTRAINT pk_conquista       PRIMARY KEY (id_conquista),
    CONSTRAINT fk_conquista_jogo  FOREIGN KEY (jogo_id)
                                  REFERENCES jogos (id_produto)
                                  ON DELETE RESTRICT
                                  ON UPDATE CASCADE
);

-- N:M usuarios <-> conquistas: quando cada usuário desbloqueou cada conquista
CREATE TABLE IF NOT EXISTS conquistas_desbloqueadas (
    id_conquista_desbloqueada  BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    usuario_id                 BIGINT UNSIGNED  NOT NULL,
    conquista_id               BIGINT UNSIGNED  NOT NULL,
    desbloqueada_em            DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    criado_em                  DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em              DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                                         ON UPDATE CURRENT_TIMESTAMP,
    deletado_em                DATETIME             NULL,

    CONSTRAINT pk_conquista_desbloqueada               PRIMARY KEY (id_conquista_desbloqueada),
    CONSTRAINT uq_conquista_desbloqueada_usuario_conq  UNIQUE (usuario_id, conquista_id),
    CONSTRAINT fk_conquista_desbloqueada_usuario       FOREIGN KEY (usuario_id)
                                                       REFERENCES usuarios (id_usuario)
                                                       ON DELETE CASCADE
                                                       ON UPDATE CASCADE,
    CONSTRAINT fk_conquista_desbloqueada_conquista     FOREIGN KEY (conquista_id)
                                                       REFERENCES conquistas (id_conquista)
                                                       ON DELETE RESTRICT
                                                       ON UPDATE CASCADE
);

-- "Avaliar uma única vez" = UNIQUE (usuario_id, produto_id). Não dá para
-- expressar isso só com PK/FK simples.
CREATE TABLE IF NOT EXISTS avaliacoes (
    id_avaliacao    BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
    usuario_id      BIGINT UNSIGNED   NOT NULL,
    produto_id      BIGINT UNSIGNED   NOT NULL,
    nota            TINYINT UNSIGNED  NOT NULL COMMENT '1 a 5',
    comentario      TEXT                  NULL,
    criado_em       DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em   DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP
                                               ON UPDATE CURRENT_TIMESTAMP,
    deletado_em     DATETIME              NULL,

    CONSTRAINT pk_avaliacao                  PRIMARY KEY (id_avaliacao),
    CONSTRAINT uq_avaliacao_usuario_produto  UNIQUE (usuario_id, produto_id),
    CONSTRAINT fk_avaliacao_usuario          FOREIGN KEY (usuario_id)
                                             REFERENCES usuarios (id_usuario)
                                             ON DELETE RESTRICT
                                             ON UPDATE CASCADE,
    CONSTRAINT fk_avaliacao_produto          FOREIGN KEY (produto_id)
                                             REFERENCES produtos (id_produto)
                                             ON DELETE RESTRICT
                                             ON UPDATE CASCADE,
    CONSTRAINT ck_avaliacao_nota             CHECK (nota BETWEEN 1 AND 5)
);


-- #############################################################################
-- 7) TRAMPOJA — marketplace de prestadores de serviço (com RBAC)
-- #############################################################################

DROP DATABASE IF EXISTS trampoja;

CREATE DATABASE trampoja
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE trampoja;

-- Sem coluna tipo_usuario: o controle de acesso é 100% via papeis/permissoes (RBAC)
CREATE TABLE IF NOT EXISTS usuarios (
    id_usuario      BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    nome            VARCHAR(255)     NOT NULL,
    email           VARCHAR(255)     NOT NULL,
    senha_hash      VARCHAR(255)     NOT NULL COMMENT 'Hash da senha — nunca a senha em texto puro',
    criado_em       DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                              ON UPDATE CURRENT_TIMESTAMP,
    deletado_em     DATETIME             NULL,

    CONSTRAINT pk_usuario        PRIMARY KEY (id_usuario),
    CONSTRAINT uq_usuario_email  UNIQUE (email)
);

CREATE TABLE IF NOT EXISTS papeis (
    id_papel        BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    nome            VARCHAR(100)     NOT NULL COMMENT 'Ex.: administrador, moderador, cliente, prestador',
    criado_em       DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                              ON UPDATE CURRENT_TIMESTAMP,
    deletado_em     DATETIME             NULL,

    CONSTRAINT pk_papel       PRIMARY KEY (id_papel),
    CONSTRAINT uq_papel_nome  UNIQUE (nome)
);

CREATE TABLE IF NOT EXISTS permissoes (
    id_permissao    BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    codigo          VARCHAR(100)     NOT NULL,
    descricao       VARCHAR(255)     NOT NULL,
    criado_em       DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                              ON UPDATE CURRENT_TIMESTAMP,
    deletado_em     DATETIME             NULL,

    CONSTRAINT pk_permissao         PRIMARY KEY (id_permissao),
    CONSTRAINT uq_permissao_codigo  UNIQUE (codigo)
);

CREATE TABLE IF NOT EXISTS papeis_permissoes (
    id_papel_permissao  BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    papel_id            BIGINT UNSIGNED  NOT NULL,
    permissao_id        BIGINT UNSIGNED  NOT NULL,
    criado_em           DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em       DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                                  ON UPDATE CURRENT_TIMESTAMP,
    deletado_em         DATETIME             NULL,

    CONSTRAINT pk_papel_permissao               PRIMARY KEY (id_papel_permissao),
    CONSTRAINT uq_papel_permissao_papel_perm    UNIQUE (papel_id, permissao_id),
    CONSTRAINT fk_papel_permissao_papel         FOREIGN KEY (papel_id)
                                                REFERENCES papeis (id_papel)
                                                ON DELETE CASCADE
                                                ON UPDATE CASCADE,
    CONSTRAINT fk_papel_permissao_permissao     FOREIGN KEY (permissao_id)
                                                REFERENCES permissoes (id_permissao)
                                                ON DELETE CASCADE
                                                ON UPDATE CASCADE
);

-- Um mesmo usuário pode acumular os papéis cliente e prestador sem mudar o schema
CREATE TABLE IF NOT EXISTS usuarios_papeis (
    id_usuario_papel  BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    usuario_id        BIGINT UNSIGNED  NOT NULL,
    papel_id          BIGINT UNSIGNED  NOT NULL,
    criado_em         DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                                ON UPDATE CURRENT_TIMESTAMP,
    deletado_em       DATETIME             NULL,

    CONSTRAINT pk_usuario_papel               PRIMARY KEY (id_usuario_papel),
    CONSTRAINT uq_usuario_papel_usuario_papel UNIQUE (usuario_id, papel_id),
    CONSTRAINT fk_usuario_papel_usuario       FOREIGN KEY (usuario_id)
                                              REFERENCES usuarios (id_usuario)
                                              ON DELETE CASCADE
                                              ON UPDATE CASCADE,
    CONSTRAINT fk_usuario_papel_papel         FOREIGN KEY (papel_id)
                                              REFERENCES papeis (id_papel)
                                              ON DELETE RESTRICT
                                              ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS categorias_servico (
    id_categoria_servico  BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    nome                  VARCHAR(100)     NOT NULL,
    criado_em             DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em         DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                                    ON UPDATE CURRENT_TIMESTAMP,
    deletado_em           DATETIME             NULL,

    CONSTRAINT pk_categoria_servico       PRIMARY KEY (id_categoria_servico),
    CONSTRAINT uq_categoria_servico_nome  UNIQUE (nome)
);

-- ESPECIALIZAÇÃO PARCIAL de usuarios: só quem decidiu oferecer serviços tem perfil
CREATE TABLE IF NOT EXISTS perfis_prestador (
    id_usuario              BIGINT UNSIGNED  NOT NULL,
    biografia               TEXT                 NULL,
    categoria_principal_id  BIGINT UNSIGNED  NOT NULL,
    criado_em               DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em           DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                                      ON UPDATE CURRENT_TIMESTAMP,
    deletado_em             DATETIME             NULL,

    CONSTRAINT pk_perfil_prestador            PRIMARY KEY (id_usuario),
    CONSTRAINT fk_perfil_prestador_usuario    FOREIGN KEY (id_usuario)
                                              REFERENCES usuarios (id_usuario)
                                              ON DELETE CASCADE
                                              ON UPDATE CASCADE,
    CONSTRAINT fk_perfil_prestador_categoria  FOREIGN KEY (categoria_principal_id)
                                              REFERENCES categorias_servico (id_categoria_servico)
                                              ON DELETE RESTRICT
                                              ON UPDATE CASCADE
);

-- prestador_id aponta para perfis_prestador: usuário sem perfil não anuncia serviço
-- (a regra fica garantida pela própria FK)
CREATE TABLE IF NOT EXISTS servicos_ofertados (
    id_servico_ofertado  BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    prestador_id         BIGINT UNSIGNED  NOT NULL,
    categoria_id         BIGINT UNSIGNED  NOT NULL,
    titulo               VARCHAR(255)     NOT NULL,
    descricao            TEXT             NOT NULL,
    preco_base           DECIMAL(10, 2)   NOT NULL,
    criado_em            DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em        DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                                   ON UPDATE CURRENT_TIMESTAMP,
    deletado_em          DATETIME             NULL,

    CONSTRAINT pk_servico_ofertado            PRIMARY KEY (id_servico_ofertado),
    CONSTRAINT fk_servico_ofertado_prestador  FOREIGN KEY (prestador_id)
                                              REFERENCES perfis_prestador (id_usuario)
                                              ON DELETE RESTRICT
                                              ON UPDATE CASCADE,
    CONSTRAINT fk_servico_ofertado_categoria  FOREIGN KEY (categoria_id)
                                              REFERENCES categorias_servico (id_categoria_servico)
                                              ON DELETE RESTRICT
                                              ON UPDATE CASCADE,
    CONSTRAINT ck_servico_ofertado_preco      CHECK (preco_base >= 0)
);

-- cliente_id: papel "cliente" sobre usuarios (Regra 7)
CREATE TABLE IF NOT EXISTS propostas (
    id_proposta           BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    servico_ofertado_id   BIGINT UNSIGNED  NOT NULL,
    cliente_id            BIGINT UNSIGNED  NOT NULL,
    mensagem              TEXT                 NULL,
    valor_proposto        DECIMAL(10, 2)   NOT NULL,
    status                ENUM('pendente', 'aceita', 'recusada') NOT NULL DEFAULT 'pendente',
    data_proposta         DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    criado_em             DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em         DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                                    ON UPDATE CURRENT_TIMESTAMP,
    deletado_em           DATETIME             NULL,

    CONSTRAINT pk_proposta                  PRIMARY KEY (id_proposta),
    CONSTRAINT fk_proposta_servico_ofertado FOREIGN KEY (servico_ofertado_id)
                                            REFERENCES servicos_ofertados (id_servico_ofertado)
                                            ON DELETE RESTRICT
                                            ON UPDATE CASCADE,
    CONSTRAINT fk_proposta_cliente          FOREIGN KEY (cliente_id)
                                            REFERENCES usuarios (id_usuario)
                                            ON DELETE RESTRICT
                                            ON UPDATE CASCADE,
    CONSTRAINT ck_proposta_valor            CHECK (valor_proposto >= 0)
);

-- Relação 1:1 com propostas: o UNIQUE em proposta_id é o que transforma o 1:N
-- natural em 1:1 (sem ele, nada impediria dois contratos para a mesma proposta)
CREATE TABLE IF NOT EXISTS contratos (
    id_contrato              BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    proposta_id              BIGINT UNSIGNED  NOT NULL,
    data_inicio              DATE             NOT NULL,
    data_conclusao_prevista  DATE             NOT NULL,
    data_conclusao_real      DATE                 NULL,
    status                   ENUM('em_andamento', 'concluido', 'cancelado')
                                              NOT NULL DEFAULT 'em_andamento',
    valor_final              DECIMAL(10, 2)   NOT NULL,
    criado_em                DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em            DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                                       ON UPDATE CURRENT_TIMESTAMP,
    deletado_em              DATETIME             NULL,

    CONSTRAINT pk_contrato           PRIMARY KEY (id_contrato),
    CONSTRAINT uq_contrato_proposta  UNIQUE (proposta_id),
    CONSTRAINT fk_contrato_proposta  FOREIGN KEY (proposta_id)
                                     REFERENCES propostas (id_proposta)
                                     ON DELETE RESTRICT
                                     ON UPDATE CASCADE,
    CONSTRAINT ck_contrato_valor     CHECK (valor_final >= 0),
    CONSTRAINT ck_contrato_previsao  CHECK (data_conclusao_prevista >= data_inicio),
    CONSTRAINT ck_contrato_real      CHECK (data_conclusao_real IS NULL OR data_conclusao_real >= data_inicio)
);

-- 1:N a partir de contratos (e não 1:1): cada linha é uma parcela, com status próprio
CREATE TABLE IF NOT EXISTS pagamentos (
    id_pagamento      BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    contrato_id       BIGINT UNSIGNED  NOT NULL,
    valor             DECIMAL(10, 2)   NOT NULL,
    forma_pagamento   ENUM('pix', 'cartao_credito', 'boleto') NOT NULL,
    status            ENUM('pendente', 'aprovado', 'estornado') NOT NULL DEFAULT 'pendente',
    data_pagamento    DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    criado_em         DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                                ON UPDATE CURRENT_TIMESTAMP,
    deletado_em       DATETIME             NULL,

    CONSTRAINT pk_pagamento           PRIMARY KEY (id_pagamento),
    CONSTRAINT fk_pagamento_contrato  FOREIGN KEY (contrato_id)
                                      REFERENCES contratos (id_contrato)
                                      ON DELETE RESTRICT
                                      ON UPDATE CASCADE,
    CONSTRAINT ck_pagamento_valor     CHECK (valor > 0)
);

-- Avaliação mútua: avaliador_id / avaliado_id (Regra 7).
-- A escala 1 a 5 é ASSUMIDA (o enunciado só diz "nota"); mantém o padrão dos outros exercícios.
CREATE TABLE IF NOT EXISTS avaliacoes (
    id_avaliacao    BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
    contrato_id     BIGINT UNSIGNED   NOT NULL,
    avaliador_id    BIGINT UNSIGNED   NOT NULL,
    avaliado_id     BIGINT UNSIGNED   NOT NULL,
    nota            TINYINT UNSIGNED  NOT NULL,
    comentario      TEXT                  NULL,
    criado_em       DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em   DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP
                                               ON UPDATE CURRENT_TIMESTAMP,
    deletado_em     DATETIME              NULL,

    CONSTRAINT pk_avaliacao            PRIMARY KEY (id_avaliacao),
    CONSTRAINT fk_avaliacao_contrato   FOREIGN KEY (contrato_id)
                                       REFERENCES contratos (id_contrato)
                                       ON DELETE RESTRICT
                                       ON UPDATE CASCADE,
    CONSTRAINT fk_avaliacao_avaliador  FOREIGN KEY (avaliador_id)
                                       REFERENCES usuarios (id_usuario)
                                       ON DELETE RESTRICT
                                       ON UPDATE CASCADE,
    CONSTRAINT fk_avaliacao_avaliado   FOREIGN KEY (avaliado_id)
                                       REFERENCES usuarios (id_usuario)
                                       ON DELETE RESTRICT
                                       ON UPDATE CASCADE,
    CONSTRAINT ck_avaliacao_nota       CHECK (nota BETWEEN 1 AND 5)
);
