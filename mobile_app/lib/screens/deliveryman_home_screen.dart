import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/confirm_dialog.dart';
import 'login_screen.dart';

class DeliverymanHomeScreen extends StatelessWidget {
  const DeliverymanHomeScreen({super.key, required this.controller});

  final AppController controller;

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Sair da conta?',
      message: 'Você precisará fazer login novamente para continuar.',
      confirmLabel: 'Sair',
    );
    if (!confirmed || !context.mounted) return;

    controller.logout();
    await Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => AppShell(
          child: LoginScreen(controller: controller),
        ),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = controller.session!.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Área do entregador'),
        actions: [
          IconButton(
            tooltip: 'Sair',
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.delivery_dining,
                        color: AppColors.primary,
                        size: 36,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Logado como entregador',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.foreground,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user.name,
                        style: const TextStyle(
                          color: AppColors.foreground,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style:
                            const TextStyle(color: AppColors.mutedForeground),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'O fluxo completo do entregador será implementado na Sprint 4.',
                style: TextStyle(
                  color: AppColors.mutedForeground,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
