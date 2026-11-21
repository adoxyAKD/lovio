import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../app/config/app_config.dart';
import '../errors/failures.dart';

abstract class ApiClient {
  Future<dynamic> get(String endpoint, {Map<String, String>? headers});
  Future<dynamic> post(String endpoint,
      {dynamic body, Map<String, String>? headers});
  Future<dynamic> put(String endpoint,
      {dynamic body, Map<String, String>? headers});
  Future<dynamic> delete(String endpoint, {Map<String, String>? headers});
}

class HttpApiClient implements ApiClient {
  final http.Client _client;
  final String _baseUrl;

  HttpApiClient({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? AppConfig.current.apiBaseUrl;

  Map<String, String> _buildHeaders(Map<String, String>? customHeaders) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?customHeaders,
    };
  }

  Uri _buildUri(String endpoint) {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    return Uri.parse('$_baseUrl$cleanEndpoint');
  }

  dynamic _processResponse(http.Response response) {
    final statusCode = response.statusCode;
    if (statusCode >= 200 && statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else if (statusCode == 401) {
      throw const AuthFailure('Session expired or unauthorized.');
    } else if (statusCode >= 400 && statusCode < 500) {
      throw ValidationFailure(response.body, code: '$statusCode');
    } else {
      throw ServerFailure(
          'Server returned status $statusCode: ${response.body}',
          code: '$statusCode');
    }
  }

  @override
  Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    try {
      final response = await _client.get(
        _buildUri(endpoint),
        headers: _buildHeaders(headers),
      );
      return _processResponse(response);
    } on SocketException {
      throw const NetworkFailure();
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<dynamic> post(String endpoint,
      {dynamic body, Map<String, String>? headers}) async {
    try {
      final response = await _client.post(
        _buildUri(endpoint),
        headers: _buildHeaders(headers),
        body: body != null ? jsonEncode(body) : null,
      );
      return _processResponse(response);
    } on SocketException {
      throw const NetworkFailure();
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<dynamic> put(String endpoint,
      {dynamic body, Map<String, String>? headers}) async {
    try {
      final response = await _client.put(
        _buildUri(endpoint),
        headers: _buildHeaders(headers),
        body: body != null ? jsonEncode(body) : null,
      );
      return _processResponse(response);
    } on SocketException {
      throw const NetworkFailure();
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<dynamic> delete(String endpoint,
      {Map<String, String>? headers}) async {
    try {
      final response = await _client.delete(
        _buildUri(endpoint),
        headers: _buildHeaders(headers),
      );
      return _processResponse(response);
    } on SocketException {
      throw const NetworkFailure();
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }
}
