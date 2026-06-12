# QuickDelivery - App Cliente

## 1. Objetivo

O app cliente implementa a entrega da Sprint 3. Ele permite que um usuário com papel `CUSTOMER` faça login, consulte suas entregas, crie novas solicitações, acompanhe detalhes e cancele entregas quando a máquina de estados permitir.

## 2. Telas

### Login

A tela de login consome `POST /auth/login`, valida que o usuário autenticado possui papel `CUSTOMER` e mantém o token em memória durante a sessão.

### Minhas Entregas

A tela principal consome `GET /deliveries` e lista apenas as entregas do cliente autenticado, conforme a autorização do backend. Cada card mostra descrição, origem, destino, status e data de atualização. A tela possui ação manual de atualizar, acesso ao perfil e botão para criar nova entrega.

### Nova Entrega

A tela de criação envia `POST /deliveries` com `customerId`, `pickupAddress`, `dropoffAddress` e `description`. Após criação bem-sucedida, o app abre o detalhe da entrega criada.

### Detalhes da Entrega

A tela de detalhe consome `GET /deliveries/:id`, exibe status, origem, destino, descrição, entregador atribuído e datas. O cliente pode cancelar a entrega quando o status está em `PENDING` ou `ACCEPTED`, usando `PATCH /deliveries/:id/status` com `{ "status": "CANCELLED" }`.

### Perfil

A tela de perfil exibe dados do cliente autenticado e oferece logout com confirmação.

## 3. Atualização Assíncrona

A atualização assíncrona foi implementada por polling, alternativa permitida no enunciado da Sprint 3. A lista de entregas e a tela de detalhe consultam o backend automaticamente a cada 30 segundos, permitindo que mudanças feitas pelo entregador sejam refletidas sem ação manual do cliente.

## 4. Arquitetura

```text
apps/customer_app/lib/
├── config/          # URL base da API
├── controllers/     # estado da sessão e entregas
├── models/          # User, AuthSession e Delivery
├── screens/         # Login, lista, detalhe, criação e perfil
├── services/        # cliente HTTP e serviços REST
├── theme/           # tema visual do app
├── utils/           # helpers de formatação
└── widgets/         # componentes reutilizáveis
```

Fluxo principal:

```text
Login -> Minhas Entregas -> Nova Entrega -> Detalhes da Entrega
                         -> Detalhes da Entrega
                         -> Perfil -> Logout
```

## 5. Execução

Em uma máquina com Flutter instalado:

```bash
cd apps/customer_app
flutter create .
flutter pub get
flutter run --dart-define=QUICKDELIVERY_API_URL=http://10.0.2.2:3000
```

Para dispositivo físico, substitua `10.0.2.2` pelo IP da máquina que executa o backend.
