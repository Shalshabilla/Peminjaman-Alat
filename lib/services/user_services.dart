import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class UserService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<AppUser>> getAllUsers({String? roleFilter}) async {
    var query = _supabase.from('users').select();
    if (roleFilter != null && roleFilter != 'Semua') {
      query = query.eq('role', roleFilter);
    }
    final res = await query.order('created_at', ascending: false);
    return res.map((e) => AppUser.fromJson(e)).toList();
  }

  Future<void> createUser(AppUser user) async {
    await _supabase.from('users').insert(user.toJson());
  }

  Future<void> updateUser(String id, AppUser user) async {
    await _supabase.from('users').update(user.toJson()).eq('id', id);
  }

  Future<void> deleteUser(String id) async {
    await _supabase.from('users').delete().eq('id', id);
  }
}