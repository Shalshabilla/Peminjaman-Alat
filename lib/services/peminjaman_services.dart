import 'supabase_services.dart';

class PeminjamanService {
  final _client = SupabaseService.client;

  Future<int> getPeminjamanAktif() async {
    final res = await _client
        .from('peminjaman')
        .select('id_peminjaman')
        .eq('status', 'dipinjam');
    return (res as List).length;
  }

  Future<int> getDikembalikanHariIni() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);

    final res = await _client
        .from('peminjaman')
        .select('id_peminjaman')
        .eq('status', 'dikembalikan')
        .eq('tgl_kembali', today);

    return (res as List).length;
  }

  Future<List<Map<String, dynamic>>> getLogTerbaru() async {
    final res = await _client
        .from('peminjaman')
        .select('user:nama, status, created_at')
        .order('created_at', ascending: false)
        .limit(5);

    return List<Map<String, dynamic>>.from(res as List);
  }
}

