import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
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

  Future<(bool, String?)> acceptJob(String orderId) async {
    try {
      final response = await _apiClient.post('jobs/$orderId/accept');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return (true, null);
      }
      return (false, 'Server error: ${response.statusCode}');
    } on DioException catch (e) {
      final msg = e.response?.data is Map 
          ? (e.response?.data['error'] ?? e.response?.data['message'] ?? e.message)
          : e.message;
      return (false, msg.toString());
    } catch (e) {
      return (false, e.toString());
    }
  }
}

final jobRepositoryProvider = Provider<JobRepository>((ref) {
  return JobRepository(ref.watch(apiClientProvider));
});

final assignedJobsProvider = FutureProvider<List<Order>>((ref) {
  return ref.watch(jobRepositoryProvider).getAssignedJobs();
});
