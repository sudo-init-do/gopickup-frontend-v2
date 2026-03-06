import 'package:dio/dio.dart';
import '../models/user_models.dart';
import 'api_client.dart';

class ProfileApi {
  Future<void> createClientProfile(ClientProfile profile) async {
    try {
      await ApiClient.dio.post('/profile/client', data: profile.toJson());
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['error'] ?? 'Client profile creation failed',
      );
    }
  }

  Future<void> createDriverProfile(DriverProfile profile) async {
    try {
      await ApiClient.dio.post('/profile/driver', data: profile.toJson());
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['error'] ?? 'Driver profile creation failed',
      );
    }
  }

  Future<void> createVendorProfile(VendorProfile profile) async {
    try {
      await ApiClient.dio.post('/profile/vendor', data: profile.toJson());
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['error'] ?? 'Vendor profile creation failed',
      );
    }
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    try {
      await ApiClient.dio.put('/profile', data: updates);
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Profile update failed');
    }
  }
}
