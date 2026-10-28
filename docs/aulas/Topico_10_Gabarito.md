<!--
GABARITO — não faz parte do fluxo principal da aula e fica fora do `nav` do
mkdocs.yml de propósito. É acessível só pelos links dentro de Topico_10_Inner_Join.md.
-->

# Gabarito — Tópico 10 — Junção de Tabelas: INNER JOIN

**Disciplina:** Banco de Dados e Aplicações <br>
**Professor:** Ronan Adriel Zenatti · ronan.zenatti@cps.sp.gov.br  <br>
**Fatec Jahu — 2º Semestre/2026**

---

!!! warning "Antes de conferir"
    Assim como nos gabaritos anteriores: este documento mostra **uma** solução correta possível para cada Checkpoint. Variações como quebras de linha, os apelidos escolhidos para as tabelas (`c`, `p`... ou outros) ou a ordem de tabelas no `FROM` (no `INNER JOIN` isso não muda o resultado) não invalidam sua resposta. O que importa é o raciocínio: cada `INNER JOIN` com seu `ON` ligando **PK = FK**, colunas qualificadas com o apelido e palavras reservadas em MAIÚSCULAS.

    Estes resultados pressupõem o banco com a **carga do Tópico 07 mais a carga complementar do Tópico 09**.

---

## Checkpoint 1 — INNER JOIN com duas tabelas {: #checkpoint-1 }

**Raciocínio:** para trocar um número (`categoria_id`) por um nome, junte a tabela que tem o nome. A ligação é a FK `produtos.categoria_id` com a PK `categorias.id_categoria`. Como as duas tabelas têm uma coluna `nome`, **precisa** qualificar (`pr.nome`, `cat.nome`) e dar apelidos às colunas para o leitor saber qual é qual.

```sql
-- (a) Nome do produto e nome da categoria
SELECT pr.nome  AS produto,
       cat.nome AS categoria
FROM produtos pr
INNER JOIN categorias cat ON cat.id_categoria = pr.categoria_id
ORDER BY cat.nome, pr.nome;

-- (b) Nome do cliente e id dos pedidos enviados
SELECT c.nome,
       p.id_pedido
FROM clientes c
INNER JOIN pedidos p ON c.id_cliente = p.cliente_id
WHERE p.status = 'enviado';

-- (c) Produtos da categoria Bebidas, do mais caro ao mais barato
SELECT pr.nome,
       pr.preco
FROM produtos pr
INNER JOIN categorias cat ON cat.id_categoria = pr.categoria_id
WHERE cat.nome = 'Bebidas'
ORDER BY pr.preco DESC;
```

Resultado esperado de (a):

```text
+-----------------------+------------+
| produto               | categoria  |
+-----------------------+------------+
| Refrigerante 2L       | Bebidas    |
| Suco de laranja 1L    | Bebidas    |
| Presunto fatiado (kg) | Frios      |
| Queijo mussarela (kg) | Frios      |
| Banana prata (kg)     | Hortifruti |
| Tomate (kg)           | Hortifruti |
| Detergente 500ml      | Limpeza    |
| Arroz 5kg             | Mercearia  |
| Café torrado 500g     | Mercearia  |
| Bolo de fubá          | Padaria    |
| Pão francês (kg)      | Padaria    |
+-----------------------+------------+
```

Resultado esperado de (b):

```text
+------------+-----------+
| nome       | id_pedido |
+------------+-----------+
| Bruno Lima |         2 |
| Ana Souza  |        12 |
+------------+-----------+
```

Resultado esperado de (c):

```text
+--------------------+-------+
| nome               | preco |
+--------------------+-------+
| Refrigerante 2L    |  9.99 |
| Suco de laranja 1L |  7.50 |
+--------------------+-------+
```

> 💡 **Dica:** em (a), os 11 produtos aparecem porque todos têm uma categoria (a FK `categoria_id` é `NOT NULL`). Em (c), o filtro é pelo **nome** da categoria: isso só é possível porque o `JOIN` trouxe a coluna `cat.nome` para dentro da consulta. Sem o `JOIN`, você teria que "saber de cabeça" que Bebidas é a categoria 2.

---

## Checkpoint 2 — Várias tabelas e aliases {: #checkpoint-2 }

**Raciocínio:** (a) precisa de um caminho de quatro tabelas — cada seta do caminho `clientes → pedidos → itens_pedidos → produtos` vira um `INNER JOIN ... ON`; o filtro pelo nome da cliente é feito no `WHERE`. (b) usa `clientes` duas vezes, uma como comprador (`c`) e outra como atendente (`a`) — por isso os apelidos são obrigatórios. (c) só precisa de `itens_pedidos` e `produtos`, pois o número do pedido já está em `itens_pedidos.pedido_id`.

```sql
-- (a) Itens dos pedidos da Ana Souza
SELECT p.id_pedido,
       pr.nome AS produto,
       ip.quantidade
FROM clientes c
INNER JOIN pedidos       p  ON c.id_cliente  = p.cliente_id
INNER JOIN itens_pedidos ip ON p.id_pedido   = ip.pedido_id
INNER JOIN produtos      pr ON ip.produto_id = pr.id_produto
WHERE c.nome = 'Ana Souza'
ORDER BY p.id_pedido;

-- (b) Cliente e atendente dos pedidos entregues que têm atendente
SELECT p.id_pedido,
       c.nome AS cliente,
       a.nome AS atendente
FROM pedidos p
INNER JOIN clientes c ON c.id_cliente = p.cliente_id
INNER JOIN clientes a ON a.id_cliente = p.funcionario_id
WHERE p.status = 'entregue'
ORDER BY p.id_pedido;

-- (c) Itens do pedido 10, com o subtotal
SELECT pr.nome                          AS produto,
       ip.quantidade,
       ip.quantidade * ip.preco_unitario AS subtotal
FROM itens_pedidos ip
INNER JOIN produtos pr ON pr.id_produto = ip.produto_id
WHERE ip.pedido_id = 10;
```

