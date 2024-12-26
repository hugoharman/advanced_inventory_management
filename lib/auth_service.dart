import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  // Add method to check current session
  bool get isAuthenticated => _supabase.auth.currentSession != null;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<void> signIn({required String email, required String password}) async {
    await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } on AuthException catch (e) {
      throw Exception('Logout failed: ${e.message}');
    } catch (e) {
      throw Exception('Network error during logout');
    }
  }
}