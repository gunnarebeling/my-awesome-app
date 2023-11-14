typedef Json = Map<String, dynamic>;

class ApiError {
  final int statusCode;
  final String message;
  final Map<String, dynamic>? details;

  ApiError(
    this.statusCode,
    this.message, {
    this.details,
  });

  factory ApiError.fromJson(Json json, int statusCode) {
    final errors = json['errors'] is List //
        ? json['errors'].first
        : json['errors'];
    final error = errors ?? json['error'];

    if (error is String) {
      return ApiError(statusCode, error);
    } else if (error is Json) {
      return ApiError(error['code'], 'Error with Details', details: error);
    } else {
      return ApiError(statusCode, 'Unknown API error');
    }
  }

  @override
  String toString() {
    return 'ApiError(statusCode: $statusCode, message: $message, details: $details)';
  }
}
