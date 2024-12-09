import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterFormState {
  final String username;
  final String email;
  final String password;
  final String confirmPassword;

  RegisterFormState({
    this.username = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
  });

  RegisterFormState copyWith(
      {String? username,
      String? email,
      String? password,
      String? confirmPassword}) {
    return RegisterFormState(
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
    );
  }
}

class RegisterFormNotifer extends StateNotifier<RegisterFormState> {
  RegisterFormNotifer() : super(RegisterFormState());

  void updatedUserName(String username) {
    state = state.copyWith(username: username);
  }

  void updatedEmail(String email) {
    state = state.copyWith(email: email);
  }

  void updatedPassword(String password) {
    state = state.copyWith(password: password);
  }

  void updatedConfirmPassword(String confirmPassword) {
    state = state.copyWith(confirmPassword: confirmPassword);
  }
}

final RegisterFormProvider =
    StateNotifierProvider<RegisterFormNotifer, RegisterFormState>((ref) {
  return RegisterFormNotifer();
});
