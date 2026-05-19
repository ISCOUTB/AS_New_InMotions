class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
  });

  final bool success;
  final String message;
  final T? data;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? value) fromData,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String? ?? '',
      data: json.containsKey('data') ? fromData(json['data']) : null,
    );
  }
}
