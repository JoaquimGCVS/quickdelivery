import 'dart:async';

import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../models/delivery.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatter.dart';
import '../widgets/app_shell.dart';
import '../widgets/empty_state.dart';
import '../widgets/status_badge.dart';
import 'delivery_detail_screen.dart';
import 'profile_screen.dart';

class DeliverymanHomeScreen extends StatefulWidget {
  const DeliverymanHomeScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<DeliverymanHomeScreen> createState() => _DeliverymanHomeScreenState();
}

class _DeliverymanHomeScreenState extends State<DeliverymanHomeScreen> {
  Timer? _timer;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.refreshDeliveries(silent: true);
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
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

  Future<void> _runAction(Future<void> Function() action) async {
    try {
      await action();
      await widget.controller.refreshDeliveries(silent: true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.controller.error ?? 'Não foi possível atualizar a entrega.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final deliveries = widget.controller.deliveries;
        final available = deliveries
            .where((delivery) => delivery.status == DeliveryStatus.pending)
            .toList();
        final assigned = deliveries
            .where((delivery) =>
                delivery.status == DeliveryStatus.accepted ||
                delivery.status == DeliveryStatus.inProgress)
            .toList();
        final history = deliveries
            .where((delivery) =>
                delivery.status == DeliveryStatus.delivered ||
                delivery.status == DeliveryStatus.cancelled)
            .toList();
        final selected = [available, assigned, history][_tabIndex];

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
                                  'Área do entregador',
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
                                        'Entregador',
                                  ),
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
                      const SizedBox(height: 16),
                      SegmentedButton<int>(
                        segments: const [
                          ButtonSegment(
                            value: 0,
                            label: Text('Disponíveis'),
                          ),
                          ButtonSegment(
                            value: 1,
                            label: Text('Minhas'),
                          ),
                          ButtonSegment(
                            value: 2,
                            label: Text('Histórico'),
                          ),
                        ],
                        selected: {_tabIndex},
                        onSelectionChanged: (selected) {
                          setState(() => _tabIndex = selected.first);
                        },
                        showSelectedIcon: false,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => widget.controller.refreshDeliveries(),
                    child: widget.controller.loading && deliveries.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : selected.isEmpty
                            ? ListView(
                                children: [
                                  EmptyState(
                                    icon: _emptyIcon(_tabIndex),
                                    title: _emptyTitle(_tabIndex),
                                    message: _emptyMessage(_tabIndex),
                                    action: OutlinedButton.icon(
                                      onPressed: () =>
                                          widget.controller.refreshDeliveries(),
                                      icon: const Icon(Icons.refresh),
                                      label: const Text('Atualizar'),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.separated(
                                padding:
                                    const EdgeInsets.fromLTRB(24, 2, 24, 28),
                                itemCount: selected.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final delivery = selected[index];
                                  return _DeliverymanCard(
                                    delivery: delivery,
                                    onTap: () => _openDetail(delivery),
                                    onAccept: delivery.status ==
                                            DeliveryStatus.pending
                                        ? () => _runAction(() async {
                                              await widget.controller
                                                  .acceptDelivery(delivery.id);
                                            })
                                        : null,
                                    onStart: delivery.status ==
                                            DeliveryStatus.accepted
                                        ? () => _runAction(() async {
                                              await widget.controller
                                                  .startDelivery(delivery.id);
                                            })
                                        : null,
                                    onComplete: delivery.status ==
                                            DeliveryStatus.inProgress
                                        ? () => _runAction(() async {
                                              await widget.controller
                                                  .completeDelivery(
                                                      delivery.id);
                                            })
                                        : null,
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

class _DeliverymanCard extends StatelessWidget {
  const _DeliverymanCard({
    required this.delivery,
    required this.onTap,
    this.onAccept,
    this.onStart,
    this.onComplete,
  });

  final Delivery delivery;
  final VoidCallback onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onStart;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    final primaryAction = onAccept ?? onStart ?? onComplete;
    final primaryLabel = onAccept != null
        ? 'Aceitar'
        : onStart != null
            ? 'Iniciar'
            : onComplete != null
                ? 'Concluir'
                : null;

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
              _AddressLine(
                icon: Icons.location_on_outlined,
                text: delivery.pickupAddress,
              ),
              const SizedBox(height: 8),
              _AddressLine(
                icon: Icons.arrow_downward,
                text: delivery.dropoffAddress,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      formatDateTime(delivery.updatedAt),
                      style: const TextStyle(
                        color: AppColors.mutedForeground,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  if (primaryAction != null && primaryLabel != null)
                    FilledButton(
                      onPressed: primaryAction,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(96, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(primaryLabel),
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

class _AddressLine extends StatelessWidget {
  const _AddressLine({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.secondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.foreground,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

IconData _emptyIcon(int tabIndex) {
  switch (tabIndex) {
    case 0:
      return Icons.inbox_outlined;
    case 1:
      return Icons.delivery_dining;
    default:
      return Icons.history;
  }
}

String _emptyTitle(int tabIndex) {
  switch (tabIndex) {
    case 0:
      return 'Nenhuma entrega disponível';
    case 1:
      return 'Você não possui entregas ativas';
    default:
      return 'Histórico vazio';
  }
}

String _emptyMessage(int tabIndex) {
  switch (tabIndex) {
    case 0:
      return 'Novas solicitações aparecerão aqui automaticamente.';
    case 1:
      return 'Entregas aceitas e em andamento ficam nesta aba.';
    default:
      return 'Entregas concluídas ou canceladas aparecerão aqui.';
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
  if (parts.isEmpty) return 'EN';
  return parts.take(2).map((part) => part[0].toUpperCase()).join();
}
