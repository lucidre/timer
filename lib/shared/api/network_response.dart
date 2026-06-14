class NetworkResponse {
  final dynamic data;
  final dynamic message;
  final bool isError;
  final int statusCode;

  NetworkResponse({
    required this.data,
    required this.isError,
    required this.statusCode,
    required this.message,
  });
}
