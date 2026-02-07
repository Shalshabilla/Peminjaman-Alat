import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_services.dart';

class UserService {
  final SupabaseClient _client = SupabaseService.client;

  Future<String?> getUserRole(String userId) async {
    final res = await _client
        .from('users')
        .select('role')
        .eq('id', userId)
        .maybeSingle();
    return res?.data?['role'];
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final res = await _client.from('users').select().execute();
    if (res.error != null || res.data == null) return [];
    return List<Map<String, dynamic>>.from(res.data as List<dynamic>);
  }

  Future<int> getTotalUsers() async {
    final res = await _client.from('users').select('id').execute();
    if (res.error != null || res.data == null) return 0;
    return (res.data as List<dynamic>).length;
  }

  Future<void> deleteUser(String userId) async {
    final res = await _client.from('users').delete().eq('id', userId).execute();
    if (res.error != null) throw res.error!;
  }
}
