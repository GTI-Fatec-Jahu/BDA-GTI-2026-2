# Avaliação de Proficiência — Banco de Dados e Aplicações (IBD951)

**Instituição:** Fatec Jahu — Centro Paula Souza  
**Curso:** Tecnologia em Gestão da Tecnologia da Informação  
**Disciplina:** Banco de Dados e Aplicações — IBD951  
**Professor:** Ronan Adriel Zenatti · ronan.zenatti@cps.sp.gov.br  
**Semestre:** 2º Semestre / 2026  
**Valor:** 10,0 pontos  
**Entrega:** via Google Classroom — atividade "Avaliação de Proficiência"  
**Formato de entrega:** Um único arquivo `.sql` com todos os comandos e comentários explicativos

---

## 📌 Instruções Gerais

Leia o enunciado com atenção antes de começar. Toda a avaliação deve estar contida em **um único arquivo `.sql`**, nomeado no formato `RA_NomeCompleto_Proficiencia.sql` (exemplo: `2300001_JoaoSilva_Proficiencia.sql`).

Dentro do arquivo, utilize **comentários SQL** (`--` para linha única e `/* */` para blocos) para identificar cada seção e, quando necessário, explicar suas escolhas de modelagem. Os comentários fazem parte da avaliação.

**Regras obrigatórias de escrita:**
- Nomes de tabelas: sempre no **plural** e em letras minúsculas (ex: `jogos`, `usuarios`)
- Nomes de colunas: sempre em **minúsculas** com underscore (ex: `nome_completo`, `data_lancamento`)
- Comandos SQL: sempre em **MAIÚSCULAS** (ex: `CREATE TABLE`, `INSERT INTO`, `SELECT`)
- Strings de texto: entre aspas simples (ex: `'Action'`, `'Brasil'`)

O MER (Diagrama Entidade-Relacionamento) **não é obrigatório**, mas sua entrega como imagem em comentário ou arquivo separado será considerada como critério de desempate em caso de notas iguais.

---

## 🎮 Contexto: NexusStore — Plataforma de Jogos Digitais

Você foi contratado como desenvolvedor júnior pela **NexusStore**, uma startup brasileira que quer criar uma plataforma de venda e gerenciamento de jogos digitais — inspirada em grandes plataformas do mercado, mas com foco no público nacional.

O CEO da empresa te convocou para uma reunião e explicou o negócio da seguinte forma:

---

*"A NexusStore precisa de um banco de dados para gerenciar nossa operação. Vou te explicar como o negócio funciona:*

*Trabalhamos com **jogos digitais**. Cada jogo tem um título, uma descrição, um preço base, uma data de lançamento e uma classificação etária (como Livre, 10+, 12+, 14+, 16+, 18+). Todo jogo pertence a exactamente **uma categoria** — como Ação, RPG, Estratégia, Esportes, Simulação, Terror — e cada categoria tem um nome e uma descrição.*

*Os nossos **usuários** se cadastram com nome completo, e-mail único, data de nascimento, país e uma senha. Cada usuário tem um **tipo de conta**: pode ser conta Padrão ou conta Premium. Usuários Premium têm direito a desconto fixo de 15% em todas as compras e acesso a jogos em fase beta. Isso é importante — usuários Padrão e Premium podem ter campos diferentes além dos comuns.*

*As **compras** são o coração do negócio. Um usuário pode comprar vários jogos, e um jogo pode ser comprado por vários usuários. Quando uma compra acontece, precisamos guardar a data da compra, o preço que foi pago de fato (que pode ser diferente do preço base por causa de promoções ou desconto Premium), e o status da compra (Pendente, Confirmada, Cancelada, Reembolsada).*

*Cada jogo também pode ter **avaliações** feitas pelos usuários. Um usuário só pode avaliar um jogo se já o tiver comprado. A avaliação tem uma nota de 0 a 10, um texto comentário e a data em que foi feita. Um usuário só pode avaliar o mesmo jogo uma única vez.*

*Por fim, precisamos de um controle básico de **desenvolvedoras**. Cada jogo é desenvolvido por uma única desenvolvedora. A desenvolvedora tem nome, país de origem e site oficial.*

*Uma coisa muito importante: precisamos saber quando cada registro foi criado, quando foi modificado pela última vez, e se ele foi excluído — mas sem apagar de verdade. Às vezes precisamos recuperar dados de usuários ou jogos que foram 'deletados'. Então o sistema precisa suportar exclusão lógica em todas as tabelas."*

---

## 📐 Regras de Negócio Consolidadas

Com base na reunião, você mapeou as seguintes regras de negócio que devem guiar sua modelagem:

**RN01 —** Todo jogo pertence a exatamente uma categoria. Uma categoria pode ter nenhum ou vários jogos.

