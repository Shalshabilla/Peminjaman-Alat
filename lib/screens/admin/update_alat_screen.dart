import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/alat_model.dart';
import '../../services/alat_services.dart';
import '../../utils/colors.dart'; 

class AlatUpdateScreen extends StatefulWidget {
  final Alat alat;

  const AlatUpdateScreen({super.key, required this.alat});

  @override
  State<AlatUpdateScreen> createState() => _AlatUpdateScreenState();
}

class _AlatUpdateScreenState extends State<AlatUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _stokController = TextEditingController();
  int? _selectedKategoriId;

  Uint8List? _newImageBytes;
  File? _newImageFile; // Untuk mobile
  String? _existingGambar; // Gambar lama
  final _picker = ImagePicker();
  final _service = AlatService();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _namaController.text = widget.alat.namaAlat;
    _stokController.text = widget.alat.stok.toString();
    _selectedKategoriId = widget.alat.idKategori;
    _existingGambar = widget.alat.gambar;
  }

  Future<List<Map<String, dynamic>>> _loadKategori() async {
    try {
      final res = await Supabase.instance.client
          .from('kategori')
          .select('id_kategori, nama_kategori')
          .order('nama_kategori');
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat kategori: $e')),
        );
      }
      return [];
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
      );

      if (file != null && mounted) {
        if (kIsWeb) {
          final bytes = await file.readAsBytes();
          setState(() => _newImageBytes = bytes);
        } else {
          setState(() => _newImageFile = File(file.path));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih foto: $e')),
        );
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _selectedKategoriId == null) {
      if (_selectedKategoriId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih kategori terlebih dahulu')),
        );
      }
      return;
    }

    setState(() => _loading = true);

    try {
      Uint8List? newBytes;
      if (kIsWeb) {
        newBytes = _newImageBytes;
      } else if (_newImageFile != null) {
        newBytes = await _newImageFile!.readAsBytes();
      }

      final updatedAlat = Alat(
        idAlat: widget.alat.idAlat,
        idKategori: _selectedKategoriId!,
        namaKategori: widget.alat.namaKategori ?? '',
        namaAlat: _namaController.text.trim(),
        stok: int.parse(_stokController.text.trim()),
        status: 'tersedia', 
        gambar: _existingGambar,
      );

      await _service.updateAlat(widget.alat.idAlat, updatedAlat, newBytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alat berhasil diupdate!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true); // Refresh list
      }
    } catch (e) {
      String errorMsg = 'Gagal update: $e';
      if (e.toString().contains('23514')) {
        errorMsg = 'Nilai status tidak valid! Cek constraint database dan sesuaikan nilai "status" di kode.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _buildImagePreview() {
    if (_newImageBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.memory(_newImageBytes!, fit: BoxFit.cover),
      );
    } else if (!kIsWeb && _newImageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(_newImageFile!, fit: BoxFit.cover),
      );
    } else if (_existingGambar != null && _existingGambar!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(_existingGambar!, fit: BoxFit.cover),
      );
    } else {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_upload, size: 48, color: AppColors.accentBlue),
            const SizedBox(height: 8),
            Text(
              'Unggah Foto Baru',
              style: TextStyle(color: AppColors.accentBlue, fontSize: 15),
            ),
          ],
        ),
      );
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
        title: const Text('Update Alat', style: TextStyle(color: AppColors.textPrimary)),
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
                    child: _buildImagePreview(),
                  ),
                ),
                const SizedBox(height: 28),

                // Nama Alat
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

                // Kategori
                const Text('Kategori', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _loadKategori(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final items = snapshot.data ?? [];
                    return DropdownButtonFormField<int>(
                      value: _selectedKategoriId,
                      hint: const Text('Pilih Kategori'),
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

                // Stok
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
                    onPressed: _loading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.8),
                          )
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