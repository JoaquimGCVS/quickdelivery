import 'package:flutter/foundation.dart';

import '../models/auth_session.dart';
import '../models/delivery.dart';
import '../services/api_exception.dart';
import '../services/auth_service.dart';
import '../services/deliveries_service.dart';

class AppController extends ChangeNotifier {
  AppController({
    required AuthService authService,
    required DeliveriesService deliveriesService,
  })  : _authService = authService,
        _deliveriesService = deliveriesService;

  final AuthService _authService;
  final DeliveriesService _deliveriesService;

  AuthSession? _session;
  List<Delivery> _deliveries = const [];
  bool _loading = false;
  String? _error;

  AuthSession? get session => _session;
  bool get isAuthenticated => _session != null;
  List<Delivery> get deliveries => _deliveries;
  bool get loading => _loading;
  String? get error => _error;
  bool get isCustomer => _session?.user.role == 'CUSTOMER';
  bool get isDeliveryman => _session?.user.role == 'DELIVERYMAN';

  String get _token {
    final token = _session?.token;
    if (token == null) {
      throw const ApiException('Sessão expirada. Faça login novamente.');
    }
    return token;
  }

  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      _session = await _authService.login(email: email, password: password);
      _error = null;
      await refreshDeliveries(silent: true);
    } catch (err) {
      _error = _messageFor(err);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void logout() {
    _session = null;
    _deliveries = const [];
    _error = null;
    notifyListeners();
  }

  Future<void> refreshDeliveries({
    bool silent = false,
    DeliveryStatus? status,
  }) async {
    if (!silent) _setLoading(true);
    try {
      final list = await _deliveriesService.list(
        token: _token,
        status: status,
      );
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _deliveries = list;
      _error = null;
      notifyListeners();
    } catch (err) {
      _error = _messageFor(err);
      notifyListeners();
      if (!silent) rethrow;
    } finally {
      if (!silent) _setLoading(false);
    }
  }

  Future<Delivery> loadDelivery(String id, {bool silent = false}) async {
    if (!silent) _setLoading(true);
    try {
      final delivery = await _deliveriesService.findById(id, token: _token);
      _upsertDelivery(delivery);
      _error = null;
      return delivery;
    } catch (err) {
      _error = _messageFor(err);
      notifyListeners();
      rethrow;
    } finally {
      if (!silent) _setLoading(false);
    }
  }

  Future<Delivery> createDelivery({
    required String pickupAddress,
    required String dropoffAddress,
    required String description,
  }) async {
    _setLoading(true);
    try {
      final user = _session!.user;
      final delivery = await _deliveriesService.create(
        token: _token,
        customerId: user.id,
        pickupAddress: pickupAddress,
        dropoffAddress: dropoffAddress,
        description: description,
      );
      _upsertDelivery(delivery);
      _error = null;
      return delivery;
    } catch (err) {
      _error = _messageFor(err);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<Delivery> cancelDelivery(String id) async {
    _setLoading(true);
    try {
      final delivery = await _deliveriesService.cancel(id, token: _token);
      _upsertDelivery(delivery);
      _error = null;
      return delivery;
    } catch (err) {
      _error = _messageFor(err);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<Delivery> acceptDelivery(String id) async {
    _setLoading(true);
    try {
      final user = _session!.user;
      final delivery = await _deliveriesService.accept(
        id,
        token: _token,
        deliverymanId: user.id,
      );
      _upsertDelivery(delivery);
      _error = null;
      return delivery;
    } catch (err) {
      _error = _messageFor(err);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<Delivery> startDelivery(String id) async {
    return _changeDeliveryStatus(id, (token) {
      return _deliveriesService.start(id, token: token);
    });
  }

  Future<Delivery> completeDelivery(String id) async {
    return _changeDeliveryStatus(id, (token) {
      return _deliveriesService.deliver(id, token: token);
    });
  }

  Delivery? deliveryById(String id) {
    for (final delivery in _deliveries) {
      if (delivery.id == id) return delivery;
    }
    return null;
  }

  void _upsertDelivery(Delivery delivery) {
    final index = _deliveries.indexWhere((item) => item.id == delivery.id);
    if (index == -1) {
      _deliveries = [delivery, ..._deliveries];
    } else {
      final next = [..._deliveries];
      next[index] = delivery;
      _deliveries = next;
    }
    notifyListeners();
  }

  Future<Delivery> _changeDeliveryStatus(
    String id,
    Future<Delivery> Function(String token) action,
  ) async {
    _setLoading(true);
    try {
      final delivery = await action(_token);
      _upsertDelivery(delivery);
      _error = null;
      return delivery;
    } catch (err) {
      _error = _messageFor(err);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  String _messageFor(Object err) {
    if (err is ApiException) return err.message;
    return 'Algo deu errado. Tente novamente.';
  }
}
