class AppUser {
  final String id;
  final String username;
  final String email;

  const AppUser({
    required this.id,
    required this.username,
    required this.email,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: (json['_id'] ?? json['id'] ?? '').toString(),
        username: (json['username'] ?? json['name'] ?? '').toString(),
        email: (json['email'] ?? '').toString(),
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'username': username,
        'email': email,
      };

  String get firstName {
    final trimmed = username.trim();
    if (trimmed.isEmpty) return 'there';
    return trimmed.split(RegExp(r'\s+')).first;
  }
}
