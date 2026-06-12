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
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
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
        SnackBar(content: Text(widget.controller.error ?? 'Não foi possível cancelar.')),
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
                    message: _error ?? 'Não encontramos essa entrega no servidor.',
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
                                StatusBadge(status: delivery.status, large: true),
                                const SizedBox(height: 12),
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.refresh,
                                      size: 14,
                                      color: AppColors.mutedForeground,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Esta tela atualiza automaticamente',
                                      style: TextStyle(
                                        color: AppColors.mutedForeground,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
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
                                  style: TextStyle(color: AppColors.mutedForeground),
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
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
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
                                        value: formatDateTime(delivery.createdAt),
                                      ),
                                    ),
                                    Expanded(
                                      child: _DateColumn(
                                        label: 'Última atualização',
                                        value: formatDateTime(delivery.updatedAt),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        OutlinedButton.icon(
                          onPressed: delivery.canCustomerCancel && !widget.controller.loading
                              ? () => _cancel(delivery)
                              : null,
                          icon: const Icon(Icons.cancel_outlined),
                          label: const Text('Cancelar entrega'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.destructive,
                            side: BorderSide(
                              color: delivery.canCustomerCancel
                                  ? AppColors.destructive.withOpacity(0.35)
                                  : AppColors.border,
                            ),
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
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
                    ),
                  ),
          ),
        );
      },
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
