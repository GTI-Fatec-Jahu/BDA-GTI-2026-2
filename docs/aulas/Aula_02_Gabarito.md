# Gabarito — Exercícios de Fixação da Aula 02

**Disciplina:** Banco de Dados e Aplicações <br>
**Professor:** Ronan Adriel Zenatti · ronan.zenatti@cps.sp.gov.br  <br>
**Fatec Jahu — 2º Semestre/2026**

---

!!! warning "Antes de conferir"
    Este gabarito mostra **uma** solução correta possível para cada exercício — em modelagem conceitual, mais de uma resposta pode estar certa dependendo das suposições feitas sobre o negócio. O que importa é o raciocínio: se sua resposta divergir, releia as [quatro perguntas-chave da seção 7](Aula_02_Modelagem_Entidades.md#7-passo-a-passo-do-cupom-fiscal-as-entidades) e confira se ela também se sustenta.

---

## Exercício 1 — Clínica Veterinária

**Raciocínio:** `TUTOR` e `ANIMAL` têm existência independente e atributos próprios ricos — são entidades fortes, com `ANIMAL` associado a um `TUTOR`. `VACINA` só faz sentido se houver um animal vacinado, e um animal pode ter várias vacinas ao longo do tempo — é entidade fraca. `telefone` do tutor é multivalorado (várias pessoas têm mais de um número).

```mermaid
erDiagram
    TUTOR {
        int id_tutor PK
        string nome
        string cpf
        string logradouro
        string numero
        string cidade
        string cep
    }
    ANIMAL {
        int id_animal PK
        string nome
        string especie
        string raca
        date data_nascimento
        int tutor_id FK
    }
    VACINA {
        int id_vacina PK
        string nome_vacina
        date data_aplicacao
        date validade
        int animal_id FK
    }
    TELEFONE_TUTOR {
        int id_telefone PK
        string numero
        int tutor_id FK
    }

    TUTOR ||--o{ ANIMAL : "possui"
    ANIMAL ||--o{ VACINA : "recebe"
    TUTOR ||--o{ TELEFONE_TUTOR : "tem"
```

**Classificação dos atributos:** `endereco` do tutor é composto; `telefone` é multivalorado (por isso virou tabela própria, mesmo raciocínio do atributo multivalorado da seção 6.4); `cpf`, `nome`, `data_nascimento` são simples; `id_tutor`/`id_animal`/`id_vacina` são identificadores.

---

## Exercício 2 — Locadora de Equipamentos

**Raciocínio:** `CLIENTE` e `EQUIPAMENTO` são entidades fortes e independentes — um equipamento existe no catálogo mesmo sem estar locado no momento. `LOCACAO` representa o "guarda-chuva" de uma retirada (data, cliente). Como uma locação pode incluir vários equipamentos, e um equipamento pode aparecer em várias locações ao longo do tempo, a relação entre eles precisa de uma **entidade associativa** — `ITEM_LOCACAO` — para guardar o que é específico daquele encontro (nada impede o mesmo equipamento de ter, por exemplo, uma condição de conservação registrada diferente a cada retirada).

```mermaid
erDiagram
    CLIENTE {
        int id_cliente PK
        string nome
    }
    EQUIPAMENTO {
        int id_equipamento PK
        string codigo
        string descricao
        decimal valor_diaria
        string estado_conservacao
    }
    LOCACAO {
        int id_locacao PK
        date data_retirada
        date data_devolucao_prevista
        decimal valor_total
        int cliente_id FK
    }
    ITEM_LOCACAO {
        int locacao_id FK
        int equipamento_id FK
    }

    CLIENTE ||--o{ LOCACAO : "realiza"
    LOCACAO ||--o{ ITEM_LOCACAO : "contém"
    EQUIPAMENTO ||--o{ ITEM_LOCACAO : "aparece em"
```

**Ponto de atenção:** é o mesmo padrão do `ITEM_CUPOM` da seção 7 — sempre que uma relação N-para-N carrega uma lista de itens de um lado ("uma locação tem vários equipamentos, um equipamento aparece em várias locações"), o sinal é de entidade associativa.

---

## Exercício 3 — Entidade fraca

**Raciocínio:** `UNIDADE` (apartamento) existe de forma independente — tem número, andar e metragem próprios, e continua existindo mesmo sem moradores cadastrados (um apartamento vazio ainda é uma unidade do condomínio). `MORADOR`, por outro lado, é explicitamente descrito como "não faz sentido cadastrar um morador sem vincular a uma unidade" — é a própria definição de entidade fraca do início da aula (seção 2).

```mermaid
erDiagram
    UNIDADE {
        int id_unidade PK
        int numero
        int andar
        decimal metragem
    }
    MORADOR {
        int id_morador PK
        string nome
        int unidade_id FK
    }

    UNIDADE ||--o{ MORADOR : "abriga"
```

**`UNIDADE` = entidade forte. `MORADOR` = entidade fraca**, exatamente pelo mesmo motivo que `DEPENDENTE` era fraco em relação a `FUNCIONARIO` no exemplo da seção 2.

---

## Exercício 4 — Generalização e Especialização

**Raciocínio:** `nome`, `cpf` e `data_contratacao` são comuns a todo professor — ficam na superclasse `PROFESSOR`. `salario_fixo` só existe para quem é CLT; `valor_hora_aula` só existe para quem é Freelancer — são atributos exclusivos de cada subclasse. O enunciado diz "um professor é sempre um dos dois tipos, nunca os dois ao mesmo tempo": isso é **especialização total** (todo professor pertence a uma subclasse) **e disjunta** (nunca as duas ao mesmo tempo) — o mesmo padrão do exemplo `CONTA_FISICA`/`CONTA_JURIDICA` da seção 4.4.

```mermaid
flowchart TB
    PROFESSOR["👨‍🏫 PROFESSOR
    nome
    cpf
    data_contratacao"]

    CLT["📋 PROFESSOR_CLT
    salario_fixo"]

    FREELANCER["🧾 PROFESSOR_FREELANCER
    valor_hora_aula"]

    PROFESSOR -->|"d — total"| CLT
    PROFESSOR --> FREELANCER
```

---

## Exercício 5 — Encontre o erro

**Erro cometido:** 6.1 — Confundir atributo com entidade. `NUMERO_MESA` não tem vida própria: ele só descreve `MESA` (um número de mesa não existe nem faz sentido fora do contexto de uma mesa específica), e a relação 1-para-1 entre `MESA` e `NUMERO_MESA` é o sintoma clássico apontado na seção 6.1 ("entidade sem atributos próprios relevantes, sempre 1-para-1 com outra").

**Correção:** `numero` deve ser um atributo simples de `MESA`, não uma entidade separada.

```mermaid
erDiagram
    PEDIDO {
        int id_pedido PK
    }
    MESA {
        int id_mesa PK
        int numero
    }
    PEDIDO ||--|| MESA : "ocupa"
```

---

## 🔗 Voltar

⬅️ [Aula 02 — Modelagem Conceitual: Entidades e Atributos](Aula_02_Modelagem_Entidades.md)

---

*Fatec Jahu · IBD951 · Prof. Ronan Adriel Zenatti · 2026*
