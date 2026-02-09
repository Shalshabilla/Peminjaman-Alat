class AppUser {
  final String id;
  final String nama;
  final String email;
  final String role; // Admin, Petugas, Siswa
  final DateTime? createdAt;

  AppUser({
    required this.id,
    required this.nama,
    required this.email,
    required this.role,
    this.createdAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      nama: json['nama'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'Petugas',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'email': email,
      'role': role,
    };
  }
}
