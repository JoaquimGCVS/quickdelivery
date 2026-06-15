# QuickDelivery Mobile App

Flutter app unificado do QuickDelivery para cliente e entregador.

## Como gerar e executar

Esta pasta contém o código-fonte Flutter. Em uma máquina com Flutter instalado, gere os arquivos de plataforma uma vez se eles ainda não existirem:

```bash
cd mobile_app
flutter create .
flutter pub get
```

Com a API rodando em `http://localhost:3000`, execute no emulador Android:

```bash
flutter emulators --launch Pixel_7
flutter run --dart-define=QUICKDELIVERY_API_URL=http://10.0.2.2:3000
```

Use `http://10.0.2.2:3000` no emulador Android. Para dispositivo físico, use o IP da máquina na rede local:

```bash
flutter run --dart-define=QUICKDELIVERY_API_URL=http://SEU_IP:3000
```

Para desligar o emulador pelo terminal:

```bash
/home/joaquimvilela/Android/Sdk/platform-tools/adb -s emulator-5554 emu kill
```

## Fluxo

- Login como cliente ou entregador.
- Lista de entregas do cliente autenticado.
- Criar nova entrega.
- Detalhar entrega.
- Cancelar entrega em `PENDING` ou `ACCEPTED`.
- Perfil e logout.
- Tela inicial simples para usuário `DELIVERYMAN`, preparando o fluxo da Sprint 4.

As telas de lista e detalhe fazem polling automático a cada 15 segundos para refletir mudanças feitas no backend.
