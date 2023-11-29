# Escopo do Projeto

O projeto tem como objetivo implementar uma arquitetura na AWS usando Terraform, incluindo um Application Load Balancer (ALB), instâncias EC2 com Auto Scaling e um banco de dados RDS.

## Região Escolhida

A AWS oferece uma ampla variedade de regiões para seus serviços, abrangendo desde dimensionamento de EC2s na América do Sul, América do Norte até a Europa, até sistemas de armazenamento de dados. Cada interface pode ser hospedada em uma região específica.

A escolha da região é guiada por requisitos não funcionais do projeto, tais como:

- **Velocidade de Conexão**
- **Velocidade de Processamento**
- **Disponibilidade de Serviços**
- **Custo de Implementação**

Nesta etapa, explicaremos por que escolhemos a zona `us-east` e outras opções para cada serviço implementado neste projeto.

### Velocidade de Conexão

A velocidade de conexão é um requisito não funcional muitas vezes subestimado, mas deve ser decidido com base nas necessidades técnicas do projeto. Para este projeto, onde a aplicação não será usada por clientes finais, a escolha de um servidor com maior latência e menor custo é possível. Em projetos em que a interação do cliente é rápida, como um site de e-commerce, é crucial que o tempo de latência e o tráfego de dados sejam mínimos, exigindo a localização dos servidores próximos ao local de maior demanda.

### Velocidade de Processamento

A velocidade de processamento é um requisito crucial, dependendo do projeto implementado. Para um projeto simples como este, em que as instâncias EC2 são usadas para hospedar e processar uma aplicação CRUD simples em FastAPI, a velocidade de processamento individual não é essencial. É mais importante ter a capacidade de escalar a plataforma de acordo com a demanda.

