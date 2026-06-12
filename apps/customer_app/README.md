# QuickDelivery Customer App

Flutter app do cliente para a Sprint 3.

## Como gerar e executar

Esta pasta contém o código-fonte Flutter. Em uma máquina com Flutter instalado, gere os arquivos de plataforma e rode:

```bash
cd apps/customer_app
flutter create .
flutter pub get
flutter run --dart-define=QUICKDELIVERY_API_URL=http://10.0.2.2:3000
```

Use `http://10.0.2.2:3000` no emulador Android. Para dispositivo físico, use o IP da máquina na rede local:

```bash
flutter run --dart-define=QUICKDELIVERY_API_URL=http://SEU_IP:3000
```

## Fluxo

- Login como cliente.
- Lista de entregas do cliente autenticado.
- Criar nova entrega.
- Detalhar entrega.
- Cancelar entrega em `PENDING` ou `ACCEPTED`.
- Perfil e logout.

As telas de lista e detalhe fazem polling automático a cada 30 segundos para refletir mudanças feitas no backend.
