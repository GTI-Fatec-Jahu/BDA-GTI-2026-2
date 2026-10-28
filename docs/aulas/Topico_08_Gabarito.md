<!--
GABARITO — não faz parte do fluxo principal da aula e fica fora do `nav` do
mkdocs.yml de propósito. É acessível só pelos links dentro de Topico_08_Filtragem_Avancada.md.
-->

# Gabarito — Tópico 08 — Filtragem Avançada: WHERE e ORDER BY

**Disciplina:** Banco de Dados e Aplicações <br>
**Professor:** Ronan Adriel Zenatti · ronan.zenatti@cps.sp.gov.br  <br>
**Fatec Jahu — 2º Semestre/2026**

---

!!! warning "Antes de conferir"
    Assim como nos gabaritos anteriores: este documento mostra **uma** solução correta possível para cada Checkpoint. Variações como quebras de linha, o nome exato do apelido ou a ordem em que as linhas aparecem (quando não há `ORDER BY`) não invalidam sua resposta. O que importa é o raciocínio: a condição certa no `WHERE`, parênteses quando misturar `AND` e `OR`, palavras reservadas em MAIÚSCULAS e o `;` no final.

---

## Checkpoint 1 — Comparações e lógica {: #checkpoint-1 }

**Raciocínio:** em todos os itens a pergunta é "quais **linhas**?", então a resposta está no `WHERE`. No item (b), as duas regras precisam valer ao mesmo tempo: `AND`.

```sql
-- (a) Nome e estoque dos produtos com estoque menor que 20
SELECT nome, estoque
FROM produtos
WHERE estoque < 20;

-- (b) Preço menor que 10 E estoque maior que 20
SELECT nome, preco, estoque
FROM produtos
WHERE preco < 10 AND estoque > 20;

-- (c) Todos os clientes, exceto o Bruno Lima
SELECT nome
FROM clientes
WHERE nome <> 'Bruno Lima';
```

Resultado esperado de (a):

```text
+-----------------------+---------+
| nome                  | estoque |
+-----------------------+---------+
| Bolo de fubá          |      12 |
| Suco de laranja 1L    |      18 |
| Tomate (kg)           |       0 |
| Presunto fatiado (kg) |       8 |
| Queijo mussarela (kg) |       6 |
+-----------------------+---------+
```

Resultado esperado de (b):

```text
+-------------------+-------+---------+
| nome              | preco | estoque |
+-------------------+-------+---------+
| Refrigerante 2L   |  9.99 |      24 |
| Banana prata (kg) |  6.90 |      35 |
| Detergente 500ml  |  2.99 |     100 |
+-------------------+-------+---------+
```

Resultado esperado de (c):

```text
+-----------------+
| nome            |
+-----------------+
| Ana Souza       |
| Carla Mendes    |
| Diego Alves     |
| Elisa Rocha     |
| Fábio Teixeira  |
+-----------------+
```

> 💡 **Dica:** no item (a), o Tomate (estoque `0`) aparece, pois `0` é menor que 20. Se você quisesse só os produtos que ainda têm algum estoque, bastaria acrescentar `AND estoque > 0`. Em (c), o `!=` no lugar do `<>` também está correto.

---

## Checkpoint 2 — Operadores especiais {: #checkpoint-2 }

**Raciocínio:** (a) é um intervalo, então `BETWEEN`, com o menor valor primeiro; (b) é uma lista de valores permitidos, então `IN`; (c) e (d) são buscas por padrão, então `LIKE` — a posição do `%` decide se é "contém" (nos dois lados) ou "termina com" (só no começo do padrão).

```sql
-- (a) Preço entre 10 e 30
SELECT nome, preco
FROM produtos
WHERE preco BETWEEN 10 AND 30;

-- (b) Pedidos pendentes ou confirmados, usando IN
SELECT id_pedido, status
FROM pedidos
WHERE status IN ('pendente', 'confirmado');

-- (c) E-mail que contém "souza"
SELECT nome, email
FROM clientes
WHERE email LIKE '%souza%';

-- (d) Nome que termina com a letra "s"
SELECT nome
FROM clientes
WHERE nome LIKE '%s';
```

Resultado esperado de (a):

```text
+--------------------+-------+
| nome               | preco |
+--------------------+-------+
| Pão francês (kg)   | 14.90 |
| Bolo de fubá       | 18.00 |
| Café torrado 500g  | 17.50 |
| Arroz 5kg          | 29.90 |
+--------------------+-------+
```

Resultado esperado de (b):

```text
+-----------+------------+
| id_pedido | status     |
+-----------+------------+
|         3 | confirmado |
|         4 | pendente   |
+-----------+------------+
```

Resultado esperado de (c):

```text
+-----------+---------------------+
| nome      | email               |
+-----------+---------------------+
| Ana Souza | ana.souza@email.com |
+-----------+---------------------+
```

Resultado esperado de (d):

