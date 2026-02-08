import 'package:flutter/material.dart';
import '../../models/kategori_model.dart';
import '../../services/kategori_services.dart';

class KategoriUpdateScreen extends StatefulWidget {
  final Kategori kategori;

  const KategoriUpdateScreen({super.key, required this.kategori});

  @override
  State<KategoriUpdateScreen> createState() => _KategoriUpdateScreenState();
}

class _KategoriUpdateScreenState extends State<KategoriUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _deskripsiController;

  final KategoriService _kategoriService = KategoriService();

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.kategori.namaKategori);
    _deskripsiController = TextEditingController(text: widget.kategori.deskripsikategori);
  }

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _updateKategori() async {
    if (_formKey.currentState!.validate()) {
      final updatedKategori = Kategori(
        id: widget.kategori.id,
        namaKategori: _namaController.text.trim(),
        deskripsikategori: _deskripsiController.text.trim(),
      );

      try {
        await _kategoriService.updateKategori(widget.kategori.id!, updatedKategori);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kategori berhasil diperbarui')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memperbarui kategori: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perbarui Kategori'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nama Kategori', style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  hintText: 'Masukkan Nama Kategori',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Nama kategori wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              const Text('Deskripsi Alat', style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _deskripsiController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Masukkan Deskripsi Alat',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Deskripsi wajib diisi' : null,
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _updateKategori,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Simpan', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}