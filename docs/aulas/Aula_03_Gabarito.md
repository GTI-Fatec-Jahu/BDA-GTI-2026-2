<!--
GABARITO — não faz parte do fluxo principal da aula e fica fora do `nav` do
mkdocs.yml de propósito. É acessível só pelos links dentro de Aula_03_Relacionamentos_Cardinalidade.md.
-->

# Gabarito — Aula 03 — Relacionamentos e Cardinalidade

**Disciplina:** Banco de Dados e Aplicações <br>
**Professor:** Ronan Adriel Zenatti · ronan.zenatti@cps.sp.gov.br  <br>
**Fatec Jahu — 2º Semestre/2026**

---

!!! warning "Antes de conferir"
    Assim como no gabarito da Aula 02: este documento mostra **uma** solução correta possível para cada Checkpoint e Exercício. O que importa é o raciocínio — sobretudo o método das perguntas-chave (Aula 03, Seção 5) e a regra de onde entra a FK (Aula 03, Seção 7). Se sua resposta divergir na cardinalidade, refaça as perguntas antes de assumir que está errada.

---

## Checkpoint 1 — Cardinalidade: plataforma de streaming de música {: #checkpoint-1 }

**Resposta:**

**(a) USUARIOS e PLAYLISTS → 1:N.** "Um usuário pode criar várias playlists" (máximo N do lado PLAYLISTS) e "cada playlist pertence a exatamente um usuário" (máximo 1 do lado USUARIOS). A FK `usuario_id` fica em `PLAYLISTS` (lado N), seguindo a Regra 6.

**(b) PLAYLISTS e MUSICAS → N:M.** "Pode ter mais de uma?" é sim nos dois sentidos — uma playlist tem várias músicas, e uma música está em várias playlists. Precisa de uma tabela associativa (ex.: `ITENS_PLAYLIST`, com `playlist_id FK` e `musica_id FK`).

**(c) USUARIOS e ASSINATURAS → 1:1.** "Um usuário tem exatamente uma assinatura ativa" e "uma assinatura pertence a exatamente um usuário" — não em quantidade nos dois sentidos. A FK fica no lado de participação parcial (se um usuário puder existir sem assinatura ativa, a FK `usuario_id` vai em `ASSINATURAS`).

---

## Checkpoint 2 — Notações: locadora de veículos {: #checkpoint-2 }

**Resposta:**

**(a)** O símbolo `O{`, perto de `FILIAIS`, descreve `VEICULOS` — significa que **uma filial pode ter zero ou muitos veículos** (mínimo 0, máximo N).

**(b)** O símbolo `||`, perto de `VEICULOS`, descreve `FILIAIS` — significa que **um veículo pertence a exatamente uma filial** (mínimo 1, máximo 1).

**(c)** Em Min-Max: `FILIAIS (0,N) ———— (1,1) VEICULOS`.

---

## Checkpoint 3 — De cardinalidade a PK/FK: sistema de manutenção industrial {: #checkpoint-3 }

**Resposta:**

**(a)** `MAQUINAS` e `ORDENS_SERVICO` são 1:N — uma máquina pode gerar várias ordens de serviço, mas cada ordem de serviço se refere a exatamente uma máquina. Pela Regra da Seção 7.1, a FK fica no lado N (`ORDENS_SERVICO`), chamada `maquina_id` (Regra 6: nome da tabela referenciada no singular + `_id`).

**(b)** `ORDENS_SERVICO` e `TECNICOS` são N:M — uma ordem pode envolver vários técnicos, e um técnico atua em várias ordens. Nenhuma FK simples resolve isso porque nenhum dos dois lados consegue guardar múltiplas referências em uma única coluna (Seção 7.2). Solução: tabela associativa `ATUACOES_TECNICAS` (ou similar), com `ordem_servico_id FK` e `tecnico_id FK`.

---

## Checkpoint 4 — De Herança a Tabelas: sistema de conteúdo de uma escola online {: #checkpoint-4 }

**Resposta:**

**(a)** Seguindo a Estratégia 2 (Seção 8.1): `conteudos` é a superclasse, com os atributos comuns; `video_aulas` e `material_pdfs` são as subclasses, cada uma com seus atributos exclusivos, e cuja PK é, ao mesmo tempo, FK única para `conteudos`.

