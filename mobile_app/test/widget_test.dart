import 'package:flutter_test/flutter_test.dart';
import 'package:quickdelivery_app/controllers/app_controller.dart';
import 'package:quickdelivery_app/main.dart';
import 'package:quickdelivery_app/services/api_client.dart';
import 'package:quickdelivery_app/services/auth_service.dart';
import 'package:quickdelivery_app/services/deliveries_service.dart';

void main() {
  testWidgets('shows shared login screen', (tester) async {
    final apiClient = ApiClient(baseUrl: 'http://localhost:3000');
    final controller = AppController(
      authService: AuthService(apiClient),
      deliveriesService: DeliveriesService(apiClient),
    );

    await tester.pumpWidget(QuickDeliveryApp(controller: controller));

    expect(find.text('QuickDelivery'), findsOneWidget);
    expect(find.text('Acesse como cliente ou entregador'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
