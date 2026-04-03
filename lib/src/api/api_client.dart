import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:flutter/foundation.dart';
import '../common/config/app_config.dart';

class ApiClient {
  static String get baseUrl => AppConfig.baseUrl; 
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  static const FlutterSecureStorage secureStorage = FlutterSecureStorage();
  static void Function()? onUnauthorized;

  static void initialize() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Read token from secure storage
          String? token = await secureStorage.read(key: 'jwt_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            // Handle global 401 Unauthorized errors by clearing the token
            await secureStorage.delete(key: 'jwt_token');
            // Trigger a logout event if a listener is attached
            onUnauthorized?.call();
          }
          return handler.next(e);
        },
      ),
    );
  }
}
