enum PsychologistBookingMethod { chat, voice, video }

extension PsychologistBookingMethodX on PsychologistBookingMethod {
  String get apiValue {
    switch (this) {
      case PsychologistBookingMethod.chat:
        return 'CHAT';
      case PsychologistBookingMethod.voice:
        return 'VOICE';
      case PsychologistBookingMethod.video:
        return 'VIDEO';
    }
  }
}

class PsychologistSearchRequest {
  final String? userId;
  final String? criteria;
  final int? limit;

  const PsychologistSearchRequest({this.userId, this.criteria, this.limit});

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (userId != null) json['userId'] = userId;
    if (criteria != null) json['criteria'] = criteria;
    if (limit != null) json['limit'] = limit;
    return json;
  }
}

class PsychologistListItem {
  final String id;
  final String fullName;
  final String specialization;
  final String location;
  final String clinicName;
  final double rating;
  final int reviewCount;

  const PsychologistListItem({
    required this.id,
    required this.fullName,
    required this.specialization,
    required this.location,
    required this.clinicName,
    required this.rating,
    required this.reviewCount,
  });

  factory PsychologistListItem.fromJson(Map<String, dynamic> json) {
    return PsychologistListItem(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      specialization: json['specialization'] as String,
      location: json['location'] as String,
      clinicName: json['clinicName'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
    );
  }
}

class PsychologistSearchResponse {
  final List<PsychologistListItem> items;

  const PsychologistSearchResponse({required this.items});

  factory PsychologistSearchResponse.fromJson(dynamic json) {
    if (json is List) {
      return PsychologistSearchResponse(
        items: json
            .map(
              (e) => PsychologistListItem.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
      );
    }
    final list = json['data'] as List? ?? json['items'] as List? ?? [];
    return PsychologistSearchResponse(
      items: list
          .map((e) => PsychologistListItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PsychologistBookingRequest {
  final String userId;
  final String psychologistId;
  final String fullName;
  final PsychologistBookingMethod method;
  final num price;
  final String? notes;
  final String scheduledAt;

  const PsychologistBookingRequest({
    required this.userId,
    required this.psychologistId,
    required this.fullName,
    required this.method,
    required this.price,
    this.notes,
    required this.scheduledAt,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'userId': userId,
      'psychologistId': psychologistId,
      'fullName': fullName,
      'method': method.apiValue,
      'price': price,
      'scheduledAt': scheduledAt,
    };
    if (notes != null) json['notes'] = notes;
    return json;
  }
}

class PsychologistBookingResponse {
  final Object? data;

  const PsychologistBookingResponse({required this.data});

  factory PsychologistBookingResponse.fromJson(Object? json) {
    return PsychologistBookingResponse(data: json);
  }
}

class PsychologistPayRequest {
  final String userId;

  const PsychologistPayRequest({required this.userId});

  Map<String, dynamic> toJson() => {'userId': userId};
}

class PsychologistPayResponse {
  final Object? data;

  const PsychologistPayResponse({required this.data});

  factory PsychologistPayResponse.fromJson(Object? json) {
    return PsychologistPayResponse(data: json);
  }
}

class PsychologistReviewRequest {
  final String userId;
  final String psychologistId;
  final num rating;
  final String? comment;

  const PsychologistReviewRequest({
    required this.userId,
    required this.psychologistId,
    required this.rating,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'userId': userId,
      'psychologistId': psychologistId,
      'rating': rating,
    };
    if (comment != null) json['comment'] = comment;
    return json;
  }
}

class PsychologistReviewResponse {
  final Object? data;

  const PsychologistReviewResponse({required this.data});

  factory PsychologistReviewResponse.fromJson(Object? json) {
    return PsychologistReviewResponse(data: json);
  }
}

class PsychologistVerificationRequest {
  final String psychologistId;

  const PsychologistVerificationRequest({required this.psychologistId});

  Map<String, dynamic> toJson() => {'psychologistId': psychologistId};
}

class PsychologistVerificationResponse {
  final Object? data;

  const PsychologistVerificationResponse({required this.data});

  factory PsychologistVerificationResponse.fromJson(Object? json) {
    return PsychologistVerificationResponse(data: json);
  }
}

class PsychologistDetailResponse {
  final String id;
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
  final String? photoUrl; // ← tambah
  final bool isAcceptingSessions; // ← tambah
  final double rating;
  final int reviewCount;
  final int price;
  final List<PsychologistEducation> education;
  final List<PsychologistReview> reviews;
  final List<PsychologistSchedule> schedules;

  const PsychologistDetailResponse({
    required this.id,
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
    this.isAcceptingSessions = true,
    required this.rating,
    required this.reviewCount,
    this.price = 0,
    required this.education,
    required this.reviews,
    required this.schedules,
  });

  factory PsychologistDetailResponse.fromJson(Map<String, dynamic> json) {
    return PsychologistDetailResponse(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      gender: json['gender'] as String,
      location: json['location'] as String,
      clinicName: json['clinicName'] as String,
      specialization: json['specialization'] as String,
      clientsHandled: json['clientsHandled'] as int,
      yearsExperience: json['yearsExperience'] as int,
      nik: json['nik'] as String? ?? '',
      strNumber: json['strNumber'] as String? ?? '',
      bio: json['bio'] as String,
      tags: List<String>.from(json['tags'] as List),
      photoUrl: json['photoUrl'] as String?, // ← tambah
      isAcceptingSessions:
          json['isAcceptingSessions'] as bool? ?? true, // ← tambah
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      price: (json['price'] as num?)?.toInt() ?? 0,
      education: (json['education'] as List)
          .map((e) => PsychologistEducation.fromJson(e as Map<String, dynamic>))
          .toList(),
      reviews: (json['reviews'] as List)
          .map((e) => PsychologistReview.fromJson(e as Map<String, dynamic>))
          .toList(),
      schedules: (json['schedules'] as List)
          .map((e) => PsychologistSchedule.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PsychologistEducation {
  final String id;
  final String level;
  final String institution;
  final int? year; // ← nullable karena response bisa null

  const PsychologistEducation({
    required this.id,
    required this.level,
    required this.institution,
    this.year,
  });

  factory PsychologistEducation.fromJson(Map<String, dynamic> json) {
    return PsychologistEducation(
      id: json['id'] as String,
      level: json['level'] as String,
      institution: json['institution'] as String,
      year: json['year'] as int?, // ← nullable
    );
  }
}

class PsychologistReview {
  final String id;
  final String userId;
  final double rating;
  final String comment;
  final String createdAt;

  const PsychologistReview({
    required this.id,
    required this.userId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory PsychologistReview.fromJson(Map<String, dynamic> json) {
    return PsychologistReview(
      id: json['id'] as String,
      userId: json['userId'] as String,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String? ?? '',
      createdAt: json['createdAt'] as String,
    );
  }
}

class PsychologistSchedule {
  final String id;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final bool isAvailable;

  const PsychologistSchedule({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
  });

  factory PsychologistSchedule.fromJson(Map<String, dynamic> json) {
    return PsychologistSchedule(
      id: json['id'] as String,
      dayOfWeek: json['dayOfWeek'] as int,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      isAvailable: json['isAvailable'] as bool,
    );
  }
}
