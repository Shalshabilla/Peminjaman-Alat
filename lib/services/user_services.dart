import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class UserService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // =========================
  // READ: Ambil semua user
  // =========================
  Future<List<AppUser>> getAllUsers() async {
    try {
      final List<Map<String, dynamic>> res =
          await _supabase
              .from('users')
              .select()
              .order('created_at', ascending: false);

      return res.map((e) => AppUser.fromJson(e)).toList();
    } catch (e) {
      print('Error getAllUsers: $e');
      return [];
    }
  }

  // =========================
  // CREATE: Buat user baru
  // =========================
  Future<void> createUser({
    required String nama,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final authRes = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'nama': nama.trim(),
          'role': role,
        },
      );

      if (authRes.user == null) {
        throw Exception('Gagal membuat akun Auth');
      }

      final userId = authRes.user!.id;

      final existing = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (existing != null) {
        await _supabase.from('users').update({
          'nama': nama.trim(),
          'role': role,
          'email': email.trim(),
        }).eq('id', userId);
        return;
      }

      await _supabase.from('users').insert({
        'id': userId,
        'nama': nama.trim(),
        'email': email.trim(),
        'role': role,
      });

    } on AuthException catch (e) {
      if (e.code == 'user_already_exists') {
        throw Exception('Email sudah terdaftar');
      }
      rethrow;
    } catch (e) {
      print('Error createUser: $e');
      rethrow;
    }
  }

  // =========================
  // UPDATE: Update user
  // =========================
  Future<void> updateUser(String id, AppUser updatedUser) async {
    try {
      await _supabase
          .from('users')
          .update(updatedUser.toJson())
          .eq('id', id);

      // Update metadata Auth hanya jika update diri sendiri
      final currentUser = _supabase.auth.currentUser;
      if (currentUser != null && currentUser.id == id) {
        await _supabase.auth.updateUser(
          UserAttributes(
            data: {
              'nama': updatedUser.nama,
              'role': updatedUser.role,
            },
          ),
        );
      }

    } catch (e) {
      print('Error updateUser: $e');
      rethrow;
    }
  }

  // =========================
  // DELETE: Hapus user
  // =========================
  Future<void> deleteUser(String id) async {
    try {
      await _supabase
          .from('users')
          .delete()
          .eq('id', id);

    } catch (e) {
      print('Error deleteUser: $e');
      rethrow;
    }
  }
}
