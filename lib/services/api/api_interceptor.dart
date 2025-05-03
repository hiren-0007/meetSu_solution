import 'package:dio/dio.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';
import 'package:flutter/material.dart';

class AuthInterceptor extends Interceptor {
  final GlobalKey<NavigatorState>? navigatorKey;

  AuthInterceptor({this.navigatorKey});

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Check if response status code is 401
    if (response.statusCode == 401) {
      _handleUnauthorized();
      handler.reject(DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error: 'Unauthorized',
      ));
    } else {
      handler.next(response);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Check if error status code is 401
    if (err.response?.statusCode == 401) {
      _handleUnauthorized();
    }
    handler.next(err);
  }

  // Handle unauthorized access
  void _handleUnauthorized() async {
    try {
      // Clear all data
      await SharedPrefsService.instance.clear();

      // Navigate to login screen
      if (navigatorKey?.currentState != null) {
        navigatorKey!.currentState!.pushNamedAndRemoveUntil(
          '/login',
              (route) => false, // Remove all routes
        );
      }
    } catch (e) {
      debugPrint('Error in handling unauthorized: $e');
    }
  }
}