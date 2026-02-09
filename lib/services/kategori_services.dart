import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/kategori_model.dart';

class KategoriService {
  final supabase = Supabase.instance.client;

  Future<List<Kategori>> getAllKategori() async {
    final response = await supabase
        .from('kategori')
        .select()
        .order('id_kategori');

    return response.map<Kategori>((e) => Kategori.fromJson(e)).toList();
  }

  Future<void> insertKategori(Kategori kategori) async {
    await supabase.from('kategori').insert(kategori.toJson());
  }

  Future<void> updateKategori(int id, Kategori kategori) async {
    await supabase
        .from('kategori')
        .update(kategori.toJson())
        .eq('id_kategori', id);
  }

  Future<void> deleteKategori(int id) async {
    await supabase.from('kategori').delete().eq('id_kategori', id);
  }
}
