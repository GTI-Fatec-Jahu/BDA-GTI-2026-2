# Avaliação — DBML: Biblioteca ou Clínica Veterinária (Aulas 01 a 03)

**Instituição:** Fatec Jahu — Centro Paula Souza
**Curso:** Tecnologia em Gestão da Tecnologia da Informação
**Disciplina:** Banco de Dados e Aplicações — IBD951
**Professor:** Ronan Adriel Zenatti · ronan.zenatti@cps.sp.gov.br
**Semestre:** 2º Semestre / 2026
**Valor:** 4,0 pontos
**Modalidade:** em dupla, em um único computador do laboratório, durante a aula

---

## 📋 Regras da avaliação

- **Em dupla, em um único computador.** A dupla trabalha junta na mesma máquina e recebe
  a mesma nota.
- **Somente nos computadores do laboratório** onde a aula acontece — não vale
  resolver em notebook pessoal ou em casa.
- **Consulta:** somente a **folha de rascunho escrita à mão** que cada aluno foi
  autorizado a trazer. Não é permitido abrir aulas, práticas, gabaritos, anotações
  digitais ou qualquer outro material no computador.
- **Qual cenário a dupla faz depende do número do computador** (o número da etiqueta na
  máquina em que a dupla está trabalhando):

    | Número do computador | Cenário que a dupla resolve |
    |---|---|
    | **Ímpar** (1, 3, 5, 7...) | 📚 **Biblioteca Comunitária** |
    | **Par** (2, 4, 6, 8...) | 🐾 **Clínica Veterinária** |

  É como a fila do posto de saúde que chama por senha par e ímpar: o número decide
  o guichê, e não adianta tentar trocar.
- **Conteúdo cobrado:** Aulas 01, 02 e 03 (introdução a bancos de dados, modelagem de
  entidades e relacionamentos/cardinalidade).

---

## 📦 O que entregar

Um único arquivo de texto, com extensão **`.txt`**, contendo duas partes, nesta ordem:

1. **As respostas das 3 perguntas** da seção abaixo, cada uma escrita como **comentário**
   no próprio arquivo (linha iniciada com `//`, que é a sintaxe de comentário do DBML).
2. **O diagrama completo em DBML** do cenário da sua dupla.

No início do arquivo, escreva em comentário o **nome dos dois integrantes** e o **cenário**
resolvido (Biblioteca ou Veterinária).

Monte o diagrama no [dbdiagram.io](https://dbdiagram.io) (o editor mostra o texto DBML
enquanto você desenha) e depois copie esse texto para dentro do `.txt`. Não precisa
exportar imagem nem PDF.

**Entrega:** **os dois integrantes** devem enviar o mesmo arquivo `.txt` na **atividade
específica desta avaliação no Google Classroom da turma**. Como a dupla usa um único
computador, cada aluno entra no **seu próprio** Classroom em um navegador diferente
(por exemplo, um no Edge e outro no Chrome) — assim as duas contas ficam logadas ao mesmo
tempo, sem precisar sair de uma para entrar na outra.

Aplique **todas as convenções de nomenclatura, tipos e padrões estruturais** vistos em
aula (nome de tabelas, chaves primárias e estrangeiras, campos de controle, relacionamentos
1:N e N:M). **Cada tabela deve ter a sua própria chave primária (PK)**, sem chaves
compostas e sem restrições de unicidade que envolvam mais de uma coluna.

---

## ❓ Perguntas — respondidas como comentário no arquivo

Escreva a resposta de cada pergunta em um bloco de comentário `//`, **antes** do
diagrama. As respostas devem se referir ao **diagrama que a sua dupla montou**, não a
exemplos de outros cenários.

1. **Chave estrangeira no relacionamento 1:N.** No relacionamento 1:N do seu
   diagrama, em qual das duas tabelas vocês colocaram a **chave estrangeira (FK)** e
   por que essa foi a escolha? O que mudaria — ou quebraria — se a FK ficasse na outra
   tabela, do lado oposto? (Lembrete: a FK é a coluna que "aponta" para a chave primária
   de outra tabela, como o número da comanda anotado em cada item consumido, que leva de
   volta à comanda da mesa.)

2. **Escolha do tipo dos campos.** Três campos do seu diagrama permitem mais de um tipo
   de dado:
    - **`quantidade`** — poderia ser `INT` ou `DECIMAL`;
    - **`cpf`** — poderia ser `VARCHAR`, `CHAR` ou `INT`;
    - **`cep`** — poderia ser `CHAR` ou `INT`.

    Para **cada um dos três**, digam qual tipo vocês escolheram e **como decidiram** que
    ele é o mais adequado para o banco: que perguntas vocês se fizeram sobre o dado
    para chegar a essa escolha? O que poderia dar errado com cada um dos outros tipos?
    (Lembrete: o tipo define o que a coluna aceita guardar — como a caixa de ovos que só
    comporta ovos. Um bom caminho de raciocínio: um número de telefone parece número,
    mas ninguém faz conta com telefone — então será que o tipo numérico é o mais
    adequado?)

