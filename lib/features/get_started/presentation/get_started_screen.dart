import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/preferences_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({Key? key}) : super(key: key);

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.backgroundGradient,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const Spacer(flex: 2),
                
                // Hero Illustration
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.menu_book_rounded,
                              color: AppColors.primary,
                              size: 120,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 48),
                
                // Title and Description
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          children: [
                            Text(
                              'Simple Recipe Keeper',
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            
                            Text(
                              'Store your favorite recipes in one place\nand never forget your ingredients again!',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.6,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                const Spacer(flex: 2),
                
                // Features List
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          children: [
                            _buildFeatureItem(
                              icon: Icons.bookmark_add_outlined,
                              title: 'Save Recipes',
                              description: 'Store all your favorite recipes',
                            ),
                            const SizedBox(height: 16),
                            _buildFeatureItem(
                              icon: Icons.list_alt_outlined,
                              title: 'Organize Ingredients',
                              description: 'Never forget what you need',
                            ),
                            const SizedBox(height: 16),
                            _buildFeatureItem(
                              icon: Icons.cloud_sync_outlined,
                              title: 'Sync Everywhere',
                              description: 'Access from any device',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                const Spacer(flex: 1),
                
                // Get Started Button
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: CustomButton(
                          text: 'Get Started',
                          onPressed: () async {
                            // Mark first launch as completed
                            await PreferencesService.setFirstLaunchComplete();
                            
                            if (context.mounted) {
                              context.go('/login');
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
