class HumanPartnerQueueRequest {
  final String userId;

  const HumanPartnerQueueRequest({required this.userId});

  Map<String, dynamic> toJson() {
    return {'userId': userId};
  }
}

class HumanPartnerQueueResponse {
  final Object? data;

  const HumanPartnerQueueResponse({required this.data});

  factory HumanPartnerQueueResponse.fromJson(Object? json) {
    return HumanPartnerQueueResponse(data: json);
  }
}

class HumanPartnerMatchResponse {
  final Object? data;

  const HumanPartnerMatchResponse({required this.data});

  factory HumanPartnerMatchResponse.fromJson(Object? json) {
    return HumanPartnerMatchResponse(data: json);
  }
}

class HumanPartnerFavoriteRequest {
  final String userId;
  final String targetUserId;

  const HumanPartnerFavoriteRequest({
    required this.userId,
    required this.targetUserId,
  });

  Map<String, dynamic> toJson() {
    return {'userId': userId, 'targetUserId': targetUserId};
  }
}

class HumanPartnerBlockRequest {
  final String userId;
  final String targetUserId;
  final String? reason;

  const HumanPartnerBlockRequest({
    required this.userId,
    required this.targetUserId,
    this.reason,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'userId': userId,
      'targetUserId': targetUserId,
    };
    if (reason != null) {
      json['reason'] = reason;
    }
    return json;
  }
}

class HumanPartnerReportRequest {
  final String userId;
  final String targetUserId;
  final String? reason;

  const HumanPartnerReportRequest({
    required this.userId,
    required this.targetUserId,
    this.reason,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'userId': userId,
      'targetUserId': targetUserId,
    };
    if (reason != null) {
      json['reason'] = reason;
    }
    return json;
  }
}

class HumanPartnerFavoritesResponse {
  final Object? data;

  const HumanPartnerFavoritesResponse({required this.data});

  factory HumanPartnerFavoritesResponse.fromJson(Object? json) {
    return HumanPartnerFavoritesResponse(data: json);
  }
}
