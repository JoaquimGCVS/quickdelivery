enum DeliveryStatus {
  pending,
  accepted,
  inProgress,
  delivered,
  cancelled,
}

class DeliveryUser {
  const DeliveryUser({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.role,
  });

  final String id;
  final String email;
  final String name;
  final String phone;
  final String role;

  factory DeliveryUser.fromJson(Map<String, dynamic> json) {
    return DeliveryUser(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      role: json['role'] as String,
    );
  }
}

class Delivery {
  const Delivery({
    required this.id,
    required this.customerId,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.customer,
    this.deliverymanId,
    this.deliveryman,
  });

  final String id;
  final String customerId;
  final DeliveryUser? customer;
  final String? deliverymanId;
  final DeliveryUser? deliveryman;
  final String pickupAddress;
  final String dropoffAddress;
  final String description;
  final DeliveryStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get canCustomerCancel {
    return status == DeliveryStatus.pending ||
        status == DeliveryStatus.accepted;
  }

  bool get isFinal {
    return status == DeliveryStatus.delivered ||
        status == DeliveryStatus.cancelled;
  }

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      customer: _optionalUser(json['customer']),
      deliverymanId: json['deliverymanId'] as String?,
      deliveryman: _optionalUser(json['deliveryman']),
      pickupAddress: json['pickupAddress'] as String,
      dropoffAddress: json['dropoffAddress'] as String,
      description: json['description'] as String,
      status: deliveryStatusFromApi(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

DeliveryUser? _optionalUser(Object? value) {
  if (value is Map<String, dynamic>) {
    return DeliveryUser.fromJson(value);
  }
  return null;
}

DeliveryStatus deliveryStatusFromApi(String value) {
  switch (value) {
    case 'PENDING':
      return DeliveryStatus.pending;
    case 'ACCEPTED':
      return DeliveryStatus.accepted;
    case 'IN_PROGRESS':
      return DeliveryStatus.inProgress;
    case 'DELIVERED':
      return DeliveryStatus.delivered;
    case 'CANCELLED':
      return DeliveryStatus.cancelled;
    default:
      throw ArgumentError('Unknown delivery status: $value');
  }
}

String deliveryStatusToApi(DeliveryStatus status) {
  switch (status) {
    case DeliveryStatus.pending:
      return 'PENDING';
    case DeliveryStatus.accepted:
      return 'ACCEPTED';
    case DeliveryStatus.inProgress:
      return 'IN_PROGRESS';
    case DeliveryStatus.delivered:
      return 'DELIVERED';
    case DeliveryStatus.cancelled:
      return 'CANCELLED';
  }
}

String deliveryStatusLabel(DeliveryStatus status) {
  switch (status) {
    case DeliveryStatus.pending:
      return 'Pendente';
    case DeliveryStatus.accepted:
      return 'Aceita';
    case DeliveryStatus.inProgress:
      return 'Em andamento';
    case DeliveryStatus.delivered:
      return 'Entregue';
    case DeliveryStatus.cancelled:
      return 'Cancelada';
  }
}
