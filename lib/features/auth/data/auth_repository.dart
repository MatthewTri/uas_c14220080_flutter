import '../../../core/services/preferences_service.dart';
import '../../../core/services/supabase_service.dart';
import '../domain/user.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

class AuthRepository {
  Future<AppUser> signUp(String email, String password, {bool rememberMe = false}) async {
    try {
      // Basic email format validation
      if (!SupabaseService.isValidEmail(email)) {
        throw AuthException('Please enter a valid email format');
      }

      final response = await SupabaseService.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AuthException('Failed to create account');
      }

      // Since we're not requiring email verification, automatically sign them in
      final signInResponse = await SupabaseService.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (signInResponse.user == null) {
        throw AuthException('Account created but failed to sign in');
      }

      // Handle Remember Me functionality
      if (rememberMe) {
        await PreferencesService.setRememberMe(true);
        await PreferencesService.saveRememberedEmail(email);
      } else {
        await PreferencesService.setRememberMe(false);
        await PreferencesService.clearRememberedEmail();
      }

      return AppUser(
        id: signInResponse.user!.id,
        email: signInResponse.user!.email ?? email,
      );
    } catch (e) {
      // Handle specific Supabase errors
      if (e is AuthException) {
        throw e;
      }
      if (e.toString().contains('Email rate limit exceeded')) {
        throw AuthException('Too many attempts. Please try again later.');
      }
      throw AuthException(e.toString());
    }
  }

  Future<AppUser> signIn(String email, String password, {bool rememberMe = false}) async {
    try {
      // Basic email format validation
      if (!SupabaseService.isValidEmail(email)) {
        throw AuthException('Please enter a valid email format');
      }

      final response = await SupabaseService.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AuthException('Invalid email or password');
      }

      // Handle Remember Me functionality
      if (rememberMe) {
        await PreferencesService.setRememberMe(true);
        await PreferencesService.saveRememberedEmail(email);
      } else {
        await PreferencesService.setRememberMe(false);
        await PreferencesService.clearRememberedEmail();
      }

      return AppUser(
        id: response.user!.id,
        email: response.user!.email ?? email,
      );
    } catch (e) {
      if (e is AuthException) {
        throw e;
      }
      if (e.toString().contains('Invalid login credentials')) {
        throw AuthException('Invalid email or password');
      }
      throw AuthException(e.toString());
    }
  }

  // Restore session from preferences if available
  Future<AppUser?> restoreSession() async {
    try {
      // Check if current user is already set
      final currentUser = SupabaseService.auth.currentUser;
      if (currentUser != null) {
        return AppUser(
          id: currentUser.id,
          email: currentUser.email ?? '',
        );
      }
      
      // Try to get session from storage
      final sessionString = PreferencesService.getUserSession();
      final email = PreferencesService.getUserEmail();
      if (sessionString == null || sessionString.isEmpty || email == null || email.isEmpty) {
        return null;
      }
      
      // For Supabase Flutter, the session should already be persisted
      // Just check if there's a current user after initialization
      final user = SupabaseService.auth.currentUser;
      if (user != null) {
        return AppUser(
          id: user.id,
          email: user.email ?? email,
        );
      }
      return null;
    } catch (e) {
      // If there's an error recovering session (e.g., expired), clear it
      await PreferencesService.clearUserSession();
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await SupabaseService.auth.signOut();
      await PreferencesService.clearUserSession();
      
      // If Remember Me is not enabled, clear the remembered email too
      if (!PreferencesService.getRememberMe()) {
        await PreferencesService.clearRememberedEmail();
      }
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  AppUser? getCurrentUser() {
    final user = SupabaseService.auth.currentUser;
    if (user == null) return null;

    return AppUser(
      id: user.id,
      email: user.email ?? '',
    );
  }

  bool isUserSignedIn() {
    return SupabaseService.auth.currentUser != null;
  }
}