```text
+--------------+
| nome         |
+--------------+
| Carla Mendes |
| Diego Alves  |
+--------------+
```

> 💡 **Dica:** o Arroz 5kg (R$ 29,90) entrou em (a) porque `BETWEEN` inclui as pontas; um produto de R$ 30,00 também entraria. Em (c), o `LIKE` ignora maiúsculas — `'%SOUZA%'` encontraria o mesmo cliente.

---

## Checkpoint 3 — Datas {: #checkpoint-3 }

**Raciocínio:** (a) usa `YEAR` para olhar só o ano da data de nascimento; (b) combina `BETWEEN` (no filtro, com a data original) com `DATE_FORMAT` (só na exibição); (c) usa `DATEDIFF` com a data fixa de "hoje" (31/10/2026) e filtra os pedidos que **não** são cancelados.

```sql
-- (a) Clientes nascidos em 1990 ou depois
SELECT nome, data_nascimento
FROM clientes
WHERE YEAR(data_nascimento) >= 1990;

-- (b) Pedidos entre 03/10/2026 e 07/10/2026, com data no formato dia/mês/ano
SELECT id_pedido,
       DATE_FORMAT(data_pedido, '%d/%m/%Y') AS data_br
FROM pedidos
WHERE data_pedido BETWEEN '2026-10-03' AND '2026-10-07';

-- (c) Dias desde o pedido, para os pedidos não cancelados (hoje = 31/10/2026)
SELECT id_pedido,
       status,
       DATEDIFF('2026-10-31', data_pedido) AS dias
FROM pedidos
WHERE status <> 'cancelado';
```

Resultado esperado de (a):

```text
+--------------+-----------------+
| nome         | data_nascimento |
+--------------+-----------------+
| Ana Souza    | 1990-05-14      |
| Carla Mendes | 1992-09-03      |
| Elisa Rocha  | 1995-07-09      |
+--------------+-----------------+
```

Resultado esperado de (b):

```text
+-----------+------------+
| id_pedido | data_br    |
+-----------+------------+
|         3 | 05/10/2026 |
|         4 | 07/10/2026 |
+-----------+------------+
```

Resultado esperado de (c):

```text
+-----------+------------+------+
| id_pedido | status     | dias |
+-----------+------------+------+
|         1 | entregue   |   30 |
|         2 | enviado    |   29 |
|         3 | confirmado |   26 |
|         4 | pendente   |   24 |
+-----------+------------+------+
```

> 💡 **Dica:** em (b), o filtro usa `data_pedido` (a data de verdade, no formato do banco), e o `DATE_FORMAT` aparece só no `SELECT`, para exibir. Filtrar pelo texto formatado (`'03/10/2026'`) não funcionaria. Em (a), `data_nascimento >= '1990-01-01'` também é uma resposta correta.

---

## Checkpoint 4 — Ordenação {: #checkpoint-4 }

**Raciocínio:** `ORDER BY` define a ordem e `LIMIT` corta o número de linhas — nessa sequência, e sempre no fim da consulta. Para os "mais baratos" a ordem é crescente (`ASC`, o padrão); para os "mais caros", decrescente (`DESC`).

```sql
-- (a) Os 3 produtos mais baratos
SELECT nome, preco
FROM produtos
ORDER BY preco ASC
LIMIT 3;

-- (b) Clientes em ordem alfabética
SELECT nome
FROM clientes
ORDER BY nome ASC;

-- (c) Produtos das categorias 3 e 6, do mais caro ao mais barato
SELECT nome, preco
FROM produtos
WHERE categoria_id IN (3, 6)
ORDER BY preco DESC;
```

Resultado esperado de (a):

```text
+--------------------+-------+
| nome               | preco |
+--------------------+-------+
| Detergente 500ml   |  2.99 |
| Banana prata (kg)  |  6.90 |
| Suco de laranja 1L |  7.50 |
+--------------------+-------+
```

Resultado esperado de (b):

```text
+-----------------+
| nome            |
+-----------------+
| Ana Souza       |
| Bruno Lima      |
| Carla Mendes    |
| Diego Alves     |
| Elisa Rocha     |
| Fábio Teixeira  |
+-----------------+
```

Resultado esperado de (c):

```text
+-----------------------+-------+
| nome                  | preco |
+-----------------------+-------+
| Queijo mussarela (kg) | 44.90 |
| Presunto fatiado (kg) | 39.90 |
| Arroz 5kg             | 29.90 |
| Café torrado 500g     | 17.50 |
+-----------------------+-------+
```

> 💡 **Dica:** em (c), a ordem das cláusulas é sempre `FROM` → `WHERE` → `ORDER BY` (→ `LIMIT`). Escrever `ORDER BY` antes do `WHERE` dá erro de sintaxe (1064). E `WHERE categoria_id = 3 OR categoria_id = 6` é equivalente ao `IN` — só mais comprido.

---

⬅️ [Voltar ao Tópico 08 — Filtragem Avançada](./Topico_08_Filtragem_Avancada.md)
