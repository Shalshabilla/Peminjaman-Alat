class Alat {
  final int idAlat;
  final int idKategori;
  final String namaKategori;
  final String namaAlat;
  final int stok;
  final String status;
  final String? gambar; 
  Alat({
    required this.idAlat,
    required this.idKategori,
    required this.namaKategori,
    required this.namaAlat,
    required this.stok,
    required this.status,
    this.gambar,
  });

factory Alat.fromJson(Map<String, dynamic> json) {
  print('DEBUG FROM JSON - keys: ${json.keys.toList()}');
  print('id_alat value: ${json['id_alat']}');

  return Alat(
    idAlat: json['id_alat'] as int? ?? (throw Exception('id_alat missing in json!')),
    idKategori: json['id_kategori'] as int? ?? 0,
    namaKategori: (json['kategori'] as Map?)?['nama_kategori'] as String? ?? 'Tidak ada',
    namaAlat: json['nama_alat'] as String? ?? '',
    stok: json['stok'] as int? ?? 0,
    status: json['status'] as String? ?? 'tersedia',
    gambar: json['gambar'] as String?,
  );
}

}
