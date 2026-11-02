import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/app_constants.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  /// `true` when the server could not be reached or did not answer with the
  /// documented JSON contract (DNS/TLS/socket errors, 404 HTML pages, 5xx...).
  final bool isUnreachable;

  const ApiException(
    this.message, {
    this.statusCode,
    this.isUnreachable = false,
  });

  @override
  String toString() => message;
}

/// Thin wrapper around `package:http` that speaks JSON with the Calley API.
class ApiClient {
  ApiClient({http.Client? client, this.baseUrl = ApiConstants.baseUrl})
      : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;

  static const _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<dynamic> get(String path, {Map<String, String>? query}) {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    return _send(() => _client.get(uri, headers: _headers), 'GET', uri);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) {
    final uri = Uri.parse('$baseUrl$path');
    return _send(
      () => _client.post(uri, headers: _headers, body: jsonEncode(body)),
      'POST',
      uri,
    );
  }

  Future<dynamic> _send(
    Future<http.Response> Function() request,
    String method,
    Uri uri,
  ) async {
    http.Response response;
    try {
      response = await request().timeout(ApiConstants.timeout);
    } on TimeoutException {
      throw const ApiException('The server took too long to respond.',
          isUnreachable: true);
    } on HandshakeException {
      throw const ApiException('Secure connection to the server failed.',
          isUnreachable: true);
    } on SocketException {
      throw const ApiException(
          'No internet connection or the server is unreachable.',
          isUnreachable: true);
    } on http.ClientException catch (e) {
      throw ApiException('Network error: ${e.message}', isUnreachable: true);
    }

    debugPrint('[API] $method $uri -> ${response.statusCode}');

    dynamic decoded;
    try {
      decoded = response.body.isEmpty ? null : jsonDecode(response.body);
    } on FormatException {
      // Server answered with HTML / plain text instead of JSON.
      throw ApiException(
        'Unexpected response from server (${response.statusCode}).',
        statusCode: response.statusCode,
        isUnreachable: true,
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    throw ApiException(
      _extractMessage(decoded) ?? 'Request failed (${response.statusCode}).',
      statusCode: response.statusCode,
      isUnreachable: response.statusCode >= 500,
    );
  }

  String? _extractMessage(dynamic decoded) {
    if (decoded is Map) {
      for (final key in ['message', 'error', 'msg']) {
        final value = decoded[key];
        if (value is String && value.isNotEmpty) return value;
      }
    }
    return null;
  }
}
