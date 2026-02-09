import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_services.dart';

class AuthService {
  final SupabaseClient _client = SupabaseService.client;

  /// LOGIN & AMBIL ROLE
Future<String> login(String email, String password) async {
  try {
    // 1. Lakukan login
    final authRes = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = authRes.user;
    if (user == null) {
      throw AuthException('User tidak ditemukan setelah login');
    }

    // 2. Ambil role dari tabel users (sekali saja, karena RLS read own aman)
    final userData = await _client
        .from('users')
        .select('role')
        .eq('id', user.id)
        .maybeSingle();

    String role = (userData?['role'] as String?)?.trim().toLowerCase() ?? 'peminjam';

    // 3. Update metadata JWT supaya role tersimpan di token (untuk policy JWT)
    await _client.auth.updateUser(
      UserAttributes(
        data: {'role': role}, 
      ),
    );

    print('Role berhasil disimpan di metadata: $role');

    // 4. Return role
    return role;
  } catch (e) {
    print('Error login: $e');
    rethrow;
  }
}

  Future<void> logout() async {
    await _client.auth.signOut();
  }
}
