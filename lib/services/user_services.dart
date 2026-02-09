import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class UserService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ================= READ =================
  Future<List<AppUser>> getAllUsers() async {
    final res = await _supabase
        .from('users')
        .select()
        .order('created_at', ascending: false);

    return (res as List)
        .map((e) => AppUser.fromJson(e))
        .toList();
  }

  // ================= CREATE =================
  Future<void> createUser({
    required String nama,
    required String email,
    required String password,
    required String role,
  }) async {

    // 1️⃣ BUAT AUTH
    final authRes = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    if (authRes.user == null) {
      throw Exception('Gagal membuat akun');
    }

    final userId = authRes.user!.id;

    // 2️⃣ INSERT KE TABLE USERS
    await _supabase.from('users').insert({
      'id': userId,
      'nama': nama,
      'email': email,
      'role': role,
    });
  }

  // ================= UPDATE =================
  Future<void> updateUser(String id, AppUser user) async {
    await _supabase
        .from('users')
        .update({
          'nama': user.nama,
          'email': user.email,
          'role': user.role,
        })
        .eq('id', id);
  }

  // ================= DELETE =================
  Future<void> deleteUser(String id) async {
    await _supabase.from('users').delete().eq('id', id);
  }
}
