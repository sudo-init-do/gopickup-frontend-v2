import 'package:dio/dio.dart';
import 'api_client.dart';

class NotificationsApi {
  Future<void> updateFcmToken(String token) async {
    try {
      await ApiClient.dio.put('/notifications/fcm-token', data: {
        'token': token,
      });
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Failed to update FCM token');
    }
  }
}
