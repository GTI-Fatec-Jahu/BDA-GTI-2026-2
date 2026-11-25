# Avaliação P2 — Inserções, Consultas e Exclusões no `sakila_pt` (Tópicos 06 a 08 e 10)

**Instituição:** Fatec Jahu — Centro Paula Souza
**Curso:** Tecnologia em Gestão da Tecnologia da Informação
**Disciplina:** Banco de Dados e Aplicações — IBD951
**Professor:** Ronan Adriel Zenatti · ronan.zenatti@cps.sp.gov.br
**Semestre:** 2º Semestre / 2026
**Valor:** 4,0 pontos
**Modalidade:** em dupla, em um único computador do laboratório, durante o horário da disciplina

---

## 📋 Regras da avaliação

- **Em dupla, em um único computador.** A dupla trabalha junta na mesma máquina e recebe
  a mesma nota.
- **Somente nos computadores do laboratório** onde a prova acontece — não vale
  resolver em notebook pessoal ou em casa.
- **Consulta permitida:**
    - a **folha de anotações escrita à mão** que cada aluno foi autorizado a trazer;
    - o **portal da disciplina**, **somente nas páginas de conteúdo dos tópicos**.
- **Consulta proibida:** exercícios, checkpoints, gabaritos, práticas, simulados,
  avaliações e qualquer outra atividade publicada no portal, além de anotações digitais
  ou qualquer outro material no computador.
- **Banco de dados:** todas as atividades usam o banco `sakila_pt`. Selecione-o antes de
  começar (o modelo do arquivo já traz o comando `USE sakila_pt;`).
- **Conteúdo cobrado:** Tópicos 06 a 08 (`INSERT`, `DELETE`, `SELECT` com `WHERE`,
  `ORDER BY` e `LIMIT`) e Tópico 10 (apenas `INNER JOIN`).
- **Todas as duplas fazem as três atividades.**

---

## 🧮 Composição da nota

| Atividade | O que a dupla faz | Valor |
|---|---|---|
| **Atividade 1** — Cadastro encadeado | 1 consulta + 2 inserções, em 3 passos | 1,5 pt |
| **Atividade 2** — Consultas com `SELECT` | **1** consulta da Parte 1 (sem `INNER JOIN`) + **1** consulta da Parte 2 (com `INNER JOIN`), à escolha da dupla (0,75 pt cada) | 1,5 pt |
| **Atividade 3** — Exclusão segura | **2** exclusões (0,5 pt cada): a **3.1** (obrigatória) + **1** das outras 2 à escolha | 1,0 pt |
| | **Total** | **4,0 pts** |

---

## 📦 O que entregar

Um único arquivo **`.sql`**, com **todos os comandos** da avaliação, preenchido nas
seções já delimitadas.

📥 Baixe o modelo e preencha-o:
[Avaliacao_P2_Sakila.sql](Avaliacao_P2_Sakila.sql){: download }

No início do arquivo, preencha em comentário o **nome dos dois integrantes** e o
**número do computador**. Na Atividade 2, marque no próprio arquivo quais itens a dupla
escolheu. Na Atividade 3, marque qual exclusão (3.2 ou 3.3) a dupla escolheu.

**Entrega:** **os dois integrantes** devem enviar o mesmo arquivo `.sql` na **atividade
específica desta avaliação no Google Classroom da turma**. Como a dupla usa um único
computador, cada aluno entra no **seu próprio** Classroom em um navegador diferente
(por exemplo, um no Edge e outro no Chrome) — assim as duas contas ficam logadas ao mesmo
tempo, sem precisar sair de uma para entrar na outra.

### Orientações gerais

- **A execução pode ser parcial.** Deixe **comentado** (com `--` no início da linha)
  qualquer trecho incompleto ou com erro, para que ele não impeça a execução do restante
  do arquivo.
- **Comandos de apoio, como `DESCRIBE`, não precisam estar no arquivo** e **não valem
  nota** — use-os à vontade para ver as colunas de uma tabela antes de inserir.

---

## Atividade 1 — Cadastro encadeado: cidade e endereço · 1,5 pt

**Cadeia de tabelas:** `paises` → `cidades` → `enderecos`

Uma **chave estrangeira (FK)** é a coluna que guarda o número de um registro de *outra*
tabela — como o número da comanda anotado em cada item consumido, que leva de volta à
comanda da mesa. Aqui, a cidade aponta para o país e o endereço aponta para a cidade; por
isso o país vem primeiro, depois a cidade, depois o endereço.

O banco gera sozinho o número (`id`) de cada registro novo. A função `LAST_INSERT_ID()`
devolve **o último número gerado na sua conexão** — como a senha que a máquina do
cartório acabou de imprimir para você.

1. **Escolher 1 id.** Consulte a tabela `paises` e localize o registro do país `'Peru'`
   para obter o seu `id_pais`.
2. **Inserir a cidade.** Cadastre na tabela `cidades` a cidade `'Cusco'`, vinculada ao
   `id_pais` encontrado no passo 1.
3. **Inserir o endereço.** Cadastre na tabela `enderecos` um novo endereço vinculado à
   cidade que acabou de ser criada, **usando o último id gerado** (`LAST_INSERT_ID()`).
   Informe `logradouro`, `bairro`, `codigo_postal` e `telefone` com dados à escolha da
   dupla (o `complemento` é opcional).

