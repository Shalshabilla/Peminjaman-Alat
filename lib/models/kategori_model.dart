class Kategori {
  final int? id; // nullable karena insert tidak butuh id
  final String namaKategori;
  final String deskripsikategori;

  Kategori({
    this.id,
    required this.namaKategori,
    required this.deskripsikategori,
  });

  factory Kategori.fromJson(Map<String, dynamic> json) {
    return Kategori(
      id: json['id_kategori'] as int?,
      namaKategori: json['nama_kategori'] as String? ?? '',
      deskripsikategori: json['deskripsi_kategori'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_kategori': namaKategori,
      'deskripsi_kategori': deskripsikategori,
    };
  }
}
