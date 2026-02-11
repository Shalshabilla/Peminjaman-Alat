import 'package:pinjam_alat_lab/models/peminjaman_model.dart';

class Pengembalian {
  final int idPengembalian;
  final String status;
  final DateTime tglKembali;
  final int denda;
  final String? namaPeminjam;
  final List<DetailPeminjaman> detail;

  Pengembalian({
    required this.idPengembalian,
    required this.status,
    required this.tglKembali,
    required this.denda,
    this.namaPeminjam,
    required this.detail,
  });

  factory Pengembalian.fromJson(Map<String, dynamic> json) {
    final peminjaman = json['peminjaman'] ?? {};
    final user = peminjaman['users'] ?? {};

    final details = (peminjaman['detail_peminjaman'] as List<dynamic>?)
            ?.map((d) => DetailPeminjaman.fromJson(d))
            .toList() ??
        [];

    return Pengembalian(
      idPengembalian: json['id_pengembalian'],
      status: peminjaman['status'] ?? 'dikembalikan',
      tglKembali: DateTime.parse(json['tgl_kembali_asli']),
      denda: (json['denda'] as num?)?.toInt() ?? 0,
      namaPeminjam: user['nama'],
      detail: details,
    );
  }
}
