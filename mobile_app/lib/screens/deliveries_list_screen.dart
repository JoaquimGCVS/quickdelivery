import 'dart:async';

import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../models/delivery.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatter.dart';
import '../widgets/app_shell.dart';
import '../widgets/empty_state.dart';
import '../widgets/status_badge.dart';
import 'create_delivery_screen.dart';
import 'delivery_detail_screen.dart';
import 'profile_screen.dart';

class DeliveriesListScreen extends StatefulWidget {
  const DeliveriesListScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<DeliveriesListScreen> createState() => _DeliveriesListScreenState();
}

class _DeliveriesListScreenState extends State<DeliveriesListScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    widget.controller.refreshDeliveries(silent: true);
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (widget.controller.isAuthenticated) {
        widget.controller.refreshDeliveries(silent: true);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _openCreate() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AppShell(
          child: CreateDeliveryScreen(controller: widget.controller),
        ),
      ),
    );
  }

  Future<void> _openProfile() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AppShell(
          child: ProfileScreen(controller: widget.controller),
        ),
      ),
    );
  }

  Future<void> _openDetail(Delivery delivery) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AppShell(
          child: DeliveryDetailScreen(
            controller: widget.controller,
            deliveryId: delivery.id,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final deliveries = widget.controller.deliveries;
        final showInitialLoading =
            widget.controller.loading && deliveries.isEmpty;
        final showError = widget.controller.error != null && deliveries.isEmpty;

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Minhas entregas',
                                  style: TextStyle(
                                    color: AppColors.foreground,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(height: 6),
                                _AutoRefreshLabel(),
                              ],
                            ),
                          ),
                          _RoundIconButton(
                            icon: Icons.refresh,
                            onPressed: () =>
                                widget.controller.refreshDeliveries(),
                          ),
                          const SizedBox(width: 8),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: _openProfile,
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.primary,
                                child: Text(
                                  _initials(
                                      widget.controller.session?.user.name ??
                                          'Cliente'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton.icon(
                        onPressed: _openCreate,
                        icon: const Icon(Icons.add),
                        label: const Text('Nova entrega'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => widget.controller.refreshDeliveries(),
                    child: showInitialLoading
                        ? const Center(child: CircularProgressIndicator())
                        : showError
                            ? ListView(
                                children: [
                                  EmptyState(
                                    icon: Icons.error_outline,
                                    title: 'Não foi possível carregar',
                                    message: widget.controller.error!,
                                    action: OutlinedButton(
                                      onPressed: () =>
                                          widget.controller.refreshDeliveries(),
                                      child: const Text('Tentar novamente'),
                                    ),
                                  ),
                                ],
                              )
                            : deliveries.isEmpty
                                ? ListView(
                                    children: [
                                      EmptyState(
                                        icon: Icons.inbox_outlined,
                                        title: 'Você ainda não possui entregas',
                                        message:
                                            'Crie sua primeira entrega para começar a acompanhar em tempo real.',
                                        action: ElevatedButton.icon(
                                          onPressed: _openCreate,
                                          icon: const Icon(Icons.add),
                                          label: const Text(
                                              'Criar primeira entrega'),
                                        ),
                                      ),
                                    ],
                                  )
                                : ListView.separated(
                                    padding: const EdgeInsets.fromLTRB(
                                        24, 4, 24, 28),
                                    itemCount: deliveries.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 12),
                                    itemBuilder: (context, index) {
                                      final delivery = deliveries[index];
                                      return _DeliveryCard(
                                        delivery: delivery,
                                        onTap: () => _openDetail(delivery),
                                      );
                                    },
                                  ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  const _DeliveryCard({
    required this.delivery,
    required this.onTap,
  });

  final Delivery delivery;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        mouseCursor: SystemMouseCursors.click,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      delivery.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.foreground,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(status: delivery.status),
                ],
              ),
              const SizedBox(height: 14),
              _AddressRow(
                icon: Icons.location_on_outlined,
                text: delivery.pickupAddress,
                muted: true,
              ),
              const SizedBox(height: 8),
              _AddressRow(
                icon: Icons.arrow_downward,
                text: delivery.dropoffAddress,
              ),
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '#${delivery.id}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.mutedForeground,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  Text(
                    formatDateTime(delivery.updatedAt),
                    style: const TextStyle(
                      color: AppColors.mutedForeground,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddressRow extends StatelessWidget {
  const _AddressRow({
    required this.icon,
    required this.text,
    this.muted = false,
  });

  final IconData icon;
  final String text;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: muted ? AppColors.mutedForeground : AppColors.secondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: muted ? AppColors.mutedForeground : AppColors.foreground,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _RoundIconButton extends StatefulWidget {
  const _RoundIconButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  State<_RoundIconButton> createState() => _RoundIconButtonState();
}

class _RoundIconButtonState extends State<_RoundIconButton> {
  double _turns = 0;

  void _handlePressed() {
    setState(() => _turns += 1);
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      shape: const CircleBorder(
        side: BorderSide(color: AppColors.border),
      ),
      child: IconButton(
        onPressed: _handlePressed,
        icon: AnimatedRotation(
          turns: _turns,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
          child: Icon(widget.icon, size: 19),
        ),
        color: AppColors.mutedForeground,
      ),
    );
  }
}

class _AutoRefreshLabel extends StatelessWidget {
  const _AutoRefreshLabel();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.circle, size: 8, color: AppColors.success),
        SizedBox(width: 6),
        Text(
          'Atualizando automaticamente',
          style: TextStyle(
            color: AppColors.mutedForeground,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

String _initials(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return 'CL';
  return parts.take(2).map((part) => part[0].toUpperCase()).join();
}
