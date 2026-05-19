class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.details,
  });

  final String message;
  final int? statusCode;
  final Object? details;

  @override
  String toString() {
    final status = statusCode == null ? '' : ' [$statusCode]';
    return '$message$status';
  }
}
