import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

enum AppExceptionType {
  network,
  server,
  serverError, // 500
  sessionExpired, // 401/403
  timeout,
  cancelled,
  unknown,
}

class AppExceptions implements Exception {
  final AppExceptionType type;
  final Object? exception;

  AppExceptions(this.type, {this.exception});

  factory AppExceptions.from(Object e) {
    if (e is SocketException ||
        e is ClientException ||
        e.toString().contains('ClientException with SocketException')) {
      return AppExceptions(AppExceptionType.network, exception: e);
    }

    if (e is TimeoutException) {
      return AppExceptions(AppExceptionType.timeout, exception: e);
    }

    if (e is AppExceptions) return e;

    return AppExceptions(AppExceptionType.unknown, exception: e);
  }

  // TODO: replace hardcoded strings with localization keys e.g. context.l10n.networkError
  String message(BuildContext context) {
    switch (type) {
      case AppExceptionType.network:
        return 'No network connection.';
      case AppExceptionType.server:
        return exception?.toString() ?? 'A server error occurred.';
      case AppExceptionType.serverError:
        return 'Something went wrong. Kindly retry later.';
      case AppExceptionType.sessionExpired:
        return 'Session Expired. Kindly login again to continue.';
      case AppExceptionType.timeout:
        return 'Request timed out. Please try again.';
      case AppExceptionType.cancelled:
        return 'Request was cancelled.';
      case AppExceptionType.unknown:
        return exception?.toString() ?? 'An unexpected error occurred.';
    }
  }
}
