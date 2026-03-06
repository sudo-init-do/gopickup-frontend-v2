import 'package:dio/dio.dart';
import '../models/order_models.dart';
import 'api_client.dart';

class DriverApi {
  Future<void> updateLocation({required double lat, required double lng}) async {
    try {
      await ApiClient.dio.patch('/driver/location', data: {
        'lat': lat,
        'lng': lng,
      });
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Failed to update location');
    }
  }

  Future<List<Order>> getAvailableJobs() async {
    try {
      final response = await ApiClient.dio.get('/jobs/available');
      return (response.data as List).map((o) => Order.fromJson(o)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Failed to get available jobs');
    }
  }

  Future<JobBid> placeBid(String orderId, double amount) async {
    try {
      final response = await ApiClient.dio.post('/jobs/$orderId/bid', data: {
        'amount': amount,
      });
      return JobBid.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Failed to place bid');
    }
  }
}
