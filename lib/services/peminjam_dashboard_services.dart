import 'package:supabase_flutter/supabase_flutter.dart';

class PeminjamDashboardService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Mengambil jumlah untuk 3 card di dashboard peminjam
  Future<Map<String, int>> getStatusCounts() async {
  try {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User tidak terautentikasi');
    }

    final now = DateTime.now().toUtc().toIso8601String();

    // 1. Menunggu Persetujuan
    final menunggu = await _supabase
        .from('peminjaman')
        .select('count(*)')  // atau .select() saja kalau tidak butuh data
        .eq('id_user', userId)
        .eq('status', 'Menunggu')
        .count(CountOption.exact);

    // 2. Peminjaman Aktif
    final aktif = await _supabase
        .from('peminjaman')
        .select('count(*)')
        .eq('id_user', userId)
        .inFilter('status', ['Disetujui', 'Dipinjam'])
        .count(CountOption.exact);

    // 3. Terlambat
    final terlambat = await _supabase
        .from('peminjaman')
        .select('count(*)')
        .eq('id_user', userId)
        .lt('tgl_kembali_rencana', now)
        .neq('status', 'Dikembalikan')
        .count(CountOption.exact);

    print('Dashboard counts: Menunggu = ${menunggu.count ?? 0}, '
          'Aktif = ${aktif.count ?? 0}, Terlambat = ${terlambat.count ?? 0}');

    return {
      'menungguPersetujuan': menunggu.count ?? 0,
      'peminjamanAktif': aktif.count ?? 0,
      'terlambat': terlambat.count ?? 0,
    };
  } catch (e, stackTrace) {
    print('Error di getStatusCounts: $e');
    print('Stack trace: $stackTrace');
    return {'menungguPersetujuan': 0, 'peminjamanAktif': 0, 'terlambat': 0};
  }
}
  // Opsional: riwayat peminjaman terbaru untuk tab riwayat nanti
  Future<List<Map<String, dynamic>>> getRiwayatPeminjaman({int limit = 10}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await _supabase
          .from('peminjaman')
          .select('''
            id_peminjaman,
            created_at,
            tgl_pinjam,
            tgl_kembali_rencana,
            status,
            alat (nama_alat, id_alat)
          ''')
          .eq('id_user', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      return response;
    } catch (e) {
      print('Error getRiwayatPeminjaman: $e');
      return [];
    }
  }
}