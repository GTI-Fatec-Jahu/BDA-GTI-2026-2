<!--
GABARITO — não faz parte do fluxo principal do site e fica fora do `nav` do
mkdocs.yml de propósito. É acessível só pelo link no final de
Pratica_DBML_Partidas_Esportivas.md.
-->

# Gabarito — Prática DBML: Partidas Esportivas (Aulas 01 a 03)

**Disciplina:** Banco de Dados e Aplicações <br>
**Professor:** Ronan Adriel Zenatti · ronan.zenatti@cps.sp.gov.br  <br>
**Fatec Jahu — 2º Semestre/2026**

> ⚠️ Este gabarito é para conferência **depois** de você tentar resolver a
> [atividade](Pratica_DBML_Partidas_Esportivas.md) por conta própria. Consultar antes
> de terminar reduz o benefício de treinar a recuperação ativa do conteúdo — e o
> objetivo aqui é se preparar para a P1, não completar a lista.

---

## Parte 1 — Respostas das 4 Perguntas de Revisão

### 1. (Aula 01) SGBD x arquivos comuns

Um SGBD centraliza o armazenamento e o acesso aos dados através de um único sistema,
em vez de deixá-los espalhados em arquivos soltos (planilhas, `.txt`, arquivos
binários próprios de cada programa). Isso resolve problemas estruturais dos sistemas
de arquivos convencionais (Aula 01, Seção 2):

- **Redundância de dados** — sem SGBD, a mesma informação acaba copiada em vários
  arquivos; o SGBD guarda o dado uma única vez, compartilhado entre quem precisa dele.
- **Inconsistência** — cópias duplicadas divergem com o tempo; o SGBD usa restrições
  de integridade para manter uma versão única e válida.
- **Dificuldade de acesso** — buscar em arquivos soltos exige programar a busca na
  mão; o SGBD oferece uma linguagem de consulta padronizada (SQL).
- **Isolamento de dados** — cada aplicação usa seu próprio formato proprietário; o
  SGBD expõe um modelo unificado, acessível por múltiplas aplicações ao mesmo tempo.
- **Falta de controle de acesso** — arquivo comum não distingue quem pode ler/escrever
  o quê; o SGBD tem sistema de permissões e usuários.
- **Problemas de concorrência** — duas pessoas editando o mesmo arquivo ao mesmo tempo
  podem se sobrescrever; o SGBD usa controle de transações e bloqueios.

Basta citar duas dessas vantagens com exemplo próprio para a resposta valer.

### 2. (Aula 02) Atributo derivado

Um **atributo derivado** é aquele cujo valor pode ser calculado a partir de outro(s)
atributo(s) já existente(s) — na notação do MER ele é representado com elipse
tracejada (Aula 02, Seção 3.1). O exemplo dado em aula é `idade`, derivada de
`data_nascimento`.

Qualquer exemplo análogo vale, ex.: `valor_total` de um carrinho de compras (derivado
da soma dos itens), `tempo_de_casa` de um funcionário (derivado da `data_admissao`),
ou — no cenário desta atividade — `vagas_disponiveis` de uma partida (derivado de
`total_vagas` menos as inscrições confirmadas).

Normalmente ele **não deveria virar uma coluna comum, editável à mão**, porque isso
cria uma segunda fonte de verdade: se o dado-origem muda (a pessoa faz aniversário, um
item é removido do carrinho, alguém cancela a inscrição) e ninguém lembra de atualizar
a coluna derivada junto, ela fica desatualizada — o mesmo problema de inconsistência
da Pergunta 1, só que dentro de uma única tabela em vez de várias. O caminho mais
seguro é recalcular o valor sempre que for consultado (numa `VIEW` ou no `SELECT`), e
só armazená-lo como coluna de fato quando houver um motivo concreto de performance —
e, mesmo assim, com uma rotina garantindo que ele nunca fique fora de sincronia com o
dado de origem (como `valor_total` em `cupons_fiscais` no Exemplo Completo da Prática
anterior).

