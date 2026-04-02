import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/profile_api.dart';
import '../models/user_models.dart';
import 'auth_provider.dart';

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

  // Basic info from the user object as a baseline
  final Map<String, dynamic> baseInfo = {
    'email': user.email,
    'role': user.role,
  };

  try {
    if (user.role == 'client') {
      final profile = await api.getClientProfile();
      return {...baseInfo, ...profile.toJson()};
    } else if (user.role == 'driver') {
      final profile = await api.getDriverProfile();
      return {...baseInfo, ...profile.toJson()};
    } else if (user.role == 'vendor') {
      final profile = await api.getVendorProfile();
      return {...baseInfo, ...profile.toJson()};
    }
    
    final generic = await api.getFullProfile();
    return {...baseInfo, ...generic};
  } catch (e) {
    // If it's a 404 or any other error, return basic info so the screen doesn't crash
    // This allows the user to still see their email and potentially "Edit" to create the profile
    if (e.toString().contains('404')) {
      return baseInfo;
    }
    rethrow;
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