```mermaid
erDiagram
    CONTEUDOS {
        int id_conteudo PK
        string titulo
        date data_publicacao
    }
    VIDEO_AULAS {
        int id_conteudo PK
        int duracao_minutos
        string url_video
    }
    MATERIAL_PDFS {
        int id_conteudo PK
        int numero_paginas
        string url_arquivo
    }
    CONTEUDOS ||--o| VIDEO_AULAS : "é um"
    CONTEUDOS ||--o| MATERIAL_PDFS : "é um"
```

**(b)** A Estratégia 1 (tabela única com coluna discriminadora) obrigaria toda linha de `conteudos` a ter as quatro colunas exclusivas (`duracao_minutos`, `url_video`, `numero_paginas`, `url_arquivo`) — metade delas sempre `NULL` para qualquer linha, já que um conteúdo nunca é os dois tipos ao mesmo tempo (especialização disjunta). Além disso, nada impediria alguém de preencher `numero_paginas` numa linha marcada como vídeo-aula.

---

## Checkpoint 5 — Participação: sistema de biblioteca com reservas {: #checkpoint-5 }

**Resposta:**

**RESERVAS → participação total** em relação a `LIVROS` e a `MEMBROS`: o enunciado diz que toda reserva obrigatoriamente está vinculada aos dois — não existe reserva "solta" (mínimo 1 dos dois lados).

**LIVROS → participação parcial** no relacionamento de reserva: nem todo livro do acervo precisa ter sido reservado (mínimo 0).

**MEMBROS → participação parcial** no relacionamento de reserva: nem todo membro cadastrado precisa ter feito uma reserva (mínimo 0).

---

## Checkpoint 6 — Auto-relacionamento e Ternário: rede social e e-commerce {: #checkpoint-6 }

**Resposta:**

**(a) Auto-relacionamento.** `USUARIOS` se relaciona com `USUARIOS` — a mesma entidade em ambos os lados do relacionamento "segue".

```mermaid
erDiagram
    USUARIOS {
        int id_usuario PK
        string nome_usuario
    }
    USUARIOS ||--o{ USUARIOS : "segue"
```

**(b) Relacionamento ternário.** As três entidades `VENDEDORES`, `PRODUTOS` e `CONDICOES_COMERCIAIS` participam juntas de uma única ocorrência — a oferta só existe pela combinação das três, exatamente como no exemplo médico/medicamento/paciente da Seção 12.

```mermaid
erDiagram
    VENDEDORES }o--o{ PRODUTOS : "oferece"
    PRODUTOS }o--o{ CONDICOES_COMERCIAIS : "sob"
    VENDEDORES }o--o{ CONDICOES_COMERCIAIS : "define"
```

---

## Exercício 1 — Leitura de Diagrama

**a) Um fornecedor pode existir sem fornecer nenhum produto?** Sim. O símbolo `O{`, próximo a `FORNECEDORES`, descreve `PRODUTOS` e começa com círculo — mínimo 0. Um fornecedor recém-cadastrado pode ainda não ter nenhum produto associado.

**b) Um produto pode existir sem estar vinculado a um fornecedor?** Não. O símbolo `||`, próximo a `PRODUTOS`, descreve `FORNECEDORES` e começa com barra dupla — mínimo 1. Todo produto precisa ter um fornecedor.

**c) Cardinalidade em Min-Max:** `FORNECEDORES (0,N) ———— (1,1) PRODUTOS`.

---

## Exercício 2 — Oficina Mecânica

**Raciocínio:** há duas cadeias 1:N encadeadas. `CLIENTES` (1) para `VEICULOS` (N) — um cliente pode ter vários veículos, mas cada veículo pertence a exatamente um cliente (participação total: não faz sentido um veículo cadastrado sem dono). `VEICULOS` (1) para `ORDENS_SERVICO` (N) — um veículo pode passar por várias ordens de serviço ao longo do tempo, mas cada ordem de serviço se refere a exatamente um veículo.

```mermaid
erDiagram
    CLIENTES {
        int id_cliente PK
        string nome
        string telefone
    }
    VEICULOS {
        int id_veiculo PK
        string placa
        string modelo
        int cliente_id FK
    }
    ORDENS_SERVICO {
        int id_ordem_servico PK
        date data_abertura
        string descricao_problema
        float valor_total
        int veiculo_id FK
    }
    CLIENTES ||--o{ VEICULOS : "possui"
    VEICULOS ||--o{ ORDENS_SERVICO : "passa por"
```

