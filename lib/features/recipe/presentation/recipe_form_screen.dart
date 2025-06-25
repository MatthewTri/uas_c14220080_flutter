import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/domain/user.dart';
import '../domain/recipe.dart';
import '../presentation/recipe_bloc.dart';
import '../presentation/recipe_state.dart';

class RecipeFormScreen extends StatefulWidget {
  final AppUser user;
  final Recipe? recipe;

  const RecipeFormScreen({
    Key? key,
    required this.user,
    this.recipe,
  }) : super(key: key);

  @override
  State<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends State<RecipeFormScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<TextEditingController> _ingredientControllers = [];
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
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
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _fadeController.forward();
    _slideController.forward();
    
    if (widget.recipe != null) {
      _nameController.text = widget.recipe!.name;
      _descriptionController.text = widget.recipe!.description;
      
      for (final ingredient in widget.recipe!.ingredients) {
        final controller = TextEditingController(text: ingredient);
        _ingredientControllers.add(controller);
      }
    } else {
      _addIngredientField();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    for (final controller in _ingredientControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addIngredientField() {
    setState(() {
      _ingredientControllers.add(TextEditingController());
    });
  }

  void _removeIngredientField(int index) {
    if (_ingredientControllers.length > 1) {
      setState(() {
        _ingredientControllers[index].dispose();
        _ingredientControllers.removeAt(index);
      });
    }
  }

  void _saveRecipe() {
    if (_formKey.currentState!.validate()) {
      final ingredients = _ingredientControllers
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      if (ingredients.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.warning, color: Colors.white),
                SizedBox(width: 8),
                Text('Please add at least one ingredient'),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        return;
      }

      if (widget.recipe != null) {
        final updatedRecipe = Recipe(
          id: widget.recipe!.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          ingredients: ingredients,
          userId: widget.user.id,
          createdAt: widget.recipe!.createdAt,
        );
        context.read<RecipeBloc>().add(RecipeUpdateEvent(updatedRecipe));
      } else {
        context.read<RecipeBloc>().add(RecipeCreateEvent(
          userId: widget.user.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          ingredients: ingredients,
        ));
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text(widget.recipe != null ? 'Recipe updated!' : 'Recipe created!'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      Navigator.of(context).pop();
    }
  }

  Widget _buildAnimatedCard({
    required int delay,
    required Widget child,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildRecipeNameSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Recipe Name',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1.5,
              ),
            ),
            child: TextFormField(
              controller: _nameController,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                hintText: 'Enter your recipe name...',
                hintStyle: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.error,
                    width: 2,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.error,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.all(20),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a recipe name';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.secondary,
                      AppColors.secondary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.description,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8F0),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFFE4CC),
                width: 1.5,
              ),
            ),
            child: TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF0F172A),
                height: 1.5,
              ),
              decoration: InputDecoration(
                hintText: 'Describe your recipe, cooking method, or any special notes...',
                hintStyle: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.secondary,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.error,
                    width: 2,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.error,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.all(20),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.accent.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.accent,
                      AppColors.accent.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.list_alt,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Ingredients',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accent.withOpacity(0.1),
                      AppColors.accent.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.accent.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _addIngredientField,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add,
                            color: AppColors.accent,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Add',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
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
          const SizedBox(height: 20),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _ingredientControllers.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F0FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.accent.withOpacity(0.15),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(12),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.accent,
                            AppColors.accent.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _ingredientControllers[index],
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter ingredient...',
                          hintStyle: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter an ingredient';
                          }
                          return null;
                        },
                      ),
                    ),
                    if (_ingredientControllers.length > 1)
                      Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.error.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => _removeIngredientField(index),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.remove,
                                color: AppColors.error,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(bool isEdit) {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isEdit
              ? [
                  AppColors.secondary,
                  AppColors.secondary.withOpacity(0.8),
                  AppColors.secondaryLight,
                ]
              : [
                  AppColors.primary,
                  AppColors.primary.withOpacity(0.8),
                  AppColors.primaryLight,
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isEdit ? AppColors.secondary : AppColors.primary).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _saveRecipe,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isEdit ? Icons.update_rounded : Icons.save_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  isEdit ? 'Update Recipe' : 'Save Recipe',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.recipe != null;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Beautiful App Bar
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            backgroundColor: isEdit ? AppColors.secondary : AppColors.primary,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.2),
                      Colors.white.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _saveRecipe,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.save_outlined, color: Colors.white, size: 18),
                          SizedBox(width: 6),
                          Text(
                            'Save',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isEdit
                        ? [
                            AppColors.secondary,
                            AppColors.secondaryLight,
                            AppColors.primary.withOpacity(0.3),
                          ]
                        : [
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
                      top: -40,
                      right: -40,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -20,
                      left: -20,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ),
                    // Content
                    Center(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 30),
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.2),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                isEdit ? Icons.edit_outlined : Icons.add_circle_outline,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              isEdit ? 'Edit Recipe' : 'Create New Recipe',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isEdit 
                                  ? 'Update your delicious recipe'
                                  : 'Share your culinary masterpiece',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
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
          // Form Content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Recipe Name Field
                        _buildAnimatedCard(
                          delay: 0,
                          child: _buildRecipeNameSection(),
                        ),
                        const SizedBox(height: 24),
                        
                        // Description Field
                        _buildAnimatedCard(
                          delay: 100,
                          child: _buildDescriptionSection(),
                        ),
                        const SizedBox(height: 24),
                        
                        // Ingredients Section
                        _buildAnimatedCard(
                          delay: 200,
                          child: _buildIngredientsSection(),
                        ),
                        const SizedBox(height: 40),
                        
                        // Save Button
                        _buildAnimatedCard(
                          delay: 300,
                          child: _buildSaveButton(isEdit),
                        ),
                        const SizedBox(height: 24), // Bottom padding
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
