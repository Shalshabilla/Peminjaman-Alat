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
      idPeminjaman: json['id_peminjaman'],
      status: json['status'],
      tglPinjam: DateTime.parse(json['tgl_pinjam']),
      tglKembali: json['tgl_kembali_rencana'] != null
          ? DateTime.parse(json['tgl_kembali_rencana'])
          : null,
      namaPeminjam: json['users']?['nama'] ?? '-',
      detail: (json['detail_peminjaman'] as List? ?? [])
          .map((e) => DetailPeminjaman.fromJson(e))
          .toList(),
    );
  }

  get tglKembaliRencana => null;
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
      jumlah: json['jumlah'],
      namaAlat: json['alat']?['nama_alat'] ?? '-',
      gambar: json['alat']?['gambar'],
    );
  }
}
