<!--
GABARITO — não faz parte do fluxo principal da aula e fica fora do `nav` do
mkdocs.yml de propósito. É acessível só pelos links dentro de Topico_11_Outer_Join.md.
-->

# Gabarito — Tópico 11 — Junções Externas: LEFT JOIN e RIGHT JOIN

**Disciplina:** Banco de Dados e Aplicações <br>
**Professor:** Ronan Adriel Zenatti · ronan.zenatti@cps.sp.gov.br  <br>
**Fatec Jahu — 2º Semestre/2026**

---

!!! warning "Antes de conferir"
    Assim como nos gabaritos anteriores: este documento mostra **uma** solução correta possível para cada Checkpoint. Variações como quebras de linha, os apelidos escolhidos para as tabelas ou escrever a tabela preservada no `RIGHT JOIN` (em vez de usar o `LEFT JOIN`) não invalidam sua resposta — desde que o resultado seja o mesmo. O que importa é o raciocínio: **a tabela que não pode perder linhas vem primeiro, num `LEFT JOIN`**; `COUNT` sobre uma coluna da direita; `IS NULL` (e nunca `= NULL`) para achar quem não tem par.

    Estes resultados pressupõem o banco com a **carga do Tópico 07 mais a carga complementar do Tópico 09**.

---

## Checkpoint 1 — LEFT JOIN {: #checkpoint-1 }

**Raciocínio:** em (a), a tabela que não pode perder linhas é `clientes`, então ela vem no `FROM` e `pedidos` entra por `LEFT JOIN`; a contagem é de uma coluna da direita (`p.id_pedido`) para que quem não tem pedido receba 0, e não 1. Em (b) e (c), o `LEFT JOIN` é usado com `IS NULL` na chave da tabela da direita, para ficar só com quem não tem par.

```sql
-- (a) Todos os clientes, com a quantidade de pedidos (inclusive zero)
SELECT c.nome             AS cliente,
       COUNT(p.id_pedido) AS total_pedidos
FROM clientes c
LEFT JOIN pedidos p ON p.cliente_id = c.id_cliente
GROUP BY c.id_cliente, c.nome
ORDER BY total_pedidos ASC, c.nome;

-- (b) Clientes que nunca fizeram pedido
SELECT c.nome,
       c.email
FROM clientes c
LEFT JOIN pedidos p ON p.cliente_id = c.id_cliente
WHERE p.id_pedido IS NULL;

-- (c) Produtos que nunca foram vendidos
SELECT pr.nome,
       pr.preco
FROM produtos pr
LEFT JOIN itens_pedidos ip ON ip.produto_id = pr.id_produto
WHERE ip.id_item_pedido IS NULL
ORDER BY pr.nome;
```

Resultado esperado de (a):

```text
+-----------------+---------------+
| cliente         | total_pedidos |
+-----------------+---------------+
| Elisa Rocha     |             0 |
| Fábio Teixeira  |             0 |
| Diego Alves     |             2 |
| Bruno Lima      |             3 |
| Carla Mendes    |             3 |
| Ana Souza       |             5 |
+-----------------+---------------+
```

Resultado esperado de (b):

```text
+-----------------+--------------------------+
| nome            | email                    |
+-----------------+--------------------------+
| Elisa Rocha     | elisa.rocha@email.com    |
| Fábio Teixeira  | fabio.teixeira@email.com |
+-----------------+--------------------------+
```

Resultado esperado de (c):

```text
+-----------------------+-------+
| nome                  | preco |
+-----------------------+-------+
| Presunto fatiado (kg) | 39.90 |
| Queijo mussarela (kg) | 44.90 |
| Tomate (kg)           |  8.90 |
+-----------------------+-------+
```

> 💡 **Erros comuns:** em (a), usar `COUNT(*)` faria Elisa e Fábio aparecerem com `1`. Em (b) e (c), escrever `= NULL` devolveria zero linhas, sem erro. Em (c), testar `ip.produto_id IS NULL` (a FK de ligação, obrigatória) dá o mesmo resultado que `ip.id_item_pedido IS NULL` (a PK); o importante é testar uma coluna da tabela da direita que **nunca seja `NULL` quando há par**.

