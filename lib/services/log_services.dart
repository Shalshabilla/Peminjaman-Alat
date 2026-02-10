import 'package:supabase_flutter/supabase_flutter.dart';

class LogService {
  static Future<void> addLog({
    required String aktifitas,
    String? detail,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    String nama = 'Unknown';
    String role = 'unknown';

    try {
      final userData = await Supabase.instance.client
          .from('users')
          .select('nama, role')
          .eq('id', user.id)
          .single();

      nama = userData['nama'] ?? 'Unknown';
      role = userData['role'] ?? 'unknown';
    } catch (_) {}

    await Supabase.instance.client.from('log_aktivitas').insert({
      'id_user': user.id,
      'nama_user': nama,
      'role': role,
      'aktifitas': aktifitas,
      'detail': detail != null ? {'info': detail} : null,
    });
  }
}