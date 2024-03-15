class User {
  final int? id;
  final int? managerId;
  final String name;
  final String email;
  final String password;
  final String role;
  final String? presenter;
  final String? manager;

  User({
    this.id,
    this.managerId,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.presenter,
    this.manager,
  });

  User copyWith({
    int? id,
    int? managerId,
    String? name,
    String? email,
    String? password,
    String? role,
    String? presenter,
    String? manager,
  }) {
    return User(
      id: id ?? this.id,
      managerId: managerId ?? this.managerId,
      name: name ?? this.name,
      password: password ?? this.password,
      email: email ?? this.email,
      role: role ?? this.role,
      presenter: presenter ?? this.presenter,
      manager: manager ?? this.manager,
    );
  }

  @override
  String toString() {
    return 'User(managerId: $managerId)';
  }
}