**RN02 —** Todo jogo foi desenvolvido por exatamente uma desenvolvedora. Uma desenvolvedora pode ter desenvolvido nenhum ou vários jogos.

**RN03 —** Um usuário pode ter zero ou várias compras. Uma compra pertence a exatamente um usuário.

**RN04 —** Uma compra pode conter vários jogos e um jogo pode aparecer em várias compras. O preço pago deve ser registrado no momento da compra.

**RN05 —** Um usuário pode avaliar zero ou vários jogos. Um jogo pode ter zero ou várias avaliações. Um usuário só avalia o mesmo jogo uma única vez.

**RN06 —** Existem dois tipos de usuário: Padrão e Premium. Ambos compartilham os dados básicos, mas o usuário Premium possui o campo percentual de desconto (padrão 15%) e uma flag indicando acesso a versões beta.

**RN07 —** Toda tabela deve conter os campos de log: `criado_em` (timestamp de criação), `atualizado_em` (timestamp da última atualização) e `excluido_em` (timestamp de exclusão lógica, nulo quando o registro está ativo).

**RN08 —** A exclusão de registros no sistema é sempre **lógica**: nunca se usa `DELETE` para remover dados permanentemente. O registro é marcado com a data/hora em `excluido_em`. Registros com `excluido_em` preenchido são considerados inativos.

---

## 📋 O que deve ser entregue

O arquivo `.sql` deve estar organizado nas seções abaixo, na ordem indicada, identificadas por comentários de bloco.

---

### SEÇÃO 1 — Criação do Banco de Dados `(1,5 ponto)`

Crie o banco de dados `nexusstore` utilizando o conjunto de caracteres e collation considerados padrão de mercado em 2026 para suporte completo a múltiplos idiomas, emojis e comparações sem distinção de maiúsculas/minúsculas.

Inclua comandos que garantam:
- A **limpeza de dados antigos**: se o banco já existir, ele deve ser removido antes de ser recriado
- A **prevenção de erros de execução**: os comandos de criação não devem gerar erros caso o objeto já exista ou não exista

Em seguida, selecione o banco para uso.

**Critério de avaliação:** banco criado com charset e collation corretos, DROP com segurança, CREATE com segurança, USE executado. *(1,5 ponto)*

---

### SEÇÃO 2 — Criação das Tabelas `(2,5 pontos)`

Crie as tabelas do banco `nexusstore`. O modelo deve conter **exatamente 6 tabelas**, respeitando todas as regras de negócio definidas no enunciado.

Atenção aos seguintes requisitos obrigatórios para esta seção:

- Toda tabela deve ter uma chave primária com `AUTO_INCREMENT`
- Toda chave estrangeira deve ser declarada com `CONSTRAINT` nomeada explicitamente
- Os campos de log (`criado_em`, `atualizado_em`, `excluido_em`) devem estar presentes em **todas** as tabelas
- `criado_em` deve ser preenchido automaticamente no momento da inserção
- `atualizado_em` deve ser atualizado automaticamente sempre que o registro for modificado
- `excluido_em` deve aceitar valor nulo (registro ativo) e ser preenchido manualmente na exclusão lógica
- A generalização/especialização entre tipos de usuário deve estar representada na estrutura das tabelas
- A tabela associativa entre compras e jogos deve registrar o preço pago no momento da compra
- A constraint que impede um usuário de avaliar o mesmo jogo duas vezes deve ser implementada via banco de dados
- A nota de avaliação deve ser validada pelo banco para aceitar apenas valores entre 0 e 10
- Use `IF EXISTS` / `IF NOT EXISTS` onde aplicável para evitar erros de reexecução
- As tabelas devem ser criadas na ordem correta para respeitar as dependências de chave estrangeira

**Critério de avaliação:** estrutura correta das 6 tabelas, PKs e FKs nomeadas, campos de log em todas as tabelas com defaults automáticos, constraints de unicidade e validação, generalização de usuário representada. *(2,5 pontos)*

---

### SEÇÃO 3 — Inserção de Dados `(1,5 ponto)`

Insira **pelo menos 3 registros em cada tabela**, totalizando no mínimo 18 inserções. Os dados devem ser coerentes com o contexto da plataforma de jogos e suficientes para que as consultas das seções seguintes produzam resultados relevantes.

Orientações para os dados:
- Cadastre desenvolvedoras de países diferentes (pelo menos Brasil, EUA e Japão)
- Cadastre categorias variadas (pelo menos Ação, RPG e Estratégia)
- Cadastre pelo menos 1 usuário Padrão e pelo menos 2 usuários Premium
- Cadastre jogos de categorias e desenvolvedoras distintas, com preços variados
- Realize ao menos 3 compras com pelo menos 2 jogos diferentes em cada uma
- Cadastre avaliações apenas para jogos que o usuário comprou

