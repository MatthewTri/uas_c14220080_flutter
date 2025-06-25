import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/auth_bloc.dart';
import '../../features/auth/presentation/auth_state.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/get_started/presentation/get_started_screen.dart';
import '../../features/recipe/presentation/home_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';

class AppRouter {
  static GoRouter get router {
    return GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        // Get the current auth state
        final authState = context.read<AuthBloc>().state;
        final isAuth = authState is AuthAuthenticated;
        final isInitializing = authState is AuthInitial || authState is AuthLoading;
        
        // Don't redirect while initializing
        if (isInitializing) {
          return null;
        }

        // Allow these routes regardless of auth state
        if (state.matchedLocation == '/' || 
            state.matchedLocation == '/get-started') {
          return null;
        }

        // Prevent authenticated users from accessing auth pages
        if (isAuth && (
            state.matchedLocation == '/login' || 
            state.matchedLocation == '/register')) {
          return '/home';
        }

        // Prevent unauthenticated users from accessing protected pages
        if (!isAuth && state.matchedLocation == '/home') {
          return '/login';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) {
            // Start with splash screen which will handle auth verification
            return const SplashScreen();
          },
        ),
        GoRoute(
          path: '/get-started',
          builder: (context, state) => const GetStartedScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
      ],
    );
  }
}