### 3. (Aula 02) Quando usar generalização/especialização

Se justifica (Aula 02, Seção 4.5) quando o enunciado sinaliza claramente que:

- existem dois ou mais **tipos** de uma mesma entidade ("existem dois tipos de X...");
- todo registro de um tipo **também é** o outro, com campos adicionais próprios
  ("todo X é também um Y, mas tem características adicionais...");
- os tipos têm **atributos próprios e exclusivos**, que não fazem sentido para os
  outros tipos (ex.: só episódio de podcast tem "número do episódio").

É complexidade desnecessária (*over-engineering*, Seção 6.5) quando a diferença entre
os registros é trivial — por exemplo, um único campo opcional que só se aplica a
alguns registros não justifica, sozinho, criar uma hierarquia de subclasses inteira.
Antes de especializar, a checagem prática é: "esses sinais realmente estão escritos no
enunciado, ou eu estou inventando uma distinção que não muda a estrutura de dados?".

### 4. (Aula 03) Em qual tabela vai a FK e como a cardinalidade decide

Quem decide é a **cardinalidade** do relacionamento (Aula 03, Seção 7). A FK é uma
coluna que guarda o valor da PK de outra tabela — um "ponteiro" —, então ela só cabe
no lado onde **cada linha aponta para uma única linha do outro lado**:

| Cardinalidade | Onde fica a FK | Por quê |
|---|---|---|
| **1:N** | Na tabela do lado **N** | Cada linha do lado N aponta para exatamente uma linha do lado 1. Se a FK ficasse no lado 1, cada linha só conseguiria guardar a referência de **uma** linha do lado N, contradizendo o "N". |
| **N:M** | Numa **tabela nova** (associativa), com duas FKs | Nenhum dos dois lados consegue guardar várias referências numa coluna só. A tabela nova recebe uma FK para cada lado, e o N:M "desaparece" e vira dois 1:N. |
| **1:1** | No lado de participação **parcial** (o "dependente", com mínimo 0) | Esse é o lado que só faz sentido completo se o outro existir. |

Exemplos deste cenário: `modalidades` 1:N `partidas` → a FK `modalidade_id` fica em
`partidas`; `usuarios` N:M `partidas` → nasce a tabela `inscricoes`, com as FKs
`usuario_id` e `partida_id`. Na prática, para achar o lado N basta perguntar "**uma**
linha de A se relaciona com quantas de B?" e "**uma** linha de B com quantas de A?" —
o lado que aparece "muitas vezes" é onde a FK vai.

---

## Parte 2 — Diagrama DBML de Referência (ChamaMaisUm)

