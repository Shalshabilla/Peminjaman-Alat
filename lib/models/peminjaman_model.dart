class Peminjaman {
  final int idPeminjaman;
  final String status;
  final DateTime tglPinjam;
  final DateTime? tglKembali; 
  final String namaPeminjam;
  final List<DetailPeminjaman> detail;

  Peminjaman({
    required this.idPeminjaman,
    required this.status,
    required this.tglPinjam,
    this.tglKembali,
    required this.namaPeminjam,
    required this.detail,
  });

  factory Peminjaman.fromJson(Map<String, dynamic> json) {
    return Peminjaman(
      idPeminjaman: json['id_peminjaman'] ?? 0,
      status: json['status'] ?? '-',
      tglPinjam: DateTime.tryParse(json['tgl_pinjam'] ?? '') ?? DateTime.now(),
      tglKembali: DateTime.tryParse(json['tgl_kembali_rencana'] ?? ''),
      namaPeminjam: json['users']?['nama'] ?? '-',
      detail: (json['detail_peminjaman'] as List<dynamic>?)
              ?.map((e) => DetailPeminjaman.fromJson(e))
              .toList() ??
          [],
    );
  }

  DateTime? get tglKembaliRencana => tglKembali;
}


class DetailPeminjaman {
  final int jumlah;
  final String namaAlat;
  final String? gambar;

  DetailPeminjaman({
    required this.jumlah,
    required this.namaAlat,
    this.gambar,
  });

  factory DetailPeminjaman.fromJson(Map<String, dynamic> json) {
    return DetailPeminjaman(
      jumlah: json['jumlah'] ?? 0,
      namaAlat: json['alat']?['nama_alat'] ?? '-',
      gambar: json['alat']?['gambar'],
    );
  }
}
