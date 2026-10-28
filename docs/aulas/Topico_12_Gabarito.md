<!--
GABARITO — não faz parte do fluxo principal da aula e fica fora do `nav` do
mkdocs.yml de propósito. É acessível só pelos links dentro de Topico_12_Introducao_PLSQL.md.
-->

# Gabarito — Tópico 12 — Introdução ao PL/SQL: Procedimentos Armazenados

**Disciplina:** Banco de Dados e Aplicações <br>
**Professor:** Ronan Adriel Zenatti · ronan.zenatti@cps.sp.gov.br  <br>
**Fatec Jahu — 2º Semestre/2026**

---

!!! warning "Antes de conferir"
    Assim como nos gabaritos anteriores: este documento mostra **uma** solução correta possível para cada Checkpoint. Variações como quebras de linha, o nome exato dos parâmetros ou comentários não invalidam sua resposta. O que importa é o raciocínio: `DELIMITER` trocado antes de criar e restaurado depois, parâmetros com o prefixo `p_`, `BEGIN ... END` envolvendo o corpo e o `CALL` (ou o `SELECT`, no caso de função) para executar.

    Estes resultados pressupõem o banco com a **carga do Tópico 07 mais a carga complementar do Tópico 09**.

---

## Checkpoint 1 — Stored procedures {: #checkpoint-1 }

**Raciocínio:** um procedimento é "uma consulta com nome". Em (a), a consulta não depende de nada de fora, então os parênteses ficam vazios. Em (b), o que muda de uma chamada para outra (a categoria) vira um parâmetro `IN`, e a consulta o usa no `WHERE` — com o prefixo `p_` para não confundir com a coluna.

```sql
DELIMITER $$

-- (a) Clientes sem telefone
CREATE PROCEDURE listar_clientes_sem_telefone()
BEGIN
    SELECT nome, email
    FROM clientes
    WHERE telefone IS NULL;
END$$

-- (b) Produtos de uma categoria, em ordem alfabética
CREATE PROCEDURE listar_produtos_da_categoria(IN p_categoria_id BIGINT UNSIGNED)
BEGIN
    SELECT nome, preco
    FROM produtos
    WHERE categoria_id = p_categoria_id
    ORDER BY nome;
END$$

DELIMITER ;
```

Executando:

```sql
CALL listar_clientes_sem_telefone();
CALL listar_produtos_da_categoria(3);
```

Resultado esperado do primeiro `CALL`:

```text
+-------------+-----------------------+
| nome        | email                 |
+-------------+-----------------------+
| Diego Alves | diego.alves@email.com |
| Elisa Rocha | elisa.rocha@email.com |
+-------------+-----------------------+
```

Resultado esperado do segundo `CALL`:

```text
+--------------------+-------+
| nome               | preco |
+--------------------+-------+
| Arroz 5kg          | 29.90 |
| Café torrado 500g  | 17.50 |
+--------------------+-------+
```

> 💡 **Dicas:** em (a), lembre que a condição para `NULL` é `IS NULL` (Tópico 08), também dentro de um procedimento. Em (b), chamar com uma categoria inexistente (`CALL listar_produtos_da_categoria(99);`) não dá erro: devolve apenas uma lista vazia. Se algum `CREATE PROCEDURE` deu o erro 1304 (*already exists*), é porque você já havia criado um com esse nome; use `DROP PROCEDURE IF EXISTS nome;` e crie de novo.

---

## Checkpoint 2 — Functions {: #checkpoint-2 }

**Raciocínio:** a função é o "contrário" de `calcular_desconto`: em vez de subtrair o percentual, soma. Declare o tipo do que devolve (`RETURNS DECIMAL(10, 2)`) e use `RETURN` no corpo. Depois de criada, ela é usada **dentro do `SELECT`**, pelo nome — sem `CALL`.

```sql
-- (a) Criação da função
DELIMITER $$

CREATE FUNCTION aplicar_acrescimo(preco DECIMAL(10, 2), percentual INT)
RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
    RETURN preco + (preco * percentual / 100);
END$$

DELIMITER ;

-- (b) Padaria com acréscimo de 10%
SELECT nome,
       preco,
       aplicar_acrescimo(preco, 10) AS preco_reajustado
FROM produtos
WHERE categoria_id = 1;

-- (c) Produtos com preço menor que R$ 8, com acréscimo de 5%
SELECT nome,
       preco,
       aplicar_acrescimo(preco, 5) AS preco_reajustado
FROM produtos
WHERE preco < 8
ORDER BY preco;
```

Resultado esperado de (b):

```text
+--------------------+-------+------------------+
| nome               | preco | preco_reajustado |
+--------------------+-------+------------------+
| Pão francês (kg)   | 14.90 |            16.39 |
| Bolo de fubá       | 18.00 |            19.80 |
+--------------------+-------+------------------+
```

Resultado esperado de (c):

```text
+--------------------+-------+------------------+
| nome               | preco | preco_reajustado |
+--------------------+-------+------------------+
| Detergente 500ml   |  2.99 |             3.14 |
| Banana prata (kg)  |  6.90 |             7.25 |
| Suco de laranja 1L |  7.50 |             7.88 |
+--------------------+-------+------------------+
```

> 💡 **Dicas:** a função **não altera** os preços na tabela — assim como `ROUND` e `UPPER`, ela só calcula o valor que aparece no resultado. Tentar `CALL aplicar_acrescimo(100, 10);` dá o erro 1305 (`PROCEDURE ... does not exist`), pois ela é uma função, e não um procedimento. Para remover as rotinas criadas nos checkpoints: `DROP PROCEDURE IF EXISTS listar_clientes_sem_telefone;`, `DROP PROCEDURE IF EXISTS listar_produtos_da_categoria;` e `DROP FUNCTION IF EXISTS aplicar_acrescimo;`.

---

⬅️ [Voltar ao Tópico 12 — Introdução ao PL/SQL](./Topico_12_Introducao_PLSQL.md)
