import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignupData {
  final String email;
  final String password;
  final String role;

  SignupData({this.email = '', this.password = '', this.role = ''});

  SignupData copyWith({String? email, String? password, String? role}) {
    return SignupData(
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
    );
  }
}

class SignupNotifier extends Notifier<SignupData> {
  @override
  SignupData build() {
    return SignupData();
  }

  void updateEmail(String email) {
    state = state.copyWith(email: email);
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password);
  }

  void updateRole(String role) {
    state = state.copyWith(role: role);
  }
}

final signupProvider = NotifierProvider<SignupNotifier, SignupData>(() {
  return SignupNotifier();
});