Seguindo a regra da Seção 7.1: a FK sempre fica no lado N. `cliente_id` fica em `VEICULOS`; `veiculo_id` fica em `ORDENS_SERVICO`. Ambas seguem a Regra 6 (nome da tabela referenciada no singular + `_id`).

---

## Exercício 3 — Identifique o Tipo e Decomponha

**a) Ingresso e Evento → 1:N.** Um evento pode vender muitos ingressos; cada ingresso é válido para exatamente um evento. A FK `evento_id` fica em `INGRESSOS`.

```mermaid
erDiagram
    EVENTOS {
        int id_evento PK
        string nome
        date data_evento
    }
    INGRESSOS {
        int id_ingresso PK
        string codigo
        float preco
        int evento_id FK
    }
    EVENTOS ||--o{ INGRESSOS : "vende"
```

**b) Aluno e Turma → N:M.** Um aluno pode estar em várias turmas no mesmo semestre (ex: turmas de disciplinas diferentes); uma turma tem vários alunos. Entidade associativa: `MATRICULAS`, com `aluno_id FK` e `turma_id FK`.

```mermaid
erDiagram
    ALUNOS { }
    TURMAS { }
    MATRICULAS {
        int aluno_id FK
        int turma_id FK
    }
    ALUNOS ||--o{ MATRICULAS : "realiza"
    TURMAS ||--o{ MATRICULAS : "recebe"
```

**c) Passageiro e Voo → N:M.** Um passageiro pode reservar assento em vários voos; um voo tem vários passageiros. Entidade associativa: `RESERVAS`, com `passageiro_id FK`, `voo_id FK` e o atributo próprio `numero_assento` (que só faz sentido na combinação passageiro+voo, não em cada entidade isolada).

```mermaid
erDiagram
    PASSAGEIROS { }
    VOOS { }
    RESERVAS {
        int passageiro_id FK
        int voo_id FK
        string numero_assento
    }
    PASSAGEIROS ||--o{ RESERVAS : "faz"
    VOOS ||--o{ RESERVAS : "recebe"
```

---

## Exercício 4 — Nomeação de PK e FK

Seguindo a Regra 5 (PK: `id_` + nome da tabela no singular):

| Tabela | Chave Primária |
|---|---|
| `editoras` | `id_editora` |
| `livros` | `id_livro` |
| `categorias` | `id_categoria` |

Seguindo a Regra 6 (FK: nome da tabela referenciada no singular + `_id`), a chave estrangeira que `livros` usa para referenciar `editoras` é **`editora_id`**.

---

## Exercício 5 — A Catraca da Academia

**Raciocínio:** o enunciado diz explicitamente que a carteirinha "funciona como identificador do aluno dentro da academia" — exatamente o mesmo papel que o código de barras cumpria para `PRODUTOS` na Seção 9. Então a PK de `ALUNOS` não precisa ser um número sequencial: pode ser o próprio `numero_carteirinha`. Um aluno pode ter zero ou muitos acessos registrados (um aluno recém-cadastrado ainda não passou pela catraca); cada acesso pertence a exatamente um aluno — 1:N clássico, FK no lado N.

```mermaid
erDiagram
    ALUNOS {
        string numero_carteirinha PK
        string nome
    }
    ACESSOS {
        int id_acesso PK
        date data_acesso
        time hora_acesso
        string tipo_catraca
        string aluno_id FK
    }
    ALUNOS ||--o{ ACESSOS : "registra"
```

Note que `aluno_id` (a FK em `ACESSOS`) segue a Regra 6 normalmente — mesmo a PK de `ALUNOS` não sendo um número, o nome da FK continua sendo `tabela_singular` + `_id`, e não `aluno_numero_carteirinha` ou algo do tipo. É o mesmo padrão aplicado no Exercício de `PRODUTOS`/`codigo_barras` da Seção 9.

---

## 🔗 Voltar

⬅️ [Aula 03 — Relacionamentos e Cardinalidade](Aula_03_Relacionamentos_Cardinalidade.md)

---

*Fatec Jahu · IBD951 · Prof. Ronan Adriel Zenatti · 2026*
