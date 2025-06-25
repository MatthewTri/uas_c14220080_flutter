import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/presentation/auth_bloc.dart';
import '../../auth/presentation/auth_state.dart';
import '../domain/recipe.dart';
import '../presentation/recipe_bloc.dart';
import '../presentation/recipe_state.dart';
import 'recipe_form_screen.dart';
import 'recipe_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRecipes();
    });
  }

  void _loadRecipes() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<RecipeBloc>().add(RecipeLoadEvent(authState.user.id));
    } else {
      // If not authenticated yet, try to initialize auth
      context.read<AuthBloc>().add(AuthInitializeEvent());
    }
  }

  // Track if we're in a loading state to avoid flickering between screens
  bool _checkingAuth = false;
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        // Show loading while initializing authentication
        if (authState is AuthLoading) {
          return const Scaffold(
            backgroundColor: Color.fromARGB(255, 40, 176, 44),
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          );
        }
        
        if (authState is AuthInitial) {
          // Auth is still initializing - dispatch initialize event if needed
          if (!_checkingAuth) {
            _checkingAuth = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<AuthBloc>().add(AuthInitializeEvent());
            });
          }
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          );
        }
        
        if (authState is! AuthAuthenticated) {
          // Only redirect after we're sure auth state is settled (not loading or initial)
          _checkingAuth = false;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/login');
          });
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          );
        }
        
        // Reset the checking flag when authenticated
        _checkingAuth = false;

        final user = authState.user;
        
        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: SafeArea(
            child: Column(
              children: [
                // Modern Header with User Info
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary,
                        AppColors.primaryLight,
                        AppColors.secondary.withOpacity(0.3),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Background pattern
                      Positioned(
                        top: -50,
                        right: -50,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -30,
                        left: -30,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                      ),
                      // Main content
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            // User Profile Section
                            Row(
                              children: [
                                // User Avatar
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white.withOpacity(0.3),
                                        Colors.white.withOpacity(0.1),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // User Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.waving_hand,
                                            color: Colors.amber,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 6),
                                          const Text(
                                            'Welcome back!',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        user.email,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                // Sign Out Button with better design
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.logout_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    onPressed: () => _showSignOutDialog(context),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Page Title with icon
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.restaurant_menu,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'My Recipe Collection',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Recipe List
                Expanded(
                  child: BlocConsumer<RecipeBloc, RecipeState>(
                    listener: (context, state) {
                      if (state is RecipeError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: AppColors.error,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }
                      if (state is RecipeActionSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                        // To ensure we always have the most up-to-date data after any action
                        _loadRecipes();
                      }
                    },
                    buildWhen: (previous, current) {
                      // Only rebuild when the state is RecipeLoaded or RecipeLoading
                      // Prevents rebuilding when we just have action success messages
                      return current is RecipeLoaded || current is RecipeLoading || current is RecipeInitial;
                    },
                    builder: (context, state) {
                      if (state is RecipeLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        );
                      }

                      if (state is RecipeLoaded) {
                        final recipes = state.recipes;

                        if (recipes.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Animated illustration
                                  Container(
                                    width: 150,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          AppColors.primary.withOpacity(0.1),
                                          AppColors.primaryLight.withOpacity(0.05),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(75),
                                    ),
                                    child: Icon(
                                      Icons.menu_book_outlined,
                                      size: 80,
                                      color: AppColors.primary.withOpacity(0.6),
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  Text(
                                    'No recipes yet',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Start building your recipe collection\nby adding your first delicious recipe',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  // Call to action button
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          AppColors.primary,
                                          AppColors.primaryLight,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(25),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withOpacity(0.3),
                                          blurRadius: 15,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(25),
                                        onTap: () => _addRecipe(context, user),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 32,
                                            vertical: 16,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.add,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'Add Your First Recipe',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: recipes.length,
                          itemBuilder: (context, index) {
                            final recipe = recipes[index];
                            return AnimatedContainer(
                              duration: Duration(milliseconds: 300 + (index * 100)),
                              curve: Curves.easeOutBack,
                              child: ModernRecipeCard(
                                recipe: recipe,
                                onDelete: () => _showDeleteConfirmationDialog(context, recipe),
                                onEdit: () => _editRecipe(context, recipe, user),
                                onTap: () => _viewRecipeDetail(context, recipe, user),
                              ),
                            );
                          },
                        );
                      }

                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Something went wrong',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.primaryLight,
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: FloatingActionButton(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              elevation: 0,
              child: const Icon(Icons.add, size: 28),
              onPressed: () => _addRecipe(context, user),
            ),
          ),
        );
      },
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.logout_rounded,
                color: AppColors.warning,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Sign Out',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.error, AppColors.error.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: () {
                context.read<AuthBloc>().add(AuthSignOutEvent());
                Navigator.of(context).pop();
              },
              child: const Text(
                'Sign Out',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Recipe recipe) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.delete_outline,
                color: AppColors.error,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Delete Recipe',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Text('Are you sure you want to delete "${recipe.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.error, AppColors.error.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: () {
                context.read<RecipeBloc>().add(RecipeDeleteEvent(recipe.id));
                Navigator.of(context).pop();
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addRecipe(BuildContext context, user) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => RecipeFormScreen(user: user),
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = const Offset(0.0, 1.0);
          var end = Offset.zero;
          var curve = Curves.ease;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  void _editRecipe(BuildContext context, Recipe recipe, user) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => RecipeFormScreen(
          user: user,
          recipe: recipe, // Pass existing recipe for edit
        ),
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = const Offset(1.0, 0.0);
          var end = Offset.zero;
          var curve = Curves.ease;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  void _viewRecipeDetail(BuildContext context, Recipe recipe, user) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => RecipeDetailScreen(
          recipe: recipe,
          user: user,
        ),
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var fadeAnimation = Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ));

          var slideAnimation = Tween<Offset>(
            begin: const Offset(0.0, 0.3),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ));

          return FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(
              position: slideAnimation,
              child: child,
            ),
          );
        },
      ),
    );
  }
}

class ModernRecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onTap;

  const ModernRecipeCard({
    Key? key,
    required this.recipe,
    required this.onDelete,
    required this.onEdit,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header dengan background gradasi
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withOpacity(0.1),
                        AppColors.primaryLight.withOpacity(0.05),
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      // Recipe Icon (Hero widget ditambahkan kembali untuk animasi)
                      Hero(
                        tag: 'recipe_icon_${recipe.id}',
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primary,
                                AppColors.primaryLight,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.restaurant_menu,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Recipe Title
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              recipe.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  // Menggunakan icon yang relevan dengan jumlah bahan
                                  Icons.list_alt,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  // Menampilkan jumlah bahan agar lebih informatif
                                  '${recipe.ingredients.length} ingredients',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Action Buttons
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              onPressed: onEdit,
                              padding: const EdgeInsets.all(8),
                              constraints: const BoxConstraints(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppColors.error,
                                size: 20,
                              ),
                              onPressed: onDelete,
                              padding: const EdgeInsets.all(8),
                              constraints: const BoxConstraints(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Content Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20), // Mengurangi padding atas
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hanya tampilkan deskripsi jika ada
                      if (recipe.description.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey[200]!,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.description_outlined,
                                size: 18,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  recipe.description,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                    height: 1.5,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      // Ingredients section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.secondary.withOpacity(0.05),
                              AppColors.secondaryLight.withOpacity(0.02),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.secondary.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.kitchen_outlined,
                                    size: 18,
                                    color: AppColors.secondary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Ingredients (${recipe.ingredients.length})',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (recipe.ingredients.isEmpty)
                              Text(
                                'No ingredients listed.',
                                style: TextStyle(
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic),
                              )
                            else ...[
                              // Ingredients list (max 3 items shown)
                              ...recipe.ingredients.take(3).map((ingredient) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        margin: const EdgeInsets.only(top: 8, right: 12),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              AppColors.primary,
                                              AppColors.primaryLight,
                                            ],
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          ingredient,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              // Show "and X more"
                              if (recipe.ingredients.length > 3)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4, left: 18),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'and ${recipe.ingredients.length - 3} more...',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                            ]
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}