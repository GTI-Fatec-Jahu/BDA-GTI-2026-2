# Prática — DBML: Partidas Esportivas (Aulas 01 a 03)

**Instituição:** Fatec Jahu — Centro Paula Souza
**Curso:** Tecnologia em Gestão da Tecnologia da Informação
**Disciplina:** Banco de Dados e Aplicações — IBD951
**Professor:** Ronan Adriel Zenatti · ronan.zenatti@cps.sp.gov.br
**Semestre:** 2º Semestre / 2026
**Valor:** não vale nota

!!! info "🧪 Atividade de treino — não vale nota"
    Esta atividade **não tem peso na média**. Ela existe para revisar o conteúdo das
    [Aulas 01](../aulas/Aula_01_Introducao_BD.md), [02](../aulas/Aula_02_Modelagem_Entidades.md)
    e [03](../aulas/Aula_03_Relacionamentos_Cardinalidade.md) antes da **P1**. Traga sua
    tentativa — mesmo incompleta — para a aula: é matéria-prima para discussão, não algo
    para entregar "pronto".

---

## 📦 O que você deve entregar

Um único arquivo de texto, com extensão **`.txt`**, contendo duas partes, nesta ordem:

1. **As respostas das 4 perguntas de revisão** da seção abaixo, cada uma escrita como
   um **comentário** no próprio arquivo (linha iniciada com `//`, a sintaxe de
   comentário do DBML) — não em um arquivo separado.
2. **O diagrama completo em DBML** do cenário descrito mais abaixo, na seção "Cenário".

Monte o diagrama normalmente no [dbdiagram.io](https://dbdiagram.io) (o editor já
mostra o texto DBML enquanto você desenha) e depois copie esse texto para dentro do
`.txt` — não precisa exportar imagem nem PDF desta vez, só o texto do diagrama mesmo.

