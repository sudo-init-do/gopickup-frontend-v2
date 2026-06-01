import 'package:dio/dio.dart';
import '../models/user_models.dart';
import 'api_client.dart';

class AuthApi {
  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String role,
  ) async {
    try {
      final response = await ApiClient.dio.post(
        'auth/register',
        data: {'email': email, 'password': password, 'role': role},
      );
      return response.data; // Expected { "token": "jwt...", "user": { ... } }
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Registration failed');
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    try {
      final response = await ApiClient.dio.post(
        'auth/verify-otp',
        data: {'email': email, 'otp': otp},
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'OTP verification failed');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await ApiClient.dio.post(
        'auth/login',
        data: {'email': email, 'password': password},
      );
      return response.data; // Expected { "token": "jwt...", "user": { ... } }
    } on DioException catch (e) {
      throw Exception(_authError(e, 'Login failed'));
    }
  }

  // Builds a user-facing error from a DioException. When there is no HTTP
  // response at all (timeout/DNS/CORS/offline) we surface a network message
  // instead of a misleading generic "Login failed".
  String _authError(DioException e, String fallback) {
    if (e.response == null) {
      return 'Network issue, please check your connection.';
    }
    final data = e.response?.data;
    if (data is Map && data['error'] != null) return data['error'].toString();
    return data?.toString() ?? fallback;
  }

  Future<Map<String, dynamic>> adminLogin(String email, String password) async {
    try {
      final response = await ApiClient.dio.post(
        'auth/admin-login',
        data: {'email': email, 'password': password},
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(_authError(e, 'Admin login failed'));
    }
  }

  Future<User> getCurrentUser() async {
    try {
      final response = await ApiClient.dio.get('auth/me');
      return User.fromJson(response.data);
    } on DioException catch (e) {
      final msg = (e.response?.data is Map) ? e.response?.data['error'] : (e.response?.data?.toString() ?? 'Failed to get current user');
      throw Exception(msg);
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await ApiClient.dio.post(
        'auth/forgot-password',
        data: {'email': email},
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Forgot password failed');
    }
  }

  Future<void> resetPassword(String email, String otp, String newPassword) async {
    try {
      await ApiClient.dio.post(
        'auth/reset-password',
        data: {
          'email': email,
          'otp': otp,
          'new_password': newPassword,
        },
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Reset password failed');
    }
  }
}
