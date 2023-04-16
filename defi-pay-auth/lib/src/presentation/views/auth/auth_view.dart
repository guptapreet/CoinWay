// ignore_for_file: use_build_context_synchronously

import 'package:defi/src/presentation/shared/utils/color.dart';
import 'package:defi/src/presentation/shared/utils/font.dart';
import 'package:defi/src/services/login/bloc/login_state.dart';
import 'package:defi/src/services/register/bloc/register_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../services/auth/bloc/auth_bloc.dart';
import '../../../services/auth/repo/auth_repository.dart';
import '../../../services/register/bloc/register_bloc.dart';
import '../../../services/register/bloc/register_state.dart';

class AuthView extends StatelessWidget {
  const AuthView({Key? key}) : super(key: key);

  static const routeName = '/auth';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorUtils.primary,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Center(
                child: Text(
                  'De-Fi Pay',
                  style: FontUtils.textStyle.copyWith(fontSize: 32),
                ),
              ),
            ),
            Expanded(
              flex: 7,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
                child: BlocProvider<RegisterBloc>(
                  create: (context) =>
                      RegisterBloc(context.read<AuthRepository>()),
                  child: const RegisterForm(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({Key? key}) : super(key: key);

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  late RegisterBloc _registerBloc;

  bool get isPopulated =>
      _emailController.text.isNotEmpty &&
      _passwordController.text.isNotEmpty &&
      _confirmPasswordController.text.isNotEmpty &&
      _nameController.text.isNotEmpty;

  bool isRegisterButtonEnabled(RegisterState state) {
    return state is RegisterInitState && isPopulated;
  }

  bool get arePasswordsSame =>
      _confirmPasswordController.text == _passwordController.text;

  @override
  void initState() {
    super.initState();

    _registerBloc = BlocProvider.of<RegisterBloc>(context);
    _emailController.addListener(_onCredentialsChanged);
    _passwordController.addListener(_onCredentialsChanged);
    _confirmPasswordController.addListener(_onCredentialsChanged);
    _nameController.addListener(_onCredentialsChanged);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterBloc, RegisterState>(
      listener: (context, state) {
        print(state);
        if (state is RegisterLoadingState) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                backgroundColor: ColorUtils.primary,
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Registering ... ',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            );
        }

        if (state is RegisterSuccessState) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          BlocProvider.of<AuthBloc>(context).add(AuthEventLogin());
          Navigator.of(context).pop();
        }

        if (state is RegisterFailedState) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Something went wrong',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                backgroundColor: ColorUtils.primary,
              ),
            );
        }
      },
      child: BlocBuilder<RegisterBloc, RegisterState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: <Widget>[
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.email),
                      labelText: 'Email',
                      iconColor: ColorUtils.primary,
                      errorStyle: TextStyle(fontWeight: FontWeight.bold),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (_) {
                      return state is RegisterCredentialsInvalidState &&
                              !state.emailValid
                          ? 'Invalid Email'
                          : null;
                    },
                  ),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.account_box),
                      labelText: 'Display Name',
                      iconColor: ColorUtils.primary,
                      errorStyle: TextStyle(fontWeight: FontWeight.bold),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    keyboardType: TextInputType.text,
                    autocorrect: false,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (_) {
                      state is RegisterCredentialsInvalidState &&
                              !state.emailValid
                          ? 'Invalid Name'
                          : null;
                    },
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.lock),
                      labelText: 'Password',
                      iconColor: ColorUtils.primary,
                      errorStyle: TextStyle(fontWeight: FontWeight.bold),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    obscureText: true,
                    autocorrect: false,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (_) {
                      return state is RegisterCredentialsInvalidState &&
                              !state.passwordValid
                          ? 'Invalid Password'
                          : null;
                    },
                  ),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.lock_outline),
                      iconColor: ColorUtils.primary,
                      labelText: 'Confirm Password',
                      errorStyle: TextStyle(fontWeight: FontWeight.bold),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    obscureText: true,
                    autocorrect: false,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (_) {
                      return state is RegisterCredentialsInvalidState &&
                              !state.passwordsMatch
                          ? 'Password don\'t match'
                          : null;
                    },
                  ),
                  state is RegisterLoadingState
                      ? const SizedBox(
                          height: 128,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: ColorUtils.primary,
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 32, horizontal: 120),
                          child: FloatingActionButton.extended(
                            onPressed: _onFormSubmitted,
                            backgroundColor: ColorUtils.primary,
                            label: Text(
                              "Register",
                              style: FontUtils.textStyle,
                            ),
                          ),
                        )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _onCredentialsChanged() {
    _registerBloc.add(
      RegisterCredentialsChanged(
        _emailController.text,
        _passwordController.text,
        _nameController.text,
        _confirmPasswordController.text,
      ),
    );
  }

  void _onFormSubmitted() {
    _registerBloc.add(
      RegisterWithEmailPassword(
        _emailController.text,
        _passwordController.text,
        _nameController.text,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}
