import 'package:equatable/equatable.dart';
import '../domain/recipe.dart';

abstract class RecipeEvent extends Equatable {
  const RecipeEvent();

  @override
  List<Object?> get props => [];
}

class RecipeLoadEvent extends RecipeEvent {
  final String userId;

  const RecipeLoadEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class RecipeCreateEvent extends RecipeEvent {
  final String userId;
  final String name;
  final String description;
  final List<String> ingredients;

  const RecipeCreateEvent({
    required this.userId,
    required this.name,
    required this.description,
    required this.ingredients,
  });

  @override
  List<Object?> get props => [userId, name, description, ingredients];
}

class RecipeUpdateEvent extends RecipeEvent {
  final Recipe recipe;

  const RecipeUpdateEvent(this.recipe);

  @override
  List<Object?> get props => [recipe];
}

class RecipeDeleteEvent extends RecipeEvent {
  final String recipeId;

  const RecipeDeleteEvent(this.recipeId);

  @override
  List<Object?> get props => [recipeId];
}

abstract class RecipeState extends Equatable {
  const RecipeState();

  @override
  List<Object?> get props => [];
}

class RecipeInitial extends RecipeState {}

class RecipeLoading extends RecipeState {}

class RecipeLoaded extends RecipeState {
  final List<Recipe> recipes;

  const RecipeLoaded(this.recipes);

  @override
  List<Object?> get props => [recipes];
}

class RecipeError extends RecipeState {
  final String message;

  const RecipeError(this.message);

  @override
  List<Object?> get props => [message];
}

class RecipeActionSuccess extends RecipeState {
  final String message;

  const RecipeActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
