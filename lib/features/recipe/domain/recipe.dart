import 'package:equatable/equatable.dart';

class Recipe extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String description;
  final List<String> ingredients;
  final DateTime createdAt;

  const Recipe({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.createdAt,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      ingredients: List<String>.from(json['ingredients']),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'ingredients': ingredients,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, userId, name, description, ingredients, createdAt];
}
