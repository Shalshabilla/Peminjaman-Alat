import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_services.dart';

class AuthService {
  final SupabaseClient _client = SupabaseService.client;

  Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    // Langsung login dulu via auth
    final authResponse = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    // Kalau sampai sini berarti login berhasil (tidak throw exception)
    final userId = authResponse.user!.id;

    // Ambil role dari tabel users (harusnya sudah bisa karena user sudah authenticated)
    final userData = await _client
        .from('users')
        .select('role')
        .eq('id', userId)
        .single();

    return {
      'role': userData['role'] as String,
    };
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }
}