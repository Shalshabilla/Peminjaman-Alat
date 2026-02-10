import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/alat_model.dart';

class AlatService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String bucketName = 'alat_images'; 

  // CREATE 
  Future<void> createAlat(Alat alat, Uint8List? imageBytes, String? fileName) async {
    String? imageUrl;

    if (imageBytes != null && fileName != null) {
      try {
        final path = 'alat/${DateTime.now().millisecondsSinceEpoch}_$fileName';

        await _supabase.storage
            .from(bucketName)
            .uploadBinary(path, imageBytes, fileOptions: const FileOptions(contentType: 'image/jpeg'));

        imageUrl = _supabase.storage.from(bucketName).getPublicUrl(path);
      } catch (e) {
        throw Exception('Gagal upload gambar: $e');
      }
    }

    await _supabase.from('alat').insert({
  'nama_alat': alat.namaAlat.trim(),
  'id_kategori': alat.idKategori,
  'stok': alat.stok,
  'gambar': imageUrl,
  'status': 'tersedia', 
});
  }

  // UPDATE 
  Future<void> updateAlat(int id, Alat updatedAlat, Uint8List? newImageBytes) async {
    try {
      String? newImageUrl = updatedAlat.gambar;

      if (newImageBytes != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final path = 'alat/$fileName';

        await _supabase.storage.from(bucketName).uploadBinary(path, newImageBytes, fileOptions: const FileOptions(contentType: 'image/jpeg'));
        newImageUrl = _supabase.storage.from(bucketName).getPublicUrl(path);

        if (updatedAlat.gambar != null && updatedAlat.gambar!.isNotEmpty) {
          final oldPath = updatedAlat.gambar!.split('/').last;
          try {
            await _supabase.storage.from(bucketName).remove(['alat/$oldPath']);
          } catch (_) {}
        }
      }

      await _supabase.from('alat').update({
  'nama_alat': updatedAlat.namaAlat.trim(),
  'id_kategori': updatedAlat.idKategori,
  'stok': updatedAlat.stok,
  'status': 'tersedia', 
  'gambar': newImageUrl,
}).eq('id_alat', id);
    } catch (e) {
      throw Exception('Gagal update alat: $e');
    }
  }

  // DELETE 
  Future<void> deleteAlat(int id) async {
    try {
      final alatData = await _supabase
          .from('alat')
          .select('gambar')
          .eq('id_alat', id)
          .maybeSingle();

      if (alatData != null && alatData['gambar'] != null) {
        final imagePath = alatData['gambar'].split('/').last;
        try {
          await _supabase.storage.from(bucketName).remove(['alat/$imagePath']);
        } catch (_) {}
      }

      await _supabase.from('alat').delete().eq('id_alat', id);
    } catch (e) {
      throw Exception('Gagal hapus alat: $e');
    }
  }

  // getAllAlat 
  Future<List<Alat>> getAllAlat({String? kategoriFilter}) async {
    try {
      dynamic query = _supabase.from('alat');

      if (kategoriFilter != null && kategoriFilter != 'Semua') {
        final catRes = await _supabase
            .from('kategori')
            .select('id_kategori')
            .eq('nama_kategori', kategoriFilter)
            .maybeSingle();

        if (catRes == null || catRes['id_kategori'] == null) return [];

        final idKat = catRes['id_kategori'] as int;
        query = query.eq('id_kategori', idKat);
      }

      final response = await query
          .select('''
            id_alat, id_kategori, nama_alat, stok, status, gambar, created_at,
            kategori!inner (nama_kategori)
          ''')
          .order('created_at', ascending: false);

      return response.map((json) => Alat.fromJson(json)).toList();
    } catch (e) {
      print('Error getAllAlat: $e');
      return [];
    }
  }
}