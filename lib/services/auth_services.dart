import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_services.dart';

class AuthService {
  final SupabaseClient _client = SupabaseService.client;

  User? get currentUser => _client.auth.currentUser;

  /// LOGIN + AMBIL ROLE
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) return null;

      final profileRes = await _client
          .from('users') // <- pakai tabel users
          .select('role')
          .eq('id', response.user!.id)
          .maybeSingle();

      final role = profileRes?.data?['role'] ?? 'peminjam';

      return {
        'user': response.user,
        'role': role,
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }
}
