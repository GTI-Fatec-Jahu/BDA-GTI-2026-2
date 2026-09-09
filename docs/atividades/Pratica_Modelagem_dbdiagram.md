# Prática — Modelagem com dbdiagram.io (Aulas 01 a 03)

**Instituição:** Fatec Jahu — Centro Paula Souza
**Curso:** Tecnologia em Gestão da Tecnologia da Informação
**Disciplina:** Banco de Dados e Aplicações — IBD951
**Professor:** Ronan Adriel Zenatti · ronan.zenatti@cps.sp.gov.br
**Semestre:** 2º Semestre / 2026
**Valor:** não vale nota

!!! info "🧪 Atividade de treino — não vale nota"
    Esta atividade **não tem peso na média**. Ela existe para você praticar, errar à
    vontade e tirar dúvidas em aula antes das avaliações que valem nota (P1, P2...).
    Traga sua tentativa — mesmo incompleta — para a aula: é matéria-prima para
    discussão, não algo para entregar "pronto".

---

## 🧠 Pré-Problema — Modelando "de olho" na Pokédex

Antes dos 6 exercícios, um aquecimento para sentir na pele por que modelagem de dados
não é opcional.

!!! danger "🔍 Desafio de sensibilização"
    Abra a [Pokédex oficial](https://www.pokemon.com/br/pokedex) em outra aba. **Sem
    combinar mais nada com ninguém**, tente esboçar — no papel ou de cabeça — as
    tabelas de um banco de dados que armazenasse essas informações, só olhando a tela
    pronta. Depois volte aqui e compare com os pontos abaixo.

A Pokédex oficial mostra, para cada Pokémon: nome, número (de 1 a 1025), um ou dois
**tipos** (Fogo, Água, Elétrico...), **fraquezas**, altura, peso, categoria, uma
descrição narrativa, **estatísticas base** (HP, Ataque, Defesa, Ataque Especial, Defesa
Especial, Velocidade), **habilidades** com descrição própria, uma **cadeia evolutiva**
(ex.: Pichu → Pikachu → Raichu) e, em alguns casos, **formas alternativas** (como o
Gigantamax de Pikachu) com estatísticas próprias. A busca ainda permite filtrar por
faixas — altura "curta/média/alta", peso "leve/médio/pesado" — em vez do valor exato.

Repare no que a tela **não deixa claro**, mesmo depois de toda essa riqueza visual:

- Um Pokémon pode ter até **dois tipos ao mesmo tempo** — isso é um atributo
  multivalorado, ou uma tabela associativa `N:M` entre `POKEMONS` e `TIPOS`? A tela não
  responde; você teria que decidir sozinho, sem saber se a decisão está certa. É como
  decidir se o "sabor" de uma pizza fica escrito numa listinha dentro da própria ficha
  do pedido, ou se vira uma tabela separada de `SABORES` que qualquer pizza da casa
  pode usar — a fachada da pizzaria não te conta qual das duas o sistema deles usa por
  trás.
- A cadeia evolutiva (Pichu → Pikachu → Raichu) é um **auto-relacionamento** — a mesma
  ideia de `FUNCIONARIO` supervisionando `FUNCIONARIO` que vimos na Aula 03, só que
  aqui é um Pokémon "vindo de" outro Pokémon, como uma árvore genealógica de família
  escrita numa caderneta, em que cada nome aponta pro nome de quem veio antes, mas
  todos moram na mesma tabela `pessoas`. Mas a FK se chamaria `evolui_de_id`? E se um
  Pokémon puder evoluir para **mais de uma** forma (como Eevee, que evolui para
  vários), isso muda a cardinalidade — e nada na tela avisa que esse caso especial
  existe até você esbarrar nele.
- O Gigantamax tem estatísticas **próprias**, mas "é" o mesmo Pokémon — isso é
  generalização/especialização (Aula 02, Seção 4), ou só uma variação de um mesmo
  registro? É como perguntar se uma Kombi virada food truck ainda é "o mesmo veículo"
  com equipamento extra, ou se virou outro cadastro — o Detran trata como o mesmo
  veículo com uma ficha adicional, que é exatamente a lógica de
  generalização/especialização. De novo: a UI não documenta a regra de negócio, só
  mostra o resultado final já decidido por outra equipe, em outro contexto, para outro
  propósito.
- **Habilidades** têm descrição própria e se repetem entre Pokémon diferentes (ex.:
  "Eletricidade Estática" aparece em vários) — se você simplesmente copiar o texto da
  tela para dentro de cada linha de Pokémon, está duplicando a mesma informação em
  várias linhas, o que já é sinal de que falta uma tabela própria para `HABILIDADES`.
  É o mesmo problema de datilografar o endereço completo do cliente em cada nota
  fiscal, em vez de guardar uma vez só e só referenciar: se o nome da rua mudar, você
  caça e corrige em dezenas de linhas em vez de uma.
- A tela não revela **nada** sobre usuários: existe alguém logado favoritando Pokémon?
  Existe histórico de busca? Múltiplos idiomas por descrição? Você não tem como saber
  — é como julgar o caixa de um mercado só pela vitrine, sem ver o estoque, o caderno
  de fiado ou quem tem a chave do cofre — e adivinhar errado agora custa uma migração
  de banco em produção depois.

!!! tip "A moral do aquecimento"
    Reverse-engineer uma interface pronta parece "mais rápido" que ler um documento de
    requisitos, mas troca decisões **verificáveis** por **suposições**, e cada
    suposição errada vira retrabalho quando o sistema já está no ar. É exatamente por
    isso que, a partir daqui, cada um dos 6 exercícios abaixo começa com uma
    **descrição textual de requisitos de negócio** — não uma tela pronta — e é a partir
    dela, e só dela, que você modela.

---

## 🎯 O que se espera em cada exercício

Para cada um dos 6 exercícios abaixo, a partir do cenário e da lista de requisitos de
negócio apresentados, você deve produzir um diagrama em
**[dbdiagram.io](https://dbdiagram.io)** que:

1. **Identifique entidades, atributos e chaves** (PK e FK) — decidindo, quando fizer
   sentido, se há generalização/especialização (nem todo exercício exige isso: releia a
   [Aula 02, Seção 4.5](../aulas/Aula_02_Modelagem_Entidades.md) para saber quando ela
   se justifica e quando é complexidade desnecessária, e a
   [Aula 03, Seção 8](../aulas/Aula_03_Relacionamentos_Cardinalidade.md#generalizacao-especializacao-tabelas)
   para como mapear a hierarquia em tabelas).
2. **Aplique a tipificação de dados correta** e as **convenções de nomenclatura** desta
   disciplina — veja a tabela de tipos e o resumo de convenções logo abaixo.
3. **Defina cardinalidade e participação** de cada relacionamento (1:1, 1:N, N:M —
   [Aula 03, Seção 5](../aulas/Aula_03_Relacionamentos_Cardinalidade.md)).
4. **Modele a gestão de usuários e acessos** — item **obrigatório em todo exercício**.
   Nos dois exercícios fáceis, isso significa autenticação simples com um tipo básico
   (`administrador` / `usuario`). Nos dois avançados, significa um sistema de **papéis
   com permissões configuráveis** (o padrão RBAC — *Role-Based Access Control* —
   detalhado na Seção de Convenções). Os intermediários usam o tipo básico, mas já
   convivem com generalização de entidades de domínio — leia o requisito de cada um com
   atenção.

> 📏 **Sobre normalização:** ainda não cobramos formalmente Formas Normais nesta
> disciplina (isso é conteúdo da Aula 04). Não é preciso justificar 1FN/2FN/3FN nos
> seus diagramas — só evite redundância óbvia (ex.: não repita o mesmo dado em duas
> tabelas sem motivo). Quando estudarmos Normalização, vale revisitar estes mesmos
> exercícios com esse olhar novo.

### Como modelar no dbdiagram.io

1. Acesse **[dbdiagram.io](https://dbdiagram.io)** e crie um diagrama novo (dá para
   usar sem conta, mas logar com Google/GitHub salva seu progresso).
2. A ferramenta usa a linguagem **DBML**: você descreve as tabelas em texto, e o
   diagrama é desenhado automaticamente. Sintaxe básica:

    ```dbml
    Table nome_da_tabela {
      id_nome_da_tabela BIGINT UNSIGNED [PK, INCREMENT]
      alguma_coluna     VARCHAR(255)    [NOT NULL]

      Note: 'observações sobre a tabela, se precisar'
    }

    Ref: outra_tabela.nome_da_tabela_id > nome_da_tabela.id_nome_da_tabela
    ```

3. Para colunas com **lista fechada de valores** (nosso `ENUM`), declare um bloco
   `Enum` separado e use o nome dele como tipo da coluna — não dá para escrever
   `ENUM('a','b')` direto dentro da tabela:

    ```dbml
    Enum status_pedido {
      pendente
      confirmado
      cancelado
    }

    Table pedidos {
      status status_pedido [NOT NULL, DEFAULT: 'pendente']
    }
    ```

4. Para **chave primária composta** (o padrão de tabela intermediária N:M da
   [Aula 03, Seção 7.2](../aulas/Aula_03_Relacionamentos_Cardinalidade.md)), marque
   `[PK]` nas duas colunas envolvidas — o dbdiagram.io entende que a chave é a
   combinação das duas.
5. Para restrições `UNIQUE` que envolvem mais de uma coluna, use um bloco `Indexes`
   dentro da tabela:

    ```dbml
    Table avaliacoes {
      usuario_id BIGINT UNSIGNED [NOT NULL]
      produto_id BIGINT UNSIGNED [NOT NULL]

      Indexes {
        (usuario_id, produto_id) [UNIQUE]
      }
    }
    ```

6. Para entregar/mostrar seu diagrama em aula, use o botão **Share** (gera um link
   público) ou exporte como PNG/PDF pelo menu — combine o formato exato com o
   professor no dia da correção em aula.

---

## 🧩 Tabela de Tipos Permitidos

Estes são **todos** os tipos usados nos gabaritos desta atividade — use apenas o que
está aqui, escolhendo o mais adequado ao dado, nunca o que "parece mais simples"
(Regra 8, formalizada na Aula 06 — SQL DDL, mas já anunciada na Aula 03). Pense nos
tipos numéricos como caixotes de feira de tamanhos diferentes: o caixote pequeno
(`TINYINT`) não dá conta de uma safra inteira de laranja, mas também não faz sentido
chamar o caminhão graneleiro (`BIGINT`) só pra carregar a nota de 1 a 5 de uma
avaliação — o trabalho é escolher o caixote do tamanho certo pro que vai guardar
dentro.

> 💡 **Adiantando conteúdo:** os tipos SQL exatos (`ENUM`, `DECIMAL`, tamanhos de
> `VARCHAR`...) e o padrão de campos de log (`criado_em`/`atualizado_em`/`deletado_em`,
> Regra 9) só serão formalizados nas Aulas 06 e 07. Usá-los aqui é proposital — é uma
> prática livre, não vale nota, e serve como preparo para quando chegarmos lá. Se
> alguma escolha não fizer sentido ainda, tudo bem: guarde a dúvida para essas aulas.

| Tipo (dbdiagram.io / MariaDB) | Tamanho / faixa | Quando usar |
|---|---|---|
| `BIGINT UNSIGNED` | 8 bytes · 0 a ~18,4 quintilhões | Toda PK (`id_...`) e toda FK que aponta para uma PK |
| `INT UNSIGNED` | 4 bytes · 0 a ~4,29 bilhões | Contadores que não cabem em `TINYINT` (duração em segundos, limite de downloads) |
| `SMALLINT UNSIGNED` | 2 bytes · 0 a 65.535 | Contadores pequenos com folga (ordem de item em lista longa) |
| `TINYINT UNSIGNED` | 1 byte · 0 a 255 | Quantidades bem pequenas e limitadas (séries, repetições, nota de 1 a 5/10, pontos) |
| `VARCHAR(n)` | até 65.535 bytes | Texto de tamanho variável e imprevisível — padrão defensivo `VARCHAR(255)` |
| `CHAR(n)` | n bytes fixos | Texto de tamanho **sempre igual** (placa de veículo, CNH) |
| `TEXT` | até 65.535 bytes | Texto longo e livre (biografia, comentário, descrição extensa) |
| `DECIMAL(p, s)` | exato · até 65 dígitos | Todo valor monetário ou medida que exige precisão exata — nunca `FLOAT`/`DOUBLE` |
| `DATE` | AAAA-MM-DD | Datas sem horário |
| `DATETIME` | AAAA-MM-DD HH:MM:SS | Datas com horário, incluindo os três campos de log opcionais (veja nota acima) |
| `BOOLEAN` (`TINYINT(1)`) | 0 ou 1 | Indicadores verdadeiro/falso |
| `ENUM(...)` | lista fechada | Conjunto **pequeno e estável** de valores — se a lista pode crescer ou precisa de metadados próprios, use tabela de domínio (é exatamente o caso de `papeis` nos exercícios avançados) |

---

## 📐 Convenções Aplicadas nesta Atividade

Recapitulando as **9 regras oficiais** de nomenclatura desta disciplina (detalhadas por
completo na [Aula 03, seção de Convenções de Nomenclatura](../aulas/Aula_03_Relacionamentos_Cardinalidade.md#convencoes-de-nomenclatura))
— todo diagrama entregue nesta atividade precisa aderir a todas elas:

| # | Regra | Exemplo aplicado nesta atividade |
|---|---|---|
| 1 | `snake_case` em tudo | `data_nascimento`, nunca `DataNascimento` |
| 2 | Minúsculas para nomes criados por você | `usuarios`, `id_usuario` — só palavras-chave SQL/DBML ficam maiúsculas |
| 3 | Palavras reservadas em MAIÚSCULAS | `BIGINT UNSIGNED`, `NOT NULL`, `PRIMARY KEY` |
| 4 | Tabelas sempre no plural | `usuarios`, `pedidos`, nunca `usuario`, `pedido` |
| 5 | PK no padrão `id_tabela_singular` | tabela `avaliacoes` → PK `id_avaliacao` |
| 6 | FK no padrão `tabela_singular_id` | FK em `itens_pedidos` que aponta para `produtos` → `produto_id` |
| 7 | FK pelo papel semântico quando a entidade referenciada tem múltiplos papéis | numa avaliação mútua entre pessoas, use `avaliador_id` / `avaliado_id` — nunca `pessoa1_id` / `pessoa2_id` |
| 8 | Tipo e tamanho adequados ao dado | ver a Tabela de Tipos acima |
| 9 | Toda tabela tem campos de log | `criado_em`, `atualizado_em`, `deletado_em` em **toda** tabela, sem exceção — inclusive tabelas de junção N:M e tabelas de subclasse |

Além das 9 regras, dois padrões estruturais que você vai usar o tempo todo nesta
atividade:

**Relacionamento N:M vira tabela intermediária com PK composta**
([Aula 03, Seção 7.2](../aulas/Aula_03_Relacionamentos_Cardinalidade.md)): as duas
FKs, juntas, formam a chave primária — sem PK substituta própria — e os atributos que
pertencem ao *relacionamento em si* (não a nenhuma das duas entidades) vivem nessa
tabela. Exemplo: `itens_pedidos (pedido_id PK FK, produto_id PK FK, quantidade)`.

**Generalização/especialização usa a Estratégia 2**
([Aula 03, Seção 8](../aulas/Aula_03_Relacionamentos_Cardinalidade.md#generalizacao-especializacao-tabelas)):
uma tabela para a superclasse, e uma tabela por subclasse cuja PK é, ao mesmo tempo, FK
única para a superclasse. Exemplo: `produtos (id_produto PK)` e `jogos (id_produto PK
FK)`.

**Gestão de usuários e acessos — dois níveis, conforme a dificuldade do exercício:**

- **Nível básico (exercícios fáceis):** uma coluna `tipo_usuario` do tipo `ENUM`, com
  os valores `'administrador'` e `'usuario'`. Simples, direto, suficiente quando só
  existem dois níveis de acesso fixos.
- **Nível RBAC — papéis com permissões (exercícios avançados):** quando o número de
  papéis pode crescer, um mesmo usuário pode acumular mais de um papel, e cada papel
  precisa de um conjunto de permissões configurável **sem alterar código**, um `ENUM`
  não resolve (lembre da Regra 8: um `ENUM` exige `ALTER TABLE` para crescer, e isso
  pode travar uma tabela em produção). A solução é o padrão **RBAC**: uma tabela
  `papeis`, uma tabela `permissoes`, e duas tabelas de junção N:M —
  `usuarios_papeis` (um usuário pode ter vários papéis) e `papeis_permissoes` (um papel
  agrupa várias permissões). Isso é generalização de comportamento, não de dados: em
  vez de decidir o acesso "no código", o próprio banco guarda a regra. Pense no molho
  de chaves de um síndico de prédio: cada chave (permissão) abre um tipo de porta
  (portaria, elevador, salão de festas), e um chaveiro pronto (papel) reúne um conjunto
  de chaves pra entregar direto pra um cargo — zelador, porteiro, síndico. Uma mesma
  pessoa pode ficar com mais de um chaveiro ao mesmo tempo (o zelador que também cobre
  a portaria num plantão), e se surgir um cargo novo amanhã, dá pra montar um chaveiro
  novo sem trocar fechadura nenhuma — exatamente como ajustar permissões sem alterar
  código.

---

## 🧾 Exemplo Completo e Comentado — Cupom Fiscal

O exemplo abaixo retoma o mesmo domínio da [Seção 9 da Aula 03](../aulas/Aula_03_Relacionamentos_Cardinalidade.md)
(o produto na leitora do caixa), já no nível de **Modelo Lógico**, 100% aderente a
todas as convenções acima. Use-o como referência de "isto está certo" antes de começar
os exercícios — cole o bloco inteiro em [dbdiagram.io](https://dbdiagram.io) para ver o
diagrama renderizado.

**Regras de negócio do exemplo:** uma loja emite cupons fiscais para clientes
cadastrados; cada cupom tem uma ou mais linhas de item, cada linha referenciando um
produto do catálogo com a quantidade comprada e o valor unitário **no momento da
venda** (o preço de um produto pode mudar depois, então o cupom precisa guardar o
valor histórico, não recalcular a partir do preço atual do produto). Todo cliente é
também um usuário do sistema de autoatendimento, com um tipo básico de acesso.

```dbml
// ============================================================
// EXEMPLO — Cupom Fiscal de Venda (mesmo domínio da Seção 6 da
// Aula 03), já no Modelo Lógico, 100% aderente às 9 regras de
// nomenclatura da disciplina.
// ============================================================

Enum tipo_usuario_enum {
  administrador
  usuario
}

Enum forma_pagamento_enum {
  dinheiro
  pix
  cartao_credito
  cartao_debito
}

// Regra 4 (plural) + Regra 9 (campos de log em toda tabela)
Table clientes {
  id_cliente     BIGINT UNSIGNED [PK, INCREMENT, note: 'Regra 5 — PK = id_ + tabela no singular']
  nome           VARCHAR(255)    [NOT NULL]
  cpf            CHAR(11)        [NOT NULL, UNIQUE, note: 'Regra 8 — tamanho fixo, só dígitos']
  email          VARCHAR(255)    [NOT NULL, UNIQUE]
  senha_hash     VARCHAR(255)    [NOT NULL]
  tipo_usuario   tipo_usuario_enum [NOT NULL, DEFAULT: 'usuario', note: 'gestão de acesso obrigatória — nível básico']
  criado_em      DATETIME        [NOT NULL, DEFAULT: `CURRENT_TIMESTAMP`, note: 'Regra 9']
  atualizado_em  DATETIME        [NOT NULL, note: 'Regra 9 — ON UPDATE CURRENT_TIMESTAMP no DDL real']
  deletado_em    DATETIME        [note: 'Regra 9 — NULL até o soft delete']
}

Table produtos {
  id_produto      BIGINT UNSIGNED [PK, INCREMENT]
  descricao       VARCHAR(255)    [NOT NULL]
  valor_unitario  DECIMAL(10,2)   [NOT NULL, note: 'Regra 8 — DECIMAL para dinheiro, nunca FLOAT/DOUBLE']
  criado_em       DATETIME        [NOT NULL, DEFAULT: `CURRENT_TIMESTAMP`]
  atualizado_em   DATETIME        [NOT NULL]
  deletado_em     DATETIME
}

Table cupons_fiscais {
  id_cupom_fiscal  BIGINT UNSIGNED   [PK, INCREMENT]
  cliente_id       BIGINT UNSIGNED   [NOT NULL, note: 'Regra 6 — FK = tabela_singular + _id']
  numero_cupom     VARCHAR(20)       [NOT NULL, UNIQUE]
  data_emissao     DATETIME          [NOT NULL, DEFAULT: `CURRENT_TIMESTAMP`]
  forma_pagamento  forma_pagamento_enum [NOT NULL]
  valor_total      DECIMAL(10,2)     [NOT NULL, note: 'derivado da soma dos itens — recalculado, não editado à mão']
  criado_em        DATETIME          [NOT NULL, DEFAULT: `CURRENT_TIMESTAMP`]
  atualizado_em    DATETIME          [NOT NULL]
  deletado_em      DATETIME
}

// Relacionamento N:M entre cupons_fiscais e produtos (Aula 03, 4.2):
// PK composta pelas duas FKs, sem PK substituta própria.
Table itens_cupom {
  cupom_fiscal_id  BIGINT UNSIGNED [PK, NOT NULL]
  produto_id       BIGINT UNSIGNED [PK, NOT NULL]
  quantidade       INT UNSIGNED    [NOT NULL]
  valor_unitario   DECIMAL(10,2)   [NOT NULL, note: 'snapshot do preço na venda']
  criado_em        DATETIME        [NOT NULL, DEFAULT: `CURRENT_TIMESTAMP`]
  atualizado_em    DATETIME        [NOT NULL]
  deletado_em      DATETIME
}

Ref fk_cupom_cliente:  cupons_fiscais.cliente_id      > clientes.id_cliente
Ref fk_item_cupom:     itens_cupom.cupom_fiscal_id     > cupons_fiscais.id_cupom_fiscal
Ref fk_item_produto:   itens_cupom.produto_id          > produtos.id_produto
```

Repare em três decisões que valem para **todos** os exercícios a seguir:

1. `valor_total` em `cupons_fiscais` e `valor_unitario` em `itens_cupom` **não** são
   redundância indevida — `valor_total` é derivado (soma dos itens), mas alguns
   sistemas optam por armazená-lo por performance, contanto que seja sempre
   recalculado, nunca editado manualmente. Já `valor_unitario` guardado no item **não é
   redundante**: ele é um snapshot histórico do preço no momento da venda, diferente do
   preço atual em `produtos.valor_unitario`, que muda com o tempo — são duas
   informações semanticamente diferentes, mesmo com nomes parecidos.
2. `itens_cupom` não tem PK própria — sua chave é a combinação `(cupom_fiscal_id,
   produto_id)`, seguindo a regra de tabela intermediária N:M.
3. `tipo_usuario` resolve a exigência obrigatória de gestão de usuários e acessos no
   nível básico, com um `ENUM` de dois valores.

---

## 📋 Os 7 Exercícios

Dificuldade progressiva: dois fáceis, três intermediários, dois avançados. Todos usam
cenários de 2026 — nenhum é biblioteca, escola ou aluno/nota.

### 🟢 Exercício 1 (Fácil) — AgendaPet: agendamento de serviços para o pet

O **AgendaPet** ajuda donos de cachorro e gato a marcar banho, tosa e vacina numa
petshop de bairro — é a mesma função que, na vida real, alguém faz a caneta na
agendinha de espiral pendurada perto do caixa. Requisitos de negócio:

- O sistema permite cadastro de usuários (donos de pet) com autenticação por e-mail e
  senha.
- Cada usuário cadastra um ou mais **pets** (nome, espécie, raça, data de nascimento),
  sempre vinculados a ele — é a mesma ideia de `cupons_fiscais` vinculado a um
  `cliente` no Exemplo Completo acima, só que aqui quem "recebe o serviço" é o pet, não
  quem paga.
- A petshop mantém um **catálogo de serviços** (ex.: "Banho", "Tosa Higiênica", "Vacina
  V10"), com nome, preço-base e duração em minutos — um catálogo único, usado por
  todos os agendamentos, do mesmo jeito que o catálogo de `produtos` do Exemplo
  Completo é usado por todos os cupons.
- O dono agenda um horário para um de seus pets, escolhendo **um ou mais serviços**
  daquele catálogo para o mesmo horário (ex.: banho + tosa juntos nem sempre são
  encaixados no mesmo dia, mas quando são, entram no mesmo agendamento).
- Cada serviço dentro de um agendamento guarda o **preço cobrado naquele momento** —
  releia o comentário 1 do Exemplo Completo (Cupom Fiscal): o preço do catálogo pode
  subir depois, mas o que já foi agendado não muda junto, do mesmo jeito que o preço
  de uma etiqueta antiga na gaveta não muda quando o produto reajusta na prateleira.
- Gestão de acesso no nível básico: `administrador` (mantém o catálogo de serviços) e
  `usuario` (cadastra pets e agenda horários).

### 🟢 Exercício 2 (Fácil) — TreinoZen: gestão de treinos e rotina fitness

O **TreinoZen** ajuda pessoas a montar e acompanhar suas rotinas de treino de academia.
Requisitos de negócio:

- Usuários se cadastram e fazem login (e-mail e senha).
- Cada usuário monta suas próprias rotinas de treino (ex.: "Treino A — Peito e
  Tríceps"), sempre vinculadas a ele.
- Uma rotina de treino é composta por vários **exercícios**, em uma **ordem
  específica**, cada um com número de séries, repetições e carga (peso) planejados
  para aquela rotina — como a lista de compras da feira, em que você anota o que pegar
  em qual banca primeiro pra não ter que voltar.
- O mesmo exercício (ex.: "Supino Reto") pode aparecer em várias rotinas diferentes,
  inclusive de usuários diferentes — a plataforma mantém um **catálogo único** de
  exercícios, com grupo muscular e instruções de execução. É como a prateleira de
  temperos do mercado: o mesmo pacote de orégano entra em receitas de gente diferente,
  sem precisar duplicar o pote pra cada receita.
- Toda vez que o usuário efetivamente realiza um treino, o app registra essa
  **execução**: data/hora, duração em minutos e uma nota de esforço percebido (1 a
  10).
- Gestão de acesso no nível básico: `administrador` (mantém o catálogo de exercícios)
  e `usuario` (monta e executa treinos).

### 🟡 Exercício 3 (Intermediário) — OndaCast: streaming de podcasts e audiolivros

A **OndaCast** é uma plataforma de streaming de áudio por assinatura, especializada em
podcasts e audiolivros. Requisitos de negócio:

- A plataforma oferece dois tipos de conteúdo de áudio: **episódios de podcast**
  (agrupados em programas/podcasts) e **capítulos de audiolivro** (agrupados em
  obras/audiolivros).
- Todo conteúdo, seja episódio ou capítulo, tem título, duração em segundos e data de
  publicação — mas **só** episódios de podcast têm número do episódio e indicação de
  transcrição disponível; **só** capítulos de audiolivro têm número do capítulo e
  narrador. Um podcast agrupa vários episódios; um audiolivro agrupa vários capítulos.
  É como a diferença entre o programa de rádio (agrupa vários episódios) e o audiobook
  (agrupa vários capítulos): os dois são "áudio pra ouvir", mas cada um tem uma ficha
  técnica própria — isso é generalização/especialização (Aula 02, Seção 4 / Aula 03,
  Seção 8).
- Usuários podem criar **playlists pessoais** que misturam episódios de podcast e
  capítulos de audiolivro, em qualquer ordem escolhida por eles.
- A plataforma funciona por assinatura: existem **planos** (ex.: "Básico", "Premium")
  com preço mensal e limite de downloads offline. Um usuário assina um plano por vez,
  mas o sistema precisa manter o **histórico** de todos os planos que aquele usuário já
  assinou, com data de início e de término (nula se ainda estiver ativo). Pense no
  plano de internet de casa: hoje você pode estar no "Premium", mas a operadora guarda
  no cadastro todos os planos que você já teve, com a data de cada troca — é a mesma
  lógica aqui.
- Gestão de acesso no nível básico: `administrador` (cadastra podcasts, audiolivros e
  planos) e `usuario` (assina planos e ouve conteúdo).

### 🟡 Exercício 4 (Intermediário) — CaronaViva: caronas urbanas compartilhadas

A **CaronaViva** conecta pessoas que fazem o mesmo trajeto todo dia, dividindo o custo
da viagem. Requisitos de negócio:

- Toda pessoa se cadastra uma única vez na plataforma (nome, CPF, e-mail, telefone) e
  faz login.
- Uma pessoa pode ser **motorista** (com CNH e dados do veículo), **passageira** (sem
  dados extras), **as duas coisas ao mesmo tempo**, ou **nenhuma delas ainda** — só se
  cadastrou e não assumiu nenhum papel na plataforma. É como um morador de condomínio
  que também é síndico: a mesma pessoa acumulando um papel a mais — nem todo morador é
  síndico, mas todo síndico também é morador.
- Um motorista pode oferecer várias **caronas**, cada uma com origem, destino, data e
  hora de saída, número de vagas disponíveis e valor por vaga.
- Um passageiro pode reservar vaga em várias caronas diferentes, e uma carona pode ter
  vários passageiros — cada **reserva** tem um status (`solicitada`, `confirmada`,
  `cancelada`, `concluída`).
- Depois de concluída uma carona, **tanto o motorista quanto o passageiro** podem
  avaliar um ao outro (nota de 1 a 5 e comentário) — o sistema precisa distinguir com
  clareza **quem avaliou quem** nessa troca mútua. Pense no motorista e no passageiro
  de um app de transporte avaliando um ao outro depois da mesma corrida: são duas
  notas independentes, cada uma com seu "quem avaliou" e seu "quem foi avaliado"
  (Regra 7 de nomenclatura).
- Gestão de acesso no nível básico: `administrador` (modera denúncias, pode suspender
  contas) e `usuario` (usa a plataforma como motorista e/ou passageiro).

### 🟡 Exercício 5 (Intermediário) — RachaConta: divisão de contas entre amigos

O **RachaConta** é um app que ajuda grupos de amigos a dividir despesas em viagens,
repúblicas ou saídas, sem precisar de planilha.

!!! note "Por que este exercício é intermediário, não fácil"
    Ele reúne, no mesmo cenário, duas tabelas associativas N:M diferentes (grupo↔membro
    e despesa↔participante) **e** um raciocínio sobre atributo derivado — três ideias
    distintas empilhadas de uma vez. Se ainda não se sente confortável com N:M com
    atributo próprio, resolva primeiro os Exercícios 1 e 2 (Fáceis), que usam essa
    mesma ideia isolada, uma de cada vez.

Requisitos de negócio:

- O sistema permite cadastro de usuários com autenticação por e-mail e senha.
- Usuários podem criar **grupos** (ex.: "Viagem para Bonito", "Apê 402") e convidar
  outros usuários cadastrados para participar. Um usuário pode participar de vários
  grupos, e um grupo tem vários membros.
- Dentro de um grupo, qualquer membro pode registrar uma **despesa** (ex.: jantar,
  corrida de aplicativo, mercado), informando quem pagou, o valor total e a data.
- Cada despesa deve ser dividida entre um **subconjunto** dos membros do grupo — nem
  sempre todos os membros participam de todas as despesas. É como dividir a conta do
  rodízio de pizza de domingo: nem todo mundo pediu sobremesa, então a divisão daquele
  item não é sempre entre o grupo inteiro, só entre quem participou dele — e o sistema
  guarda quanto cada participante deve daquela despesa específica.
- O saldo de cada membro dentro de um grupo (quanto deve ou tem a receber) é sempre
  **calculado** a partir das despesas registradas. Ninguém escreve "quanto o Fulano
  deve" numa lousa fixa na parede da república — isso ficaria desatualizado a cada
  despesa nova. É como a conta de um bar: ninguém anota o total no meio da noite, ele
  é somado no fim a partir de cada pedido lançado. Pense se o saldo deveria ser uma
  coluna guardada, ou algo calculado na hora a partir das despesas (releia a Aula 02,
  Seção 3.1 — Atributo Derivado).
- Gestão de acesso no nível básico: `administrador` (gerencia a plataforma, pode
  desativar contas) e `usuario` (uso normal do app).

### 🔴 Exercício 6 (Avançado) — PlayHub: marketplace de jogos digitais

A **PlayHub** é um marketplace de jogos digitais (pense em Steam ou Epic Games Store),
com biblioteca de jogos, conquistas e avaliações. Requisitos de negócio:

- A plataforma vende **jogos** e **conteúdos adicionais (DLCs)** publicados por
  estúdios desenvolvedores parceiros. Todo produto vendido é obrigatoriamente um
  jogo-base **ou** uma DLC — nunca as duas coisas ao mesmo tempo — e toda DLC pertence
  a exatamente um jogo-base.
- Um usuário compra produtos (jogos e/ou DLCs) e eles passam a fazer parte da sua
  biblioteca; o sistema registra cada compra com o valor efetivamente pago e a data —
  o preço de um jogo pode mudar ao longo do tempo, então o valor pago numa compra
  antiga não deve mudar junto com o preço atual do catálogo.
- Cada jogo tem um catálogo próprio de **conquistas** (achievements) que os jogadores
  desbloqueiam jogando; o sistema registra quando cada usuário desbloqueou cada
  conquista.
- Usuários que compraram um produto podem avaliá-lo **uma única vez** (nota de 1 a 5 +
  comentário) — não é permitido avaliar duas vezes o mesmo produto.
- **Controle de acesso com papéis e permissões (obrigatório neste exercício):** a
  plataforma tem múltiplos tipos de acesso interno — `administrador` (gerencia toda a
  plataforma), `desenvolvedor` (gerencia apenas o catálogo dos jogos do próprio
  estúdio), `suporte` (processa reembolsos e modera avaliações denunciadas) e
  `jogador` (usuário comum, compra e joga). **Um mesmo usuário pode acumular mais de
  um papel** (ex.: alguém do estúdio que também joga na própria plataforma), e cada
  papel tem um conjunto específico de permissões que precisa poder ser
  criado/ajustado **sem alterar código-fonte** — a mesma lógica do molho de chaves do
  síndico (analogia na seção de Convenções acima): cada permissão é uma chave, cada
  papel é um chaveiro pronto.

### 🔴 Exercício 7 (Avançado) — TrampoJá: marketplace de prestadores de serviço

A **TrampoJá** conecta clientes que precisam de um serviço a prestadores autônomos que
o oferecem — típico app de *gig economy* de serviços (elétrica residencial, design
gráfico, aulas particulares etc.). Requisitos de negócio:

- Todo usuário se cadastra uma vez na plataforma e faz login. Um usuário que quer
  oferecer serviços cria um **perfil de prestador** (biografia, categoria principal) —
  **nem todo** usuário cadastrado é prestador; alguns são só clientes.
- Um prestador pode anunciar vários **serviços**, cada um com título, descrição e
  preço-base, dentro de uma **categoria** (ex.: "Elétrica Residencial", "Design
  Gráfico").
- Um cliente pode enviar uma **proposta** de contratação para um serviço anunciado,
  informando o valor que está disposto a pagar; o prestador aceita ou recusa.
- Quando uma proposta é aceita, ela vira um **contrato**, com data de início, previsão
  de conclusão e status. Um contrato pode ter **mais de um pagamento** associado (o
  cliente pode pagar em parcelas).
- Ao final do contrato, cliente e prestador podem se **avaliar mutuamente** (nota +
  comentário) — o sistema precisa registrar com clareza quem avaliou quem.
- **Controle de acesso com papéis e permissões (obrigatório neste exercício):** existem
  quatro tipos de acesso — `administrador` (gerencia toda a plataforma), `moderador`
  (modera denúncias e avaliações, sem acesso a dados financeiros), `cliente` e
  `prestador` (papéis de uso comum — **um mesmo usuário pode acumular `cliente` e
  `prestador` simultaneamente**). As permissões de cada papel precisam poder ser
  reconfiguradas pela equipe da plataforma **sem alterar código** — de novo, o molho de
  chaves do síndico: cada papel é um chaveiro que agrupa um conjunto de permissões.

---

⬅️ [Voltar para Atividades e Avaliações](index.md)

---

*Fatec Jahu · IBD951 · Prof. Ronan Adriel Zenatti · 2026*
