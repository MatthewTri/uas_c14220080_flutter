import 'package:supabase_flutter/supabase_flutter.dart';
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
        throw AuthException('Format email tidak valid. Silakan masukkan email yang benar.');
      }

      final response = await SupabaseService.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AuthException('Pendaftaran gagal. Silakan coba lagi.');
      }

      // Since we're not requiring email verification, automatically sign them in
      final signInResponse = await SupabaseService.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (signInResponse.user == null) {
        throw AuthException('Akun berhasil dibuat tetapi gagal login. Silakan login manual.');
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
    } on AuthApiException catch (e) {
      // Handle specific Supabase auth errors
      String errorMessage;
      final message = e.message.toLowerCase();
      
      if (message.contains('user already registered') || message.contains('email already exists')) {
        errorMessage = 'Email sudah terdaftar. Silakan gunakan email lain atau login.';
      } else if (message.contains('password should be at least')) {
        errorMessage = 'Password harus minimal 6 karakter.';
      } else if (message.contains('invalid email')) {
        errorMessage = 'Format email tidak valid. Silakan masukkan email yang benar.';
      } else if (message.contains('weak password')) {
        errorMessage = 'Password terlalu lemah. Gunakan kombinasi huruf, angka, dan simbol.';
      } else if (message.contains('rate limit')) {
        errorMessage = 'Terlalu banyak percobaan. Silakan coba lagi nanti.';
      } else {
        errorMessage = 'Pendaftaran gagal. Silakan coba lagi.';
      }
      throw AuthException(errorMessage);
    } catch (e) {
      if (e is AuthException) {
        throw e;
      }
      throw AuthException('Terjadi kesalahan saat mendaftar. Silakan coba lagi.');
    }
  }

  Future<AppUser> signIn(String email, String password, {bool rememberMe = false}) async {
    try {
      // Basic email format validation
      if (!SupabaseService.isValidEmail(email)) {
        throw AuthException('Format email tidak valid. Silakan masukkan email yang benar.');
      }

      final response = await SupabaseService.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AuthException('Email atau password salah. Silakan periksa kembali.');
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
    } on AuthApiException catch (e) {
      // Handle specific Supabase auth errors
      String errorMessage;
      final message = e.message.toLowerCase();
      
      if (message.contains('invalid login credentials') || message.contains('invalid email or password')) {
        errorMessage = 'Email atau password salah. Silakan periksa kembali.';
      } else if (message.contains('email not confirmed')) {
        errorMessage = 'Email belum diverifikasi. Silakan cek email Anda.';
      } else if (message.contains('too many requests') || message.contains('rate limit')) {
        errorMessage = 'Terlalu banyak percobaan login. Silakan coba lagi nanti.';
      } else if (message.contains('user not found')) {
        errorMessage = 'Akun dengan email ini tidak ditemukan.';
      } else if (message.contains('account is disabled')) {
        errorMessage = 'Akun Anda telah dinonaktifkan. Hubungi dukungan.';
      } else {
        errorMessage = 'Login gagal. Silakan coba lagi.';
      }
      throw AuthException(errorMessage);
    } catch (e) {
      if (e is AuthException) {
        throw e;
      }
      throw AuthException('Terjadi kesalahan saat login. Silakan coba lagi.');
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