Considerando esse contexto, escolhemos uma região com alta disponibilidade de opções de processamento, dando destaque à instância [t2.micro](https://aws.amazon.com/ec2/instance-types/t2/), que permite, até certo nível de demanda, a instância gratuita da aplicação.

### Disponibilidade de Serviços

Além da baixa exigência de processamento individual, é crucial considerar as zonas de disponibilidade de cada plataforma. A região `us-east`, localizada na [Virginia do Norte, Estados Unidos](https://aws.amazon.com/about-aws/global-infrastructure/regions_az/), é a região com maior disponibilidade de tipos de instâncias, como evidenciado pelo portal [DZone](https://dzone.com/articles/aws-outages-is-north-virginia-the-least-reliable-a), analisando a quantidade de serviços disponíveis nesta região, que pode chegar a mais de 215.

Ao contrário de regiões como [Europa (Espanha)](https://aws.amazon.com/es/about-aws/global-infrastructure/regions_az/), que não têm disponibilidade de instâncias gratuitas como a [t2.micro](https://aws.amazon.com/ec2/instance-types/t2/), a `us-east` possui a maior disponibilidade de máquinas. No entanto, como consequência desse aumento de disponibilidade, há um aumento no tráfego e uso dos data centers, tornando-os mais lentos e com maior possibilidade de *outages*, de acordo com a DZone em 2022, que registrou 22 *outages*, um número significativamente maior do que em outras regiões.

### Custo de Implementação

Juntamente com o maior número de serviços, esta região apresenta o menor custo, conforme a [Concurrency Labs](https://www.concurrencylabs.com/blog/choose-your-aws-region-wisely/), estando empatada com [Ohio](https://aws.amazon.com/about-aws/global-infrastructure/regions_az/) e [Oregon](https://aws.amazon.com/about-aws/global-infrastructure/regions_az/). A região com maior custo é [São Paulo, Brasil](https://aws.amazon.com/pt-br/about-aws/global-infrastructure/regions_az/).

Vários fatores podem causar essa variação de custos, como tráfego nos data centers, uso pelo usuário e investimentos da AWS, que mantém a estrutura cada vez mais eficiente, de acordo com o [Data Center Frontier](https://www.datacenterfrontier.com/cloud/article/11427911/aws-has-spent-35-billion-on-its-northern-virginia-data-centers).

### Escolha

Com base nesses quatro requisitos não funcionais, escolhemos a região `us-east` porque o projeto não exige velocidade de conexão ou processamento rápido. A região também oferece alta disponibilidade de serviços a um custo de implementação mais baixo.

### Outras Possíveis Regiões

Outra região que poderia ser usada de forma híbrida neste projeto é a [sa-east, São Paulo, Brasil](https://aws.amazon.com/pt-br/about-aws/global-infrastructure/regions_az/), que poderia hospedar o [load balancer](https://aws.amazon.com/pt-br/elasticloadbalancing/) e instâncias [ec2](https://aws.amazon.com/pt-br/ec2/). No entanto, isso aumentaria os custos do projeto, mas resultaria em uma menor latência de conexão.

# Documentação Técnica

O código Terraform fornecido neste repositório representa uma implementação abrangente de infraestrutura na AWS, seguindo as melhores práticas para garantir segurança, escalabilidade e resiliência. Abaixo estão os detalhes dos principais elementos implementados e as decisões técnicas tomadas.

## Infraestrutura como Código (IaC) com Terraform

### VPC (Virtual Private Cloud)

Foi implementada uma [Virtual Private Cloud (VPC)](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html) para isolar a infraestrutura e fornecer uma rede privada na AWS. A VPC possui CIDR `10.0.0.0/16`.

- **Subnets:**
  - **Subnet Pública 1 (`10.0.1.0/24`):** Associada à Zona de Disponibilidade `us-east-1a`.
  - **Subnet Pública 2 (`10.0.3.0/24`):** Associada à Zona de Disponibilidade `us-east-1b`.
  - **Subnet Privada 1 (`10.0.2.0/24`):** Associada à Zona de Disponibilidade `us-east-1a`.
  - **Subnet Privada 2 (`10.0.4.0/24`):** Associada à Zona de Disponibilidade `us-east-1b`.

### Security Groups (Grupos de Segurança)

- **EC2 Security Group (`ec2_sg`):**
  - Permite tráfego nas portas `80` (HTTP) e `22` (SSH) de qualquer lugar.

- **ALB Security Group (`lb_sg`):**
  - Permite tráfego nas portas `80` (HTTP) e `443` (HTTPS) de qualquer lugar.

- **RDS Security Group (`rds_sg`):**
  - Permite que a instância RDS receba tráfego na porta `3306` apenas do Security Group associado à instância EC2.

### IAM (Identity and Access Management)

- **IAM Role (`cloud_iam_role`):**
  - Permite que as instâncias EC2 assumam essa role para acessar outros serviços AWS.

- **IAM Policy (`cloud_ec2_policy`):**
  - Concede permissões para interagir com serviços como CloudWatch e RDS.

- **IAM Instance Profile (`cloud_instance_profile`):**
  - Associa a role IAM às instâncias EC2.

### RDS (Relational Database Service)

- **Instância RDS (`rds_instance`):**
  - Utiliza o mecanismo MySQL (`engine = "mysql"`) com a versão `8.0.31`.
  - Configurado para armazenar dados em `gp2` com uma capacidade de `20 GB`.
  - Backup automático ativado com retenção de `7 dias`.
  - Janela de manutenção configurada para às segundas-feiras, entre `01:00` e `03:00 UTC`.
  - Multi-AZ desativado para este exemplo, mas pode ser configurado conforme necessário.

### Application Load Balancer (ALB)

- **ALB (`application_lb`):**
  - Cria um Application Load Balancer para distribuir o tráfego entre as instâncias EC2.
  - Configurado para operar externamente (`internal = false`) e utilizar IPv4.
  - Associado aos Security Groups adequados.

- **Listener (`listener`):**
  - Configura um listener na porta `80` para encaminhar o tráfego para o Target Group.

### Auto Scaling Group (ASG)

- **Auto Scaling Group (`asg`):**
  - Mantém entre `5` e `20` instâncias EC2, escalando com base em políticas definidas.
  - Utiliza um Launch Template que especifica a AMI, tipo de instância, chave SSH e outros detalhes de configuração.

### CloudWatch Alarms e Políticas de Escala

- **CloudWatch Alarms (`asg_metric_alarm_up` e `asg_metric_alarm_down`):**
  - Monitoram a utilização da CPU e ajustam automaticamente o número de instâncias no ASG conforme necessário.

- **Auto Scaling Policies (`asg_policy_up` e `asg_policy_down`):**
  - Definem políticas de escala para aumentar ou reduzir o número de instâncias com base nos alarmes do CloudWatch.

### Secrets Manager e Variáveis Locais

- **Secrets Manager (`cloud_credentials` e `cloud_secrets`):**
  - Utiliza o AWS Secrets Manager para armazenar credenciais sensíveis, como nome do banco de dados, usuário e senha.

- **Variáveis Locais (`rds_credentials`):**
  - Armazena localmente as credenciais recuperadas do Secrets Manager para uso em outros recursos.

## Considerações sobre Portas e Conexões

- **EC2 Instances:**
  - As instâncias EC2 permitem tráfego nas port

as `80` (HTTP) e `22` (SSH) do mundo.

- **ALB:**
  - O Application Load Balancer permite tráfego nas portas `80` (HTTP) e `443` (HTTPS) do mundo.

- **RDS:**
  - A instância RDS aceita tráfego na porta `3306` apenas das instâncias EC2 associadas ao Security Group correspondente.

Esta infraestrutura foi projetada para ser altamente disponível, escalável e segura, atendendo aos requisitos específicos do projeto. Certifique-se de revisar as configurações e personalizá-las conforme necessário antes de implantar em um ambiente de produção.

# Analise de Custos
Descrição dos serviços contratados na AWS

Amazon EC2

O Amazon EC2 fornece capacidade de computação flexível e escalável na nuvem. As instâncias do EC2 são servidores virtuais que podem ser personalizados para atender às suas necessidades específicas.

Neste caso, o Amazon EC2 está sendo usado para hospedar uma aplicação web. A configuração atual é de uma instância t2.micro, que é uma instância compartilhada de baixo custo. A instância está sendo dimensionada automaticamente para atender à demanda, com uma linha de base de 1 instância e um pico de 5 instâncias.

Parâmetros:

Região: US East (N. Virginia)
Instância: t2.micro
Dimensionamento automático: Sim
Linha de base: 1 instância
Pico: 5 instâncias
Amazon RDS for MySQL

O Amazon RDS for MySQL é um serviço de banco de dados relacional na nuvem. Ele oferece uma variedade de opções de configuração para atender às suas necessidades específicas.

Neste caso, o Amazon RDS for MySQL está sendo usado para armazenar os dados da aplicação web. A configuração atual é de uma instância db.t2.micro, que é uma instância de baixo custo. A instância está usando um armazenamento de 20 GB e está configurada para replicação multi-AZ.

Parâmetros:

Região: US East (N. Virginia)
Instância: db.t2.micro
Armazenamento: 20 GB
Replicação: Multi-AZ
Elastic Load Balancing

O Elastic Load Balancing distribui o tráfego de entrada entre várias instâncias do EC2. Isso ajuda a garantir que sua aplicação web possa lidar com um aumento no tráfego.

Neste caso, o Elastic Load Balancing está sendo usado para distribuir o tráfego de entrada para as instâncias do EC2 que estão hospedando a aplicação web.

Parâmetros:

Região: US East (N. Virginia)
Número de Load Balancers: 1
Amazon Simple Storage Service (S3)

O Amazon S3 é um serviço de armazenamento de objetos na nuvem. Ele é usado para armazenar dados de forma durável e escalável.

Neste caso, o Amazon S3 está sendo usado para armazenar arquivos estáticos, como imagens e CSS. A configuração atual é de 1 GB de armazenamento.

Parâmetros:

Região: US East (N. Virginia)
Armazenamento: 1 GB
Amazon API Gateway

O Amazon API Gateway é um serviço de API gerenciado que permite criar, publicar e gerenciar APIs.

Neste caso, o Amazon API Gateway está sendo usado para expor uma API REST para a aplicação web. A configuração atual é de 100 solicitações por mês.

Parâmetros:

Região: US East (N. Virginia)
Unidades de solicitação da API REST: 100
Amazon Virtual Private Cloud (VPC)

Uma VPC é uma rede virtual privada na nuvem. Ela permite que você crie uma rede isolada para suas instâncias do EC2.

Neste caso, a VPC está sendo usada para separar a aplicação web da rede pública. A configuração atual é de 5 endereços IP ativos.

Parâmetros:

Região: US East (N. Virginia)
Tráfego de entrada: Todas as outras regiões
Tráfego de saída: Internet
Tráfego intrarregional: (1 GB por mês)
Custo de transferência de dados: 0,11
Número de endereços IP ativos: 5

O **Custo Total** foi de `USD 63,04/mês`. A analise detalhada está disponível neste [link](https://github.com/AntonioAEMartins/aws-terraform/blob/main/Estimativa-Precos.pdf)
