import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignupData {
  final String email;
  final String password;

  SignupData({this.email = '', this.password = ''});

  SignupData copyWith({String? email, String? password}) {
    return SignupData(
      email: email ?? this.email,
      password: password ?? this.password,
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
}

final signupProvider = NotifierProvider<SignupNotifier, SignupData>(() {
  return SignupNotifier();
});
