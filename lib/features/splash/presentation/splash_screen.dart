import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../features/auth/presentation/auth_bloc.dart';
import '../../../features/auth/presentation/auth_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/preferences_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize auth state
    context.read<AuthBloc>().add(AuthInitializeEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/home');
          });
        } else if (state is AuthUnauthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Check if this is the first launch
            if (PreferencesService.isFirstLaunch()) {
              context.go('/get-started');
            } else {
              context.go('/login');
            }
          });
        }
        // Stay on splash screen if still loading
      },
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.menu_book,
                size: 100,
                color: Colors.white,
              ),
              SizedBox(height: 24),
              Text(
                'Recipe Keeper',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 48),
              CircularProgressIndicator(
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
