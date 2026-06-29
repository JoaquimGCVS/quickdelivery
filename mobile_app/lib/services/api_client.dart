import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_exception.dart';

class ApiClient {
  ApiClient({
    required this.baseUrl,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final http.Client _httpClient;
  static const _timeout = Duration(seconds: 10);

  Uri _uri(String path) {
    return Uri.parse('$baseUrl$path');
  }

  Future<dynamic> get(String path, {String? token}) {
    return _send('GET', path, token: token);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body,
      {String? token}) {
    return _send('POST', path, body: body, token: token);
  }

  Future<dynamic> patch(String path, Map<String, dynamic> body,
      {String? token}) {
    return _send('PATCH', path, body: body, token: token);
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final headers = <String, String>{
      'content-type': 'application/json',
      if (token != null) 'authorization': 'Bearer $token',
    };

    late final http.Response response;
    final uri = _uri(path);
    final encodedBody = body == null ? null : jsonEncode(body);

    try {
      switch (method) {
        case 'GET':
          response = await _httpClient.get(uri, headers: headers).timeout(
                _timeout,
              );
          break;
        case 'POST':
          response = await _httpClient
              .post(uri, headers: headers, body: encodedBody)
              .timeout(_timeout);
          break;
        case 'PATCH':
          response = await _httpClient
              .patch(uri, headers: headers, body: encodedBody)
              .timeout(_timeout);
          break;
        default:
          throw ArgumentError('Unsupported method $method');
      }
    } catch (_) {
      throw ApiException('Não foi possível conectar ao servidor em $baseUrl.');
    }

    final text = response.body;
    dynamic data;
    if (text.isNotEmpty) {
      try {
        data = jsonDecode(text);
      } catch (_) {
        data = text;
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = data is Map<String, dynamic> && data['error'] is String
          ? data['error'] as String
          : 'Erro ao processar a solicitação.';
      throw ApiException(message, statusCode: response.statusCode);
    }

    return data;
  }
}
