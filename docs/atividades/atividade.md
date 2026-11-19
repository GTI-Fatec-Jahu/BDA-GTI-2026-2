# Atividade Prática — Fluxo Encadeado de Consultas, Inserções e Atualizações no `sakila_pt`

**Objetivo:** Praticar o fluxo completo de exploração da estrutura das tabelas, busca de chaves estrangeiras existentes, cadastro encadeado em tabelas dependentes, conferência dos IDs recém-gerados e atualização posterior dos registros criados — no mesmo formato trabalhado em aula com a cadeia `paises` → `cidades` → `enderecos` → `clientes`.

**Orientações gerais:**
- Antes de iniciar qualquer atividade, selecione o banco de dados `sakila_pt`.
- Em todas as etapas de cadastro, inspecione primeiro a estrutura da tabela para identificar quais colunas são obrigatórias, seus tipos de dados e quais são chaves estrangeiras.
- Após cada inserção em tabelas com chave primária autoincrementável, faça uma consulta trazendo apenas o último registro cadastrado para confirmar a gravação e anotar o ID gerado antes de prosseguir para a próxima tabela.
- Ao final de cada atividade, atualize o registro criado filtrando sempre pela chave primária obtida na etapa anterior e confira o resultado.

---

## Atividade 1 — Fluxo de Produção: Elenco e Classificação por Categoria
**Cadeia de tabelas:** `categorias` + `atores` + `idiomas` → `filmes` → `filmes_categorias` e `filmes_atores`

1. Consulte a tabela `categorias` e verifique se existe alguma categoria chamada `'Video Aulas'`.
2. Inspecione a estrutura da tabela `categorias`, cadastre `'Video Aulas'` e consulte o último registro inserido para anotar o `id_categoria`.
3. Consulte a tabela `atores` e verifique se já existe algum ator com o sobrenome `'Zenatti'`.
4. Inspecione a estrutura da tabela `atores`, cadastre um novo ator com primeiro nome `'Ronan'` e último nome `'Zenatti'`, e consulte o último registro inserido para anotar o `id_ator`.
5. Consulte a tabela `idiomas` filtrando por `'Português'` se não encontrar, cadastre o idioma e anote seu `id_idioma`;
6. Inspecione a estrutura da tabela `filmes`, cadastre um novo filme com os dados de tema de uma aula utilizando o `id_idioma` anotado e consulte o último registro inserido para obter o `id_filme`.
7. Inspecione a estrutura da tabela `filmes_categorias` e insira o vínculo relacionando o `id_filme` recém-criado ao `id_categoria` criado no passo 2.
8. Inspecione a estrutura da tabela `filmes_atores` e insira o vínculo relacionando o `id_ator` criado no passo 4 ao `id_filme` recém-criado.
9. Consulte as tabelas `filmes_categorias` e `filmes_atores` filtrando pelo `id_filme` recém-criado para confirmar que os relacionamentos foram gravados corretamente.
10. Atualize o ator recém-criado na tabela `atores`, alterando o `primeiro_nome` para `'Ronan Adriel'`.
11. Adicione o idioma mandarim na coluna idioma_original_id do filme recem criado.

---

## Atividade 2 — Fluxo de Contratação de Funcionário
**Cadeia de tabelas:** `paises` → `cidades` → `enderecos` → `funcionarios` *(com consulta em `lojas`)*

1. Consulte a tabela `paises` e localize o registro do país `'Argentina'` (ou `'Brasil'`) para anotar seu `id_pais`.
2. Verifique na tabela `cidades` se já existe uma cidade chamada `'Mendoza'` (caso tenha escolhido `'Argentina'`) ou `'Jaú'` (caso tenha escolhido `'Brasil'`).
3. Inspecione a estrutura da tabela `cidades`, cadastre a nova cidade vinculada ao `id_pais` anotado e consulte o último registro inserido para obter o `id_cidade`.
4. Inspecione a estrutura da tabela `enderecos`, cadastre um novo endereço completo vinculado ao `id_cidade` recém-criado (informando logradouro, complemento opcional, bairro, código postal e telefone) e consulte o último registro inserido para anotar o `id_endereco`.
5. Consulte a tabela `lojas` para verificar quais `id_loja` existem cadastrados.
6. Inspecione a estrutura da tabela `funcionarios` para identificar todos os campos obrigatórios (como nome, sobrenome, endereço, loja, status ativo e nome de usuário).
7. Cadastre um novo funcionário na tabela `funcionarios` vinculado ao `id_endereco` recém-criado e à loja `1` (deixando os campos opcionais como `foto` e `senha` como nulos, se preferir).
8. Consulte o último registro inserido na tabela `funcionarios` para confirmar o cadastro e anotar o `id_funcionario`.
9. Atualize o registro do funcionário recém-criado na tabela `funcionarios` (filtrando pelo seu `id_funcionario`), alterando o `email`, o `nome_usuario` e transferindo-o para a loja `2` (`loja_id`). Em seguida, consulte o registro novamente para validar as alterações.

---

## Atividade 3 — Consultas Analíticas com `SELECT` (Dificuldade Crescente)

