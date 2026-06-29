import 'dart:async';

import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../models/delivery.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatter.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_state.dart';
import '../widgets/info_section.dart';
import '../widgets/status_badge.dart';

class DeliveryDetailScreen extends StatefulWidget {
  const DeliveryDetailScreen({
    super.key,
    required this.controller,
    required this.deliveryId,
  });

  final AppController controller;
  final String deliveryId;

  @override
  State<DeliveryDetailScreen> createState() => _DeliveryDetailScreenState();
}

class _DeliveryDetailScreenState extends State<DeliveryDetailScreen> {
  Timer? _timer;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load(silent: true);
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      final delivery = widget.controller.deliveryById(widget.deliveryId);
      if (delivery == null || !delivery.isFinal) {
        _load(silent: true);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    try {
      await widget.controller.loadDelivery(widget.deliveryId, silent: silent);
      if (mounted) setState(() => _error = null);
    } catch (_) {
      if (mounted) setState(() => _error = widget.controller.error);
    }
  }

  Future<void> _cancel(Delivery delivery) async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Cancelar entrega?',
      message: 'Esta ação não poderá ser desfeita.',
      confirmLabel: 'Cancelar entrega',
      cancelLabel: 'Voltar',
    );
    if (!confirmed || !mounted) return;

    try {
      await widget.controller.cancelDelivery(delivery.id);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(widget.controller.error ?? 'Não foi possível cancelar.')),
      );
    }
  }

  Future<void> _accept(Delivery delivery) async {
    await _runDeliverymanAction(() {
      return widget.controller.acceptDelivery(delivery.id);
    });
  }

  Future<void> _start(Delivery delivery) async {
    await _runDeliverymanAction(() {
      return widget.controller.startDelivery(delivery.id);
    });
  }

  Future<void> _complete(Delivery delivery) async {
    await _runDeliverymanAction(() {
      return widget.controller.completeDelivery(delivery.id);
    });
  }

  Future<void> _runDeliverymanAction(Future<Delivery> Function() action) async {
    try {
      await action();
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
        final delivery = widget.controller.deliveryById(widget.deliveryId);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detalhes da entrega'),
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          body: SafeArea(
            child: delivery == null
                ? EmptyState(
                    icon: Icons.search_off,
                    title: 'Entrega não encontrada',
                    message:
                        _error ?? 'Não encontramos essa entrega no servidor.',
                    action: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Voltar à lista'),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => _load(),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                const Text(
                                  'STATUS ATUAL',
                                  style: TextStyle(
                                    color: AppColors.mutedForeground,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.7,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                StatusBadge(
                                    status: delivery.status, large: true),
                              ],
                            ),
                          ),
                        ),
                        InfoSection(
                          title: 'Retirada',
                          icon: Icons.location_on_outlined,
                          child: Text(delivery.pickupAddress),
                        ),
                        InfoSection(
                          title: 'Entrega',
                          icon: Icons.arrow_downward,
                          child: Text(delivery.dropoffAddress),
                        ),
                        InfoSection(
                          title: 'Item',
                          icon: Icons.inventory_2_outlined,
                          child: Text(delivery.description),
                        ),
                        InfoSection(
                          title: 'Entregador',
                          icon: Icons.person_outline,
                          child: delivery.deliverymanId == null
                              ? const Text(
                                  'Aguardando entregador',
                                  style: TextStyle(
                                      color: AppColors.mutedForeground),
                                )
                              : Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 18,
                                      backgroundColor: Color(0xFFE8F0F7),
                                      child: Icon(
                                        Icons.person,
                                        color: AppColors.primary,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            delivery.deliveryman?.name ??
                                                delivery.deliverymanId!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const Text(
                                            'Entregador atribuído',
                                            style: TextStyle(
                                              color: AppColors.mutedForeground,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                        Card(
                          margin: const EdgeInsets.only(top: 14),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today_outlined,
                                      size: 15,
                                      color: AppColors.secondary,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'DATAS',
                                      style: TextStyle(
                                        color: AppColors.mutedForeground,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _DateColumn(
                                        label: 'Criação',
                                        value:
                                            formatDateTime(delivery.createdAt),
                                      ),
                                    ),
                                    Expanded(
                                      child: _DateColumn(
                                        label: 'Última atualização',
                                        value:
                                            formatDateTime(delivery.updatedAt),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        _DeliveryActions(
                          delivery: delivery,
                          isCustomer: widget.controller.isCustomer,
                          isDeliveryman: widget.controller.isDeliveryman,
                          loading: widget.controller.loading,
                          onCancel: () => _cancel(delivery),
                          onAccept: () => _accept(delivery),
                          onStart: () => _start(delivery),
                          onComplete: () => _complete(delivery),
                        ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class _DeliveryActions extends StatelessWidget {
  const _DeliveryActions({
    required this.delivery,
    required this.isCustomer,
    required this.isDeliveryman,
    required this.loading,
    required this.onCancel,
    required this.onAccept,
    required this.onStart,
    required this.onComplete,
  });

  final Delivery delivery;
  final bool isCustomer;
  final bool isDeliveryman;
  final bool loading;
  final VoidCallback onCancel;
  final VoidCallback onAccept;
  final VoidCallback onStart;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    if (isDeliveryman) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (delivery.status == DeliveryStatus.pending)
            _PrimaryDeliveryButton(
              icon: Icons.check_circle_outline,
              label: 'Aceitar entrega',
              loading: loading,
              onPressed: onAccept,
            ),
          if (delivery.status == DeliveryStatus.accepted) ...[
            _PrimaryDeliveryButton(
              icon: Icons.play_circle_outline,
              label: 'Iniciar entrega',
              loading: loading,
              onPressed: onStart,
            ),
            const SizedBox(height: 10),
            _CancelDeliveryButton(
              enabled: !loading,
              onPressed: onCancel,
            ),
          ],
          if (delivery.status == DeliveryStatus.inProgress)
            _PrimaryDeliveryButton(
              icon: Icons.task_alt,
              label: 'Concluir entrega',
              loading: loading,
              onPressed: onComplete,
            ),
          if (delivery.status == DeliveryStatus.delivered ||
              delivery.status == DeliveryStatus.cancelled)
            Text(
              _finalMessage(delivery.status),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.mutedForeground,
                fontSize: 12,
              ),
            ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CancelDeliveryButton(
          enabled: delivery.canCustomerCancel && !loading,
          onPressed: onCancel,
        ),
        if (!delivery.canCustomerCancel)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              _cannotCancelMessage(delivery.status),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.mutedForeground,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

class _PrimaryDeliveryButton extends StatelessWidget {
  const _PrimaryDeliveryButton({
    required this.icon,
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: loading ? null : onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

class _CancelDeliveryButton extends StatelessWidget {
  const _CancelDeliveryButton({
    required this.enabled,
    required this.onPressed,
  });

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: enabled ? onPressed : null,
      icon: const Icon(Icons.cancel_outlined),
      label: const Text('Cancelar entrega'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.destructive,
        side: BorderSide(
          color: enabled
              ? AppColors.destructive.withValues(alpha: 0.35)
              : AppColors.border,
        ),
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

class _DateColumn extends StatelessWidget {
  const _DateColumn({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.mutedForeground,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.foreground,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

String _cannotCancelMessage(DeliveryStatus status) {
  switch (status) {
    case DeliveryStatus.inProgress:
      return 'Entrega em andamento - não é possível cancelar.';
    case DeliveryStatus.delivered:
      return 'Entrega concluída - não é possível cancelar.';
    case DeliveryStatus.cancelled:
      return 'Esta entrega já foi cancelada.';
    case DeliveryStatus.pending:
    case DeliveryStatus.accepted:
      return '';
  }
}

String _finalMessage(DeliveryStatus status) {
  switch (status) {
    case DeliveryStatus.delivered:
      return 'Entrega concluída.';
    case DeliveryStatus.cancelled:
      return 'Entrega cancelada.';
    case DeliveryStatus.pending:
    case DeliveryStatus.accepted:
    case DeliveryStatus.inProgress:
      return '';
  }
}
