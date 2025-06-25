import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://xkgwttlftnlmtrbbezoh.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhrZ3d0dGxmdG5sbXRyYmJlem9oIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA4MjQxNDUsImV4cCI6MjA2NjQwMDE0NX0.y3t4a02xEfB69PO1s_kxnl3te3xEZceIH7xXJLumzUU',
      authOptions: FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        autoRefreshToken: true,
      ),
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
  static GoTrueClient get auth => client.auth;

  // Helper method to check if an email is a valid format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
