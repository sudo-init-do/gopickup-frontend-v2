import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'mock_interceptor.dart';

class ApiClient {
  late final Dio dio;
  final storage = const FlutterSecureStorage();
  final void Function()? onUnauthorized;

  ApiClient({
    required String baseUrl,
    bool useMock = false,
    this.onUnauthorized,
  }) {
    dio = Dio(
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

    if (useMock) {
      dio.interceptors.add(MockInterceptor());
    }

    // Add interceptor for JWT authentication
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storage.read(key: 'jwt_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            // Handle global 401 Unauthorized by clearing local token
            await storage.delete(key: 'jwt_token');
            // Trigger the onUnauthorized callback if provided
            onUnauthorized?.call();
          }
          return handler.next(e);
        },
      ),
    );
  }

  // Helper methods for common HTTP verbs
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data, Options? options}) {
    return dio.post(path, data: data, options: options);
  }

  Future<Response> put(String path, {dynamic data}) {
    return dio.put(path, data: data);
  }

  Future<Response> patch(String path, {dynamic data}) {
    return dio.patch(path, data: data);
  }

  Future<Response> delete(String path) {
    return dio.delete(path);
  }

  Future<Response> uploadImage(String path, {required MultipartFile file}) async {
    final token = await storage.read(key: 'jwt_token');
    final formData = FormData.fromMap({
      'image': file,
    });
    
    // Explicitly add token to URL to bypass header-stripping issues in some environments
    final uploadPath = token != null ? '$path?token=$token' : path;

    return dio.post(
      uploadPath,
      data: formData,
      options: Options(
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ),
    );
  }
}
