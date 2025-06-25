import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/router/app_router.dart';
import 'core/services/preferences_service.dart';
import 'core/services/supabase_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/auth_bloc.dart';
import 'features/auth/presentation/auth_state.dart';
import 'features/recipe/data/recipe_repository.dart';
import 'features/recipe/presentation/recipe_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await PreferencesService.initialize();
  await SupabaseService.initialize();
  
  // Note: Supabase Flutter SDK automatically persists sessions by default
  // We're handling restoration in the AuthBloc to be extra safe
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            AuthRepository(),
          )..add(AuthInitializeEvent()),
        ),
        BlocProvider<RecipeBloc>(
          create: (context) => RecipeBloc(
            RecipeRepository(),
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'Recipe Keeper',
        theme: AppTheme.light,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
