import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/admin_api.dart';
import '../domain/admin_stats.dart';

final adminApiProvider = Provider<AdminApi>((ref) => AdminApi());

final adminStatsProvider = FutureProvider<AdminStats>((ref) => ref.read(adminApiProvider).getStats());

final adminUsersProvider = FutureProvider.family<List<Map<String, dynamic>>, String?>((ref, role) {
  return ref.read(adminApiProvider).getUsers(role: role);
});

final adminOrdersProvider = FutureProvider((ref) {
  return ref.read(adminApiProvider).getOrders();
});
