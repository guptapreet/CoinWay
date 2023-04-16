import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/repo/auth_repository.dart';
import '../../common/validators.dart';
import 'register_event.dart';
import 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc(AuthRepository authRepository)
      : _authRepository = authRepository,
        super(const RegisterInitState()) {
    on<RegisterWithEmailPassword>(_registerWithEmailPassword);
    on<RegisterCredentialsChanged>(_credentialsChanged);
  }

  final AuthRepository _authRepository;

  Future<void> _registerWithEmailPassword(
    RegisterWithEmailPassword event,
    Emitter<RegisterState> emit,
  ) async {
    emit(const RegisterLoadingState());
    final messenger = await _authRepository.createUserWithEmailAndPassword(
        email: event.email, password: event.password, name: event.name);
    if (messenger.error) {
      emit(RegisterFailedState(messenger.message));
    } else {
      emit(const RegisterSuccessState());
    }
  }

  Future<void> _credentialsChanged(
      RegisterCredentialsChanged event, Emitter<RegisterState> emit) async {
    final emailValid = Validate.email(event.email);
    final passwordValid = Validate.password(event.password);
    final passwordsMatch = (event.password.isNotEmpty &&
        event.confirmPassword.isNotEmpty &&
        event.password == event.confirmPassword);
    // TODO : add name Validator
    const nameValid = true;
    if (emailValid && passwordValid && passwordsMatch && nameValid) {
      emit(const RegisterInitState());
    } else {
      emit(
        RegisterCredentialsInvalidState(
            emailValid, passwordValid, nameValid, passwordsMatch),
      );
    }
  }
}
