import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stacy_frontend/src/services/logger.dart';
import 'package:stacy_frontend/src/utilities/manager/storage_manager.dart';
import 'package:stacy_frontend/src/views/add_plant_view.dart';
import 'package:stacy_frontend/src/views/home_view.dart';
import 'package:stacy_frontend/src/views/welcome/loading_view.dart';
import 'package:stacy_frontend/src/views/welcome/login_view.dart';
import 'package:stacy_frontend/src/views/welcome/signup_view.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: LoadingView.routeName,
      builder: (BuildContext context, GoRouterState state) {
        return const LoadingView();
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
      path: AddPlantView.routeName,
      builder: (BuildContext context, GoRouterState state) {
        return const AddPlantView();
      },
    ),
    GoRoute(
        path: HomeView.routeName,
        // redirect: (BuildContext context, GoRouterState state) {
        //   if (state.fullPath == HomeView.routeName) {
        //     log.fine(
        //         'Redirecting from ${state.fullPath} to ${HomeView.routeName}/0');
        //     return '${HomeView.routeName}/0';
        //   }
        //   return null; // Otherwise, allow the route or its children to handle it
        // },
        builder: (BuildContext context, GoRouterState state) {
          log.shout('Navigating to HomeView without id');
          return HomeView();
        },
        routes: [
          GoRoute(
            path: ':id',
            builder: (BuildContext context, GoRouterState state) {
              final int id = int.tryParse(state.pathParameters['id']!) ?? 0;
              log.shout('Navigating to HomeView with id: $id');
              return HomeView(id: id);
            },
          ),
        ]),
  ],
  redirect: (context, state) async {
    if (state.uri.path == LoadingView.routeName) {
      log.fine('Not redirecting from LoadingView');
      return null;
    }

    final bool isAuthRoute = [
      LoginView.routeName,
      SignUpView.routeName,
    ].contains(state.uri.path);

    final bool isAuthenticated = await StorageManager().isLoggedIn();
    log.fine(
        'Navigating to: ${state.uri.path}, Is Authenticated: $isAuthenticated, Is Auth Route: $isAuthRoute');

    // If the user is NOT authenticated AND trying to go to a protected route,
    // redirect them to the welcome screen.
    if (!isAuthenticated && !isAuthRoute) {
      log.fine('Redirecting to LoadingView (not authenticated)');
      return LoadingView.routeName;
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
  errorBuilder: (BuildContext context, GoRouterState state) {
    log.severe('Error navigating to ${state.uri.path}: ${state.error}');
    return Scaffold(
      body: Center(
        child: Text(
          'Error: ${state.error}',
          style: const TextStyle(fontSize: 24, color: Colors.red),
        ),
      ),
    );
  },
);
