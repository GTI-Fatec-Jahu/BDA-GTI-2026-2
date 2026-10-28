<!--
GABARITO — não faz parte do fluxo principal da aula e fica fora do `nav` do
mkdocs.yml de propósito. É acessível só pelos links dentro de Topico_09_Agregacao_Dados.md.
-->

# Gabarito — Tópico 09 — Agregação de Dados: GROUP BY e Funções de Grupo

**Disciplina:** Banco de Dados e Aplicações <br>
**Professor:** Ronan Adriel Zenatti · ronan.zenatti@cps.sp.gov.br  <br>
**Fatec Jahu — 2º Semestre/2026**

---

!!! warning "Antes de conferir"
    Assim como nos gabaritos anteriores: este documento mostra **uma** solução correta possível para cada Checkpoint. Variações como quebras de linha, o nome exato do apelido ou a ordem de linhas que **empatam** no critério de ordenação não invalidam sua resposta. O que importa é o raciocínio: a função de agregação certa, `GROUP BY` com todas as colunas não agregadas, `WHERE` para filtrar linhas e `HAVING` para filtrar grupos.

    Estes resultados pressupõem o banco com a **carga do Tópico 07 mais a carga complementar do Tópico 09** (13 pedidos e 24 itens).

---

## Checkpoint 1 — Funções de agregação {: #checkpoint-1 }

**Raciocínio:** cada item pede **um número só**, então não há `GROUP BY`: o `SELECT` tem apenas funções de agregação. No item (d), o `WHERE` filtra primeiro os pedidos entregues e só depois o `MIN` e o `MAX` olham para o que sobrou.

```sql
-- (a) Quantos produtos estão cadastrados
SELECT COUNT(*) AS total_produtos
FROM produtos;

-- (b) Soma de todo o estoque
SELECT SUM(estoque) AS unidades_em_estoque
FROM produtos;

-- (c) Preço médio, com 2 casas
SELECT ROUND(AVG(preco), 2) AS preco_medio
FROM produtos;

-- (d) Menor e maior valor entre os pedidos entregues
SELECT MIN(valor_total) AS menor_pedido,
       MAX(valor_total) AS maior_pedido
FROM pedidos
WHERE status = 'entregue';
```

Resultado esperado de (a):

```text
+----------------+
| total_produtos |
+----------------+
|             11 |
+----------------+
```

Resultado esperado de (b):

```text
+---------------------+
| unidades_em_estoque |
+---------------------+
|                 323 |
+---------------------+
```

Resultado esperado de (c):

```text
+-------------+
| preco_medio |
+-------------+
|       18.31 |
+-------------+
```

Resultado esperado de (d):

```text
+--------------+--------------+
| menor_pedido | maior_pedido |
+--------------+--------------+
|        44.97 |        77.30 |
+--------------+--------------+
```

> 💡 **Erro comum:** esquecer o `ROUND` em (c) e receber `18.307273`. A média quase sempre vem com mais casas decimais do que um preço em reais precisa.

---

## Checkpoint 2 — GROUP BY {: #checkpoint-2 }

**Raciocínio:** a palavra "**cada**" ("de cada categoria", "por cliente", "por mês") é a pista de que a pergunta pede `GROUP BY` naquela coluna. No item (b), o `WHERE` descarta os pedidos não entregues **antes** de formar os grupos; o `ORDER BY` usa o apelido `total_gasto`, o que é permitido (ele roda depois do `SELECT`).

```sql
-- (a) Quantidade de produtos de cada categoria
SELECT categoria_id,
       COUNT(*) AS qtd_produtos
FROM produtos
GROUP BY categoria_id;

-- (b) Total gasto por cliente, só pedidos entregues, do maior para o menor
SELECT cliente_id,
       SUM(valor_total) AS total_gasto
FROM pedidos
WHERE status = 'entregue'
GROUP BY cliente_id
ORDER BY total_gasto DESC;

-- (c) Quantidade de pedidos por mês
SELECT MONTH(data_pedido) AS mes,
       COUNT(*)           AS pedidos
FROM pedidos
GROUP BY MONTH(data_pedido)
ORDER BY mes;
```