Resultado esperado de (a):

```text
+-----------+--------------------+------------+
| id_pedido | produto            | quantidade |
+-----------+--------------------+------------+
|         1 | Pão francês (kg)   |          2 |
|         1 | Café torrado 500g  |          1 |
|         3 | Suco de laranja 1L |          3 |
|         7 | Café torrado 500g  |          2 |
|         7 | Refrigerante 2L    |          1 |
|         9 | Suco de laranja 1L |          2 |
|        12 | Refrigerante 2L    |          6 |
|        12 | Suco de laranja 1L |          2 |
+-----------+--------------------+------------+
```

Resultado esperado de (b):

```text
+-----------+--------------+-----------------+
| id_pedido | cliente      | atendente       |
+-----------+--------------+-----------------+
|         6 | Bruno Lima   | Elisa Rocha     |
|         7 | Ana Souza    | Elisa Rocha     |
|         8 | Carla Mendes | Fábio Teixeira  |
|        10 | Bruno Lima   | Fábio Teixeira  |
+-----------+--------------+-----------------+
```

Resultado esperado de (c):

```text
+--------------------+------------+----------+
| produto            | quantidade | subtotal |
+--------------------+------------+----------+
| Pão francês (kg)   |          1 |    14.90 |
| Banana prata (kg)  |          4 |    27.60 |
| Detergente 500ml   |          2 |     5.98 |
+--------------------+------------+----------+
```

> 💡 **Dica:** em (b), os pedidos entregues **sem atendente** (pedidos 1 e 11) não aparecem — o `INNER JOIN` descarta quem não tem par. Para listá-los também, com o atendente em branco (`NULL`), seria preciso um `LEFT JOIN` (Tópico 11). Em (c), o subtotal somado dá 48,48, o `valor_total` do pedido 10.

---

## Checkpoint 3 — JOIN com agregação {: #checkpoint-3 }

**Raciocínio:** são os relatórios do Tópico 09, agora com nomes. O padrão é: `JOIN` para trazer o nome → `WHERE` para filtrar linhas → `GROUP BY chave, nome` → função de agregação → `HAVING` se a condição for sobre o resultado da função → `ORDER BY`.

```sql
-- (a) Total gasto por cliente, sem contar pedidos cancelados
SELECT c.nome             AS cliente,
       SUM(p.valor_total) AS total_gasto
FROM clientes c
INNER JOIN pedidos p ON p.cliente_id = c.id_cliente
WHERE p.status <> 'cancelado'
GROUP BY c.id_cliente, c.nome
ORDER BY total_gasto DESC;

-- (b) Unidades vendidas por categoria
SELECT cat.nome          AS categoria,
       SUM(ip.quantidade) AS unidades_vendidas
FROM categorias cat
INNER JOIN produtos pr       ON pr.categoria_id = cat.id_categoria
INNER JOIN itens_pedidos ip  ON ip.produto_id   = pr.id_produto
GROUP BY cat.id_categoria, cat.nome
ORDER BY unidades_vendidas DESC;

-- (c) Clientes com 2 ou mais pedidos entregues
SELECT c.nome   AS cliente,
       COUNT(*) AS pedidos_entregues
FROM clientes c
INNER JOIN pedidos p ON p.cliente_id = c.id_cliente
WHERE p.status = 'entregue'
GROUP BY c.id_cliente, c.nome
HAVING COUNT(*) >= 2
ORDER BY pedidos_entregues DESC, c.nome;
```

Resultado esperado de (a):

```text
+--------------+-------------+
| cliente      | total_gasto |
+--------------+-------------+
| Ana Souza    |      189.73 |
| Bruno Lima   |      172.96 |
| Carla Mendes |      121.23 |
| Diego Alves  |       77.30 |
+--------------+-------------+
```

Resultado esperado de (b):

```text
+------------+-------------------+
| categoria  | unidades_vendidas |
+------------+-------------------+
| Bebidas    |                16 |
| Padaria    |                11 |
| Hortifruti |                 9 |
| Limpeza    |                 9 |
| Mercearia  |                 8 |
+------------+-------------------+
```

Os produtos 9 (Detergente, Limpeza) e 7 (Banana, Hortifruti) empatam em 9 unidades; a ordem entre **Hortifruti** e **Limpeza** pode aparecer trocada na sua tela, e está correta. A categoria **Frios** não aparece, pois nenhum de seus produtos foi vendido.

Resultado esperado de (c):

```text
+------------+-------------------+
| cliente    | pedidos_entregues |
+------------+-------------------+
| Ana Souza  |                 2 |
| Bruno Lima |                 2 |
+------------+-------------------+
```

> 💡 **Dica:** em (c), o `COUNT(*)` está correto porque **não juntamos** `itens_pedidos` — cada linha do resultado do `JOIN` é um pedido. Se você juntasse também os itens, passaria a contar itens e precisaria de `COUNT(DISTINCT p.id_pedido)`. E em (a), `valor_total` é somado direto da tabela `pedidos`, sem passar pelos itens, para não multiplicar o valor de cada pedido pela quantidade de itens.

---

⬅️ [Voltar ao Tópico 10 — INNER JOIN](./Topico_10_Inner_Join.md)
