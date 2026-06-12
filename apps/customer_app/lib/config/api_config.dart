class ApiConfig {
  static const baseUrl = String.fromEnvironment(
    'QUICKDELIVERY_API_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );
}
