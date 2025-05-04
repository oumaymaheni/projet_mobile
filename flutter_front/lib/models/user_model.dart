class User {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String joinDate;
  final String? avatar; // Peut être null si pas d'image

  User({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.joinDate,
    this.avatar,
  });
}