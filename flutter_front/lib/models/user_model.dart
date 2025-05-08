class User {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String joinDate;
  final String? avatar;

  User({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.joinDate,
    this.avatar,
  });

  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      name: data['name']?.toString() ?? 'Non renseigné',
      email: data['email']?.toString() ?? '',
      phone: data['phone']?.toString() ?? 'Non renseigné',
      address: data['address']?.toString() ?? 'Non renseignée',
      joinDate: data['joinDate']?.toString() ?? DateTime.now().toString(),
      avatar: data['avatar']?.toString(),
    );
  }

  User copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? joinDate,
    String? avatar,
  }) {
    return User(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      joinDate: joinDate ?? this.joinDate,
      avatar: avatar ?? this.avatar,
    );
  }
}