3. **Especialização na modelagem.** Como a **especialização** poderia ser incluída na
   modelagem do cenário da sua dupla? Indiquem qual tabela do seu diagrama seria a
   **tabela geral**, quais seriam as **tabelas especializadas**, qual **campo exclusivo**
   cada tabela especializada teria e **como as chaves (PK e FK) ligariam as tabelas
   especializadas à tabela geral**. Não é necessário incluir a especialização no
   diagrama — a pergunta é sobre como ela entraria na modelagem. (Lembrete: é como a
   padaria que vende "produtos": todo pão de queijo e todo bolo são produtos, mas o bolo
   tem o campo "sabor da cobertura" que o pão de queijo não tem.)

---

## 📚 Cenário A — Biblioteca Comunitária (computador **ímpar**)

O **LeiaBairro** é o sistema de uma pequena biblioteca comunitária, dessas mantidas pela
associação do bairro ou por uma escola da cidade. Hoje o controle é feito num caderno
e na memória da bibliotecária — e já aconteceu de dois leitores saírem com o mesmo
livro e de ninguém lembrar quem está com o quê.

Requisitos de negócio:

- Os livros são organizados por **categoria** (ex.: "Romance", "Didático", "Infantil").
  Cada categoria tem nome (que não pode se repetir) e uma descrição opcional.
- Cada **livro** pertence a **uma única** categoria, e uma categoria pode ter muitos
  livros. O livro tem título, autor, **ISBN** (o código de 13 dígitos impresso no verso,
  que identifica a edição e não se repete entre livros), ano de publicação, o estado de
  conservação (texto curto, como "ótimo", "bom" ou "desgastado") e a **quantidade** de
  exemplares que a biblioteca possui daquele livro.
- Cada **leitor** tem nome, **CPF** (que não pode se repetir), e-mail, telefone, **CEP**
  do endereço e data de nascimento.
- Um leitor pode pegar emprestados vários livros ao longo do tempo, e um mesmo livro
  pode ser emprestado a vários leitores (em momentos diferentes). Cada **empréstimo** é
  um registro próprio — **o mesmo leitor pode pegar o mesmo livro mais de uma vez**, em
  datas diferentes. O empréstimo guarda a data em que saiu, a data prevista de devolução
  e a data em que o livro de fato voltou (que fica vazia enquanto o livro não for
  devolvido).

---

## 🐾 Cenário B — Clínica Veterinária (computador **par**)

A **Clínica Amigo Fiel** é uma clínica veterinária de bairro que quer deixar a ficha de
papel de lado. Hoje, para saber quando o Thor tomou a última vacina ou quanto foi cobrado
no banho do mês passado, a recepcionista precisa revirar o fichário.

Requisitos de negócio:

- Cada **tutor** (o dono do bicho) tem nome, **CPF** (que não pode se repetir),
  telefone, e-mail e **CEP** do endereço.
- Um tutor pode ter vários **pets**, mas cada pet pertence a **um único** tutor. O pet
  tem nome, espécie (texto curto, como "cão" ou "gato"), raça (opcional, pois nem todo
  pet tem raça definida) e data de nascimento (opcional).
- A clínica mantém um **catálogo de procedimentos** (ex.: "Vacina antirrábica", "Banho e
  tosa", "Consulta clínica"), cada um com nome (que não pode se repetir), descrição
  opcional e o **valor de tabela** em reais.
- Um pet pode receber vários procedimentos ao longo da vida, e um mesmo procedimento pode
  ser feito em vários pets. Cada **atendimento** é um registro próprio — **o mesmo pet
  pode receber o mesmo procedimento mais de uma vez**, em datas diferentes (a vacina é
  anual, por exemplo). O atendimento guarda a data e hora em que aconteceu, a
  **quantidade** aplicada do procedimento (por exemplo, número de doses ou de sessões),
  o **valor realmente cobrado** (que pode ser diferente do valor de tabela, por causa de
  desconto) e observações opcionais.

---

## 🎯 Como será a correção (4,0 pontos)

| Item | Pontos |
|---|---|
| Pergunta 1 — FK no 1:N | 0,5 |
| Pergunta 2 — escolha dos tipos (`quantidade`, `cpf`, `cep`) | 0,5 |
| Pergunta 3 — especialização na modelagem | 0,5 |
| Diagrama DBML (4 tabelas, 1:N, N:M com tabela intermediária, nomenclatura, tipos, restrições) | 2,5 |

O diagrama deve ter **exatamente 4 tabelas**: as 3 do cenário e a tabela intermediária
que resolve o relacionamento N:M.

---

🔑 O gabarito será disponibilizado pelo professor **depois da avaliação**.

---

⬅️ [Voltar para Atividades e Avaliações](index.md)

---

*Fatec Jahu · IBD951 · Prof. Ronan Adriel Zenatti · 2026*
