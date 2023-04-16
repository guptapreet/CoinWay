import 'package:equatable/equatable.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent(this.email, this.password, this.name);

  final String email;
  final String password;
  final String name;
  @override
  List<Object> get props => [email, password, name];
}

class RegisterWithEmailPassword extends RegisterEvent {
  const RegisterWithEmailPassword(String email, String password, String name)
      : super(email, password, name);
}

class RegisterCredentialsChanged extends RegisterEvent {
  final String confirmPassword;

  const RegisterCredentialsChanged(
    String email,
    String password,
    String name,
    this.confirmPassword,
  ) : super(email, password, name);
}