**Critério de avaliação:** ao menos 3 registros por tabela, dados coerentes, campos de log preenchidos corretamente. *(1,5 ponto)*

---

### SEÇÃO 4 — Atualização de Registros `(0,5 ponto)`

Realize **pelo menos 4 atualizações** utilizando o comando `UPDATE`, sendo:

- **2 atualizações diretas** (atualizar dados de um registro sem envolver outra tabela):
  - Atualize o preço base de um jogo específico
  - Atualize o e-mail de um usuário específico

- **2 atualizações com relacionamento** (o critério de seleção do registro envolve uma junção ou subquery):
  - Atualize o status de todas as compras de um usuário identificado pelo seu e-mail (use subquery)
  - Atualize a nota de uma avaliação identificando o registro pelo nome do jogo e nome do usuário (use subquery ou JOIN no WHERE)

Em todas as atualizações, o campo `atualizado_em` deve refletir o momento da alteração.

**Critério de avaliação:** 4 updates executados corretamente, uso de subquery/relacionamento nos dois casos exigidos, `atualizado_em` atualizado. *(0,5 ponto)*

---

### SEÇÃO 5 — Exclusão de Registros `(0,5 ponto)`

Esta seção possui uma parte obrigatória e uma parte bônus.

**Parte obrigatória — Exclusão física (0,5 ponto):**

Exclua **3 registros** usando `DELETE`. Escolha registros que não possuam dependências de chave estrangeira (ou remova-os na ordem correta) para não violar a integridade referencial. Cada exclusão deve ser acompanhada de um comentário explicando qual registro está sendo removido e por quê ele pode ser excluído fisicamente.

**Parte bônus — Exclusão lógica (+0,5 ponto bônus):**

Implemente a exclusão lógica de **3 registros** adicionais. A exclusão lógica consiste em um `UPDATE` que preenche o campo `excluido_em` com o timestamp atual, sem remover o registro fisicamente da tabela.

Após cada exclusão lógica, escreva uma consulta `SELECT` que demonstre que o registro ainda existe na tabela, mas aparece com `excluido_em` preenchido.

**Critério de avaliação:** 3 DELETEs corretos sem violar integridade referencial (0,5 ponto obrigatório) + 3 exclusões lógicas via UPDATE com SELECT de comprovação (+0,5 ponto bônus). *(máximo: 1,0 ponto nesta seção)*

---

### SEÇÃO 6 — Consultas Simples `(1,0 ponto)`

Escreva o comando SQL para cada consulta abaixo. O enunciado descreve o que o relatório deve retornar; você deve escrever o SQL correspondente.

**Consulta S1 — Catálogo de jogos ativos**
*(Dica: use WHERE, ORDER BY e IS NULL)*

O time de marketing precisa de uma listagem de todos os jogos que estão ativos na plataforma (não foram excluídos logicamente), exibindo o título, o preço base e a classificação etária, ordenados pelo preço do mais barato para o mais caro.

---

**Consulta S2 — Busca por categoria e faixa de preço**
*(Dica: use WHERE com LIKE ou = e BETWEEN)*

O suporte recebeu a reclamação de um usuário que quer ver apenas jogos de RPG com preço entre R$ 30,00 e R$ 150,00. Retorne o título, o preço e a data de lançamento desses jogos.

---

**Consulta S3 — Usuários Premium ativos**
*(Dica: use JOIN entre as tabelas de usuário, WHERE e ORDER BY)*

O time financeiro precisa de uma lista de todos os usuários Premium ativos (não excluídos logicamente), mostrando o nome completo, o e-mail e o percentual de desconto ao qual têm direito, ordenados por nome.

---

**Critério de avaliação:** cada consulta correta e retornando os dados solicitados vale 0,33 ponto. *(1,0 ponto)*

---

### SEÇÃO 7 — Consultas com Agregação `(1,5 ponto)`

**Consulta A1 — Ticket médio e total de receita por categoria**
*(Dica: use JOIN, GROUP BY, AVG, SUM, COUNT, HAVING)*

O diretor financeiro quer um relatório com o nome de cada categoria, a quantidade de jogos vendidos nessa categoria, o valor total arrecadado e o ticket médio por jogo. Mostre apenas as categorias que geraram mais de R$ 100,00 em receita total, ordenadas pela receita total de forma decrescente.

---

**Consulta A2 — Ranking de jogos mais bem avaliados**
*(Dica: use JOIN, GROUP BY, AVG, COUNT, ORDER BY)*

