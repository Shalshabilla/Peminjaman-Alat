import 'package:flutter/material.dart';
import '../../models/kategori_model.dart';
import '../../services/kategori_services.dart';

class AddEditKategoriDialog {
  static Future<bool?> show(
    BuildContext context, {
    Kategori? kategori,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => _AddEditDialogContent(kategori: kategori),
    );
  }
}

// Widget internal (bisa private karena hanya dipakai di sini)
class _AddEditDialogContent extends StatefulWidget {
  final Kategori? kategori;

  const _AddEditDialogContent({this.kategori});

  @override
  State<_AddEditDialogContent> createState() => __AddEditDialogContentState();
}

class __AddEditDialogContentState extends State<_AddEditDialogContent> {
  final KategoriService _service = KategoriService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _namaController;
  late TextEditingController _deskripsiController;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.kategori?.namaKategori ?? '');
    _deskripsiController = TextEditingController(text: widget.kategori?.deskripsikategori ?? '');
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final newKategori = Kategori(
      id: widget.kategori?.id,
      namaKategori: _namaController.text.trim(),
      deskripsikategori: _deskripsiController.text.trim(),
    );

    try {
      if (widget.kategori == null) {
        await _service.insertKategori(newKategori);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kategori berhasil ditambahkan')),
          );
        }
      } else {
        await _service.updateKategori(widget.kategori!.id!, newKategori);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kategori berhasil diperbarui')),
          );
        }
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.kategori != null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        isEdit ? 'Perbarui Kategori' : 'Tambah Kategori',
        style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _namaController,
              decoration: InputDecoration(
                labelText: 'Nama Kategori',
                hintText: 'Masukkan Nama Kategori',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              ),
              validator: (v) => v?.trim().isEmpty ?? true ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _deskripsiController,
              decoration: InputDecoration(
                labelText: 'Deskripsi Kategori',
                hintText: 'Masukkan Deskripsi Kategori',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              ),
              validator: (v) => v?.trim().isEmpty ?? true ? 'Wajib diisi' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'Batal',
            style: TextStyle(color: Colors.blue[800]),
          ),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.blue[800],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: _save,
          child: const Text('Simpan', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }
}