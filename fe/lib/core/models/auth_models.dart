class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class LoginResponse {
  final String accessToken;
  final String? refreshToken;
  final String userId;
  final String email;
  final String? displayName;
  final String role;

  const LoginResponse({
    required this.accessToken,
    this.refreshToken,
    required this.userId,
    required this.email,
    this.displayName,
    required this.role,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String?,
      userId: json['userId'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      role: json['role'] as String,
    );
  }
}

class RegisterRequest {
  final String email;
  final String password;
  final String role;
  final String? displayName;

  const RegisterRequest({
    required this.email,
    required this.password,
    required this.role,
    this.displayName,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'role': role,
    'displayName': displayName,
  };
}

class RegisterResponse {
  final String userId;
  final String email;
  final String role;

  const RegisterResponse({
    required this.userId,
    required this.email,
    required this.role,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      userId: json['userId'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
    );
  }
}

class RefreshTokenRequest {
  final String refreshToken;

  const RefreshTokenRequest({required this.refreshToken});

  Map<String, dynamic> toJson() => {'refreshToken': refreshToken};
}

class RefreshTokenResponse {
  final String accessToken;
  final String? refreshToken;

  const RefreshTokenResponse({required this.accessToken, this.refreshToken});

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String?,
    );
  }
}

class CurrentUserResponse {
  final String id;
  final String email;
  final String? displayName;
  final String role;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CurrentUserResponse({
    required this.id,
    required this.email,
    this.displayName,
    required this.role,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CurrentUserResponse.fromJson(Map<String, dynamic> json) {
    return CurrentUserResponse(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      role: json['role'] as String,
      photoUrl: json['photoUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
    'currentPassword': currentPassword,
    'newPassword': newPassword,
  };
}
