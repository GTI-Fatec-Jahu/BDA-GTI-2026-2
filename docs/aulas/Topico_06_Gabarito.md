<!--
GABARITO — não faz parte do fluxo principal da aula e fica fora do `nav` do
mkdocs.yml de propósito. É acessível só pelos links dentro de Topico_06_SQL_DML.md.
-->

# Gabarito — Tópico 06 — SQL: Linguagem de Manipulação de Dados (DML)

**Disciplina:** Banco de Dados e Aplicações <br>
**Professor:** Ronan Adriel Zenatti · ronan.zenatti@cps.sp.gov.br  <br>
**Fatec Jahu — 2º Semestre/2026**

---

!!! warning "Antes de conferir"
    Assim como nos gabaritos anteriores: este documento mostra **uma** solução correta possível para cada Checkpoint. Pequenas variações — a ordem das colunas na lista, a quebra de linha, o uso de um `id` diferente porque o seu `AUTO_INCREMENT` já "pulou" números — não invalidam sua resposta. O que importa é o raciocínio: lista de colunas escrita, pais antes de filhos, `WHERE` presente em todo `UPDATE` e `DELETE`.

---

## Checkpoint 1 — Cadastrando mais dados {: #checkpoint-1 }

**Raciocínio:** `Frios` é uma categoria nova, então vem **primeiro** (é o "pai"). Os produtos precisam do `id_categoria` dela — como `Frios` é a sexta categoria cadastrada, o id é `6` (confirme com `SELECT * FROM categorias;`). A cliente `Elisa` não depende de ninguém e não tem telefone, então basta omitir a coluna `telefone`.

```sql
-- (a) Categoria nova
INSERT INTO categorias (nome, descricao)
VALUES ('Frios', 'Queijos, presuntos e embutidos');

-- (b) Dois produtos de uma vez (categoria_id = 6, a nova categoria Frios)
INSERT INTO produtos (categoria_id, nome, preco, estoque) VALUES
    (6, 'Presunto fatiado (kg)', 39.90, 8),
    (6, 'Queijo mussarela (kg)', 44.90, 6);

-- (c) Cliente sem telefone: a coluna é opcional, então basta não listá-la
INSERT INTO clientes (nome, cpf, email, data_nascimento)
VALUES ('Elisa Rocha', '55566677788', 'elisa.rocha@email.com', '1995-07-09');
```

Resultado esperado: `Query OK, 1 row affected`, `Query OK, 2 rows affected` e `Query OK, 1 row affected`. Se o seu `id_categoria` de `Frios` não for 6, use o id que o `SELECT` mostrou.

> 💡 **Erro comum:** informar `descricao`, `ativa` ou `id_categoria` "por garantia". O id nunca deve ser informado (é `AUTO_INCREMENT`), e `ativa` já tem `DEFAULT 1`.

---

## Checkpoint 2 — O banco aceita ou rejeita? {: #checkpoint-2 }

| | Comando | Resultado | Por quê |
|---|---|---|---|
| **(a)** | `INSERT INTO categorias (nome) VALUES ('Padaria');` | ❌ **Rejeita** — erro **1062** | `Duplicate entry 'Padaria' for key 'uq_cat_nome'`. A constraint `UNIQUE` no `nome` não permite duas categorias com o mesmo nome |
| **(b)** | `INSERT INTO produtos (categoria_id, nome, preco) VALUES (3, 'Macarrão 500g', 5.49);` | ✅ **Aceita** | A categoria 3 (Mercearia) existe; `estoque` e `ativo` não foram informados e usam o `DEFAULT` (`0` e `1`) |
| **(c)** | `INSERT INTO produtos (categoria_id, nome, preco, estoque) VALUES (3, 'Farinha de trigo', 6.20, -10);` | ❌ **Rejeita** — erro **4025** | `CONSTRAINT 'ck_estoque' failed for 'loja_virtual'.'produtos'`. O `CHECK (estoque >= 0)` não aceita estoque negativo |
| **(d)** | `INSERT INTO itens_pedidos (pedido_id, produto_id, quantidade, preco_unitario) VALUES (1, 4, 1, 29.90);` | ❌ **Rejeita** — erro **1062** | `Duplicate entry '1-4' for key 'uq_item_pedido'`. O pedido 1 **já tem** o produto 4 (Arroz 5kg). O `UNIQUE (pedido_id, produto_id)` é composto: o mesmo produto não pode aparecer duas vezes no mesmo pedido — para vender mais unidades, o certo é aumentar a `quantidade` com `UPDATE` |
| **(e)** | `INSERT INTO pedidos (cliente_id, data_pedido) VALUES (50, '2026-10-07');` | ❌ **Rejeita** — erro **1452** | `Cannot add or update a child row ... fk_pedido_cliente`. Não existe cliente com id 50; o "pai" precisa existir antes do "filho" |

