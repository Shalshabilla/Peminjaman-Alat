import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class UserService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // READ: Ambil semua user
  Future<List<AppUser>> getAllUsers() async {
    try {
      final res = await _supabase
          .from('users')
          .select()
          .order('created_at', ascending: false);

      print('Data dari Supabase: $res'); // Debug: lihat apa yang dikembalikan

      return (res as List<dynamic>)
          .map((e) => AppUser.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getAllUsers: $e');
      return [];
    }
  }

  // CREATE: Buat user baru (Auth + tabel users)
  Future<void> createUser({
  required String nama,
  required String email,
  required String password,
  required String role,
}) async {
  try {
    print('Mencoba create: nama=$nama, email=$email, role=$role');

    // 1. Buat akun Auth
    final authRes = await _supabase.auth.signUp(
      email: email.trim(),
      password: password,
      data: {'nama': nama.trim(), 'role': role},
    );

    if (authRes.user == null) {
      throw Exception('Gagal membuat akun Auth');
    }

    final userId = authRes.user!.id;
    print('Auth ID: $userId');

    // 2. Cek apakah sudah ada di tabel users
    final existing = await _supabase
        .from('users')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (existing != null) {
      print('User sudah ada di tabel users → update saja');
      // Update nama & role jika kosong atau berbeda
      await _supabase.from('users').update({
        'nama': nama.trim(),
        'role': role,
        'email': email.trim(),
      }).eq('id', userId);
      print('Update berhasil karena sebelumnya duplikat');
      return;
    }

    // 3. Insert baru
    final insertRes = await _supabase.from('users').insert({
      'id': userId,
      'nama': nama.trim(),
      'email': email.trim(),
      'role': role,
    }).select();

    print('Insert berhasil: $insertRes');

  } on AuthException catch (e) {
    if (e.code == 'user_already_exists') {
      throw Exception('Email sudah terdaftar. Gunakan email lain atau hapus dulu di dashboard.');
    }
    rethrow;
  } catch (e) {
    print('Error createUser: $e');
    rethrow;
  }
}

  // UPDATE: Update data user
  Future<void> updateUser(String id, AppUser updatedUser) async {
    try {
      await _supabase
          .from('users')
          .update(updatedUser.toJson())
          .eq('id', id);

      print('User $id berhasil diupdate: ${updatedUser.toJson()}');

      // Optional: Update metadata Auth
      await _supabase.auth.updateUser(
        UserAttributes(data: {'nama': updatedUser.nama, 'role': updatedUser.role}),
      );
    } catch (e) {
      print('Error updateUser: $e');
      rethrow;
    }
  }

  // DELETE: Hapus user
  Future<void> deleteUser(String id) async {
    try {
      await _supabase.from('users').delete().eq('id', id);
      print('User $id dihapus dari tabel users');

      // Hapus dari Auth (hanya jika pakai service role key)
      // await _supabase.auth.admin.deleteUser(id);
    } catch (e) {
      print('Error deleteUser: $e');
      rethrow;
    }
  }
}