import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/profile_api.dart';
import '../models/user_models.dart';

final profileApiProvider = Provider((ref) => ProfileApi());

class ProfileState {
  final bool isLoading;
  final String? error;

  ProfileState({this.isLoading = false, this.error});

  ProfileState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class ProfileNotifier extends Notifier<ProfileState> {
  ProfileApi get _api => ref.read(profileApiProvider);

  @override
  ProfileState build() {
    return ProfileState();
  }

  Future<bool> createClientProfile(ClientProfile profile) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _api.createClientProfile(profile);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> createDriverProfile(DriverProfile profile) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _api.createDriverProfile(profile);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> createVendorProfile(VendorProfile profile) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _api.createVendorProfile(profile);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _api.updateProfile(updates);
      state = state.copyWith(isLoading: false);
      ref.invalidate(fullProfileProvider);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final fullProfileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final user = ref.watch(authProvider).user;
  final api = ref.watch(profileApiProvider);
  
  if (user == null) {
    throw Exception('User not logged in');
  }

  try {
    if (user.role == 'client') {
      final profile = await api.getClientProfile();
      return profile.toJson();
    } else if (user.role == 'driver') {
      final profile = await api.getDriverProfile();
      return profile.toJson();
    } else if (user.role == 'vendor') {
      final profile = await api.getVendorProfile();
      return profile.toJson();
    }
    
    // Fallback to generic if role is something else or above fails
    return await api.getFullProfile();
  } catch (e) {
    // If specific one fails, try generic as last resort before giving up
    try {
      return await api.getFullProfile();
    } catch (_) {
      rethrow;
    }
  }
});

final profileProvider = NotifierProvider<ProfileNotifier, ProfileState>(() {
  return ProfileNotifier();
});

final driverProfileProvider = FutureProvider<DriverProfile>((ref) {
  return ref.watch(profileApiProvider).getDriverProfile();
});

final vendorProfileProvider = FutureProvider<VendorProfile>((ref) {
  return ref.watch(profileApiProvider).getVendorProfile();
});
