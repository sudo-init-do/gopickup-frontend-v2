import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/api/api_client.dart';
import '../../../common/api/api_providers.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final _storage = const FlutterSecureStorage();

  AuthRepository(this._apiClient);

  Future<bool> login(String email, String password) async {
    try {
      final response = await _apiClient.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final token = response.data['token'];
        final role = response.data['user']['role'];
        final userId = response.data['user']['id'];
        await _storage.write(key: 'jwt_token', value: token);
        await _storage.write(key: 'user_role', value: role);
        await _storage.write(key: 'user_id', value: userId);
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> register(String email, String password, String role) async {
    try {
      final response = await _apiClient.post('/auth/register', data: {
        'email': email,
        'password': password,
        'role': role.toLowerCase(),
      });
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> verifyOTP(String email, String otp) async {
    try {
      final response = await _apiClient.post('/auth/verify-otp', data: {
        'email': email,
        'code': otp,
      });
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> completeOnboarding(Map<String, dynamic> profileData) async {
    try {
      final response = await _apiClient.post('/auth/onboarding/complete', data: profileData);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'user_role');
    await _storage.delete(key: 'user_id');
  }


  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'jwt_token');
    return token != null;
  }

  Future<String?> getUserRole() async {
    return await _storage.read(key: 'user_role');
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(apiClientProvider));
});


