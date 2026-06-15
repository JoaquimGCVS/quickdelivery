# QuickDelivery - Backend

**Projeto Integrador - PUC Minas - Engenharia de Software**

Aluno: Joaquim Vilela

## Resumo do Projeto

O **QuickDelivery** é uma plataforma de delivery que conecta clientes a entregadores. O cliente solicita uma entrega informando origem, destino e descrição do item; o entregador visualiza demandas pendentes, aceita uma entrega e atualiza seu status até a conclusão.

O backend é uma API REST em **Node.js + Express + TypeScript**, com **PostgreSQL** via Docker, **Prisma ORM** e **RabbitMQ** para eventos assíncronos. O sistema possui autenticação por token, usuários com papel (`CUSTOMER` ou `DELIVERYMAN`), autorização por perfil e gerenciamento do ciclo de vida das entregas.

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

### 4. Subir o PostgreSQL e RabbitMQ

```bash
docker compose up -d
```

### 5. Aplicar as migrations

```bash
npx prisma migrate dev
```

As migrations criam as tabelas `users` e `deliveries`, além dos enums `UserRole` e `DeliveryStatus`.

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

Para acompanhar os eventos de entrega publicados no RabbitMQ, rode em outro terminal:

```bash
npm run consumer:deliveries
```

Para parar a API, use `Ctrl+C` no terminal em que `npm run dev` está rodando. Para parar PostgreSQL e RabbitMQ:

```bash
docker compose down
```

### 8. Testar no Postman

Importe `postman/QuickDelivery.postman_collection.json` e execute as requisições em ordem. O fluxo principal é: login do cliente -> login do entregador -> criar entrega -> aceitar -> marcar em andamento -> marcar como entregue.

### 9. Testar RabbitMQ

Com a API e o consumer rodando, execute no Postman:

1. `Auth / Login Customer 1`
2. `Auth / Login Deliveryman 1`
3. `Deliveries / Create Delivery`
4. `Deliveries / Accept Delivery (Deliveryman)`
5. `Deliveries / Update to IN_PROGRESS`
6. `Deliveries / Update to DELIVERED`

O terminal do consumer deve exibir os eventos:

- `delivery.created`
- `delivery.accepted`
- `delivery.status_changed`

Também é possível acompanhar o RabbitMQ no navegador:

```text
http://localhost:15672
```

Credenciais:

```text
quickdelivery / quickdelivery
```

A exchange usada é `quickdelivery.events` e a fila consumida é `quickdelivery.delivery-events`.

### 10. Vídeo da mensageria

O funcionamento da mensageria com RabbitMQ pode ser visto no vídeo:

- [Arquivo local](assets/video-mensageria.webm)
- [YouTube](https://www.youtube.com/watch?v=EBn9ehJyqDc)

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

Ao mover uma entrega para `ACCEPTED`, o body deve enviar `deliverymanId`. Um entregador só pode aceitar entregas para si mesmo. Cancelamento é permitido em `PENDING` pelo cliente dono da entrega e em `ACCEPTED` pelo cliente dono ou pelo entregador atribuído. Entregas em `IN_PROGRESS`, `DELIVERED` ou `CANCELLED` não podem ser canceladas.

---

## Scripts Disponíveis

| Script | Descrição |
|---|---|
| `npm run dev` | Sobe o servidor com hot reload. |
| `npm run build` | Compila TypeScript para `dist/`. |
| `npm start` | Executa a versão compilada. |
| `npm run consumer:deliveries` | Inicia o consumidor dos eventos de entrega no RabbitMQ. |
| `npm run prisma:migrate` | Cria/aplica migrations com Prisma. |
| `npm run prisma:generate` | Gera o Prisma Client. |
| `npm run prisma:studio` | Abre o Prisma Studio. |
| `npm run seed` | Popula o banco com usuários e entregas de teste. |

---

## App Flutter

O código-fonte do app Flutter unificado está em `mobile_app`. A Sprint 3 entrega o fluxo do cliente: login, listagem das próprias entregas, criação de entrega, tela de detalhes, cancelamento quando permitido e atualização automática por polling a cada 15 segundos. O login de entregador já existe e abre uma tela inicial simples, preparando o fluxo completo do prestador para a Sprint 4.

Em uma máquina com Flutter instalado, se os diretórios de plataforma ainda não existirem, gere-os uma vez:

```bash
cd mobile_app
flutter create .
flutter pub get
```

Para executar no emulador Android:

```bash
flutter emulators --launch Pixel_7
flutter run --dart-define=QUICKDELIVERY_API_URL=http://10.0.2.2:3000
```

Use `http://10.0.2.2:3000` para emulador Android. Em dispositivo físico, use o IP da máquina que está rodando o backend.

Se o app já estiver instalado no emulador e o código não tiver mudado, basta iniciar o emulador e abrir o ícone do QuickDelivery.

Para desligar o emulador pelo terminal:

```bash
/home/joaquimvilela/Android/Sdk/platform-tools/adb -s emulator-5554 emu kill
```

---

## Estrutura do Projeto

```text
quickdelivery/
├── mobile_app/                  # App Flutter unificado
├── docker-compose.yml
├── prisma/
│   ├── schema.prisma            # Modelo User e Delivery
│   └── migrations/
├── postman/
│   └── QuickDelivery.postman_collection.json
└── src/
    ├── server.ts
    ├── app.ts
    ├── consumers/
    ├── events/
    ├── routes/
    ├── controllers/
    ├── services/
    ├── repositories/
    ├── infrastructure/
    ├── middlewares/
    └── types/
```
