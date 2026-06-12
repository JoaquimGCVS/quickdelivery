class User {
  const User({
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

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      role: json['role'] as String,
    );
  }
}
