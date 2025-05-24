import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stacy_frontend/src/services/logger.dart';
import 'package:stacy_frontend/src/utilities/manager/storage_manager.dart';
// import 'package:stacy_frontend/src/settings/settings_view.dart';
import 'package:stacy_frontend/src/views/home_view.dart';
import 'package:stacy_frontend/src/views/weather_view.dart';
import 'package:stacy_frontend/src/views/welcome/loading_view.dart';
import 'package:stacy_frontend/src/views/welcome/login_view.dart';
import 'package:stacy_frontend/src/views/welcome/signup_view.dart';
import 'package:stacy_frontend/src/views/welcome/welcome_view.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: LoadingView.routeName,
      builder: (BuildContext context, GoRouterState state) {
        return const LoadingView();
      },
      routes: <RouteBase>[
        GoRoute(
          path: WelcomeView.routeName,
          builder: (BuildContext context, GoRouterState state) {
            return const WelcomeView();
          },
        ),
        GoRoute(
          path: HomeView.routeName,
          builder: (BuildContext context, GoRouterState state) {
            return const HomeView();
          },
        ),
        GoRoute(
          path: LoginView.routeName,
          builder: (BuildContext context, GoRouterState state) {
            return const LoginView();
          },
        ),
        GoRoute(
          path: SignUpView.routeName,
          builder: (BuildContext context, GoRouterState state) {
            return const SignUpView();
          },
        ),
        GoRoute(
          path: WeatherView.routeName,
          builder: (BuildContext context, GoRouterState state) {
            return const WeatherView();
          },
        ),
      ],
    ),
  ],
  redirect: (context, state) async {
    if (state.uri.path == LoadingView.routeName) {
      return null; // Laisser la LoadingView gérer la navigation
    }

    final bool isAuthRoute = [
      LoadingView.routeName,
      WelcomeView.routeName,
      LoginView.routeName,
      SignUpView.routeName,
    ].contains(state.uri.path);

    final bool isAuthenticated = await StorageManager().isLoggedIn();
    log.fine(
        'Navigating to: ${state.uri.path}, Is Authenticated: $isAuthenticated, Is Auth Route: $isAuthRoute');

    // If the user is NOT authenticated AND trying to go to a protected route,
    // redirect them to the welcome screen.
    if (!isAuthenticated && !isAuthRoute) {
      log.fine('Redirecting to WelcomeView (not authenticated)');
      return WelcomeView.routeName;
    }

    // If the user IS authenticated AND trying to go to an authentication/welcome route,
    // redirect them to the home screen (to prevent them from seeing login/signup again).
    if (isAuthenticated && isAuthRoute) {
      log.fine('Redirecting to HomeView (already authenticated)');
      return HomeView.routeName;
    }

    // If no redirect is needed, return null to let GoRouter continue to the requested path.
    return null;
  },
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Error')),
    body: Center(child: Text('Page not found: ${state.uri.path}')),
  ),
);
