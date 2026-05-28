class ApiResponse<T> {
  final int statusCode;
  final T data;

  const ApiResponse({required this.statusCode, required this.data});

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}