Aplique no seu DBML **todas as convenções de nomenclatura, tipos e padrões estruturais**
já usados em aula e na [Prática — Modelagem com dbdiagram.io](Pratica_Modelagem_dbdiagram.md)
— não vou repetir a lista aqui. Se tiver dúvida sobre alguma convenção específica (como
nomear PK/FK, como declarar um `ENUM`, como montar uma tabela intermediária N:M...),
volte para aquela página ou para a
[Aula 03, seção de Convenções de Nomenclatura](../aulas/Aula_03_Relacionamentos_Cardinalidade.md#convencoes-de-nomenclatura).

---

## ❓ Perguntas de Revisão — respondidas como comentário no arquivo

Antes do diagrama, escreva no `.txt` a resposta de cada uma das 4 perguntas abaixo, uma
por bloco de comentário `//`. Elas cobrem as Aulas 01 a 03 e revisam exatamente o tipo
de raciocínio que cai na P1 — não é sobre o cenário de esportes, é teoria da aula.

1. **(Aula 01)** Qual a diferença entre um SGBD (Sistema Gerenciador de Banco de Dados)
   e guardar os dados soltos em arquivos comuns (planilhas, arquivos de texto)? Cite
   pelo menos duas vantagens concretas de se usar um SGBD.
2. **(Aula 02)** O que é um **atributo derivado**? Dê um exemplo diferente dos usados em
   aula e explique por que, normalmente, ele não deveria virar uma coluna comum,
   editável à mão, no banco.
3. **(Aula 02)** Em que situação usar **generalização/especialização** na modelagem se
   justifica, e em que situação isso é complexidade desnecessária?
4. **(Aula 03)** Em um relacionamento entre duas tabelas, como saber em qual delas a
   **chave estrangeira (FK)** deve ser colocada? Explique como a **cardinalidade**
   (1:1, 1:N e N:M) define essa escolha. (Lembrete: a FK é a coluna que "aponta" para a
   chave primária de outra tabela — como o número da comanda anotado em cada item
   consumido, que leva de volta à comanda da mesa.)

---

## 🏐 Cenário — ChamaMaisUm: encontrar partidas de esporte pra jogar

O **ChamaMaisUm** é um app para quem quer jogar uma partida de esporte amador (futebol,
vôlei, basquete...) e não tem um grupo fechado pra isso — é a versão digital daquele
grupo de WhatsApp da pelada de sexta-feira, só que aberto: em vez de contar só com os
mesmos oito de sempre, qualquer pessoa perto do ginásio da prefeitura ou da quadra do
bairro pode entrar numa partida que ainda tem vaga sobrando.

!!! note "Por que este exercício é intermediário, não fácil"
    O ponto central aqui é reconhecer um **atributo derivado** (Aula 02, Seção 3.1 —
    Tipos de Atributos): quantas vagas ainda restam numa partida não é um número que
    alguém digita e atualiza à mão — ele nasce de uma conta (total de vagas da partida
    menos as inscrições já confirmadas). Guardar esse número solto, sem recalculá-lo a
    partir das inscrições, é o mesmo erro do saldo fixo na parede da república do
    RachaConta (Exercício 5 da [Prática anterior](Pratica_Modelagem_dbdiagram.md)) —
    decida se essa informação vira coluna guardada no banco ou é só calculada na hora.
    Além disso, o **local** da partida também tem regras próprias (endereço que não pode
    se repetir e avaliação opcional) — leia esse requisito com calma antes de modelar.

Requisitos de negócio:

- O sistema permite cadastro de usuários com autenticação por e-mail e senha.
- A plataforma mantém um **catálogo de modalidades esportivas** (ex.: "Futebol
  Society", "Vôlei de Quadra", "Basquete 3x3"), com nome e o número padrão de
  jogadores por time daquela modalidade — um catálogo único, do mesmo jeito que o
  catálogo de serviços do AgendaPet ou de exercícios do TreinoZen (Prática anterior),
  usado por todas as partidas daquela modalidade.
- Qualquer usuário pode cadastrar um **local** (quadra, ginásio, campo...) informando
  nome e endereço (logradouro, número, bairro, cidade e CEP). Antes de cadastrar, o
  sistema **valida o endereço**: se já existe um local naquele mesmo endereço, não
  aceita um segundo — é como o cadastro de imóveis da prefeitura, em que o mesmo
  endereço não aparece duas vezes. O mesmo local, uma vez cadastrado, serve para
  qualquer número de partidas.
- Qualquer usuário pode criar uma **partida**, escolhendo a modalidade, o local (entre
  os já cadastrados), a data e hora, e o número total de vagas (jogadores
  necessários). Isso vale
  tanto pra quem está começando um jogo do zero e precisa juntar todo mundo, quanto pra
  quem já tem quase um time fechado — um grupo de amigos, por exemplo — e só precisa
  completar os últimos lugares antes do horário marcado. Nos dois casos, o que existe
  no fim é uma partida com um número de vagas em aberto; a plataforma não trata "criar
  do zero" e "completar o time" como duas telas com resultado diferente no banco. Toda
  partida tem um usuário **organizador** — quem criou —, e esse organizador ocupa
  automaticamente uma das vagas como participante inscrito.
- Qualquer usuário pode se inscrever numa partida que ainda tenha vaga disponível; cada
  inscrição tem um status (`confirmada`, `cancelada`) — se alguém cancela, a vaga volta
  a ficar disponível para outra pessoa.
- Depois que a partida acontece, cada participante que quiser pode avaliar a partida
  (nota de 1 a 5 e um comentário livre) — isso é **opcional**: nem todo participante
  avalia, e quem avalia faz isso uma única vez por partida, nunca duas.
- Também depois da partida, os participantes podem avaliar o **local** onde ela
  aconteceu (nota de 1 a 5 e uma descrição livre). Assim como a avaliação da partida,
  isso é **opcional** e vale uma única vez por participante, por partida — quem gostou
  do jogo mas não quer opinar sobre a quadra simplesmente não avalia o local, e vice-versa.
- Gestão de acesso no nível básico: `administrador` (mantém o catálogo de modalidades e
  modera denúncias) e `usuario` (cadastra locais, cria partidas, se inscreve e avalia).

---

⬅️ [Voltar para Atividades e Avaliações](index.md)

---

*Fatec Jahu · IBD951 · Prof. Ronan Adriel Zenatti · 2026*
