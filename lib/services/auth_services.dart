import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_services.dart';

class AuthService {
  final SupabaseClient _client = SupabaseService.client;

  /// LOGIN & AMBIL ROLE
  Future<String> login(String email, String password) async {
    // 1. LOGIN AUTH
    final authRes = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = authRes.user;
    if (user == null) {
      throw 'Login gagal';
    }

    // 2. AMBIL ROLE (AMAN DENGAN RLS)
    final userData = await _client
        .from('users')
        .select('role')
        .eq('id', user.id)
        .maybeSingle(); 

    // 3. DEFAULT ROLE JIKA NULL
    return userData?['role'] ?? 'Siswa';
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }
}
