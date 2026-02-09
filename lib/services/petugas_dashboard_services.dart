import 'package:supabase_flutter/supabase_flutter.dart';

class PetugasDashboardService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Mengambil jumlah untuk 4 card di dashboard petugas
  Future<Map<String, int>> getStatusCounts() async {
    try {
      // Hari ini dalam format YYYY-MM-DD (UTC untuk konsistensi)
      final now = DateTime.now().toUtc();
      final todayStart = now.toIso8601String().split('T')[0];
      final todayEnd = DateTime(now.year, now.month, now.day + 1)
          .toUtc()
          .toIso8601String()
          .split('T')[0];

      // 1. Pengajuan peminjaman baru (status = 'menunggu' atau 'diajukan' atau sesuai DB kamu)
      final pengajuanBaru = await _supabase
          .from('peminjaman')
          .count(CountOption.exact)
          .eq('status', 'Menunggu'); // ← sesuaikan nama status

      // 2. Peminjaman Aktif
      final peminjamanAktif = await _supabase
          .from('peminjaman')
          .count(CountOption.exact)
          .eq('status', 'Dipinjam'); // ← sesuaikan nama status

      // 3. Pengembalian hari ini
      final pengembalianHariIni = await _supabase
          .from('pengembalian') // atau view/join jika pengembalian ada di tabel lain
          .count(CountOption.exact)
          .gte('created_at', '$todayStart 00:00:00+00')
          .lt('created_at', '$todayEnd 00:00:00+00');

      // 4. Terlambat
      // Contoh logika: peminjaman yang status dipinjam dan tanggal_kembali < hari ini
      final terlambat = await _supabase
          .from('peminjaman')
          .count(CountOption.exact)
          .eq('status', 'Dipinjam')
          .lt('tgl_kembali_rencana', now.toIso8601String()); // ← sesuaikan nama kolom

      return {
        'pengajuanBaru': pengajuanBaru ?? 0,
        'peminjamanAktif': peminjamanAktif ?? 0,
        'pengembalianHariIni': pengembalianHariIni ?? 0,
        'terlambat': terlambat ?? 0,
      };
    } catch (e) {
      print('Error PetugasDashboardService.getStatusCounts: $e');
      return {
        'pengajuanBaru': 0,
        'peminjamanAktif': 0,
        'pengembalianHariIni': 0,
        'terlambat': 0,
      };
    }
  }

  // Opsional: jika nanti butuh daftar pengajuan terbaru / terlambat dll
  Future<List<Map<String, dynamic>>> getRecentPengajuan({int limit = 5}) async {
    try {
      final response = await _supabase
          .from('peminjaman')
          .select('''
            id_peminjaman,
            created_at,
            status,
            users!peminjaman_id_user_fkey (nama),
            alat (nama_alat)
          ''')
          .eq('status', 'Menunggu')
          .order('created_at', ascending: false)
          .limit(limit);

      return response;
    } catch (e) {
      print('Error getRecentPengajuan: $e');
      return [];
    }
  }
}