class ClientProfileDto {
  final String userId;
  final String? email;
  final String? displayName;
  final String username;
  final String? birthDate;
  final String? gender;
  final String? photoUrl;

  const ClientProfileDto({
    required this.userId,
    this.email,
    this.displayName,
    required this.username,
    this.birthDate,
    this.gender,
    this.photoUrl,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'userId': userId, 'username': username};
    if (email != null) json['email'] = email;
    if (displayName != null) json['displayName'] = displayName;
    if (birthDate != null) json['birthDate'] = birthDate;
    if (gender != null) json['gender'] = gender;
    if (photoUrl != null) json['photoUrl'] = photoUrl;
    return json;
  }

  factory ClientProfileDto.fromJson(Map<String, dynamic> json) {
    return ClientProfileDto(
      userId: json['userId'] as String,
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      username: json['username'] as String,
      birthDate: json['birthDate'] as String?,
      gender: json['gender'] as String?,
      photoUrl: json['photoUrl'] as String?,
    );
  }
}

class PsychologistProfileDto {
  final String userId;
  final String? email;
  final String fullName;
  final String phoneNumber;
  final String gender;
  final String location;
  final String clinicName;
  final String specialization;
  final int yearsExperience;
  final String nik;
  final String strNumber;
  final String? photoUrl;
  final List<String> education;
  final int? clientsHandled;
  final String? bio;
  final List<String>? tags;

  const PsychologistProfileDto({
    required this.userId,
    this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.gender,
    required this.location,
    required this.clinicName,
    required this.specialization,
    required this.yearsExperience,
    required this.nik,
    required this.strNumber,
    this.photoUrl,
    required this.education,
    this.clientsHandled,
    this.bio,
    this.tags,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'userId': userId,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'gender': gender,
      'location': location,
      'clinicName': clinicName,
      'specialization': specialization,
      'yearsExperience': yearsExperience,
      'nik': nik,
      'strNumber': strNumber,
      'education': education,
    };
    if (email != null) json['email'] = email;
    if (photoUrl != null) json['photoUrl'] = photoUrl;
    if (clientsHandled != null) json['clientsHandled'] = clientsHandled;
    if (bio != null) json['bio'] = bio;
    if (tags != null && tags!.isNotEmpty) json['tags'] = tags;
    return json;
  }

  factory PsychologistProfileDto.fromJson(Map<String, dynamic> json) {
    return PsychologistProfileDto(
      userId: json['userId'] as String,
      email: json['email'] as String?,
      fullName: json['fullName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      gender: json['gender'] as String,
      location: json['location'] as String,
      clinicName: json['clinicName'] as String,
      specialization: json['specialization'] as String,
      yearsExperience: json['yearsExperience'] as int,
      nik: json['nik'] as String? ?? '',
      strNumber: json['strNumber'] as String? ?? '',
      photoUrl: json['photoUrl'] as String?,
      education: List<String>.from(json['education'] as List? ?? []),
      clientsHandled: json['clientsHandled'] as int?,
      bio: json['bio'] as String?,
      tags: (json['tags'] as List?)?.cast<String>(),
    );
  }
}

class PsychologistDocumentsDto {
  final String userId;
  final String ktpUrl;
  final String faceWithKtpUrl;
  final String strLicenseUrl;

  const PsychologistDocumentsDto({
    required this.userId,
    required this.ktpUrl,
    required this.faceWithKtpUrl,
    required this.strLicenseUrl,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'ktpUrl': ktpUrl,
    'faceWithKtpUrl': faceWithKtpUrl,
    'strLicenseUrl': strLicenseUrl,
  };

  factory PsychologistDocumentsDto.fromJson(Map<String, dynamic> json) {
    return PsychologistDocumentsDto(
      userId: json['userId'] as String,
      ktpUrl: json['ktpUrl'] as String,
      faceWithKtpUrl: json['faceWithKtpUrl'] as String,
      strLicenseUrl: json['strLicenseUrl'] as String,
    );
  }
}

class ClientProfileResponse {
  final String userId;
  final String username;
  final String? birthDate;
  final String? gender;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ClientProfileResponse({
    required this.userId,
    required this.username,
    this.birthDate,
    this.gender,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ClientProfileResponse.fromJson(Map<String, dynamic> json) {
    return ClientProfileResponse(
      userId: json['userId'] as String,
      username: json['username'] as String,
      birthDate: json['birthDate'] as String?,
      gender: json['gender'] as String?,
      photoUrl: json['photoUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class PsychologistProfileResponse {
  final String id;
  final String userId;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String gender;
  final String location;
  final String clinicName;
  final String specialization;
  final int clientsHandled;
  final int yearsExperience;
  final String nik;
  final String strNumber;
  final String bio;
  final List<String> tags;
  final String? photoUrl;
  final List<EducationItem> education;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PsychologistProfileResponse({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.gender,
    required this.location,
    required this.clinicName,
    required this.specialization,
    required this.clientsHandled,
    required this.yearsExperience,
    required this.nik,
    required this.strNumber,
    required this.bio,
    required this.tags,
    this.photoUrl,
    required this.education,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PsychologistProfileResponse.fromJson(Map<String, dynamic> json) {
    return PsychologistProfileResponse(
      id: json['id'] as String,
      userId: json['userId'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      gender: json['gender'] as String,
      location: json['location'] as String,
      clinicName: json['clinicName'] as String,
      specialization: json['specialization'] as String,
      clientsHandled: json['clientsHandled'] as int? ?? 0,
      yearsExperience: json['yearsExperience'] as int,
      nik: json['nik'] as String? ?? '',
      strNumber: json['strNumber'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      tags: List<String>.from(json['tags'] as List? ?? []),
      photoUrl: json['photoUrl'] as String?,
      education:
          (json['education'] as List?)
              ?.map((e) => EducationItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class EducationItem {
  final String id;
  final String level;
  final String institution;
  final int year;

  const EducationItem({
    required this.id,
    required this.level,
    required this.institution,
    required this.year,
  });

  factory EducationItem.fromJson(Map<String, dynamic> json) {
    return EducationItem(
      id: json['id'] as String,
      level: json['level'] as String,
      institution: json['institution'] as String,
      year: json['year'] as int,
    );
  }
}

class VerificationDocument {
  final String id;
  final String psychologistId;
  final String type;
  final String url;
  final String status;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VerificationDocument({
    required this.id,
    required this.psychologistId,
    required this.type,
    required this.url,
    required this.status,
    this.rejectionReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VerificationDocument.fromJson(Map<String, dynamic> json) {
    return VerificationDocument(
      id: json['id'] as String,
      psychologistId: json['psychologistId'] as String,
      type: json['type'] as String,
      url: json['url'] as String,
      status: json['status'] as String,
      rejectionReason: json['rejectionReason'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