---

## Checkpoint 2 — LEFT JOIN avançado {: #checkpoint-2 }

**Raciocínio:** (a) parte de `categorias` e usa `LEFT JOIN` nas **duas** junções (se a segunda fosse `INNER`, a categoria Frios sumiria de novo); o `IFNULL` transforma o `NULL` da soma em `0`. (b) o atendente é opcional (`funcionario_id` pode ser `NULL`), então a segunda cópia de `clientes` entra por `LEFT JOIN`; o filtro `status = 'entregue'` é sobre a tabela da **esquerda** (`pedidos`), por isso pode ficar no `WHERE`. (c) precisa contar cancelados **de todos os clientes**, inclusive zero; o filtro sobre a tabela da direita (`p.status`) fica no `ON`, e não no `WHERE`.

```sql
-- (a) Unidades vendidas por categoria, incluindo as que não venderam
SELECT cat.nome                      AS categoria,
       IFNULL(SUM(ip.quantidade), 0) AS unidades_vendidas
FROM categorias cat
LEFT JOIN produtos pr       ON pr.categoria_id = cat.id_categoria
LEFT JOIN itens_pedidos ip  ON ip.produto_id   = pr.id_produto
GROUP BY cat.id_categoria, cat.nome
ORDER BY unidades_vendidas DESC, cat.nome;

-- (b) Atendente dos pedidos entregues ('sem atendente' quando não houver)
SELECT p.id_pedido,
       IFNULL(a.nome, 'sem atendente') AS atendente
FROM pedidos p
LEFT JOIN clientes a ON a.id_cliente = p.funcionario_id
WHERE p.status = 'entregue'
ORDER BY p.id_pedido;

-- (c) Quantidade de pedidos cancelados de cada cliente (inclusive zero)
SELECT c.nome             AS cliente,
       COUNT(p.id_pedido) AS pedidos_cancelados
FROM clientes c
LEFT JOIN pedidos p ON p.cliente_id = c.id_cliente
                   AND p.status = 'cancelado'
GROUP BY c.id_cliente, c.nome
ORDER BY pedidos_cancelados DESC, c.nome;
```

Resultado esperado de (a):

```text
+------------+-------------------+
| categoria  | unidades_vendidas |
+------------+-------------------+
| Bebidas    |                16 |
| Padaria    |                11 |
| Hortifruti |                 9 |
| Limpeza    |                 9 |
| Mercearia  |                 8 |
| Frios      |                 0 |
+------------+-------------------+
```

Resultado esperado de (b):

```text
+-----------+-----------------+
| id_pedido | atendente       |
+-----------+-----------------+
|         1 | sem atendente   |
|         6 | Elisa Rocha     |
|         7 | Elisa Rocha     |
|         8 | Fábio Teixeira  |
|        10 | Fábio Teixeira  |
|        11 | sem atendente   |
+-----------+-----------------+
```

Resultado esperado de (c):

```text
+-----------------+--------------------+
| cliente         | pedidos_cancelados |
+-----------------+--------------------+
| Ana Souza       |                  1 |
| Diego Alves     |                  1 |
| Bruno Lima      |                  0 |
| Carla Mendes    |                  0 |
| Elisa Rocha     |                  0 |
| Fábio Teixeira  |                  0 |
+-----------------+--------------------+
```

> 💡 **Dica:** se em (c) você colocou `WHERE p.status = 'cancelado'`, só Ana e Diego apareceriam — o `WHERE` desfaz o `LEFT JOIN`. Em (b), repare que o `WHERE` **é** adequado porque filtra a tabela `pedidos`, a da esquerda, que é a que estamos listando; o que não pode ir no `WHERE` é uma condição sobre a tabela da direita (`a`).

---

⬅️ [Voltar ao Tópico 11 — Junções Externas](./Topico_11_Outer_Join.md)
