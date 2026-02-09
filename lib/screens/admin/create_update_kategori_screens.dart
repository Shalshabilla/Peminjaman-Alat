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
      barrierDismissible: false,
      builder: (_) => _AddEditDialogContent(kategori: kategori),
    );
  }
}

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

  final Color primary = const Color(0xFF2F3A8F);

  @override
  void initState() {
    super.initState();
    _namaController =
        TextEditingController(text: widget.kategori?.namaKategori ?? '');
    _deskripsiController =
        TextEditingController(text: widget.kategori?.deskripsikategori ?? '');
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
      } else {
        await _service.updateKategori(widget.kategori!.id!, newKategori);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    }
  }

  InputDecoration fieldStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: primary, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: primary, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.kategori != null;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isEdit ? 'Perbarui Kategori' : 'Tambah Kategori',
                style: TextStyle(
                  color: primary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              Align(
                alignment: Alignment.centerLeft,
                child: Text('Nama Kategori',
                    style: TextStyle(color: primary)),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _namaController,
                decoration: fieldStyle('Masukkan Nama Kategori'),
                validator: (v) =>
                    v!.trim().isEmpty ? 'Wajib diisi' : null,
              ),

              const SizedBox(height: 16),

              Align(
                alignment: Alignment.centerLeft,
                child: Text('Deskripsi Alat',
                    style: TextStyle(color: primary)),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _deskripsiController,
                decoration: fieldStyle('Masukkan Deskripsi Alat'),
                validator: (v) =>
                    v!.trim().isEmpty ? 'Wajib diisi' : null,
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        side: BorderSide(color: primary, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text('Batal',
                          style: TextStyle(color: primary)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Simpan',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
