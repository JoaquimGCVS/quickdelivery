import '../models/auth_session.dart';
import '../models/user.dart';
import 'api_client.dart';
import 'api_exception.dart';

class AuthService {
  const AuthService(this._apiClient);

  final ApiClient _apiClient;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final data = await _apiClient.post('/auth/login', {
      'email': email,
      'password': password,
    }) as Map<String, dynamic>;

    final user = User.fromJson(data['user'] as Map<String, dynamic>);
    if (user.role != 'CUSTOMER') {
      throw const ApiException('Este aplicativo é exclusivo para clientes.');
    }

    return AuthSession(
      user: user,
      token: data['token'] as String,
    );
  }
}
