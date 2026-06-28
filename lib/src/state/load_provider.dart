import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/loads_api.dart';
import '../models/load_models.dart';

final loadsApiProvider = Provider<LoadsApi>((ref) => LoadsApi());

/// Client: the loads I have posted.
final myLoadsProvider = FutureProvider<List<Load>>((ref) {
  return ref.watch(loadsApiProvider).getMyLoads();
});

/// Driver: open loads available to bid on.
final availableLoadsProvider = FutureProvider<List<Load>>((ref) {
  return ref.watch(loadsApiProvider).listAvailableLoads();
});

/// Driver: loads assigned to me that are in progress.
final assignedLoadsProvider = FutureProvider<List<Load>>((ref) {
  return ref.watch(loadsApiProvider).getAssignedLoads();
});

/// A single load by id — used as the polling fallback on the matching/tracking
/// screens in case a websocket event is missed across a reconnect.
final loadProvider = FutureProvider.family<Load, String>((ref, id) {
  return ref.watch(loadsApiProvider).getLoad(id);
});
