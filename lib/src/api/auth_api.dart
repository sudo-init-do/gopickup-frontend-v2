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
        '/auth/register',
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
        '/auth/verify-otp',
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
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return response.data; // Expected { "token": "jwt...", "user": { ... } }
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Login failed');
    }
  }

  Future<User> getCurrentUser() async {
    try {
      final response = await ApiClient.dio.get('/auth/me');
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['error'] ?? 'Failed to get current user',
      );
    }
  }
}
