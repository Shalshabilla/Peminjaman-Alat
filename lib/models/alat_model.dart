class Alat {
  final int idAlat;
  final int idKategori;
  final String namaAlat;
  final int stok;
  final String status;
  final String? gambar;
  final DateTime? createdAt;

  String? namaKategori; 

  Alat({
    required this.idAlat,
    required this.idKategori,
    required this.namaAlat,
    required this.stok,
    required this.status,
    this.gambar,
    this.createdAt,
    this.namaKategori,
  });

  factory Alat.fromJson(Map<String, dynamic> json) {
    return Alat(
      idAlat: json['id_alat'] as int,
      idKategori: json['id_kategori'] as int,
      namaAlat: json['nama_alat'] as String,
      stok: json['stok'] as int,
      status: json['status'] as String,
      gambar: json['gambar'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }
}
