class ApiError {
  final int statusCode;
  final String message;
  final Map<String, dynamic>? details;

  ApiError(this.statusCode, this.message, {this.details});

  factory ApiError.fromJson(Map json, int statusCode) {
    try {
      if (json.containsKey('errors')) {
        var errorJson = json['errors'] is List ? (json['errors'] as List).first : json['errors'];
        if (errorJson is String) {
          return ApiError(statusCode, errorJson);
        }

        if (errorJson is Map<String, dynamic>) {
          return ApiError(statusCode, 'Error with Details', details: errorJson);
        }

        return ApiError(statusCode, 'Unknown Error');
      } else if (json.toString().contains('error')) {
        var errorJson = json['error'];
        if (errorJson is String) {
          return ApiError(statusCode, errorJson);
        }
        return ApiError(statusCode, 'Unknown Error');
      } else {
        return ApiError(statusCode, 'Unknown API error');
      }
    } catch (err) {
      return ApiError(statusCode, err.toString());
    }
  }

  @override
  String toString() {
    return 'ApiError(statusCode: $statusCode, message: $message, details: $details)';
  }
}
