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
    if (userId != null) {
      json['userId'] = userId;
    }
    if (criteria != null) {
      json['criteria'] = criteria;
    }
    if (limit != null) {
      json['limit'] = limit;
    }
    return json;
  }
}

class PsychologistSearchResponse {
  final Object? data;

  const PsychologistSearchResponse({required this.data});

  factory PsychologistSearchResponse.fromJson(Object? json) {
    return PsychologistSearchResponse(data: json);
  }
}

class PsychologistDetailResponse {
  final Object? data;

  const PsychologistDetailResponse({required this.data});

  factory PsychologistDetailResponse.fromJson(Object? json) {
    return PsychologistDetailResponse(data: json);
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
    if (notes != null) {
      json['notes'] = notes;
    }
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

  Map<String, dynamic> toJson() {
    return {'userId': userId};
  }
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
    if (comment != null) {
      json['comment'] = comment;
    }
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

  Map<String, dynamic> toJson() {
    return {'psychologistId': psychologistId};
  }
}

class PsychologistVerificationResponse {
  final Object? data;

  const PsychologistVerificationResponse({required this.data});

  factory PsychologistVerificationResponse.fromJson(Object? json) {
    return PsychologistVerificationResponse(data: json);
  }
}
