class AiChatSessionRequest {
  final String? userId;
  final String? title;

  const AiChatSessionRequest({this.userId, this.title});

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (userId != null) {
      json['userId'] = userId;
    }
    if (title != null) {
      json['title'] = title;
    }
    return json;
  }
}

class AiChatSessionResponse {
  final Object? data;

  const AiChatSessionResponse({required this.data});

  factory AiChatSessionResponse.fromJson(Object? json) {
    return AiChatSessionResponse(data: json);
  }
}

class AiChatMessageRequest {
  final String? userId;
  final String content;

  const AiChatMessageRequest({this.userId, required this.content});

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'content': content};
    if (userId != null) {
      json['userId'] = userId;
    }
    return json;
  }
}

class AiChatMessageResponse {
  final Object? data;

  const AiChatMessageResponse({required this.data});

  factory AiChatMessageResponse.fromJson(Object? json) {
    return AiChatMessageResponse(data: json);
  }
}
