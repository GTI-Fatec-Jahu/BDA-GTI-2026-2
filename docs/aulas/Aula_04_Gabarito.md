<!--
GABARITO — não faz parte do fluxo principal da aula e fica fora do `nav` do
mkdocs.yml de propósito. É acessível só pelos links dentro de Aula_04_Normalizacao.md.
-->

# Gabarito — Aula 04 — Normalização de Dados

**Disciplina:** Banco de Dados e Aplicações <br>
**Professor:** Ronan Adriel Zenatti · ronan.zenatti@cps.sp.gov.br  <br>
**Fatec Jahu — 2º Semestre/2026**

---

!!! warning "Antes de conferir"
    Assim como nos gabaritos anteriores: este documento mostra **uma** solução correta possível para cada Checkpoint e Exercício. O que importa é o raciocínio — identificar a dependência funcional errada antes de propor a correção. Se sua divisão de tabelas divergir um pouco desta, refaça o teste "de quem esse atributo depende de verdade?" antes de assumir que está errado.

---

## Checkpoint 1 — 1FN: revenda de gás de bairro {: #checkpoint-1 }

**(a) Violações encontradas:**

- `telefones` guarda múltiplos valores numa única célula (`"99111-2233, 99222-3344"`) — viola a exigência de valores atômicos.
- `itens` guarda múltiplos valores numa única célula (`"P13, P45"`) — mesmo problema, e ainda impede saber a quantidade de cada peça pedida.

**(b) Tabelas corrigidas:**

Tabela `pedidos_revenda`:

| id_pedido | nome_cliente |
|---|---|
| ... | ... |

Tabela `telefones_clientes`:

| id_telefone | pedido_revenda_id FK | numero |
|---|---|---|

Tabela `itens_pedido_revenda`:

| pedido_revenda_id FK | produto_id FK | quantidade |
|---|---|---|

`pedido_revenda_id` e `produto_id` seguem a Regra 6 (tabela referenciada no singular + `_id`); `id_telefone` segue a Regra 5. Repare que separar `itens` também exige uma tabela `produtos` com o catálogo de botijões, para que `produto_id` tenha o que referenciar.

---

## Checkpoint 2 — 2FN: oficina de bicicletas {: #checkpoint-2 }

**(a) Colunas "pegando carona":** `nome_peca`, `preco_peca` e `fornecedor_peca` dependem apenas de `peca_id` — não importa em qual ordem de serviço a peça aparece, essas informações não mudam. Elas não dependem da PK composta inteira `(ordem_id, peca_id)`, só da parte `peca_id`.

**(b) Tabelas corrigidas:**

Tabela `itens_ordem` (só o que pertence ao par ordem+peça):

| **ordem_id** | **peca_id** | quantidade |
|---|---|---|

Tabela `pecas` (dados que pertencem só à peça):

| **id_peca** | nome_peca | preco_peca | fornecedor_peca |
|---|---|---|---|

---

## Checkpoint 3 — 3FN: rede de postos de gasolina {: #checkpoint-3 }

**(a) Cadeia de dependência transitiva:** `id_funcionario → posto_id → nome_posto, cidade_posto, gerente_posto`. Os dados do posto (nome, cidade, gerente) dependem de `posto_id`, não diretamente de `id_funcionario` — é uma dependência transitiva clássica, no mesmo formato do exemplo `funcionario → departamento` da Seção 5.

**(b) Tabelas corrigidas:**

Tabela `funcionarios`:

| **id_funcionario** | nome | posto_id |
|---|---|---|

Tabela `postos`:

| **id_posto** | nome_posto | cidade_posto | gerente_posto |
|---|---|---|---|

---

## Exercício 1 — Locadora de Filmes

**a) Violações da 1FN:**

- `filme1/genero1/duracao1/diaria1` e `filme2/genero2/duracao2/diaria2` são grupos de colunas repetitivas para a mesma informação (dados do filme locado) — o mesmo problema visto em `produto1/produto2` (Seção 3, Exemplo 2). Se uma locação tiver 3 filmes, não há onde colocá-los sem alterar a tabela.
- Cada linha mistura, numa célula só, informações de assuntos diferentes: cliente, filme e funcionário — não é atomicidade de valor, mas o mesmo espírito de "informação misturada" do Exemplo 3 (endereço completo).

**b) Aplicando a 1FN:**

Tabela `clientes`:

| id_cliente | nome | cpf | cidade |
|---|---|---|---|
| 1 | Lucas Maia | 111.222.333-44 | Jahu |
| 2 | Mariana Paz | 555.666.777-88 | Bauru |

Tabela `funcionarios`:

| id_funcionario | nome | salario |
|---|---|---|
| F01 | Bruna | R$ 2.200 |
| F02 | Carlos | R$ 2.500 |

Tabela `filmes`:

| id_filme | titulo | genero | duracao |
|---|---|---|---|
| 1 | Inception | Ficção | 148min |
| 2 | Interstellar | Ficção | 169min |
| 3 | Shrek | Animação | 90min |
| 4 | O Poderoso Chefão | Drama | 175min |

Tabela `locacoes`:

| id_locacao | data_locacao | cliente_id FK | funcionario_id FK |
|---|---|---|---|
| 1 | 2026-03-10 | 1 | F01 |
| 2 | 2026-03-11 | 2 | F01 |
| 3 | 2026-03-11 | 1 | F02 |

Tabela `itens_locacao` (PK composta `locacao_id, filme_id`, guardando a diária cobrada naquele filme daquela locação):

| locacao_id FK | filme_id FK | diaria |
|---|---|---|
| 1 | 1 | R$ 6,00 |
| 1 | 2 | R$ 6,00 |
| 2 | 3 | R$ 4,00 |
| 3 | 4 | R$ 8,00 |
| 3 | 3 | R$ 4,00 |

**c) Aplicando a 2FN:** a PK composta de `itens_locacao` é `(locacao_id, filme_id)`. A `diaria` depende dos dois (o valor cobrado pode variar por locação/promoção), então não há dependência parcial ali. Se a tabela tivesse trazido `titulo`/`genero` junto (como na tabela original), esses dados dependeriam só de `filme_id` — violação já resolvida ao criar a tabela `filmes` separada no passo (b).

**d) Aplicando a 3FN:** em `clientes`, a coluna `cidade` foi mantida direto (não foi criada uma tabela `ceps` separada) porque o enunciado não fornece CEP — não há dependência transitiva detectável com os dados disponíveis. As demais tabelas (`funcionarios`, `filmes`, `locacoes`, `itens_locacao`) não têm atributo não-chave dependendo de outro atributo não-chave.

**e) Reflexão:** a `diaria` em `itens_locacao` é um bom candidato a **redundância intencional** (Seção 7.3) — mesmo que no futuro o preço padrão de locação mude, o valor efetivamente cobrado naquela locação específica deve ficar congelado ali, como um snapshot histórico.

---

## 🔗 Voltar

⬅️ [Aula 04 — Normalização de Dados](Aula_04_Normalizacao.md)

---

*Fatec Jahu · IBD951 · Prof. Ronan Adriel Zenatti · 2026*
