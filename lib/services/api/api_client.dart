import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrlNew = 'https://meetsusolutions.com/api/web/';
  final Map<String, String> _headers;

  // Add timeouts for connection issues
  final Duration _connectionTimeout = const Duration(seconds: 30);
  final Duration _receiveTimeout = const Duration(seconds: 30);

  ApiClient({Map<String, String>? headers})
      : _headers = headers ?? {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Add auth token
  void addAuthToken(String token) {
    _headers['Authorization'] = 'Bearer $token';
  }

  // Generic GET request
  Future<Map<String, dynamic>> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    try {
      debugPrint('🔍 Making GET request to: ${baseUrlNew + endpoint}');
      final uri = Uri.parse(baseUrlNew + endpoint).replace(queryParameters: queryParams);

      final client = http.Client();
      try {
        final request = http.Request('GET', uri);
        request.headers.addAll(_headers);

        final streamedResponse = await client.send(request)
            .timeout(_connectionTimeout);

        final response = await http.Response.fromStream(streamedResponse)
            .timeout(_receiveTimeout);

        return _handleResponse(response);
      } finally {
        client.close();
      }
    } catch (e) {
      debugPrint('❌ GET request error: $e');
      throw _handleError(e);
    }
  }

  // Generic POST request
  Future<Map<String, dynamic>> post(String endpoint, {dynamic body}) async {
    try {
      debugPrint('🔍 Making POST request to: ${baseUrlNew + endpoint}');
      debugPrint('📦 Request body: $body');

      final uri = Uri.parse(baseUrlNew + endpoint);

      final client = http.Client();
      try {
        final request = http.Request('POST', uri);
        request.headers.addAll(_headers);
        request.body = jsonEncode(body);

        final streamedResponse = await client.send(request)
            .timeout(_connectionTimeout);

        final response = await http.Response.fromStream(streamedResponse)
            .timeout(_receiveTimeout);

        debugPrint('✅ Response status: ${response.statusCode}');
        debugPrint('📄 Response body: ${response.body}');

        return _handleResponse(response);
      } finally {
        client.close();
      }
    } catch (e) {
      debugPrint('❌ POST request error: $e');
      throw _handleError(e);
    }
  }

  // Generic PUT request
  Future<Map<String, dynamic>> put(String endpoint, {dynamic body}) async {
    try {
      final uri = Uri.parse(baseUrlNew + endpoint);

      final client = http.Client();
      try {
        final request = http.Request('PUT', uri);
        request.headers.addAll(_headers);
        request.body = jsonEncode(body);

        final streamedResponse = await client.send(request)
            .timeout(_connectionTimeout);

        final response = await http.Response.fromStream(streamedResponse)
            .timeout(_receiveTimeout);

        return _handleResponse(response);
      } finally {
        client.close();
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Generic DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final uri = Uri.parse(baseUrlNew + endpoint);

      final client = http.Client();
      try {
        final request = http.Request('DELETE', uri);
        request.headers.addAll(_headers);

        final streamedResponse = await client.send(request)
            .timeout(_connectionTimeout);

        final response = await http.Response.fromStream(streamedResponse)
            .timeout(_receiveTimeout);

        return _handleResponse(response);
      } finally {
        client.close();
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      Map<String, dynamic> responseData;
      if (response.body.isEmpty) {
        responseData = {};
      } else {
        try {
          responseData = json.decode(response.body);
        } catch (e) {
          debugPrint('❌ Error decoding JSON: $e');
          responseData = {'body': response.body};
        }
      }

      responseData['statusCode'] = response.statusCode;
      return responseData;
    } else {
      throw HttpException(
        statusCode: response.statusCode,
        message: response.body,
      );
    }
  }

  Exception _handleError(dynamic error) {
    if (error is HttpException) return error;
    return Exception('Something went wrong: ${error.toString()}');
  }
}

class HttpException implements Exception {
  final int statusCode;
  final String message;

  HttpException({
    required this.statusCode,
    required this.message,
  });

  @override
  String toString() => 'HttpException: $statusCode - $message';
}