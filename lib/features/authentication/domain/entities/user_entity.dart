enum AuthProviderType {
  email,
  google,
  facebook,
  apple,
  custom;

  String get label {
    switch (this) {
      case AuthProviderType.email:
        return 'Email';
      case AuthProviderType.google:
        return 'Google';
      case AuthProviderType.facebook:
        return 'Facebook';
      case AuthProviderType.apple:
        return 'Apple';
      case AuthProviderType.custom:
        return 'Custom Server';
    }
  }
}

/// Core User Entity representing a Lovio user profile
class UserEntity {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? partnerName;
  final DateTime? anniversaryDate;
  final String? bio;
  final AuthProviderType provider;
  final DateTime createdAt;
  final bool isEmailVerified;

  const UserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.partnerName,
    this.anniversaryDate,
    this.bio,
    this.provider = AuthProviderType.email,
    required this.createdAt,
    this.isEmailVerified = false,
  });

  /// Computed property: Days together with partner
  int? get daysTogether {
    if (anniversaryDate == null) return null;
    final now = DateTime.now();
    return now.difference(anniversaryDate!).inDays;
  }

  UserEntity copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? partnerName,
    DateTime? anniversaryDate,
    String? bio,
    AuthProviderType? provider,
    DateTime? createdAt,
    bool? isEmailVerified,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      partnerName: partnerName ?? this.partnerName,
      anniversaryDate: anniversaryDate ?? this.anniversaryDate,
      bio: bio ?? this.bio,
      provider: provider ?? this.provider,
      createdAt: createdAt ?? this.createdAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'partnerName': partnerName,
      'anniversaryDate': anniversaryDate?.toIso8601String(),
      'bio': bio,
      'provider': provider.name,
      'createdAt': createdAt.toIso8601String(),
      'isEmailVerified': isEmailVerified,
    };
  }

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? 'Beloved',
      photoUrl: json['photoUrl'] as String?,
      partnerName: json['partnerName'] as String?,
      anniversaryDate: json['anniversaryDate'] != null
          ? DateTime.tryParse(json['anniversaryDate'] as String)
          : null,
      bio: json['bio'] as String?,
      provider: AuthProviderType.values.firstWhere(
        (p) => p.name == json['provider'],
        orElse: () => AuthProviderType.email,
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      isEmailVerified: (json['isEmailVerified'] as bool?) ?? false,
    );
  }
}

