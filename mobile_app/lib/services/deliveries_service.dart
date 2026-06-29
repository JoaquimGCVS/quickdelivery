import '../models/delivery.dart';
import 'api_client.dart';

class DeliveriesService {
  const DeliveriesService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Delivery>> list({
    required String token,
    DeliveryStatus? status,
  }) async {
    final query =
        status == null ? '' : '?status=${deliveryStatusToApi(status)}';
    final data = await _apiClient.get('/deliveries$query', token: token)
        as List<dynamic>;
    return data
        .map((item) => Delivery.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Delivery> findById(String id, {required String token}) async {
    final data = await _apiClient.get('/deliveries/$id', token: token)
        as Map<String, dynamic>;
    return Delivery.fromJson(data);
  }

  Future<Delivery> create({
    required String token,
    required String customerId,
    required String pickupAddress,
    required String dropoffAddress,
    required String description,
  }) async {
    final data = await _apiClient.post(
      '/deliveries',
      {
        'customerId': customerId,
        'pickupAddress': pickupAddress,
        'dropoffAddress': dropoffAddress,
        'description': description,
      },
      token: token,
    ) as Map<String, dynamic>;
    return Delivery.fromJson(data);
  }

  Future<Delivery> cancel(String id, {required String token}) async {
    final data = await _apiClient.patch(
      '/deliveries/$id/status',
      {'status': 'CANCELLED'},
      token: token,
    ) as Map<String, dynamic>;
    return Delivery.fromJson(data);
  }

  Future<Delivery> accept(
    String id, {
    required String token,
    required String deliverymanId,
  }) async {
    return _updateStatus(
      id,
      token: token,
      body: {
        'status': 'ACCEPTED',
        'deliverymanId': deliverymanId,
      },
    );
  }

  Future<Delivery> start(String id, {required String token}) async {
    return _updateStatus(
      id,
      token: token,
      body: {'status': 'IN_PROGRESS'},
    );
  }

  Future<Delivery> deliver(String id, {required String token}) async {
    return _updateStatus(
      id,
      token: token,
      body: {'status': 'DELIVERED'},
    );
  }

  Future<Delivery> _updateStatus(
    String id, {
    required String token,
    required Map<String, dynamic> body,
  }) async {
    final data = await _apiClient.patch(
      '/deliveries/$id/status',
      body,
      token: token,
    ) as Map<String, dynamic>;
    return Delivery.fromJson(data);
  }
}