!!! tip "Conferir (opcional, não vale nota)"
    Depois dos passos 2 e 3, um `SELECT` filtrando pela chave primária do registro
    novo mostra se ele foi gravado. Execute os passos 2 e 3 **em sequência**: se outro
    `INSERT` acontecer entre eles, o "último id gerado" deixa de ser o da cidade.


---

## Atividade 2 — Consultas com `SELECT` · 1,5 pt

**A dupla escolhe livremente 1 item da Parte 1 e 1 item da Parte 2** — 2 consultas no
total, 0,75 pt cada. Itens além dos 2 escolhidos não valem nota extra.

**Regras desta atividade:**

- Utilize apenas as cláusulas: `SELECT`, `FROM`, `WHERE`, `INNER JOIN`, `ORDER BY` e
  `LIMIT`.
- **Sem funções e sem `GROUP BY`.**
- Os itens **1 e 2** devem ser resolvidos **sem `INNER JOIN`** (apenas uma tabela).
- Os itens **3 e 4** devem ser resolvidos **com `INNER JOIN`**: o item 3 liga **2 tabelas**
  (1 `INNER JOIN`) e o item 4 liga **3 tabelas** (2 `INNER JOIN`).
- Mostre **somente as colunas pedidas**, na ordem em que aparecem no enunciado.

!!! info "Lembrete: o que o `INNER JOIN` faz"
    O `INNER JOIN` junta duas tabelas pelas colunas que combinam (a FK de uma com a PK da
    outra) e devolve só as linhas que têm par. É como cruzar a nota fiscal com a ficha do
    cliente usando o número do cliente anotado nas duas: só entra na lista quem aparece
    nos dois papéis.

### Parte 1 — Consultas em tabela única (sem `INNER JOIN`) — escolha 1

1. **Tabela `filmes`.** Liste o `titulo`, a `duracao` e a `taxa_aluguel` dos filmes com
   classificação `'NC-17'` **e** duração de, no máximo, `60` minutos, ordenados pelo
   `titulo` em ordem alfabética.
2. **Tabela `clientes`.** Liste o `primeiro_nome`, o `ultimo_nome` e o `email` dos
   clientes **inativos** (`ativo = 0`), ordenados pelo `ultimo_nome` em ordem alfabética,
   mostrando apenas os **5 primeiros** (`LIMIT 5`).

### Parte 2 — Consultas relacionais (com `INNER JOIN`) — escolha 1

3. **Tabelas `cidades` e `paises`** (1 `INNER JOIN`). Liste o nome da cidade
   (`cidades.cidade`) e o nome do país (`paises.pais`) de todas as cidades do país
   `'Peru'`, ordenadas pelo nome da cidade.

    !!! tip "Dica"
        Se a Atividade 1 foi concluída, a cidade `'Cusco'` aparece na lista.

4. **Tabelas `clientes`, `enderecos` e `cidades`** (2 `INNER JOIN`). Liste o
   `clientes.primeiro_nome`, o `clientes.ultimo_nome`, o `enderecos.logradouro` e o
   `cidades.cidade` dos clientes que moram na cidade `'Aurora'`, ordenados pelo
   `clientes.primeiro_nome`.

    !!! tip "Dica"
        O cliente aponta para o endereço (`clientes.endereco_id`) e o endereço aponta
        para a cidade (`enderecos.cidade_id`): são duas ligações em sequência, como ir
        da ficha do cliente ao endereço e do endereço à cidade.

---

## Atividade 3 — Exclusão Segura de Registros (`DELETE`) · 1,0 pt

A dupla faz **2 exclusões** — 0,5 pt cada: a **3.1 (obrigatória)** e **1 entre a 3.2 e
a 3.3**, à escolha da dupla.

O `DELETE` sem `WHERE` apaga a tabela inteira, como esvaziar a prateleira toda quando se
queria tirar um único produto vencido. Por isso, cada exclusão tem **3 etapas**:

1. **Conferir** o registro com um `SELECT` filtrando pela chave primária (PK) informada.
2. **Excluir** com `DELETE`, filtrando **pela chave primária** (e não pelo nome ou por
   outra característica).
3. **Confirmar** a exclusão com o mesmo `SELECT` da etapa 1, que agora não deve retornar
   nada.

Os **ids são informados** no enunciado. Todos os registros abaixo não possuem
dependências bloqueadoras (`ON DELETE RESTRICT`) no banco `sakila_pt`.

| Exclusão | Tabela | Registro a excluir (chave primária) |
|---|---|---|
| **3.1** — obrigatória | `idiomas` | `id_idioma = 2` (idioma `'Italiano'`, que não está vinculado a nenhum filme) |
| **3.2** — escolha | `pagamentos` | `id_pagamento = 14675` (pagamento de valor `3.99` sem aluguel vinculado) |
| **3.3** — escolha | `cidades` | `id_cidade = 313` (cidade `'Londres'`, do Canadá, sem nenhum endereço cadastrado) |

---

!!! warning "Antes de entregar"
    Execute o arquivo inteiro do começo ao fim no `sakila_pt` e confira se não há erro
    interrompendo a execução. Trechos incompletos devem ficar **comentados**.

---

🔑 O gabarito será disponibilizado pelo professor **depois da avaliação**.

---

⬅️ [Voltar para Atividades e Avaliações](index.md)

---

*Fatec Jahu · IBD951 · Prof. Ronan Adriel Zenatti · 2026*