O time de produto quer ver o ranking dos jogos com pelo menos 1 avaliação, exibindo o título do jogo, a quantidade de avaliações recebidas e a média das notas, ordenados da maior média para a menor. Em caso de empate na média, ordene pelo maior número de avaliações.

---

**Consulta A3 — Resumo de compras por usuário**
*(Dica: use JOIN, GROUP BY, COUNT, SUM, WHERE com IS NULL)*

O setor de CRM precisa de um relatório com o nome completo de cada usuário ativo, a quantidade de compras realizadas e o valor total gasto, considerando apenas compras com status `'Confirmada'`. Inclua usuários que nunca compraram (mostrando 0 compras e R$ 0,00). Ordene pelo valor total gasto de forma decrescente.

---

**Critério de avaliação:** cada consulta correta vale 0,5 ponto. *(1,5 pontos)*

---

### SEÇÃO 8 — Consultas com Relacionamentos `(1,0 ponto)`

**Consulta R1 — Histórico de compras detalhado**
*(Dica: use INNER JOIN entre pelo menos 3 tabelas)*

O suporte precisa consultar o histórico completo de compras da plataforma. O relatório deve mostrar o nome do usuário, o título do jogo comprado, o preço pago, a data da compra e o status da compra, ordenado pela data da compra da mais recente para a mais antiga.

---

**Consulta R2 — Jogos nunca avaliados**
*(Dica: use LEFT JOIN e IS NULL)*

O time de qualidade quer identificar quais jogos ativos nunca receberam nenhuma avaliação, para criar uma campanha incentivando os usuários a avaliarem. Retorne o título do jogo, o nome da desenvolvedora e a data de lançamento.

---

**Consulta R3 — Avaliações completas com dados do usuário e do jogo**
*(Dica: use INNER JOIN entre pelo menos 3 tabelas, WHERE, ORDER BY)*

O blog da NexusStore quer publicar as avaliações mais recentes. Retorne o nome do usuário que avaliou, o título do jogo avaliado, a nota dada, o comentário escrito e a data da avaliação, mostrando apenas avaliações de jogos e usuários ativos (não excluídos logicamente), ordenadas pela data da avaliação da mais recente para a mais antiga.

---

**Critério de avaliação:** cada consulta correta vale 0,33 ponto. *(1,0 ponto)*

---

## 📊 Tabela de Pontuação

| Seção | Descrição | Pontos |
|---|---|---|
| 1 | Criação do Banco de Dados | 1,5 |
| 2 | Criação das Tabelas | 2,5 |
| 3 | Inserção de Dados | 1,5 |
| 4 | Atualização de Registros | 0,5 |
| 5 | Exclusão Física (obrigatório) | 0,5 |
| 6 | Consultas Simples | 1,0 |
| 7 | Consultas com Agregação | 1,5 |
| 8 | Consultas com Relacionamentos | 1,0 |
| **Total** | | **10,0** |
| 🎁 Bônus | Exclusão Lógica (Seção 5) | +0,5 |
| 🎁 Bônus | Entrega do MER | desempate |

---

## ⚠️ Critérios de Desconto Automático

| Situação | Desconto |
|---|---|
| Arquivo com nome fora do padrão solicitado | −0,2 ponto |
| Comandos SQL em minúsculas (violação da regra de escrita) | −0,1 por ocorrência |
| Nomes de tabelas no singular | −0,2 por tabela |
| Ausência de comentários identificando as seções | −0,5 ponto |
| Arquivo que não executa sem erros do início ao fim | −1,0 ponto |
| Plágio ou entrega idêntica entre alunos | Nota zero para todos os envolvidos |

---

## 💡 Dicas Finais

Antes de entregar, execute o arquivo completo do zero em um banco de dados limpo e verifique se ele roda sem erros. Uma boa estratégia é: abra o MySQL Workbench (ou DBeaver), crie uma conexão, abra seu arquivo `.sql` e execute tudo de uma só vez com Ctrl+Shift+Enter. Se aparecer algum erro, corrija antes de enviar.

Lembre-se: a seção de inserção de dados define a qualidade das seções de consultas. Insira dados suficientemente variados para que suas consultas retornem resultados reais e relevantes — consultas que retornam zero linhas por falta de dados serão penalizadas como se estivessem incorretas.

Dúvidas até 24h antes da entrega podem ser enviadas por e-mail para ronan.zenatti@cps.sp.gov.br com o assunto `[IBD951] Dúvida Avaliação Proficiência`.

---

**Boa avaliação!**

---

*Fatec Jahu · Centro Paula Souza · Governo do Estado de São Paulo*  
*IBD951 — Banco de Dados e Aplicações · Prof. Ronan Adriel Zenatti · 1º Semestre / 2026*
