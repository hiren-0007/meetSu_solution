import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';
import 'package:meetsu_solutions/main.dart';

class ApiClient {
  final String baseUrlNew = 'https://meetsusolutions.com/api/web/';
  final Map<String, String> _headers;

  // Add timeouts for connection issues
  final Duration _connectionTimeout = const Duration(seconds: 30);
  final Duration _receiveTimeout = const Duration(seconds: 30);

  ApiClient({Map<String, String>? headers})
      : _headers = headers ??
            {
              'Accept': 'application/json',
            };

  // Add auth token
  void addAuthToken(String token) {
    _headers['Authorization'] = 'Bearer $token';
  }

  // Remove auth token
  void removeAuthToken() {
    _headers.remove('Authorization');
  }

  // Handle 401 Unauthorized - with option to skip for login
  void _handle401(http.Response response, {bool skipRedirect = false}) async {
    if (skipRedirect) {
      debugPrint('401 detected but skipping redirect for login endpoint');
      return;
    }

    try {
      await SharedPrefsService.instance.clear();
      removeAuthToken();

      if (navigatorKey.currentState != null) {
        navigatorKey.currentState!.pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('Error handling 401: $e');
    }
  }

  // Generic GET request
  Future<Map<String, dynamic>> get(String endpoint,
      {Map<String, dynamic>? queryParams}) async {
    try {
      debugPrint('Making GET request to: ${baseUrlNew + endpoint}');
      final uri = Uri.parse(baseUrlNew + endpoint)
          .replace(queryParameters: queryParams);

      final client = http.Client();
      try {
        final request = http.Request('GET', uri);
        request.headers.addAll(_headers);

        final streamedResponse =
            await client.send(request).timeout(_connectionTimeout);

        final response = await http.Response.fromStream(streamedResponse)
            .timeout(_receiveTimeout);

        return _handleResponse(response);
      } finally {
        client.close();
      }
    } catch (e) {
      debugPrint('GET request error: $e');
      throw _handleError(e);
    }
  }

  // Generic POST request - now with option for form data and login context
  Future<Map<String, dynamic>> post(String endpoint,
      {dynamic body,
      bool useFormData = false,
      bool isLoginRequest = false}) async {
    try {
      debugPrint('Making POST request to: ${baseUrlNew + endpoint}');
      debugPrint('Request body: $body');
      debugPrint('Using form-data: $useFormData');
      debugPrint('Is login request: $isLoginRequest');

      final uri = Uri.parse(baseUrlNew + endpoint);

      if (useFormData) {
        final request = http.MultipartRequest('POST', uri);

        Map<String, String> headers = Map.from(_headers);
        headers.remove('Content-Type');
        request.headers.addAll(headers);

        // Add form fields
        if (body != null) {
          body.forEach((key, value) {
            request.fields[key] = value.toString();
          });
        }

        final client = http.Client();
        try {
          final streamedResponse =
              await client.send(request).timeout(_connectionTimeout);

          final response = await http.Response.fromStream(streamedResponse)
              .timeout(_receiveTimeout);

          return _handleResponse(response, isLoginRequest: isLoginRequest);
        } finally {
          client.close();
        }
      } else {
        // Use original JSON approach
        final client = http.Client();
        try {
          final request = http.Request('POST', uri);
          request.headers
              .addAll({..._headers, 'Content-Type': 'application/json'});
          request.body = jsonEncode(body);

          final streamedResponse =
              await client.send(request).timeout(_connectionTimeout);

          final response = await http.Response.fromStream(streamedResponse)
              .timeout(_receiveTimeout);

          return _handleResponse(response, isLoginRequest: isLoginRequest);
        } finally {
          client.close();
        }
      }
    } catch (e) {
      debugPrint('POST request error: $e');
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
        request.headers
            .addAll({..._headers, 'Content-Type': 'application/json'});
        request.body = jsonEncode(body);

        final streamedResponse =
            await client.send(request).timeout(_connectionTimeout);

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

        final streamedResponse =
            await client.send(request).timeout(_connectionTimeout);

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

  // Add this method to your ApiClient class
  Future<Map<String, dynamic>> postMultipart(
    String endpoint, {
    Map<String, dynamic>? body,
    File? file,
    String? fileField,
  }) async {
    try {
      debugPrint('Making POST multipart request to: ${baseUrlNew + endpoint}');

      final uri = Uri.parse(baseUrlNew + endpoint);
      final request = http.MultipartRequest('POST', uri);

      Map<String, String> headers = Map.from(_headers);
      headers.remove('Content-Type');
      request.headers.addAll(headers);

      if (body != null) {
        body.forEach((key, value) {
          request.fields[key] = value.toString();
        });
      }

      if (file != null && fileField != null) {
        final fileStream = http.ByteStream(file.openRead());
        final fileLength = await file.length();

        final multipartFile = http.MultipartFile(
          fileField,
          fileStream,
          fileLength,
          filename: file.path.split('/').last,
        );

        request.files.add(multipartFile);
      }

      // Send the request
      final client = http.Client();
      try {
        final streamedResponse =
            await client.send(request).timeout(_connectionTimeout);

        final response = await http.Response.fromStream(streamedResponse)
            .timeout(_receiveTimeout);

        return _handleResponse(response);
      } finally {
        client.close();
      }
    } catch (e) {
      debugPrint('POST multipart request error: $e');
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> fetchQuote() async {
    try {
      final url = Uri.parse(
          'https://api.forismatic.com/api/1.0/?method=getQuote&lang=en&format=json');

      final client = http.Client();
      try {
        final response = await client.get(url).timeout(_connectionTimeout);

        if (response.statusCode == 200) {
          return json.decode(response.body);
        } else {
          throw HttpException(
            statusCode: response.statusCode,
            message: response.body,
          );
        }
      } finally {
        client.close();
      }
    } catch (e) {
      debugPrint('Error fetching quote: $e');
      throw _handleError(e);
    }
  }

  // Updated _handleResponse method with login context
  Map<String, dynamic> _handleResponse(http.Response response,
      {bool isLoginRequest = false}) {
    debugPrint('=== API RESPONSE ===');
    debugPrint('Status Code: ${response.statusCode}');
    debugPrint('Response Body: ${response.body}');
    debugPrint('Is Login Request: $isLoginRequest');
    debugPrint('==================');

    // Parse response data
    Map<String, dynamic> responseData;
    if (response.body.isEmpty) {
      responseData = {};
    } else {
      try {
        responseData = json.decode(response.body);
      } catch (e) {
        debugPrint('Error decoding JSON: $e');
        responseData = {'body': response.body};
      }
    }

    responseData['statusCode'] = response.statusCode;

    // Handle different response codes
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Success response
      return responseData;
    } else if (response.statusCode == 401) {
      // Handle 401 - don't auto-redirect if it's a login request
      _handle401(response, skipRedirect: isLoginRequest);

      if (isLoginRequest) {
        // For login requests, return the error response instead of throwing
        return responseData;
      } else {
        // For authenticated endpoints, throw exception
        throw HttpException(
          statusCode: response.statusCode,
          message: response.body,
        );
      }
    } else {
      // Other error codes - throw exception
      throw HttpException(
        statusCode: response.statusCode,
        message: response.body.isNotEmpty
            ? response.body
            : 'HTTP ${response.statusCode}',
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
