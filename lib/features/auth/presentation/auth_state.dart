import 'package:equatable/equatable.dart';
import '../domain/user.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// Events
class AuthSignInEvent extends AuthEvent {
  final String email;
  final String password;
  final bool rememberMe;

  const AuthSignInEvent({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  @override
  List<Object?> get props => [email, password, rememberMe];
}

class AuthSignUpEvent extends AuthEvent {
  final String email;
  final String password;
  final bool rememberMe;

  const AuthSignUpEvent({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  @override
  List<Object?> get props => [email, password, rememberMe];
}

class AuthSignOutEvent extends AuthEvent {}

class AuthInitializeEvent extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final AppUser user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
