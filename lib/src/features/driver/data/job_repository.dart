import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/api/api_client.dart';
import '../../../common/api/api_providers.dart';
import '../../../common/models/order.dart';

class JobRepository {
  final ApiClient _apiClient;

  JobRepository(this._apiClient);

  Future<List<Order>> getAssignedJobs() async {
    try {
      final response = await _apiClient.get('jobs/assigned');
      final List<dynamic> data = response.data;
      return data.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> acceptJob(String orderId) async {
    try {
      final response = await _apiClient.post('jobs/$orderId/accept');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}

final jobRepositoryProvider = Provider<JobRepository>((ref) {
  return JobRepository(ref.watch(apiClientProvider));
});

final assignedJobsProvider = FutureProvider<List<Order>>((ref) {
  return ref.watch(jobRepositoryProvider).getAssignedJobs();
});
