<!--
GABARITO — não faz parte do fluxo principal da aula e fica fora do `nav` do
mkdocs.yml de propósito. É acessível só pelos links dentro de Topico_07_SQL_DQL.md.
-->

# Gabarito — Tópico 07 — SQL: Consultas Básicas (DQL)

**Disciplina:** Banco de Dados e Aplicações <br>
**Professor:** Ronan Adriel Zenatti · ronan.zenatti@cps.sp.gov.br  <br>
**Fatec Jahu — 2º Semestre/2026**

---

!!! warning "Antes de conferir"
    Assim como nos gabaritos anteriores: este documento mostra **uma** solução correta possível para cada Checkpoint. Variações como quebras de linha, o nome exato do apelido ou a ordem em que as linhas aparecem não invalidam sua resposta. O que importa é o raciocínio: colunas separadas por vírgula, `AS` nos apelidos, palavras reservadas em MAIÚSCULAS e o `;` no final.

---

## Checkpoint 1 — Escolhendo colunas {: #checkpoint-1 }

**Raciocínio:** em todos os itens, o que muda é só a lista entre o `SELECT` e o `FROM`. O item (c) pede *todas* as colunas, então vale o asterisco.

```sql
-- (a) Nome e e-mail dos clientes
SELECT nome, email
FROM clientes;

-- (b) Nome e estoque dos produtos, com apelidos
SELECT nome AS produto,
       estoque AS quantidade_em_estoque
FROM produtos;

-- (c) Todas as colunas da tabela itens_pedidos
SELECT *
FROM itens_pedidos;
```

Resultado esperado de (a):

```text
+-----------------+--------------------------+
| nome            | email                    |
+-----------------+--------------------------+
| Ana Souza       | ana.souza@email.com      |
| Bruno Lima      | bruno.lima@email.com     |
| Carla Mendes    | carla.mendes@email.com   |
| Diego Alves     | diego.alves@email.com    |
| Elisa Rocha     | elisa.rocha@email.com    |
| Fábio Teixeira  | fabio.teixeira@email.com |
+-----------------+--------------------------+
```

> 💡 **Erro comum:** esquecer a vírgula entre `nome` e `email` (`SELECT nome email ...`). O banco não reclama: trata `email` como apelido de `nome` e mostra só uma coluna.

---

## Checkpoint 2 — Colunas calculadas {: #checkpoint-2 }

**(a)** 15% de desconto equivale a pagar 85% do preço, ou seja, multiplicar por `0.85`. O `ROUND` com 2 casas evita resultados como `12.665`:

```sql
SELECT nome,
       ROUND(preco * 0.85, 2) AS preco_promocional
FROM produtos;
```

```text
+-----------------------+-------------------+
| nome                  | preco_promocional |
+-----------------------+-------------------+
| Pão francês (kg)      |             12.67 |
| Bolo de fubá          |             15.30 |
| Café torrado 500g     |             14.88 |
| Arroz 5kg             |             25.42 |
| Refrigerante 2L       |              8.49 |
| Suco de laranja 1L    |              6.38 |
| Banana prata (kg)     |              5.87 |
| Tomate (kg)           |              7.57 |
| Detergente 500ml      |              2.54 |
| Presunto fatiado (kg) |             33.92 |
| Queijo mussarela (kg) |             38.17 |
+-----------------------+-------------------+
```

**(b)** Subtotal = quantidade × preço unitário, linha por linha:

```sql
SELECT pedido_id,
       produto_id,
       quantidade * preco_unitario AS subtotal
FROM itens_pedidos;
```

```text
+-----------+------------+----------+
| pedido_id | produto_id | subtotal |
+-----------+------------+----------+
|         1 |          1 |    29.80 |
|         1 |          3 |    17.50 |
|         2 |          4 |    29.90 |
|         2 |          5 |    19.98 |
|         3 |          6 |    22.50 |
|         4 |          7 |    13.80 |
|         4 |          9 |    11.96 |
|         5 |          2 |    18.00 |
+-----------+------------+----------+
```

**(c)** **Não**, os preços não mudaram. O `SELECT` só **lê** os dados; a coluna `preco_promocional` foi calculada na hora e existe apenas no resultado da consulta. Para de fato alterar os preços seria necessário um `UPDATE` (Tópico 06).

---

## Checkpoint 3 — Texto, NULL e DISTINCT {: #checkpoint-3 }

**(a)** `UPPER` para o nome e `IFNULL` para trocar o telefone `NULL`:

```sql
SELECT UPPER(nome) AS nome_maiusculo,
       IFNULL(telefone, 'sem telefone') AS telefone_contato
FROM clientes;
```

```text
+-----------------+------------------+
| nome_maiusculo  | telefone_contato |
+-----------------+------------------+
| ANA SOUZA       | 14991234567      |
| BRUNO LIMA      | 14998887766      |
| CARLA MENDES    | 14997654321      |
| DIEGO ALVES     | sem telefone     |
| ELISA ROCHA     | sem telefone     |
| FÁBIO TEIXEIRA  | 14996543210      |
+-----------------+------------------+
```

**(b)** `DISTINCT` logo depois do `SELECT`:

```sql
SELECT DISTINCT status
FROM pedidos;
```

```text
+------------+
| status     |
+------------+
| entregue   |
| enviado    |
| confirmado |
| pendente   |
| cancelado  |
+------------+
```

Cinco linhas: cada pedido da carga tem um status diferente. (Se você cadastrar mais pedidos com status já existente, o `DISTINCT` continuará mostrando cada status uma única vez.)

**(c)** `CONCAT` com o texto fixo ` - R$ ` (note os espaços **dentro** das aspas):

```sql
SELECT CONCAT(nome, ' - R$ ', preco) AS etiqueta
FROM produtos;
```

```text
+----------------------------------+
| etiqueta                         |
+----------------------------------+
| Pão francês (kg) - R$ 14.90      |
| Bolo de fubá - R$ 18.00          |
| Café torrado 500g - R$ 17.50     |
| Arroz 5kg - R$ 29.90             |
...
```

> 💡 **Dica:** o `CONCAT` aceita números (como `preco`) misturados com textos — ele converte para texto sozinho. O ponto decimal aparece como ponto (`14.90`), e não como vírgula; a formatação para o padrão brasileiro é tarefa da aplicação.

---

⬅️ [Voltar ao Tópico 07 — SQL: Consultas Básicas (DQL)](./Topico_07_SQL_DQL.md)
