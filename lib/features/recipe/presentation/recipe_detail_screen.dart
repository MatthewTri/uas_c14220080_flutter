import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/domain/user.dart';
import '../domain/recipe.dart';
import '../presentation/recipe_bloc.dart';
import '../presentation/recipe_state.dart';
import 'recipe_form_screen.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;
  final AppUser user;

  const RecipeDetailScreen({
    Key? key,
    required this.recipe,
    required this.user,
  }) : super(key: key);

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
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
      begin: const Offset(0, 0.2),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: CustomScrollView(
        slivers: [
          // Beautiful App Bar with Hero Animation
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => _editRecipe(),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => _showDeleteDialog(),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
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
                    // Recipe Icon and Title
                    Center(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            Hero(
                              tag: 'recipe_icon_${widget.recipe.id}',
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.2),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.restaurant_menu,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                widget.recipe.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Recipe Stats
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.list_alt,
                              title: 'Ingredients',
                              value: '${widget.recipe.ingredients.length}',
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.access_time,
                              title: 'Prep Time',
                              value: 'Quick',
                              color: AppColors.secondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.star_outline,
                              title: 'Difficulty',
                              value: 'Easy',
                              color: AppColors.info,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Description Section
                      if (widget.recipe.description.isNotEmpty) ...[
                        _buildSectionHeader(
                          icon: Icons.description_outlined,
                          title: 'Description',
                          color: AppColors.secondary,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            widget.recipe.description,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                              height: 1.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      // Ingredients Section
                      _buildSectionHeader(
                        icon: Icons.list_alt,
                        title: 'Ingredients',
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: widget.recipe.ingredients.asMap().entries.map((entry) {
                            final index = entry.key;
                            final ingredient = entry.value;
                            final isLast = index == widget.recipe.ingredients.length - 1;
                            
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: !isLast
                                    ? Border(
                                        bottom: BorderSide(
                                          color: Colors.grey[200]!,
                                          width: 1,
                                        ),
                                      )
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          AppColors.primary.withOpacity(0.8),
                                          AppColors.primaryLight.withOpacity(0.6),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      ingredient,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Icon(
                                      Icons.check_circle_outline,
                                      color: AppColors.success,
                                      size: 16,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Quick Actions
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppColors.primary, AppColors.primaryLight],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: _editRecipe,
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.edit_outlined, color: Colors.white, size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          'Edit Recipe',
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
                          ),
                          const SizedBox(width: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: _shareRecipe,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Icon(
                                    Icons.share_outlined,
                                    color: Colors.grey[700],
                                    size: 24,
                                  ),
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
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  void _editRecipe() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => RecipeFormScreen(
          user: widget.user,
          recipe: widget.recipe,
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

  void _shareRecipe() {
    // Simple share functionality - you can integrate with share_plus package
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(Icons.share_outlined, color: AppColors.info, size: 16),
            ),
            const SizedBox(width: 8),
            const Text('Share Recipe', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: Text('Share "${widget.recipe.name}" with your friends!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(Icons.delete_outline, color: AppColors.error, size: 16),
            ),
            const SizedBox(width: 8),
            const Text('Delete Recipe', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: Text('Are you sure you want to delete "${widget.recipe.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
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
                context.read<RecipeBloc>().add(RecipeDeleteEvent(widget.recipe.id));
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to home
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
}