**Regras desta atividade:**
- Utilize apenas as cláusulas: `SELECT`, `FROM`, `WHERE`, `INNER JOIN`, `GROUP BY`, `ORDER BY` e `LIMIT`.
- Quando necessário, utilize no máximo **uma** função de agregação simples por consulta (`SUM`, `AVG`, `MIN` ou `MAX`).
- Os itens **1 a 5** devem ser resolvidos **sem `INNER JOIN`** (apenas uma tabela).
- Os itens **6 a 10** devem ser resolvidos **com `INNER JOIN`** (relacionando duas ou mais tabelas).

### Parte 1 — Consultas em tabela única (sem `INNER JOIN`)

1. Liste o `titulo`, a `taxa_aluguel` e a `duracao` dos filmes da tabela `filmes` que possuem classificação `'PG-13'`, ordenados pelo `titulo` em ordem alfabética.
2. Apresente os **10 filmes com maior custo de reposição** (`custo_reposicao`) da tabela `filmes`, exibindo o `titulo`, a `classificacao` e o `custo_reposicao`, ordenados do maior para o menor valor.
3. Calcule a média (usando `AVG` no campo `taxa_aluguel`) dos filmes da tabela `filmes` cuja `classificacao` seja `'G'`.
4. Na tabela `filmes`, apresente a maior duração (usando `MAX` no campo `duracao`) para cada classificação, agrupando (`GROUP BY`) pelo campo `classificacao`, e ordene o resultado da maior para a menor duração.
5. Considerando apenas os registros com `valor` maior que `0` na tabela `pagamentos`, apresente o `cliente_id` e o valor total pago (usando `SUM` no campo `valor`) dos **5 clientes que mais gastaram**, agrupando (`GROUP BY`) pelo campo `cliente_id` e ordenando do maior para o menor total.

### Parte 2 — Consultas relacionais (com `INNER JOIN`)

6. Liste o `primeiro_nome`, `ultimo_nome` e `email` de todos os clientes ativos (`ativo = 1`), juntamente com o `logradouro` e o `telefone` de seus respectivos endereços (relacionando `clientes` e `enderecos`), ordenados por `primeiro_nome` em ordem alfabética.
7. Apresente o **funcionário com maior valor total em vendas**, exibindo `primeiro_nome`, `ultimo_nome` e o total vendido (usando `SUM` no campo `pagamentos.valor`), relacionando `funcionarios` e `pagamentos` e agrupando (`GROUP BY`) pelos campos `funcionarios.id_funcionario`, `funcionarios.primeiro_nome` e `funcionarios.ultimo_nome`.
8. Apresente os **5 melhores clientes ativos** (`ativo = 1`) da locadora, exibindo `primeiro_nome`, `ultimo_nome`, `email` e o valor total gasto (usando `SUM` no campo `pagamentos.valor`), relacionando `clientes` e `pagamentos`, agrupando (`GROUP BY`) pelos campos `clientes.id_cliente`, `clientes.primeiro_nome`, `clientes.ultimo_nome` e `clientes.email`, e ordenando do maior para o menor valor gasto.
9. Apresente os **10 filmes mais vendidos (maior faturamento)** da locadora, exibindo `filmes.titulo` e o faturamento total (usando `SUM` no campo `pagamentos.valor`), relacionando `filmes`, `inventarios`, `alugueis` e `pagamentos`, agrupando (`GROUP BY`) pelos campos `filmes.id_filme` e `filmes.titulo`, e ordenando do maior para o menor faturamento.
10. Apresente os **10 piores filmes em faturamento** (menor valor total arrecadado), exibindo `filmes.titulo`, `categorias.nome` e o faturamento total (usando `SUM` no campo `pagamentos.valor`), relacionando `filmes`, `filmes_categorias`, `categorias`, `inventarios`, `alugueis` e `pagamentos`, agrupando (`GROUP BY`) pelos campos `filmes.id_filme`, `filmes.titulo` e `categorias.nome`, e ordenando do menor para o maior faturamento.

---

## Atividade 4 — Exclusão Segura de Registros (`DELETE`)

**Orientações:** Antes de executar cada exclusão, faça um `SELECT` com o mesmo filtro `WHERE` para conferir o registro que será removido e, após o `DELETE`, execute a consulta novamente para confirmar que ele não existe mais. Todos os 4 registros abaixo não possuem dependências bloqueadoras (`ON DELETE RESTRICT`) no banco `sakila_pt`.

1. **Tabela `idiomas`:** Exclua o idioma `'Alemão'` (`id_idioma = 6`), que não está vinculado a nenhum filme na tabela `filmes`.
2. **Tabela `pagamentos`:** Exclua o pagamento de `id_pagamento = 424` (registro de valor `1.99` que não está vinculado a nenhum aluguel — `aluguel_id` nulo).
3. **Tabela `filmes_atores`:** Exclua o vínculo entre a atriz `'Penelope Guiness'` (`ator_id = 1`) e o filme `'DESAFIO NAS MONTANHAS ROCHOSAS'` (`filme_id = 1`), filtrando pelos dois campos da chave primária composta.
4. **Tabela `inventarios`:** Exclua o exemplar de `id_inventario = 5` (cópia do filme `id_filme = 1` na `loja_id = 2`), que nunca foi alugado na tabela `alugueis`.




