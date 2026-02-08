import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/alat_model.dart';
import '../../utils/colors.dart';

class AlatUpdateScreen extends StatefulWidget {
  final Alat alat;

  const AlatUpdateScreen({super.key, required this.alat});

  @override
  State<AlatUpdateScreen> createState() => _AlatUpdateScreenState();
}

class _AlatUpdateScreenState extends State<AlatUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _stokController;
  int? _selectedKategoriId;
  Uint8List? _newImageBytes;

  final _picker = ImagePicker();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.alat.namaAlat);
    _stokController = TextEditingController(text: widget.alat.stok.toString());
    _selectedKategoriId = widget.alat.idKategori;
  }

  Future<void> _pickImage() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
      );
      if (file != null && mounted) {
        final bytes = await file.readAsBytes();
        setState(() {
          _newImageBytes = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih foto: $e')),
        );
      }
    }
  }

 Future<void> _update() async {
  if (!_formKey.currentState!.validate() || _selectedKategoriId == null) return;

  setState(() => _loading = true);

  try {
    print('=== MULAI UPDATE ===');
    print('ID target: ${widget.alat.idAlat}');
    print('Nilai lama dari widget: nama_alat=${widget.alat.namaAlat}, stok=${widget.alat.stok}');

    String? newImageUrl = widget.alat.gambar;

    if (_newImageBytes != null) {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'alat/$fileName';

      await Supabase.instance.client.storage
          .from('alat_images')
          .uploadBinary(path, _newImageBytes!, fileOptions: const FileOptions(contentType: 'image/jpeg'));

      newImageUrl = Supabase.instance.client.storage.from('alat_images').getPublicUrl(path);
    }

    final updateData = {
      'nama_alat': _namaController.text.trim(),
      'id_kategori': _selectedKategoriId,
      'stok': int.parse(_stokController.text.trim()),
      'gambar': newImageUrl,
    };

    print('Nilai baru yang akan dikirim: $updateData');

    // Cek row sebelum update
    final checkBefore = await Supabase.instance.client
        .from('alat')
        .select('id_alat, nama_alat, stok, gambar')
        .eq('id_alat', widget.alat.idAlat)
        .maybeSingle();

    print('Row sebelum update: $checkBefore');

    // Lakukan update + return row yang terupdate
    final updatedRows = await Supabase.instance.client
        .from('alat')
        .update(updateData)
        .eq('id_alat', widget.alat.idAlat)
        .select(); // ← Return row setelah update

    print('Row setelah update: $updatedRows');

    if (updatedRows.isEmpty) {
      print('WARNING: Update tidak mengubah row apapun (nilai mungkin sama dengan DB)');
      // Optional: kalau ingin force update meskipun sama, tambah field dummy seperti updated_at = now()
      await Supabase.instance.client
          .from('alat')
          .update({'updated_at': DateTime.now().toIso8601String()}) // dummy field kalau ada kolom updated_at
          .eq('id_alat', widget.alat.idAlat);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alat berhasil diperbarui'), backgroundColor: AppColors.success),
      );
      Navigator.pop(context, true);
    }
  } catch (e) {
    print('Update error detail: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal update: $e'), backgroundColor: AppColors.danger),
      );
    }
  } finally {
    if (mounted) setState(() => _loading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Perbarui Alat', style: TextStyle(color: AppColors.textPrimary)),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Foto Alat', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: _newImageBytes != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.memory(_newImageBytes!, fit: BoxFit.cover),
                          )
                        : (widget.alat.gambar != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  widget.alat.gambar!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 60),
                                ),
                              )
                            : Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.cloud_upload, size: 48, color: AppColors.accentBlue),
                                    const SizedBox(height: 8),
                                    Text('Unggah Foto Baru', style: TextStyle(color: AppColors.accentBlue, fontSize: 15)),
                                  ],
                                ),
                              )),
                  ),
                ),
                const SizedBox(height: 28),

                const Text('Nama Alat', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _namaController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: 'Masukkan Nama Alat',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                  validator: (v) => v?.trim().isEmpty ?? true ? 'Wajib diisi' : null,
                ),

                const SizedBox(height: 24),

                const Text('Kategori', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: Supabase.instance.client.from('kategori').select('id_kategori, nama_kategori').order('nama_kategori'),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                    final items = snapshot.data ?? [];
                    return DropdownButtonFormField<int>(
                      value: _selectedKategoriId,
                      isExpanded: true,
                      items: items.map((k) => DropdownMenuItem<int>(
                            value: k['id_kategori'] as int,
                            child: Text(k['nama_kategori'] as String),
                          )).toList(),
                      onChanged: (v) => setState(() => _selectedKategoriId = v),
                      validator: (v) => v == null ? 'Pilih kategori' : null,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                const Text('Stok', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _stokController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Masukkan Stok Alat',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                  validator: (v) {
                    if (v?.trim().isEmpty ?? true) return 'Wajib diisi';
                    final n = int.tryParse(v!.trim());
                    if (n == null || n < 0) return 'Stok harus ≥ 0';
                    return null;
                  },
                ),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _update,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _loading
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.8))
                        : const Text('Simpan Perubahan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _stokController.dispose();
    super.dispose();
  }
}