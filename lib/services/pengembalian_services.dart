import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pengembalian_model.dart';

class PengembalianService {
  final supabase = Supabase.instance.client;

  Future<List<Pengembalian>> getAllPengembalian() async {
    final response = await supabase
        .from('pengembalian')
        .select('''
          id_pengembalian,
          tgl_kembali_asli,
          denda,
          peminjaman!pengembalian_id_peminjaman_fkey (
            id_peminjaman,
            status,
            users!peminjaman_id_user_fkey (
              nama
            ),
            detail_peminjaman (
              jumlah,
              alat (
                nama_alat
              )
            )
          )
        ''')
        .order('created_at', ascending: false);

    return (response as List)
        .map((e) => Pengembalian.fromJson(e))
        .toList();
  }
}
