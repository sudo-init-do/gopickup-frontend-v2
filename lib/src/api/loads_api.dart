import 'package:dio/dio.dart';
import '../models/load_models.dart';
import 'api_client.dart';

/// REST client for the backend "Loads" system (delivery requests + driver bids).
/// Follows the same dio + error-unwrapping pattern as [OrdersApi].
class LoadsApi {
  // ─── Client ────────────────────────────────────────────────────────────────

  Future<Load> createLoad({
    required String title,
    required String goodsType,
    required String pickupAddress,
    required String deliveryAddress,
    String? description,
    double? weight,
    double? budgetAmount,
    double? pickupLat,
    double? pickupLng,
    double? deliveryLat,
    double? deliveryLng,
    DateTime? scheduledAt,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        'loads',
        data: {
          'title': title,
          'goods_type': goodsType,
          'pickup_address': pickupAddress,
          'delivery_address': deliveryAddress,
          if (description != null && description.isNotEmpty)
            'description': description,
          if (weight != null) 'weight': weight,
          if (budgetAmount != null) 'budget_amount': budgetAmount,
          if (pickupLat != null) 'pickup_lat': pickupLat,
          if (pickupLng != null) 'pickup_lng': pickupLng,
          if (deliveryLat != null) 'delivery_lat': deliveryLat,
          if (deliveryLng != null) 'delivery_lng': deliveryLng,
          if (scheduledAt != null)
            'scheduled_at': scheduledAt.toUtc().toIso8601String(),
        },
      );
      return Load.fromJson(_unwrap(response.data));
    } on DioException catch (e) {
      throw Exception(_error(e) ?? 'Failed to create load');
    }
  }

  Future<List<Load>> getMyLoads() async {
    try {
      final response = await ApiClient.dio.get('loads/my');
      return _list(response.data);
    } on DioException catch (e) {
      throw Exception(_error(e) ?? 'Failed to load your requests');
    }
  }

  Future<Load> getLoad(String id) async {
    try {
      final response = await ApiClient.dio.get('loads/$id');
      return Load.fromJson(_unwrap(response.data));
    } on DioException catch (e) {
      throw Exception(_error(e) ?? 'Failed to load request');
    }
  }

  Future<Load> cancelLoad(String id) async {
    try {
      final response = await ApiClient.dio.patch('loads/$id/cancel');
      return Load.fromJson(_unwrap(response.data));
    } on DioException catch (e) {
      throw Exception(_error(e) ?? 'Failed to cancel request');
    }
  }

  Future<Load> acceptLoadBid(String loadId, String bidId) async {
    try {
      final response =
          await ApiClient.dio.post('loads/$loadId/bids/$bidId/accept');
      return Load.fromJson(_unwrap(response.data));
    } on DioException catch (e) {
      throw Exception(_error(e) ?? 'Failed to accept bid');
    }
  }

  // ─── Driver ──────────────────────────────────────────────────────────────────

  Future<List<Load>> listAvailableLoads() async {
    try {
      final response = await ApiClient.dio.get('loads/available');
      return _list(response.data);
    } on DioException catch (e) {
      throw Exception(_error(e) ?? 'Failed to load available jobs');
    }
  }

  Future<List<Load>> getAssignedLoads() async {
    try {
      final response = await ApiClient.dio.get('loads/assigned');
      return _list(response.data);
    } on DioException catch (e) {
      throw Exception(_error(e) ?? 'Failed to load assigned jobs');
    }
  }

  Future<void> placeBid(String loadId, double amount, {String? note}) async {
    try {
      await ApiClient.dio.post(
        'loads/$loadId/bid',
        data: {'amount': amount, if (note != null && note.isNotEmpty) 'note': note},
      );
    } on DioException catch (e) {
      throw Exception(_error(e) ?? 'Failed to place bid');
    }
  }

  Future<void> updateLoadStatus(String loadId, String status) async {
    try {
      await ApiClient.dio.patch('loads/$loadId/status', data: {'status': status});
    } on DioException catch (e) {
      throw Exception(_error(e) ?? 'Failed to update status');
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────────

  /// The list endpoints return either a bare array or `{ "data": [...] }`.
  List<Load> _list(dynamic data) {
    final raw = data is Map<String, dynamic> ? data['data'] : data;
    if (raw is! List) return [];
    return raw
        .map((e) => Load.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Object endpoints return either the load directly or `{ "data": {...} }`
  /// or `{ "load": {...} }`.
  Map<String, dynamic> _unwrap(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['data'] is Map<String, dynamic>) {
        return data['data'] as Map<String, dynamic>;
      }
      if (data['load'] is Map<String, dynamic>) {
        return data['load'] as Map<String, dynamic>;
      }
      return data;
    }
    return <String, dynamic>{};
  }

  String? _error(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      return (data['error'] ?? data['message'])?.toString();
    }
    return e.message;
  }
}
