import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginFormState {
  final String email;
  final String password;

  // 初始化
  LoginFormState({
    this.email = '',
    this.password = '',
  });

  // 預設值
  LoginFormState copyWith({
    String? email,
    String? password,
  }) {
    return LoginFormState(
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}

class LoginFormNontifer extends StateNotifier<LoginFormState> {
  LoginFormNontifer() : super(LoginFormState());

  void updatedEmail(String email) {
    state = state.copyWith(email: email);
  }

  void updatedPassword(String password) {
    state = state.copyWith(password: password);
  }
}

final loginFormProvider =
    StateNotifierProvider<LoginFormNontifer, LoginFormState>((ref) {
  return LoginFormNontifer();
});
