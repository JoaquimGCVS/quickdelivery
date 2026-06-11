# QuickDelivery - Esquema de Tabelas

## 1. Visão Geral

O banco possui duas tabelas principais: `users` e `deliveries`. A tabela `users` concentra os dados de autenticação e identificação dos dois perfis do sistema. A tabela `deliveries` registra as solicitações de entrega e referencia `users` duas vezes: uma para o cliente solicitante e outra, opcional, para o entregador responsável.

Relacionamentos principais:

- Um usuário com papel `CUSTOMER` pode solicitar várias entregas.
- Um usuário com papel `DELIVERYMAN` pode atender várias entregas.
- Toda entrega possui um cliente obrigatório.
- Uma entrega pendente ainda não possui entregador associado.

## 2. Entidades

`User` representa qualquer usuário autenticável do sistema. O campo `role` separa os dois perfis do domínio:

- `CUSTOMER`: cliente que cria e acompanha suas próprias entregas.
- `DELIVERYMAN`: entregador que visualiza entregas pendentes, aceita entregas e atualiza o status das entregas atribuídas a ele.

`Delivery` representa uma solicitação de entrega. Toda entrega possui um cliente obrigatório (`customer_id`) e pode possuir um entregador associado (`deliveryman_id`) depois do aceite. Enquanto a entrega está `PENDING`, `deliveryman_id` permanece nulo.

## 3. Máquina de Estados de `Delivery.status`

O atributo status segue uma máquina de estados validada na camada de serviço do backend:

```text
PENDING ----> ACCEPTED ----> IN_PROGRESS ----> DELIVERED
   |              |
   v              v
CANCELLED     CANCELLED
```

Transições permitidas:

- `PENDING -> ACCEPTED`
- `PENDING -> CANCELLED`
- `ACCEPTED -> IN_PROGRESS`
- `ACCEPTED -> CANCELLED`

<div style="page-break-after: always;"></div>

- `IN_PROGRESS -> DELIVERED`

Estados finais:

- `DELIVERED`
- `CANCELLED`

Tentativas de transição inválida, como `DELIVERED -> ACCEPTED`, são rejeitadas pelo backend com HTTP `400`. O cancelamento é bloqueado quando a entrega já está em andamento.

## 4. Schema Físico

O schema completo está versionado em `prisma/schema.prisma` e materializado no PostgreSQL pelas migrations em `prisma/migrations`.

Tabelas físicas:

- `users` (`id`, `email`, `password`, `name`, `phone`, `role`, `created_at`, `updated_at`)
- `deliveries` (`id`, `customer_id`, `deliveryman_id`, `pickup_address`, `dropoff_address`, `description`, `status`, `created_at`, `updated_at`)

Tipos enumerados nativos no PostgreSQL:

- `UserRole`: `CUSTOMER`, `DELIVERYMAN`
- `DeliveryStatus`: `PENDING`, `ACCEPTED`, `IN_PROGRESS`, `DELIVERED`, `CANCELLED`

Relacionamentos:

- `deliveries.customer_id` referencia `users.id`.
- `deliveries.deliveryman_id` referencia `users.id` e permite `NULL`.
