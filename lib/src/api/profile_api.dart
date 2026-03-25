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
      await ApiClient.dio.post('/profile/vendor', data: profile.toCreateJson());
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

  Future<DriverProfile> getDriverProfile() async {
    try {
      final response = await ApiClient.dio.get('/profile/driver');
      return DriverProfile.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['error'] ?? 'Failed to get driver profile',
      );
    }
  }

  Future<VendorProfile> getVendorProfile() async {
    try {
      final response = await ApiClient.dio.get('/profile/vendor');
      return VendorProfile.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['error'] ?? 'Failed to get vendor profile',
      );
    }
  }
}
