# QuickDelivery – Backend (Sprint 1)

**Projeto Integrador – PUC Minas – Engenharia de Software**
Aluno: Joaquim Vilela

## Resumo do Projeto

O **QuickDelivery** é uma plataforma de delivery que conecta clientes a prestadores de serviço (entregadores) por meio de uma arquitetura distribuída orientada a eventos. O cliente solicita uma entrega informando origem, destino e descrição do item; o prestador recebe a demanda, aceita o serviço e atualiza o status da entrega até a conclusão. Esta Sprint 1 entrega o **backend REST** do sistema, implementado em **Node.js + Express + TypeScript** com persistência em **PostgreSQL** (via Prisma ORM e Docker), cobrindo o ciclo completo da entrega (`PENDING → ACCEPTED → IN_PROGRESS → DELIVERED`, com `CANCELLED` permitido nos estados intermediários). As sprints seguintes adicionarão Middleware Orientado a Mensagens (RabbitMQ) e os aplicativos móveis Flutter para cliente e prestador.

---

## Passo a Passo para Executar o Projeto

### Pré-requisitos

- [**nvm**](https://github.com/nvm-sh/nvm) instalado (gerenciador de versões do Node).
- **Docker Desktop** instalado e em execução.

### 1. Selecionar a versão do Node

Na raiz do projeto:

```bash
nvm use
```

O arquivo `.nvmrc` define Node 24 (LTS). Se ainda não tiver instalado, rode `nvm install 24` antes.

### 2. Instalar dependências

```bash
npm install
```

### 3. Configurar variáveis de ambiente

```bash
cp .env.example .env
```

O `.env.example` já está preenchido com credenciais que batem com o `docker-compose.yml`. Nenhum ajuste manual é necessário em ambiente local.

### 4. Subir o banco PostgreSQL via Docker

```bash
docker compose up -d
```

Isso inicia o container `quickdelivery-postgres` em `localhost:5432`.

### 5. Aplicar a migration inicial do Prisma

```bash
npx prisma migrate dev --name init
```

Esse comando cria as tabelas `clients`, `providers` e `deliveries` no banco e gera o Prisma Client.

### 6. Iniciar o servidor

```bash
npm run dev
```

A API estará disponível em `http://localhost:3000`. Para verificar:

```bash
curl http://localhost:3000/health
# {"status":"ok"}
```

### 7. Testar os endpoints

A coleção Postman está em `postman/QuickDelivery.postman_collection.json`. Importe-a no Postman ou Insomnia; ela executa o caminho feliz em sequência (criar cliente → criar prestador → criar entrega → aceitar → em andamento → entregue), salvando os IDs em variáveis de coleção.

---

## Endpoints

| Método | Rota | Descrição |
|---|---|---|
| `GET` | `/health` | Healthcheck. |
| `POST` | `/clients` | Cria um cliente. |
| `GET` | `/clients` | Lista clientes. |
| `POST` | `/providers` | Cria um prestador (entregador). |
| `GET` | `/providers` | Lista prestadores. |
| `POST` | `/deliveries` | Cliente cria uma solicitação de entrega. |
| `GET` | `/deliveries` | Lista entregas. Aceita `?status=` e `?providerId=`. |
| `GET` | `/deliveries/:id` | Detalhe de uma entrega. |
| `PATCH` | `/deliveries/:id/status` | Atualiza o status (com validação de transição). |

Ao mover uma entrega para `ACCEPTED`, o campo `providerId` é obrigatório no body.

---

## Scripts Disponíveis

| Script | Descrição |
|---|---|
| `npm run dev` | Sobe o servidor com hot reload (ts-node-dev). |
| `npm run build` | Compila TypeScript para `dist/`. |
| `npm start` | Executa a versão compilada. |
| `npm run prisma:migrate` | Cria/aplica novas migrations. |
| `npm run prisma:studio` | Abre o Prisma Studio (GUI do banco). |

---

## Estrutura do Projeto

```
delivery-back/
├── docker-compose.yml           # PostgreSQL
├── prisma/
│   ├── schema.prisma            # Modelo (Client, Provider, Delivery)
│   └── migrations/              # Histórico de migrations
├── postman/
│   └── QuickDelivery.postman_collection.json
└── src/
    ├── server.ts                # Bootstrap
    ├── app.ts                   # Configuração do Express
    ├── routes/                  # Express Routers
    ├── controllers/             # Handlers HTTP (req/res)
    ├── services/                # Regras de negócio
    ├── repositories/            # Acesso a dados via Prisma
    ├── infrastructure/prisma.ts # PrismaClient singleton
    ├── middlewares/             # Tratamento de erros
    └── types/                   # Enum DeliveryStatus + transições válidas
```
