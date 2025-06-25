import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/recipe_repository.dart';
import 'recipe_state.dart';

class RecipeBloc extends Bloc<RecipeEvent, RecipeState> {
  final RecipeRepository _recipeRepository;

  RecipeBloc(this._recipeRepository) : super(RecipeInitial()) {
    on<RecipeLoadEvent>(_onLoadRecipes);
    on<RecipeCreateEvent>(_onCreateRecipe);
    on<RecipeUpdateEvent>(_onUpdateRecipe);
    on<RecipeDeleteEvent>(_onDeleteRecipe);
  }

  Future<void> _onLoadRecipes(
    RecipeLoadEvent event,
    Emitter<RecipeState> emit,
  ) async {
    emit(RecipeLoading());
    
    try {
      final recipes = await _recipeRepository.getRecipesForUser(event.userId);
      emit(RecipeLoaded(recipes));
    } catch (e) {
      emit(RecipeError(e.toString()));
    }
  }

  Future<void> _onCreateRecipe(
    RecipeCreateEvent event,
    Emitter<RecipeState> emit,
  ) async {
    final currentState = state;
    emit(RecipeLoading());
    
    try {
      final recipe = await _recipeRepository.createRecipe(
        event.userId,
        event.name,
        event.description,
        event.ingredients,
      );
      
      if (currentState is RecipeLoaded) {
        emit(RecipeLoaded([recipe, ...currentState.recipes]));
      } else {
        emit(RecipeLoaded([recipe]));
      }
      
      emit(RecipeActionSuccess('Recipe created successfully'));
      
      // Reload the recipes to ensure we have the latest data
      add(RecipeLoadEvent(event.userId));
    } catch (e) {
      emit(RecipeError(e.toString()));
    }
  }

  Future<void> _onUpdateRecipe(
    RecipeUpdateEvent event,
    Emitter<RecipeState> emit,
  ) async {
    final currentState = state;
    emit(RecipeLoading());
    
    try {
      final updatedRecipe = await _recipeRepository.updateRecipe(event.recipe);
      
      if (currentState is RecipeLoaded) {
        final updatedRecipes = currentState.recipes.map((recipe) {
          return recipe.id == updatedRecipe.id ? updatedRecipe : recipe;
        }).toList();
        
        emit(RecipeLoaded(updatedRecipes));
      }
      
      emit(RecipeActionSuccess('Recipe updated successfully'));
      
      // Reload the recipes to ensure we have the latest data
      add(RecipeLoadEvent(event.recipe.userId));
    } catch (e) {
      emit(RecipeError(e.toString()));
    }
  }

  Future<void> _onDeleteRecipe(
    RecipeDeleteEvent event,
    Emitter<RecipeState> emit,
  ) async {
    final currentState = state;
    emit(RecipeLoading());
    
    try {
      await _recipeRepository.deleteRecipe(event.recipeId);
      
      if (currentState is RecipeLoaded) {
        final updatedRecipes = currentState.recipes
            .where((recipe) => recipe.id != event.recipeId)
            .toList();
        
        // Emit successful deletion with updated recipes list
        emit(RecipeLoaded(updatedRecipes));
        
        // Now emit success message
        emit(RecipeActionSuccess('Recipe deleted successfully'));
      } else {
        // Even if we weren't in a loaded state, still indicate success
        emit(RecipeActionSuccess('Recipe deleted successfully'));
      }
    } catch (e) {
      emit(RecipeError(e.toString()));
    }
  }
}