Aderente às 9 regras de nomenclatura, à tabela de tipos e aos padrões estruturais da
disciplina (mesmos da Prática anterior). Colar em [dbdiagram.io](https://dbdiagram.io)
para conferir o diagrama renderizado.

```dbml
// ============================================================
// GABARITO — ChamaMaisUm: partidas de esporte amador
// Modelo Lógico, aderente às 9 regras de nomenclatura da disciplina.
// ============================================================

Enum tipo_usuario_enum {
  administrador
  usuario
}

Enum status_inscricao_enum {
  confirmada
  cancelada
}

Table usuarios {
  id_usuario     "BIGINT UNSIGNED" [PK, INCREMENT]
  nome           VARCHAR(255)      [NOT NULL]
  email          VARCHAR(255)      [NOT NULL, UNIQUE]
  senha_hash     VARCHAR(255)      [NOT NULL]
  tipo_usuario   tipo_usuario_enum [NOT NULL, DEFAULT: 'usuario', note: 'gestão de acesso obrigatória — nível básico']
  criado_em      DATETIME          [NOT NULL, DEFAULT: `CURRENT_TIMESTAMP`]
  atualizado_em  DATETIME          [NOT NULL]
  deletado_em    DATETIME
}

Table modalidades {
  id_modalidade       "BIGINT UNSIGNED"  [PK, INCREMENT]
  nome                VARCHAR(100)       [NOT NULL, UNIQUE, note: 'ex.: Futebol Society, Vôlei de Quadra']
  jogadores_por_time  "TINYINT UNSIGNED" [NOT NULL, note: 'quantidade pequena e limitada — Regra 8']
  criado_em           DATETIME           [NOT NULL, DEFAULT: `CURRENT_TIMESTAMP`]
  atualizado_em       DATETIME           [NOT NULL]
  deletado_em         DATETIME
}

// O endereço é atributo COMPOSTO (Aula 02, Seção 3.1), decomposto em colunas.
// A validação "não pode existir dois locais no mesmo endereço" vira um UNIQUE
// sobre a COMBINAÇÃO das colunas do endereço (Indexes), não sobre uma só.
Table locais {
  id_local       "BIGINT UNSIGNED" [PK, INCREMENT]
  nome           VARCHAR(255)      [NOT NULL]
  logradouro     VARCHAR(255)      [NOT NULL]
  numero         VARCHAR(10)       [NOT NULL, note: 'texto, não número — aceita "S/N", "120-A"']
  bairro         VARCHAR(100)      [NOT NULL]
  cidade         VARCHAR(100)      [NOT NULL]
  cep            CHAR(8)           [NOT NULL, note: 'tamanho fixo, só dígitos — Regra 8']
  criado_em      DATETIME          [NOT NULL, DEFAULT: `CURRENT_TIMESTAMP`]
  atualizado_em  DATETIME          [NOT NULL]
  deletado_em    DATETIME

  Indexes {
    (logradouro, numero, bairro, cidade, cep) [UNIQUE, note: 'validação: mesmo endereço não pode ser cadastrado duas vezes']
  }
}

// vagas_disponiveis NÃO é coluna desta tabela — é atributo derivado
// (Aula 02, Seção 3.1): total_vagas - COUNT(inscricoes.status = 'confirmada')
// para esta partida. Diferente de valor_total no Exemplo Completo (Cupom
// Fiscal), aqui optamos por NÃO armazenar, já que recalcular é barato e
// evita o risco de o número ficar fora de sincronia com as inscrições.
Table partidas {
  id_partida      "BIGINT UNSIGNED"  [PK, INCREMENT]
  modalidade_id   "BIGINT UNSIGNED"  [NOT NULL, note: 'Regra 6 — FK = tabela_singular + _id']
  local_id        "BIGINT UNSIGNED"  [NOT NULL, note: 'FK para locais — o local vira entidade, não texto solto']
  organizador_id  "BIGINT UNSIGNED"  [NOT NULL, note: 'Regra 7 — papel semântico: quem criou a partida']
  data_hora       DATETIME           [NOT NULL]
  total_vagas     "TINYINT UNSIGNED" [NOT NULL]
  criado_em       DATETIME           [NOT NULL, DEFAULT: `CURRENT_TIMESTAMP`]
  atualizado_em   DATETIME           [NOT NULL]
  deletado_em     DATETIME
}

// Relacionamento N:M entre usuarios e partidas (Aula 03, Seção 7.2):
// PK composta pelas duas FKs, sem PK substituta própria.
Table inscricoes {
  partida_id     "BIGINT UNSIGNED"     [PK, NOT NULL]
  usuario_id     "BIGINT UNSIGNED"     [PK, NOT NULL]
  status         status_inscricao_enum [NOT NULL, DEFAULT: 'confirmada']
  criado_em      DATETIME              [NOT NULL, DEFAULT: `CURRENT_TIMESTAMP`]
  atualizado_em  DATETIME              [NOT NULL]
  deletado_em    DATETIME
}

// Avaliação da partida é OPCIONAL (nem todo participante avalia) e feita no
// máximo uma vez por partida — por isso tem PK própria (nem toda inscrição
// gera avaliação) + Indexes UNIQUE para impedir duplicata.
Table avaliacoes_partidas {
  id_avaliacao_partida  "BIGINT UNSIGNED"  [PK, INCREMENT]
  partida_id            "BIGINT UNSIGNED"  [NOT NULL]
  usuario_id            "BIGINT UNSIGNED"  [NOT NULL]
  nota                  "TINYINT UNSIGNED" [NOT NULL, note: '1 a 5']
  comentario            TEXT               [note: 'opcional — pode ficar em branco mesmo com nota preenchida']
  criado_em             DATETIME           [NOT NULL, DEFAULT: `CURRENT_TIMESTAMP`]
  atualizado_em         DATETIME           [NOT NULL]
  deletado_em           DATETIME

  Indexes {
    (partida_id, usuario_id) [UNIQUE, note: 'uma avaliação por participante, por partida']
  }
}

// Avaliação do local: mesma lógica, mas é uma tabela SEPARADA — o participante
// pode avaliar só a partida, só o local, os dois ou nenhum. O local avaliado é
// o de partidas.local_id, então NÃO se repete local_id aqui (seria redundância:
// o mesmo dado em dois lugares).
Table avaliacoes_locais {
  id_avaliacao_local  "BIGINT UNSIGNED"  [PK, INCREMENT]
  partida_id          "BIGINT UNSIGNED"  [NOT NULL]
  usuario_id          "BIGINT UNSIGNED"  [NOT NULL]
  nota                "TINYINT UNSIGNED" [NOT NULL, note: '1 a 5']
  descricao           TEXT               [note: 'opcional']
  criado_em           DATETIME           [NOT NULL, DEFAULT: `CURRENT_TIMESTAMP`]
  atualizado_em       DATETIME           [NOT NULL]
  deletado_em         DATETIME

  Indexes {
    (partida_id, usuario_id) [UNIQUE, note: 'uma avaliação do local por participante, por partida']
  }
}

Ref fk_partida_modalidade:        partidas.modalidade_id         > modalidades.id_modalidade
Ref fk_partida_local:             partidas.local_id              > locais.id_local
Ref fk_partida_organizador:       partidas.organizador_id        > usuarios.id_usuario
Ref fk_inscricao_partida:         inscricoes.partida_id          > partidas.id_partida
Ref fk_inscricao_usuario:         inscricoes.usuario_id          > usuarios.id_usuario
Ref fk_avaliacao_partida_partida: avaliacoes_partidas.partida_id > partidas.id_partida
Ref fk_avaliacao_partida_usuario: avaliacoes_partidas.usuario_id > usuarios.id_usuario
Ref fk_avaliacao_local_partida:   avaliacoes_locais.partida_id   > partidas.id_partida
Ref fk_avaliacao_local_usuario:   avaliacoes_locais.usuario_id   > usuarios.id_usuario
```

---

## Parte 3 — Erros comuns: confira o seu diagrama

Depois de comparar seu DBML com o de referência, use a lista abaixo como um
**exame de consciência**: para cada item, releia o seu arquivo e responda com sinceridade
se você cometeu aquele erro — e, principalmente, **por que** ele é um problema. Se
descobrir um erro seu, não basta corrigir: tente explicar com as suas palavras o que
teria dado errado no sistema funcionando de verdade.

### 1. Vagas restantes guardadas como coluna comum

- **O erro:** criar `vagas_disponiveis` em `partidas` como um número que alguém
  atualiza à mão.
- **Exemplo do problema:** a partida tem `total_vagas = 10` e `vagas_disponiveis = 4`.
  Um jogador cancela a inscrição, mas o sistema esquece de somar 1 na coluna — ela
  continua mostrando 4 quando o certo é 5. Agora existem duas "verdades" diferentes no
  banco. É a mesma ideia do saldo escrito à mão na parede da república (RachaConta): no
  primeiro gasto novo que ninguém anotar, o número fica errado.
- **Reflita:** você guardou essa informação ou a calculou a partir das inscrições
  confirmadas? Se guardou, o que garantiria que ela nunca ficasse desatualizada?

### 2. Duas tabelas para "partida nova" e "completar o time"

- **O erro:** criar, por exemplo, `partidas_novas` e `partidas_para_completar`.
- **Exemplo do problema:** as duas tabelas acabam com as mesmas colunas (modalidade,
  local, data e hora, vagas). Uma partida que começou "do zero" e depois virou "só
  faltam 2" teria que ser copiada de uma tabela para a outra — e qualquer consulta
  "todas as partidas de sábado" precisaria olhar nas duas.
- **Reflita:** o que muda, **nos dados guardados**, entre os dois casos? Se a resposta
  for "nada", lembre da Aula 02, Seção 6.5: não crie estrutura sem necessidade real.
  Uma tela diferente no aplicativo não obriga uma tabela diferente no banco.

### 3. O local como texto solto dentro de `partidas`

- **O erro:** manter uma coluna `local VARCHAR(255)` em `partidas`, em vez de uma
  tabela própria `locais`.
- **Exemplo do problema:** três organizadores digitam "Ginásio Municipal", "ginasio
  municipal" e "Ginásio Mun." para o mesmo lugar. Para o banco são três locais
  diferentes: não dá para validar endereço, reaproveitar o cadastro nem juntar as
  avaliações de um mesmo local.
- **Reflita:** o local tem "vida própria" (endereço, avaliações) ou só descreve a
  partida? É a mesma pergunta do erro "atributo virou entidade" (Aula 02, Seção 6.1),
  só que ao contrário: aqui a entidade foi tratada como se fosse um atributo.

### 4. Endereço sem validação de duplicidade — ou com `UNIQUE` no lugar errado

- **O erro:** esquecer completamente a validação, **ou** colocar `UNIQUE` em cada coluna
  do endereço separadamente (`cep UNIQUE`, `cidade UNIQUE`...).
- **Exemplo do problema:** com `cidade UNIQUE`, só poderia existir **um** local em
  Jahu — o segundo cadastro na mesma cidade seria recusado, mesmo com rua e número
  diferentes. O que o enunciado pede é que a **combinação** (logradouro, número,
  bairro, cidade e CEP) não se repita, como no cadastro de imóveis da prefeitura: cada
  endereço completo aparece uma vez, mas a mesma rua pode ter vários imóveis. Isso se
  declara com um `UNIQUE` **composto**, no bloco `Indexes`.
- **Reflita:** se eu cadastrar "Rua das Flores, 100" e depois "Rua das Flores, 200"
  na mesma cidade, o seu modelo aceita os dois? E se eu cadastrar "Rua das Flores, 100"
  duas vezes, ele recusa?

### 5. Endereço inteiro numa coluna só

- **O erro:** `endereco VARCHAR(255)` com `UNIQUE`, em vez de colunas separadas.
- **Exemplo do problema:** valida a duplicidade, mas quando alguém pedir "mostre só as
  quadras do bairro Jardim Novo", não há como filtrar sem vasculhar texto. Lembre do
  atributo **composto** da Aula 02, Seção 3.1: um dado que se divide em partes com
  significado próprio (rua, bairro, cidade) costuma ser decomposto quando o sistema
  precisa consultar por uma dessas partes.
- **Reflita:** o sistema precisaria buscar por bairro ou por cidade? Sua escolha
  (coluna única ou decomposta) combina com essa necessidade?

### 6. `numero` do endereço com tipo numérico

- **O erro:** declarar `numero` como `INT` ou `TINYINT`.
- **Exemplo do problema:** o campo não aceita "S/N" (sem número) nem "120-A", que são
  endereços reais. Lembre da Regra 8 (tipo adequado ao dado): nem tudo que parece
  número é número — número de casa, como CPF e telefone, é um **identificador**, não
  algo em que se faz conta.
- **Reflita:** você chegaria a somar ou multiplicar números de endereço? Se não, um
  tipo numérico faz sentido?

### 7. `local_id` repetido na avaliação do local

- **O erro:** criar `avaliacoes_locais` com `partida_id` **e** `local_id`.
- **Exemplo do problema:** a partida 12 aconteceu no local 3. Alguém grava a avaliação
  com `partida_id = 12` e `local_id = 5` — o banco aceita, e agora a avaliação diz que a
  partida 12 foi em dois lugares diferentes. Como a partida já aponta para o seu local
  (`partidas.local_id`), guardar o local de novo é repetir a informação: é como
  datilografar o endereço do cliente em toda nota fiscal (a analogia usada no
  pré-problema da Pokédex, na Prática anterior). Não invalida o modelo, mas é uma
  redundância que você vai estudar formalmente na Normalização.
- **Reflita:** dá para descobrir o local de uma avaliação sem precisar de uma coluna
  a mais? Como?

### 8. Uma única tabela `avaliacoes` para partida e para local

- **O erro:** uma tabela só, com `nota_partida`, `comentario`, `nota_local` e
  `descricao_local`.
- **Exemplo do problema:** o enunciado diz que cada avaliação é opcional e
  independente. Um jogador que só quer avaliar o local deixaria `nota_partida` e
  `comentario` vazios (`NULL`) — e boa parte da tabela viraria colunas vazias, sem que
  dê para distinguir "não quis avaliar" de "esqueceu de preencher".
- **Reflita:** o seu modelo permite avaliar **só a partida**, **só o local**, **os
  dois** ou **nenhum**, sem deixar buracos? O que cada linha da tabela significa?

### 9. `inscricoes` com chave primária própria

- **O erro:** criar `id_inscricao` como PK em vez de usar as duas FKs juntas
  `(partida_id, usuario_id)`.
- **Exemplo do problema:** não é exatamente "errado" — é uma alternativa válida, desde
  que você também declare `UNIQUE(partida_id, usuario_id)`. Sem essa restrição, o
  mesmo usuário poderia se inscrever duas vezes na mesma partida, ocupando duas vagas.
  Mesmo com ela, o padrão que a disciplina adota para tabelas de junção N:M é a PK
  composta (Aula 03, Seção 7.2).
- **Reflita:** por que uma tabela que nasce de um N:M já tem, nas suas duas FKs, tudo
  o que precisa para identificar cada linha?

### 10. Faltar o `UNIQUE(partida_id, usuario_id)` nas avaliações

- **O erro:** criar as tabelas de avaliação com `partida_id` e `usuario_id`, mas sem a
  restrição de unicidade.
- **Exemplo do problema:** o requisito é "uma única vez por partida". Sem o `UNIQUE`,
  o mesmo usuário poderia enviar cinco avaliações da mesma partida — as quatro
  notas extras distorcem a média.
- **Reflita:** que parte do seu DBML impede a avaliação duplicada? Está nas **duas**
  tabelas de avaliação, ou só em uma?

### 11. Organizador sem FK, ou com nome genérico

- **O erro:** não ligar `partidas` a `usuarios` para registrar quem criou a partida, ou
  chamar essa FK de `usuario_id`.
- **Exemplo do problema:** sem o vínculo, ninguém sabe quem organizou o jogo (nem
  quem pode cancelá-lo). Com o nome genérico, quem ler `partidas.usuario_id` não sabe
  se é o organizador, um jogador ou quem cadastrou — a Regra 7 pede o **papel**
  (`organizador_id`), do mesmo jeito que `avaliador_id` e `avaliado_id` no CaronaViva.
- **Reflita:** olhando só para o nome da coluna, alguém entenderia o papel do
  usuário naquela tabela?

### 12. Campos de log faltando

- **O erro:** esquecer `criado_em`, `atualizado_em` e `deletado_em` em alguma
  tabela — o mais comum é esquecer na tabela de junção (`inscricoes`), por parecer
  "só uma ligação".
- **Exemplo do problema:** sem `criado_em` em `inscricoes`, não dá para saber quem se
  inscreveu primeiro (útil para lista de espera); sem `deletado_em`, não há como
  "apagar" uma inscrição sem perder o histórico. A Regra 9 vale para **toda** tabela,
  sem exceção.
- **Reflita:** confira tabela por tabela — alguma ficou sem os três campos?
