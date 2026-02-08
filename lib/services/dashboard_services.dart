import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      // 1. Total User
      final totalUser = await _supabase.from('users').count(CountOption.exact);

      // 2. Total Alat
      final totalAlat = await _supabase.from('alat').count(CountOption.exact);

      // 3. Peminjaman Aktif
      final peminjamanAktif = await _supabase
          .from('peminjaman')
          .count(CountOption.exact)
          .eq('status', 'dipinjam'); // sesuaikan nama status jika beda

      // 4. Dikembalikan Hari Ini (contoh query)
      final today = DateTime.now().toUtc().toIso8601String().split('T')[0];
      final dikembalikanHariIni = await _supabase
          .from('pengembalian')
          .count(CountOption.exact)
          .gte('created_at', '$today 00:00:00')
          .lt('created_at', '$today 23:59:59'); // sesuaikan kolom tanggal

      return {
        'totalUser': totalUser,
        'totalAlat': totalAlat,
        'peminjamanAktif': peminjamanAktif,
        'dikembalikanHariIni': dikembalikanHariIni,
      };
    } catch (e) {
      print('Error getDashboardData: $e');
      return {
        'totalUser': 0,
        'totalAlat': 0,
        'peminjamanAktif': 0,
        'dikembalikanHariIni': 0,
      };
    }
  }

  /// Ambil 5 aktivitas terbaru (log)
  Future<List<Map<String, dynamic>>> getRecentActivities({int limit = 6}) async {
    try {
      final response = await _supabase
          .from('log_aktifitas')
          .select('''
            id_log,
            created_at,
            aktifitas,
            id_user,
            users!inner (nama)
          ''')
          .order('created_at', ascending: false)
          .limit(limit);

      return _parseLogs(response);
    } catch (e) {
      print('Error getRecentActivities: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllActivities() async {
    try {
      final response = await _supabase
          .from('log_aktifitas')
          .select('''
            id_log,
            created_at,
            aktifitas,
            id_user,
            users!inner (nama)
          ''')
          .order('created_at', ascending: false);

      return _parseLogs(response);
    } catch (e) {
      print('Error getAllActivities: $e');
      return [];
    }
  }

  List<Map<String, dynamic>> _parseLogs(dynamic response) {
    final List<Map<String, dynamic>> logs = [];
    for (var row in response as List<dynamic>) {
      final userData = (row as Map<String, dynamic>)['users'] as Map<String, dynamic>?;
      final namaUser = userData?['nama'] as String? ?? 'Pengguna Tidak Diketahui';

      logs.add({
        'created_at': row['created_at'],
        'aktifitas': row['aktifitas'],
        'nama_user': namaUser,
      });
    }
    return logs;
  }
}