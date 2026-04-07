import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/auth_api.dart';
import '../api/api_client.dart';
import '../models/user_models.dart';
import 'order_provider.dart'; // Add this to access websocketServiceProvider

final authApiProvider = Provider<AuthApi>((ref) => AuthApi());

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  AuthApi get _authApi => ref.read(authApiProvider);

  @override
  AuthState build() {
    // Schedule checkLoginStatus after the first frame / build phase
    Future.microtask(_checkLoginStatus);
    return AuthState(isLoading: true);
  }

  Future<void> _checkLoginStatus() async {
    // Clear any existing session to enforce manual login
    await ApiClient.secureStorage.delete(key: 'jwt_token');
    ref.read(websocketServiceProvider).disconnect();
    state = state.copyWith(isLoading: false, user: null, error: null);
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _authApi.login(email, password);
      final token = response['token'] as String;
      final userDict = response['user'] as Map<String, dynamic>;

      await ApiClient.secureStorage.write(key: 'jwt_token', value: token);
      final user = User.fromJson(userDict);

      state = state.copyWith(user: user, isLoading: false);
      ref.read(websocketServiceProvider).connect(token);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> adminLogin(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _authApi.adminLogin(email, password);
      final token = response['token'] as String;
      final userDict = response['user'] as Map<String, dynamic>;

      await ApiClient.secureStorage.write(key: 'jwt_token', value: token);
      final user = User.fromJson(userDict);

      state = state.copyWith(user: user, isLoading: false);
      ref.read(websocketServiceProvider).connect(token);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> register(String email, String password, String role) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _authApi.register(email, password, role.toLowerCase());
      final token = response['token'] as String;
      final userDict = response['user'] as Map<String, dynamic>;

      await ApiClient.secureStorage.write(key: 'jwt_token', value: token);
      final user = User.fromJson(userDict);

      state = state.copyWith(user: user, isLoading: false);
      ref.read(websocketServiceProvider).connect(token);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _authApi.verifyOtp(email, otp);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await ApiClient.secureStorage.delete(key: 'jwt_token');
    ref.read(websocketServiceProvider).disconnect();
    state = AuthState(); // Reset state
  }

  Future<bool> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _authApi.forgotPassword(email);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _authApi.resetPassword(email, otp, newPassword);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void markProfileComplete() {
    if (state.user != null) {
      state = state.copyWith(user: state.user!.copyWith(isComplete: true));
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
