import 'package:defi/src/presentation/shared/utils/color.dart';
import 'package:defi/src/presentation/views/home/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'presentation/views/auth/auth_view.dart';
import 'presentation/views/onboarding/onboarding_view.dart';
import 'presentation/views/splash/splash_view.dart';
import 'services/auth/bloc/auth_bloc.dart';
import 'services/auth/repo/auth_repository.dart';
import 'services/auth/services/auth_service.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  Widget _getHome(AuthState state) {
    if (state is AuthUninitialized) {
      return const SplashView();
    } else if (state is Unauthenticated) {
      return const OnBoardingView();
    } else if (state is Authenticated) {
      return const HomeView();
    } else {
      return const Scaffold(
        body: Center(
          child: Text('Unhandled State'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepository(AuthService());
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: authRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                AuthBloc(authRepository)..add(AuthEventStart()),
          ),
        ],
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return MaterialApp(
              // Providing a restorationScopeId allows the Navigator built by the
              // MaterialApp to restore the navigation stack when a user leaves and
              // returns to the app after it has been killed while running in the
              // background.
              restorationScopeId: 'app',

              // Define a light and dark color theme. Then, read the user's
              // preferred ThemeMode (light, dark, or system default) from the
              // SettingsController to display the correct theme.
              theme: ThemeData(
                brightness: Brightness.dark,
                primarySwatch: ColorUtils.primarySwatch,
                fontFamily: 'Sans',
              ),

              debugShowCheckedModeBanner: false,
              home: _getHome(state),

              // Define a function to handle named routes in order to support
              // Flutter web url navigation and deep linking.
              onGenerateRoute: (RouteSettings routeSettings) {
                switch (routeSettings.name) {
                  case SplashView.routeName:
                    return MaterialPageRoute(
                        builder: (_) => const SplashView());
                  case OnBoardingView.routeName:
                    return MaterialPageRoute(
                        builder: (_) => const OnBoardingView());
                  case AuthView.routeName:
                    return MaterialPageRoute(builder: (_) => const AuthView());
                }
              },
            );
          },
        ),
      ),
    );
  }
}
