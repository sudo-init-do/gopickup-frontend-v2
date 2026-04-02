import 'package:dio/dio.dart';
import '../models/user_models.dart';
import 'api_client.dart';

class ProfileApi {
  Future<void> createClientProfile(ClientProfile profile) async {
    try {
      await ApiClient.dio.post('profile/client', data: profile.toJson());
    } on DioException catch (e) {
      final msg = (e.response?.data is Map) ? e.response?.data['error'] : (e.response?.data?.toString() ?? 'Client profile creation failed');
      throw Exception(msg);
    }
  }

  Future<void> createDriverProfile(DriverProfile profile) async {
    try {
      await ApiClient.dio.post('profile/driver', data: profile.toJson());
    } on DioException catch (e) {
      final msg = (e.response?.data is Map) ? e.response?.data['error'] : (e.response?.data?.toString() ?? 'Driver profile creation failed');
      throw Exception(msg);
    }
  }

  Future<void> createVendorProfile(VendorProfile profile) async {
    try {
      await ApiClient.dio.post('profile/vendor', data: profile.toCreateJson());
    } on DioException catch (e) {
      final msg = (e.response?.data is Map) ? e.response?.data['error'] : (e.response?.data?.toString() ?? 'Vendor profile creation failed');
      throw Exception(msg);
    }
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    try {
      await ApiClient.dio.put('profile', data: updates);
    } on DioException catch (e) {
      final msg = (e.response?.data is Map) ? e.response?.data['error'] : (e.response?.data?.toString() ?? 'Profile update failed');
      throw Exception(msg);
    }
  }

  Future<DriverProfile> getDriverProfile() async {
    try {
      final response = await ApiClient.dio.get('profile/driver');
      return DriverProfile.fromJson(response.data);
    } on DioException catch (e) {
      final msg = (e.response?.data is Map) ? e.response?.data['error'] : (e.response?.data?.toString() ?? 'Failed to get driver profile');
      throw Exception(msg);
    }
  }

  Future<VendorProfile> getVendorProfile() async {
    try {
      final response = await ApiClient.dio.get('profile/vendor');
      return VendorProfile.fromJson(response.data);
    } on DioException catch (e) {
      final msg = (e.response?.data is Map) ? e.response?.data['error'] : (e.response?.data?.toString() ?? 'Failed to get vendor profile');
      throw Exception(msg);
    }
  }

  Future<ClientProfile> getClientProfile() async {
    try {
      final response = await ApiClient.dio.get('profile/client');
      return ClientProfile.fromJson(response.data);
    } on DioException catch (e) {
      final msg = (e.response?.data is Map) ? e.response?.data['error'] : (e.response?.data?.toString() ?? 'Failed to get client profile');
      throw Exception(msg);
    }
  }

  Future<Map<String, dynamic>> getFullProfile() async {
    try {
      final response = await ApiClient.dio.get('profile');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final error = (e.response?.data is Map) 
        ? e.response?.data['error'] 
        : (e.response?.data?.toString() ?? 'Failed to get full profile');
      throw Exception(error);
    }
  }
}
