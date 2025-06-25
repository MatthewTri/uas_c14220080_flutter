import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/auth_repository.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<AuthInitializeEvent>(_onInitialize);
    on<AuthSignInEvent>(_onSignIn);
    on<AuthSignUpEvent>(_onSignUp);
    on<AuthSignOutEvent>(_onSignOut);
  }

  Future<void> _onInitialize(
    AuthInitializeEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      // First check if there's a current user in memory
      var user = _authRepository.getCurrentUser();
      
      // If not, try to restore from the saved session
      if (user == null) {
        user = await _authRepository.restoreSession();
      }
      
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      // If there's an error during initialization, just treat as unauthenticated
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onSignIn(
    AuthSignInEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final user = await _authRepository.signIn(
        event.email,
        event.password,
        rememberMe: event.rememberMe,
      );
      
      emit(AuthAuthenticated(user));
    } catch (e) {
      // Extract the actual error message
      String errorMessage = e.toString();
      if (errorMessage.startsWith('AuthException: ')) {
        errorMessage = errorMessage.substring(15);
      } else if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      emit(AuthError(errorMessage));
    }
  }

  Future<void> _onSignUp(
    AuthSignUpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final user = await _authRepository.signUp(
        event.email,
        event.password,
        rememberMe: event.rememberMe,
      );
      
      emit(AuthAuthenticated(user));
    } catch (e) {
      // Extract the actual error message
      String errorMessage = e.toString();
      if (errorMessage.startsWith('AuthException: ')) {
        errorMessage = errorMessage.substring(15);
      } else if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      emit(AuthError(errorMessage));
    }
  }

  Future<void> _onSignOut(
    AuthSignOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      await _authRepository.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
