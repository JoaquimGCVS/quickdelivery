# QuickDelivery - Backend

**Projeto Integrador - PUC Minas - Engenharia de Software**

Aluno: Joaquim Vilela

## Resumo do Projeto

O **QuickDelivery** é uma plataforma de delivery que conecta clientes a entregadores. O cliente solicita uma entrega informando origem, destino e descrição do item; o entregador visualiza demandas pendentes, aceita uma entrega e atualiza seu status até a conclusão.

O backend é uma API REST em **Node.js + Express + TypeScript**, com **PostgreSQL** via Docker e **Prisma ORM**. O sistema possui autenticação por token, usuários com papel (`CUSTOMER` ou `DELIVERYMAN`), autorização por perfil, auditoria básica e gerenciamento do ciclo de vida das entregas.

---

## Como Executar

### Pré-requisitos

- `nvm` instalado.
- Docker Desktop instalado e em execução.

### 1. Selecionar a versão do Node

```bash
nvm use
```

O arquivo `.nvmrc` define Node 24. Se necessário, rode `nvm install 24`.

### 2. Instalar dependências

```bash
npm install
```

### 3. Configurar ambiente

```bash
cp .env.example .env
```

O `.env.example` usa as mesmas credenciais do `docker-compose.yml`.

### 4. Subir o PostgreSQL

```bash
docker compose up -d
```

### 5. Aplicar as migrations

```bash
npx prisma migrate dev
```

As migrations criam as tabelas `users`, `deliveries` e `audit_logs`, além dos enums `UserRole`, `DeliveryStatus` e `AuditAction`.

### 6. Popular dados de teste

```bash
npm run seed
```

A coleção Postman usa estes usuários seedados:

| Perfil | Email | Senha |
|---|---|---|
| Cliente | `customer1@example.com` | `password123` |
| Cliente | `customer2@example.com` | `password123` |
| Entregador | `deliveryman1@example.com` | `password123` |
| Entregador | `deliveryman2@example.com` | `password123` |

### 7. Iniciar o servidor

```bash
npm run dev
```

A API estará disponível em `http://localhost:3000`.

```bash
curl http://localhost:3000/health
# {"status":"ok"}
```

### 8. Testar no Postman

Importe `postman/QuickDelivery.postman_collection.json` e execute as requisições em ordem. O fluxo principal é: login do cliente -> login do entregador -> criar entrega -> aceitar -> marcar em andamento -> marcar como entregue.

---

## Endpoints

| Método | Rota | Autenticação | Descrição |
|---|---|---|---|
| `GET` | `/health` | Não | Healthcheck. |
| `POST` | `/auth/signup` | Não | Cria usuário cliente ou entregador. |
| `POST` | `/auth/login` | Não | Autentica usuário e retorna token. |
| `GET` | `/auth/me` | Sim | Retorna o usuário autenticado. |
| `GET` | `/customers` | Não | Lista usuários com papel `CUSTOMER`. |
| `GET` | `/customers/:id` | Não | Detalha cliente sem expor senha. |
| `DELETE` | `/customers/:id` | Sim, cliente dono | Remove a própria conta de cliente. |
| `GET` | `/deliverymen` | Não | Lista usuários com papel `DELIVERYMAN`. |
| `GET` | `/deliverymen/:id` | Não | Detalha entregador sem expor senha. |
| `POST` | `/deliveries` | Sim | Cliente cria uma entrega para si mesmo. |
| `GET` | `/deliveries` | Sim | Lista entregas conforme perfil autenticado. Aceita `?status=`. |
| `GET` | `/deliveries/:id` | Sim | Detalha entrega respeitando autorização por perfil. |
| `PATCH` | `/deliveries/:id/status` | Sim | Atualiza status com validação de transição. |

Ao mover uma entrega para `ACCEPTED`, o body deve enviar `deliverymanId`. Um entregador só pode aceitar entregas para si mesmo. Clientes só conseguem criar, listar e alterar entregas próprias.

---

## Scripts Disponíveis

| Script | Descrição |
|---|---|
| `npm run dev` | Sobe o servidor com hot reload. |
| `npm run build` | Compila TypeScript para `dist/`. |
| `npm start` | Executa a versão compilada. |
| `npm run prisma:migrate` | Cria/aplica migrations com Prisma. |
| `npm run prisma:generate` | Gera o Prisma Client. |
| `npm run prisma:studio` | Abre o Prisma Studio. |
| `npm run seed` | Popula o banco com usuários e entregas de teste. |

---

## Estrutura do Projeto

```text
delivery-back/
├── docker-compose.yml
├── prisma/
│   ├── schema.prisma            # Modelo User, Delivery e AuditLog
│   └── migrations/
├── postman/
│   └── QuickDelivery.postman_collection.json
└── src/
    ├── server.ts
    ├── app.ts
    ├── routes/
    ├── controllers/
    ├── services/
    ├── repositories/
    ├── infrastructure/prisma.ts
    ├── middlewares/
    └── types/
```
