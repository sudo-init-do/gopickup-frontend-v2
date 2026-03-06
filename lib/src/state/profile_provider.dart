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
}

final profileProvider = NotifierProvider<ProfileNotifier, ProfileState>(() {
  return ProfileNotifier();
});