Resultado esperado de (a):

```text
+--------------+--------------+
| categoria_id | qtd_produtos |
+--------------+--------------+
|            1 |            2 |
|            2 |            2 |
|            3 |            2 |
|            4 |            2 |
|            5 |            1 |
|            6 |            2 |
+--------------+--------------+
```

Resultado esperado de (b):

```text
+------------+-------------+
| cliente_id | total_gasto |
+------------+-------------+
|          2 |      123.08 |
|          1 |       92.29 |
|          4 |       77.30 |
|          3 |       44.97 |
+------------+-------------+
```

Resultado esperado de (c):

```text
+------+---------+
| mes  | pedidos |
+------+---------+
|    8 |       2 |
|    9 |       4 |
|   10 |       7 |
+------+---------+
```

> 💡 **Dica:** em (c), como todos os pedidos são de 2026, agrupar só por `MONTH` funciona. Numa tabela com vários anos, o correto é `GROUP BY YEAR(data_pedido), MONTH(data_pedido)` (e mostrar o ano no `SELECT`), para não misturar o mesmo mês de anos diferentes.

---

## Checkpoint 3 — HAVING {: #checkpoint-3 }

**Raciocínio:** em todos os itens a condição envolve o **resultado de uma função de agregação** (contagem ou soma do grupo). Isso só pode ser testado depois de agrupar, então vai no `HAVING`. No item (c), as duas ideias aparecem juntas: o `WHERE` tira os cancelados (filtra linhas) e o `HAVING` tira os clientes que gastaram até R$ 150 (filtra grupos).

```sql
-- (a) Categorias com mais de 1 produto
SELECT categoria_id,
       COUNT(*) AS qtd_produtos
FROM produtos
GROUP BY categoria_id
HAVING COUNT(*) > 1;

-- (b) Produtos que venderam mais de 5 unidades no total
SELECT produto_id,
       SUM(quantidade) AS unidades_vendidas
FROM itens_pedidos
GROUP BY produto_id
HAVING SUM(quantidade) > 5
ORDER BY unidades_vendidas DESC;

-- (c) Clientes que gastaram mais de R$ 150 em pedidos não cancelados
SELECT cliente_id,
       SUM(valor_total) AS total_gasto
FROM pedidos
WHERE status <> 'cancelado'
GROUP BY cliente_id
HAVING SUM(valor_total) > 150;
```

Resultado esperado de (a):

```text
+--------------+--------------+
| categoria_id | qtd_produtos |
+--------------+--------------+
|            1 |            2 |
|            2 |            2 |
|            3 |            2 |
|            4 |            2 |
|            6 |            2 |
+--------------+--------------+
```

A categoria 5 (Limpeza, com um único produto) ficou de fora.

Resultado esperado de (b):

```text
+------------+-------------------+
| produto_id | unidades_vendidas |
+------------+-------------------+
|          5 |                 9 |
|          7 |                 9 |
|          9 |                 9 |
|          1 |                 8 |
|          6 |                 7 |
+------------+-------------------+
```

Os produtos 5, 7 e 9 **empatam** com 9 unidades; a ordem entre eles pode ser diferente na sua tela, e está correta.

Resultado esperado de (c):

```text
+------------+-------------+
| cliente_id | total_gasto |
+------------+-------------+
|          1 |      189.73 |
|          2 |      172.96 |
+------------+-------------+
```

> 💡 **Dica:** se você tentou `WHERE COUNT(*) > 1` ou `WHERE SUM(valor_total) > 150`, recebeu o erro 1111 (`Invalid use of group function`). A solução é sempre a mesma: a condição sobre função de agregação vai para o `HAVING`.

---

⬅️ [Voltar ao Tópico 09 — Agregação de Dados](./Topico_09_Agregacao_Dados.md)
