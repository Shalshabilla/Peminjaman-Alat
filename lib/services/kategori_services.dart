import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/kategori_model.dart';

class KategoriService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Kategori>> getAllKategori() async {
    try {
      final response = await _client.from('kategori').select();
      return response.map((map) => Kategori.fromMap(map)).toList();
    } on PostgrestException catch (e) {
      throw Exception('Gagal mengambil data: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  Future<void> insertKategori(Kategori kategori) async {
    try {
      await _client.from('kategori').insert(kategori.toMap());
    } on PostgrestException catch (e) {
      throw Exception('Gagal menambah kategori: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  Future<void> updateKategori(int id, Kategori kategori) async {
    try {
      await _client.from('kategori').update(kategori.toMap()).eq('id', id);
    } on PostgrestException catch (e) {
      throw Exception('Gagal memperbarui kategori: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  Future<void> deleteKategori(int id) async {
    try {
      await _client.from('kategori').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw Exception('Gagal menghapus kategori: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}