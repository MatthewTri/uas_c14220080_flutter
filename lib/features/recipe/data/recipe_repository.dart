import 'package:uuid/uuid.dart';
import '../../../core/services/supabase_service.dart';
import '../domain/recipe.dart';

class RecipeException implements Exception {
  final String message;
  RecipeException(this.message);
}

class RecipeRepository {
  static const String tableName = 'recipes';
  final _uuid = const Uuid();

  // Create a new recipe
  Future<Recipe> createRecipe(
    String userId,
    String name,
    String description,
    List<String> ingredients,
  ) async {
    try {
      final id = _uuid.v4();
      final createdAt = DateTime.now();

      final recipe = Recipe(
        id: id,
        userId: userId,
        name: name,
        description: description,
        ingredients: ingredients,
        createdAt: createdAt,
      );

      await SupabaseService.client.from(tableName).insert(recipe.toJson());
      return recipe;
    } catch (e) {
      throw RecipeException('Failed to create recipe: ${e.toString()}');
    }
  }

  // Get all recipes for a user
  Future<List<Recipe>> getRecipesForUser(String userId) async {
    try {
      final response = await SupabaseService.client
          .from(tableName)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List).map((json) => Recipe.fromJson(json)).toList();
    } catch (e) {
      throw RecipeException('Failed to get recipes: ${e.toString()}');
    }
  }

  // Delete a recipe
  Future<void> deleteRecipe(String recipeId) async {
    try {
      await SupabaseService.client
          .from(tableName)
          .delete()
          .eq('id', recipeId);
    } catch (e) {
      throw RecipeException('Failed to delete recipe: ${e.toString()}');
    }
  }

  // Update a recipe
  Future<Recipe> updateRecipe(Recipe recipe) async {
    try {
      await SupabaseService.client
          .from(tableName)
          .update(recipe.toJson())
          .eq('id', recipe.id);
      return recipe;
    } catch (e) {
      throw RecipeException('Failed to update recipe: ${e.toString()}');
    }
  }
}
