import 'package:flutter/material.dart';

import '../models/delivery.dart';
import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.status,
    this.large = false,
  });

  final DeliveryStatus status;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final colors = _colors(status);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 16 : 10,
        vertical: large ? 8 : 4,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.border),
      ),
      child: Text(
        deliveryStatusLabel(status),
        style: TextStyle(
          color: colors.foreground,
          fontSize: large ? 14 : 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

({Color background, Color border, Color foreground}) _colors(
    DeliveryStatus status) {
  switch (status) {
    case DeliveryStatus.pending:
      return (
        background: AppColors.warning.withValues(alpha: 0.12),
        border: AppColors.warning.withValues(alpha: 0.35),
        foreground: AppColors.warning,
      );
    case DeliveryStatus.accepted:
      return (
        background: AppColors.info.withValues(alpha: 0.10),
        border: AppColors.info.withValues(alpha: 0.30),
        foreground: AppColors.info,
      );
    case DeliveryStatus.inProgress:
      return (
        background: AppColors.progress.withValues(alpha: 0.10),
        border: AppColors.progress.withValues(alpha: 0.30),
        foreground: AppColors.progress,
      );
    case DeliveryStatus.delivered:
      return (
        background: AppColors.success.withValues(alpha: 0.10),
        border: AppColors.success.withValues(alpha: 0.30),
        foreground: AppColors.success,
      );
    case DeliveryStatus.cancelled:
      return (
        background: AppColors.destructive.withValues(alpha: 0.08),
        border: AppColors.destructive.withValues(alpha: 0.28),
        foreground: AppColors.destructive,
      );
  }
}