> 💡 **Dica de leitura:** a mensagem de erro sempre cita o **nome da constraint** (`uq_cat_nome`, `ck_estoque`, `uq_item_pedido`, `fk_pedido_cliente`). Foi por isso que, no Tópico 05, recomendamos **nomear** as constraints — o nome vira uma pista imediata do que deu errado.

---

## Checkpoint 3 — Reajustes e baixas {: #checkpoint-3 }

**Raciocínio:** todo `UPDATE` precisa de `WHERE`. Como nomes podem se repetir, usamos o id (confirmado antes com `SELECT`).

```sql
-- (a) Diego Alves (id 4 no nosso banco; confirme com SELECT * FROM clientes;)
UPDATE clientes
SET telefone = '14993332211'
WHERE id_cliente = 4;

-- (b) Baixa de 3 unidades no Refrigerante 2L (id 5)
UPDATE produtos
SET estoque = estoque - 3
WHERE id_produto = 5;

-- (c) Pedido 2 enviado
UPDATE pedidos
SET status = 'enviado'
WHERE id_pedido = 2;
```

Cada um deve responder `Rows matched: 1  Changed: 1`. Se aparecer `Rows matched: 0`, o id usado não existe — confira com `SELECT`.

**(d)** O comando **é rejeitado** com o erro **4025** (`CONSTRAINT 'ck_estoque' failed`), e o estoque **não é alterado**. O `CHECK (estoque >= 0)` verifica o valor **novo** (estoque atual − 100 seria negativo) antes de gravar. A ideia é a mesma do "tudo ou nada": ou o `UPDATE` inteiro vale, ou nada muda.

---

## Checkpoint 4 — Apagando com responsabilidade {: #checkpoint-4 }

**(a)** O banco **recusa** com o erro **1451** (`Cannot delete or update a parent row`). A categoria `Limpeza` (id 5) é o "pai" do produto `Detergente 500ml`, e a FK `fk_produto_categoria` foi criada com `ON DELETE RESTRICT` — que impede apagar um pai que ainda tem filhos. Para apagar a categoria seria preciso, antes, remover (ou mover para outra categoria) o detergente.

**(b)** Exclusão lógica da Carla Mendes (id 3 no nosso banco):

```sql
UPDATE clientes
SET deletado_em = NOW()
WHERE id_cliente = 3;
```

**(c)** Reativando a Carla:

```sql
UPDATE clientes
SET deletado_em = NULL
WHERE id_cliente = 3;
```

**(d)** `DELETE FROM clientes;` não tem `WHERE`, então vale para **todas as linhas** da tabela — o banco não pergunta se você tem certeza. Aqui, como `pedidos.cliente_id` usa `ON DELETE RESTRICT`, o MariaDB provavelmente recusaria o comando inteiro com o erro 1451 (pois há clientes com pedidos) — mas isso seria sorte, não segurança. Em uma tabela sem vínculos, todos os dados sumiriam de uma vez, sem volta (a não ser com backup). O hábito certo é: sempre `WHERE`, sempre conferir com `SELECT` antes e, para dados de negócio com histórico, preferir a exclusão lógica.

---

⬅️ [Voltar ao Tópico 06 — SQL: Linguagem de Manipulação de Dados (DML)](./Topico_06_SQL_DML.md)
