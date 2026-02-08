class Kategori {
  final int? id;
  final String namaKategori;
  final String deskripsikategori;

  Kategori({
    this.id,
    required this.namaKategori,
    required this.deskripsikategori,
  });

  factory Kategori.fromMap(Map<String, dynamic> map) {
    return Kategori(
      id: map['id'] as int?,
      namaKategori: map['nama_kategori'] as String? ?? '',
      deskripsikategori: map['deskripsi_kategori'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama_kategori': namaKategori,
      'deskripsi_kategori': deskripsikategori,
    };
  }
}