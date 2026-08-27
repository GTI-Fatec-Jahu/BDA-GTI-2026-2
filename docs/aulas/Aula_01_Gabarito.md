<!--
GABARITO — não faz parte do fluxo principal da aula e fica fora do `nav` do
mkdocs.yml de propósito. É acessível só pelo link no final de Aula_01_Introducao_BD.md.
-->

# Gabarito — Aula 01 — Introdução a Banco de Dados

**Disciplina:** Banco de Dados e Aplicações <br>
**Professor:** Ronan Adriel Zenatti · ronan.zenatti@cps.sp.gov.br  <br>
**Fatec Jahu — 2º Semestre/2026**

> ⚠️ Este gabarito é para conferência **depois** de você tentar resolver os
> Checkpoints por conta própria na [Aula 01](Aula_01_Introducao_BD.md). Resolver
> antes de tentar reduz o benefício de treinar a recuperação ativa do conteúdo.

---

## Checkpoint 1 — Dado, Informação e Conhecimento: app de corrida {: #checkpoint-1 }

**Resposta:**

A sequência bruta de coordenadas de GPS é **dado**: são fatos isolados (posição a
cada segundo), sem nenhuma interpretação — sozinhas, essas coordenadas não dizem
nada útil ao usuário.

A distância total percorrida no treino é **informação**: o app pegou o dado bruto
(coordenadas) e o contextualizou em algo interpretável e útil — "5,2 km" já responde
a uma pergunta concreta do usuário ("quanto eu corri?").

O padrão identificado ao longo dos meses (corridas acima de 8 km melhoram o ritmo
das seguintes) é **conhecimento**: surgiu do acúmulo e da relação entre várias
informações ao longo do tempo, revelando uma tendência que nenhum treino isolado
mostraria sozinho — e é isso que permite ao app fazer uma recomendação.

---

## Checkpoint 2 — Sistemas de Arquivos: rede de clínicas populares {: #checkpoint-2 }

**Resposta:**

| Problema no cenário | Problema da tabela | Como o SGBD resolveria |
|---|---|---|
| Dados do mesmo paciente digitados de novo em cada planilha | Redundância de dados | Dado armazenado uma única vez, compartilhado entre as três unidades |
| Pequenas diferenças de grafia entre as cópias do mesmo paciente | Inconsistência | Restrições de integridade garantem que exista uma versão única e válida |
| Duas recepcionistas editando a mesma planilha ao mesmo tempo, com perda de dados | Problemas de concorrência | Controle de transações e bloqueios evita que uma edição sobrescreva a outra sem controle |

Também vale observar que o cenário sugere **dificuldade de acesso**: procurar o
histórico de um paciente que já passou por mais de uma unidade exige abrir e cruzar
várias planilhas manualmente — algo que uma consulta SQL padronizada resolveria em
um único comando.

---

## Checkpoint 3 — Arquitetura ANSI/SPARC: sistema de matrícula acadêmica {: #checkpoint-3 }

**Resposta:**

**(a) Nível Externo.** O aluno enxerga apenas uma visão personalizada dos dados —
as disciplinas do seu próprio curso — não a estrutura completa do banco. Isso é
exatamente a definição de nível externo: uma janela recortada para um tipo de
usuário.

**(b) Nível Conceitual.** Adicionar uma coluna à estrutura lógica que descreve o
aluno é alterar o **esquema lógico completo** do banco — a mudança se propaga para
todas as visões (nível externo) que dependem dela, mas a alteração em si acontece
no nível conceitual.

**(c) Nível Interno.** Trocar o tipo de disco onde os arquivos físicos são
armazenados é uma mudança de armazenamento físico pura. Graças à independência de
dados entre os três níveis, essa troca não exige reescrever nenhuma consulta SQL —
o nível conceitual (e, por consequência, o externo) nem "percebe" a mudança.

---

## Checkpoint 4 — Componentes do SGBD: consulta em um app de delivery {: #checkpoint-4 }

**Resposta:**

**(1) Processador de consultas** — interpreta o `SELECT` gerado pela busca e decide
o plano de execução mais eficiente.

**(2) Gerenciador de armazenamento** — controla a leitura física dos dados dos
restaurantes gravados em disco.

**(3) Gerenciador de transações** — garante atomicidade e controle de concorrência
entre a busca de um usuário e a confirmação de pedido de outro, evitando
inconsistência.

**(4) Gerenciador de buffer** — mantém em memória os dados das pizzarias mais
pesquisadas, evitando reler o disco a cada busca repetida.

---

⬅️ [Voltar à Aula 01 — Introdução a Banco de Dados](./Aula_01_Introducao_BD.md)

---

*Fatec Jahu · IBD951 · Prof. Ronan Adriel Zenatti · 2026*
