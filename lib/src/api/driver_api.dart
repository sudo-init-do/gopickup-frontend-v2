import 'package:dio/dio.dart';
import '../models/order_models.dart';
import 'api_client.dart';

class DriverApi {
  Future<void> updateLocation({
    required double lat,
    required double lng,
  }) async {
    try {
      await ApiClient.dio.patch(
        'driver/location',
        data: {'lat': lat, 'lng': lng},
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Failed to update location');
    }
  }

  Future<List<Order>> getAssignedJobs() async {
    try {
      final response = await ApiClient.dio.get('jobs/assigned');
      return (response.data as List).map((o) => Order.fromJson(o)).toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['error'] ?? 'Failed to get assigned jobs',
      );
    }
  }

  Future<void> acceptJob(String jobId) async {
    try {
      await ApiClient.dio.post('jobs/$jobId/accept');
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Failed to accept job');
    }
  }
}
