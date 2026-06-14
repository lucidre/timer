import 'package:timer/common_libs.dart';
import 'package:timer/shared/api/network_response.dart';
import 'package:timer/shared/api/http_client.dart';
import 'package:http/http.dart' as http;

export 'package:timer/shared/api/connectivity.dart';

// ─── Config ───────────────────────────────────────────────────────────────────

const String hostUrl = 'http://8.8.4.4';
const bool isLive = false;

const Duration _kTimeout = Duration(seconds: 10);

// ─── Platform-aware client ────────────────────────────────────────────────────

http.Client _buildClient() => buildHttpClient();

// ─── Logging ──────────────────────────────────────────────────────────────────

void _log(String label, Object? value) =>
    $log('Network', '[$label] ${value.toString()}');

void _logRequest(String method, String url, {Map? headers, Object? body}) {
  _log('$method URL', url);
  _log('$method HEADERS', headers);
  if (body != null) _log('$method BODY', body);
}

void _logResponse(int statusCode, Object? body) {
  _log('RESPONSE STATUS', statusCode);
  _log('RESPONSE BODY', body);
}

// ─── Headers ──────────────────────────────────────────────────────────────────

Map<String, String> get _defaultHeaders => {'Content-Type': 'application/json'};

Map<String, String> _buildHeaders({Map<String, String>? extra, String? token}) {
  return {
    ..._defaultHeaders,
    ...(extra ?? {}),
    if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
  };
}

// ─── Response Parser ──────────────────────────────────────────────────────────

NetworkResponse _parseResponse(http.Response response) {
  final statusCode = response.statusCode;

  dynamic jsonData;
  try {
    jsonData = jsonDecode(response.body);
  } catch (_) {
    jsonData = {'message': response.body};
  }

  _logResponse(statusCode, jsonData);

  if (statusCode == 200 || statusCode == 201) {
    return NetworkResponse(
      data: jsonData,
      isError: false,
      statusCode: statusCode,
      message: jsonData['message'],
    );
  } else if (statusCode == 500) {
    throw AppExceptions(AppExceptionType.serverError);
  } else {
    return NetworkResponse(
      data: jsonData,
      isError: true,
      statusCode: statusCode,
      message: jsonData['message'],
    );
  }
}

// ─── Exception Handler ────────────────────────────────────────────────────────

Never _handleException(Object e) {
  _log('EXCEPTION', e);
  throw AppExceptions.from(e);
}

// ─── HTTP Methods ─────────────────────────────────────────────────────────────

Future<NetworkResponse> $get(
  String url, {
  String? host,
  String? token,
  Map<String, String>? headers,
}) async {
  final fullUrl = '${host ?? hostUrl}$url';
  final builtHeaders = _buildHeaders(extra: headers, token: token);
  final client = _buildClient();
  try {
    _logRequest('GET', fullUrl, headers: builtHeaders);
    final response = await client
        .get(Uri.parse(fullUrl), headers: builtHeaders)
        .timeout(_kTimeout);
    return _parseResponse(response);
  } catch (e) {
    _handleException(e);
  } finally {
    client.close();
  }
}

Future<NetworkResponse> $post(
  String url, {
  String? host,
  Map<String, dynamic> body = const {},
  Map<String, String>? headers,
  String? token,
}) async {
  final fullUrl = '${host ?? hostUrl}$url';
  final builtHeaders = _buildHeaders(extra: headers, token: token);
  final encodedBody = jsonEncode(body);
  final client = _buildClient();
  try {
    _logRequest('POST', fullUrl, headers: builtHeaders, body: encodedBody);
    final response = await client
        .post(Uri.parse(fullUrl), body: encodedBody, headers: builtHeaders)
        .timeout(_kTimeout);
    return _parseResponse(response);
  } catch (e) {
    _handleException(e);
  } finally {
    client.close();
  }
}

Future<NetworkResponse> $patch(
  String url, {
  String? host,
  Map<String, dynamic> body = const {},
  Map<String, String>? headers,
  String? token,
}) async {
  final fullUrl = '${host ?? hostUrl}$url';
  final builtHeaders = _buildHeaders(extra: headers, token: token);
  final encodedBody = jsonEncode(body);
  final client = _buildClient();
  try {
    _logRequest('PATCH', fullUrl, headers: builtHeaders, body: encodedBody);
    final response = await client
        .patch(Uri.parse(fullUrl), body: encodedBody, headers: builtHeaders)
        .timeout(_kTimeout);
    return _parseResponse(response);
  } catch (e) {
    _handleException(e);
  } finally {
    client.close();
  }
}

Future<NetworkResponse> $put(
  String url, {
  String? host,
  Map<String, dynamic> body = const {},
  Map<String, String>? headers,
  String? token,
}) async {
  final fullUrl = '${host ?? hostUrl}$url';
  final builtHeaders = _buildHeaders(extra: headers, token: token);
  final encodedBody = jsonEncode(body);
  final client = _buildClient();
  try {
    _logRequest('PUT', fullUrl, headers: builtHeaders, body: encodedBody);
    final response = await client
        .put(Uri.parse(fullUrl), body: encodedBody, headers: builtHeaders)
        .timeout(_kTimeout);
    return _parseResponse(response);
  } catch (e) {
    _handleException(e);
  } finally {
    client.close();
  }
}

Future<NetworkResponse> $delete(
  String url, {
  String? host,
  Map<String, String>? headers,
  String? token,
}) async {
  final fullUrl = '${host ?? hostUrl}$url';
  final builtHeaders = _buildHeaders(extra: headers, token: token);
  final client = _buildClient();
  try {
    _logRequest('DELETE', fullUrl, headers: builtHeaders);
    final response = await client
        .delete(Uri.parse(fullUrl), headers: builtHeaders)
        .timeout(_kTimeout);
    return _parseResponse(response);
  } catch (e) {
    _handleException(e);
  } finally {
    client.close();
  }
}
