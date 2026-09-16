<!--
GABARITO — não faz parte do fluxo principal da aula e fica fora do `nav` do
mkdocs.yml de propósito. É acessível só pelos links dentro de Aula_06_SQL_DDL.md.
-->

# Gabarito — Aula 06 — SQL: Linguagem de Definição de Dados (DDL)

**Disciplina:** Banco de Dados e Aplicações <br>
**Professor:** Ronan Adriel Zenatti · ronan.zenatti@cps.sp.gov.br  <br>
**Fatec Jahu — 2º Semestre/2026**

---

!!! warning "Antes de conferir"
    Assim como nos gabaritos anteriores: este documento mostra **uma** solução correta possível para cada Checkpoint. O que importa é você ter seguido as 9 regras de nomenclatura e escolhido os tipos de dados corretos (Seção 5) — pequenas variações de nome de constraint ou de tamanho de `VARCHAR` não invalidam sua resposta.

---

## Checkpoint 1 — Criação guiada: sistema de biblioteca {: #checkpoint-1 }

**Raciocínio:** `autores` e `livros` têm relação N:M (um livro pode ter vários autores; um autor pode ter escrito vários livros) — precisa de uma tabela associativa, `autorias_livros`. `usuarios` e `emprestimos` têm relação 1:N (um usuário pode ter vários empréstimos; cada empréstimo é de um único usuário), e `livros` e `emprestimos` também têm 1:N (um livro pode ter vários empréstimos ao longo do tempo; cada empréstimo é de um único livro).

```sql
CREATE DATABASE IF NOT EXISTS biblioteca
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE biblioteca;

CREATE TABLE IF NOT EXISTS autores (
    id_autor      BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    nome          VARCHAR(255)     NOT NULL,
    criado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                            ON UPDATE CURRENT_TIMESTAMP,
    deletado_em   DATETIME             NULL,

    CONSTRAINT pk_autor PRIMARY KEY (id_autor)
);

CREATE TABLE IF NOT EXISTS livros (
    id_livro      BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    titulo        VARCHAR(255)     NOT NULL,
    isbn          CHAR(13)             NULL COMMENT 'Apenas dígitos, sem formatação',
    ano_publicacao YEAR            NULL,
    criado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                            ON UPDATE CURRENT_TIMESTAMP,
    deletado_em   DATETIME             NULL,

    CONSTRAINT pk_livro PRIMARY KEY (id_livro),
    CONSTRAINT uq_livro_isbn UNIQUE (isbn)
);

-- Tabela associativa: resolve o N:M entre autores e livros
CREATE TABLE IF NOT EXISTS autorias_livros (
    autor_id      BIGINT UNSIGNED  NOT NULL,
    livro_id      BIGINT UNSIGNED  NOT NULL,
    criado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_autoria_livro PRIMARY KEY (autor_id, livro_id),
    CONSTRAINT fk_autoria_autor FOREIGN KEY (autor_id)
                                REFERENCES autores (id_autor)
                                ON DELETE RESTRICT
                                ON UPDATE CASCADE,
    CONSTRAINT fk_autoria_livro FOREIGN KEY (livro_id)
                                REFERENCES livros (id_livro)
                                ON DELETE CASCADE
                                ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS usuarios (
    id_usuario    BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    nome          VARCHAR(255)     NOT NULL,
    email         VARCHAR(255)     NOT NULL,
    criado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                            ON UPDATE CURRENT_TIMESTAMP,
    deletado_em   DATETIME             NULL,

    CONSTRAINT pk_usuario PRIMARY KEY (id_usuario),
    CONSTRAINT uq_usuario_email UNIQUE (email)
);

CREATE TABLE IF NOT EXISTS emprestimos (
    id_emprestimo   BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    usuario_id      BIGINT UNSIGNED  NOT NULL,
    livro_id        BIGINT UNSIGNED  NOT NULL,
    data_emprestimo DATE             NOT NULL DEFAULT (CURRENT_DATE),
    data_devolucao  DATE                 NULL COMMENT 'NULL enquanto o livro não for devolvido',
    criado_em       DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                              ON UPDATE CURRENT_TIMESTAMP,
    deletado_em     DATETIME             NULL,

    CONSTRAINT pk_emprestimo PRIMARY KEY (id_emprestimo),
    CONSTRAINT fk_emprestimo_usuario FOREIGN KEY (usuario_id)
                                     REFERENCES usuarios (id_usuario)
                                     ON DELETE RESTRICT
                                     ON UPDATE CASCADE,
    CONSTRAINT fk_emprestimo_livro   FOREIGN KEY (livro_id)
                                     REFERENCES livros (id_livro)
                                     ON DELETE RESTRICT
                                     ON UPDATE CASCADE,
    CONSTRAINT ck_emprestimo_datas   CHECK (data_devolucao IS NULL OR data_devolucao >= data_emprestimo)
);
```

Repare que `autorias_livros` usa PK composta (`autor_id`, `livro_id`) em vez de uma PK surrogate própria — diferente de `itens_pedidos` (Seção 6.6), aqui não existe nenhuma coluna extra do relacionamento (como `preco_unitario`) que justificasse uma PK própria, então a combinação das duas FKs já basta como identificador único da linha (a mesma dupla autor+livro não deveria se repetir).

---

## Checkpoint 2 — ALTER TABLE: ajustando produtos {: #checkpoint-2 }

```sql
-- (a) Adicionar a coluna peso
ALTER TABLE produtos
    ADD COLUMN peso DECIMAL(8, 3) NULL COMMENT 'Peso em quilogramas';

-- (b) Renomear ativo -> disponivel, mantendo tipo e DEFAULT
ALTER TABLE produtos
    CHANGE COLUMN ativo disponivel TINYINT(1) NOT NULL DEFAULT 1;

-- (c) CHECK que só valida peso quando ele não for NULL
ALTER TABLE produtos
    ADD CONSTRAINT ck_produto_peso CHECK (peso IS NULL OR peso > 0);
```

Repare no `CHECK` do item (c): `peso IS NULL OR peso > 0` permite que a coluna continue opcional (produtos que ainda não tiveram o peso cadastrado guardam `NULL`), mas rejeita qualquer valor de peso que seja zero ou negativo assim que alguém tentar informá-lo. Um `CHECK (peso > 0)` sozinho, sem o `OR peso IS NULL`, rejeitaria incorretamente até o valor `NULL` em alguns SGBDs — por isso a condição de nulidade vem explícita.

---

## 🔗 Voltar

⬅️ [Aula 06 — SQL: Linguagem de Definição de Dados (DDL)](Aula_06_SQL_DDL.md)

---

*Fatec Jahu · IBD951 · Prof. Ronan Adriel Zenatti · 2026*
