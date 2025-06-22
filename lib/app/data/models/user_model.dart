class UserModel {
  final String id;
  final String name;
  final String email;
  final String provider;
  final String photoUrl;
  final String lastLogin;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.provider,
    required this.photoUrl,
    required this.lastLogin,
  });

  /// Factory untuk parsing dari JSON (pastikan semua dipaksa ke String)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id']?.toString() ?? '', // biasanya _id dari MongoDB
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      provider: json['provider']?.toString() ?? 'email',
      photoUrl: json['photoUrl']?.toString() ?? '',
      lastLogin:
          json['lastLogin']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }

  /// Untuk konversi ke JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id, // sesuaikan dengan nama field dari server
      'name': name,
      'email': email,
      'provider': provider,
      'photoUrl': photoUrl,
      'lastLogin': lastLogin,
    };
  }

  /// Untuk salin user dengan perubahan sebagian
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? provider,
    String? photoUrl,
    String? lastLogin,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      provider: provider ?? this.provider,
      photoUrl: photoUrl ?? this.photoUrl,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
