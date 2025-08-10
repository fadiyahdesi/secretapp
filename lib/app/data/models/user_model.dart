class UserModel {
  final String id;
  final String name;
  final String email;
  final String provider;
  String photoUrl;
  final String lastLogin;
  int points;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.provider,
    required this.photoUrl,
    required this.lastLogin,
    this.points = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final id =
        json['_id']?.toString() ??
        json['user_id']?.toString() ??
        json['id']?.toString() ??
        '';

    final name = json['name']?.toString() ?? '';
    final email = json['email']?.toString() ?? '';

    final rawProvider = json['provider']?.toString().toLowerCase() ?? 'email';
    final provider = rawProvider.contains('google') ? 'google' : 'email';

    String photoUrl = json['photoUrl']?.toString() ?? '';
    if (photoUrl.isEmpty) {
      photoUrl =
          'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}';
    }

    final lastLogin =
        json['lastLogin']?.toString() ?? DateTime.now().toIso8601String();

    final points = json['points'] ?? 0;

    return UserModel(
      id: id,
      name: name,
      email: email,
      provider: provider,
      photoUrl: photoUrl,
      lastLogin: lastLogin,
      points: points,
    );
  }

  Map<String, dynamic> toJson({bool forBackend = true}) {
    return {
      forBackend ? 'user_id' : '_id': id,
      'name': name,
      'email': email,
      'provider': provider,
      'photoUrl': photoUrl,
      'lastLogin': lastLogin,
      'points': points,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? provider,
    String? photoUrl,
    String? lastLogin,
    int? points,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      provider: provider ?? this.provider,
      photoUrl: photoUrl ?? this.photoUrl,
      lastLogin: lastLogin ?? this.lastLogin,
      points: points ?? this.points,
    );
  }
}
