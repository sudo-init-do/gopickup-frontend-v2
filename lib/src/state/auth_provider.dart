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
    Future.microtask(() => _checkLoginStatus());
    return AuthState();
  }

  Future<void> _checkLoginStatus() async {
    state = state.copyWith(isLoading: true);
    try {
      final token = await ApiClient.secureStorage.read(key: 'jwt_token');
      if (token != null) {
        final user = await _authApi.getCurrentUser();
        state = state.copyWith(user: user, isLoading: false);
        // Automatically connect to websocket if a valid token exists
        ref.read(websocketServiceProvider).connect(token);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      // Token might be expired or invalid
      await ApiClient.secureStorage.delete(key: 'jwt_token');
      ref.read(websocketServiceProvider).disconnect();
      state = state.copyWith(isLoading: false, error: e.toString());
    }
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

  Future<bool> register(String email, String password, String role) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _authApi.register(email, password, role);
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
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
