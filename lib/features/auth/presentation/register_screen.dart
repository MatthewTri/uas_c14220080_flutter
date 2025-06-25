import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../presentation/auth_bloc.dart';
import '../presentation/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go('/home');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(child: Text(state.message)),
                  ],
                ),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
          }
        },
        builder: (context, state) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.secondary.withOpacity(0.1),
                  Colors.white,
                  AppColors.primary.withOpacity(0.05),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Custom App Bar
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios,
                              color: AppColors.textPrimary,
                            ),
                            onPressed: () => context.go('/login'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Main Content
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    // Logo Section
                                    Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            AppColors.secondary,
                                            AppColors.secondaryLight,
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.secondary.withOpacity(0.3),
                                            blurRadius: 30,
                                            spreadRadius: 0,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.person_add_outlined,
                                        color: Colors.white,
                                        size: 50,
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                    
                                    // Title Text
                                    const Text(
                                      'Join Recipe Keeper',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Start building your personal recipe collection',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                        height: 1.5,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 40),
                                    
                                    // Email Field
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 20,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: TextFormField(
                                        controller: _emailController,
                                        keyboardType: TextInputType.emailAddress,
                                        decoration: InputDecoration(
                                          labelText: 'Email Address',
                                          hintText: 'Enter your email',
                                          prefixIcon: Container(
                                            margin: const EdgeInsets.all(12),
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              Icons.email_outlined,
                                              color: AppColors.primary,
                                              size: 20,
                                            ),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            borderSide: BorderSide.none,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            borderSide: BorderSide(
                                              color: AppColors.primary,
                                              width: 2,
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 20,
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter your email';
                                          }
                                          if (!value.contains('@')) {
                                            return 'Please enter a valid email';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    
                                    // Email Helper Text
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.info_outline,
                                            size: 16,
                                            color: Colors.grey[500],
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'You can use any email format (e.g., user@example.com)',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    
                                    // Password Field
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 20,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: TextFormField(
                                        controller: _passwordController,
                                        obscureText: !_isPasswordVisible,
                                        decoration: InputDecoration(
                                          labelText: 'Password',
                                          hintText: 'Create a password',
                                          prefixIcon: Container(
                                            margin: const EdgeInsets.all(12),
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: AppColors.secondary.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              Icons.lock_outline,
                                              color: AppColors.secondary,
                                              size: 20,
                                            ),
                                          ),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _isPasswordVisible
                                                  ? Icons.visibility_off_outlined
                                                  : Icons.visibility_outlined,
                                              color: Colors.grey[600],
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _isPasswordVisible = !_isPasswordVisible;
                                              });
                                            },
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            borderSide: BorderSide.none,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            borderSide: BorderSide(
                                              color: AppColors.primary,
                                              width: 2,
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 20,
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter your password';
                                          }
                                          if (value.length < 6) {
                                            return 'Password must be at least 6 characters';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    
                                    // Confirm Password Field
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 20,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: TextFormField(
                                        controller: _confirmPasswordController,
                                        obscureText: !_isConfirmPasswordVisible,
                                        decoration: InputDecoration(
                                          labelText: 'Confirm Password',
                                          hintText: 'Confirm your password',
                                          prefixIcon: Container(
                                            margin: const EdgeInsets.all(12),
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: AppColors.info.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              Icons.lock_clock_outlined,
                                              color: AppColors.info,
                                              size: 20,
                                            ),
                                          ),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _isConfirmPasswordVisible
                                                  ? Icons.visibility_off_outlined
                                                  : Icons.visibility_outlined,
                                              color: Colors.grey[600],
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                              });
                                            },
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            borderSide: BorderSide.none,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            borderSide: BorderSide(
                                              color: AppColors.primary,
                                              width: 2,
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 20,
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please confirm your password';
                                          }
                                          if (value != _passwordController.text) {
                                            return 'Passwords do not match';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                    
                                    // Sign Up Button
                                    Container(
                                      width: double.infinity,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            AppColors.secondary,
                                            AppColors.secondaryLight,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.secondary.withOpacity(0.4),
                                            blurRadius: 20,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(16),
                                          onTap: state is AuthLoading
                                              ? null
                                              : () {
                                                  if (_formKey.currentState!.validate()) {
                                                    context.read<AuthBloc>().add(AuthSignUpEvent(
                                                      email: _emailController.text,
                                                      password: _passwordController.text,
                                                    ));
                                                  }
                                                },
                                          child: Container(
                                            alignment: Alignment.center,
                                            child: state is AuthLoading
                                                ? const SizedBox(
                                                    height: 24,
                                                    width: 24,
                                                    child: CircularProgressIndicator(
                                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                      strokeWidth: 2,
                                                    ),
                                                  )
                                                : const Text(
                                                    'Create Account',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.w600,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                    
                                    // Sign In Link
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Already have an account? ',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 16,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => context.go('/login'),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              'Sign In',
                                              style: TextStyle(
                                                color: AppColors.primary,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
