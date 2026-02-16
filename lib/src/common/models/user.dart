enum UserRole { client, driver, vendor }

class User {
  final String id;
  final String name;
  final UserRole role;
  final String avatarUrl;

  User({
    required this.id,
    required this.name,
    required this.role,
    this.avatarUrl = '',
  });
}
