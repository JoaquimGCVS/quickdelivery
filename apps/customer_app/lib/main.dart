import 'package:flutter/material.dart';

import 'config/api_config.dart';
import 'controllers/app_controller.dart';
import 'screens/login_screen.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/deliveries_service.dart';
import 'theme/app_theme.dart';
import 'widgets/app_shell.dart';

void main() {
  final apiClient = ApiClient(baseUrl: ApiConfig.baseUrl);
  final controller = AppController(
    authService: AuthService(apiClient),
    deliveriesService: DeliveriesService(apiClient),
  );

  runApp(QuickDeliveryCustomerApp(controller: controller));
}

class QuickDeliveryCustomerApp extends StatelessWidget {
  const QuickDeliveryCustomerApp({
    super.key,
    required this.controller,
  });

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickDelivery Cliente',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: AppShell(
        child: LoginScreen(controller: controller),
      ),
    );
  }
}
