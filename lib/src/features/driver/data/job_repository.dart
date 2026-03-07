import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/api/api_client.dart';
import '../../../common/api/api_providers.dart';
import '../../../common/models/order.dart';

class JobRepository {
  final ApiClient _apiClient;

  JobRepository(this._apiClient);

  Future<List<Order>> getAvailableJobs() async {
    try {
      final response = await _apiClient.get('/jobs/available');
      final List<dynamic> data = response.data;
      return data.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> submitBid({
    required String orderId,
    required double amount,
    String? pickupTime,
    String? deliveryTime,
  }) async {
    try {
      final response = await _apiClient.post(
        '/jobs/$orderId/bid',
        data: {
          'amount': amount,
          'estimated_pickup_time': pickupTime,
          'estimated_delivery_time': deliveryTime,
        },
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<List<dynamic>> getDriverBids() async {
    try {
      final response = await _apiClient.get('/driver/bids');
      return response.data as List<dynamic>;
    } catch (e) {
      return [];
    }
  }
}

final jobRepositoryProvider = Provider<JobRepository>((ref) {
  return JobRepository(ref.watch(apiClientProvider));
});

final availableJobsProvider = FutureProvider<List<Order>>((ref) {
  return ref.watch(jobRepositoryProvider).getAvailableJobs();
});

final driverBidsProvider = FutureProvider<List<dynamic>>((ref) {
  return ref.watch(jobRepositoryProvider).getDriverBids();
});
