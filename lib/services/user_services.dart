import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<String?> getUserRole(String userId) async {
    final data = await _client
        .from('profiles')
        .select('role')
        .eq('id', userId)
        .single();

    return data['role'];
  }
}
