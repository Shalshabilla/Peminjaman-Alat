import 'package:supabase_flutter/supabase_flutter.dart';

class PeminjamDashboardService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Mengambil jumlah untuk 3 card di dashboard peminjam
  Future<Map<String, int>> getStatusCounts() async {
    try {
      // Ambil user yang sedang login
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User tidak terautentikasi');
      }

      // Hari ini (untuk filter terlambat jika diperlukan)
      final now = DateTime.now().toUtc().toIso8601String();

      // 1. Menunggu Persetujuan (status menunggu / pending)
      final menungguPersetujuan = await _supabase
          .from('peminjaman')
          .count(CountOption.exact)
          .eq('id_user', userId)
          .eq('status', 'Menunggu'); // ← sesuaikan nama status

      // 2. Peminjaman Aktif
      final peminjamanAktif = await _supabase
          .from('peminjaman')
          .count(CountOption.exact)
          .eq('id_user', userId)
          .eq('status', 'Dipinjam'); // ← sesuaikan nama status

      // 3. Terlambat (hanya yang masih dipinjam dan lewat tanggal kembali)
      final terlambat = await _supabase
          .from('peminjaman')
          .count(CountOption.exact)
          .eq('id_user', userId)
          .eq('status', 'Dipinjam')
          .lt('tgl_kembali_rencana', now); // ← sesuaikan nama kolom tanggal kembali

      return {
        'menungguPersetujuan': menungguPersetujuan ?? 0,
        'peminjamanAktif': peminjamanAktif ?? 0,
        'terlambat': terlambat ?? 0,
      };
    } catch (e) {
      print('Error PeminjamDashboardService.getStatusCounts: $e');
      return {
        'menungguPersetujuan': 0,
        'peminjamanAktif': 0,
        'terlambat': 0,
      };
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