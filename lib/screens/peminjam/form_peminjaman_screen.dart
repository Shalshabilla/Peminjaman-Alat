import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/alat_model.dart';
import '../../widgets/peminjam_bottom_navbar.dart';
import '../../utils/colors.dart';

class FormPeminjamanScreen extends StatefulWidget {
  final Alat? alat;

  const FormPeminjamanScreen({Key? key, this.alat}) : super(key: key);

  @override
  State<FormPeminjamanScreen> createState() => _FormPeminjamanPageState();
}

class _FormPeminjamanPageState extends State<FormPeminjamanScreen> {
  late Alat alat;

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _jumlahController = TextEditingController();

  DateTime? _tanggalPinjam;
  DateTime? _tanggalKembali;

  int _currentIndex = 1;
  bool _isSubmitting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Ambil alat dari constructor ATAU route arguments
    alat = widget.alat ??
        (ModalRoute.of(context)!.settings.arguments as Alat);
  }

  Future<void> _selectDate(BuildContext context, bool isPinjam) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        if (isPinjam) {
          _tanggalPinjam = picked;
        } else {
          _tanggalKembali = picked;
        }
      });
    }
  }

  void _onBottomNavTap(int index) {
    setState(() => _currentIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/peminjam/dashboard');
        break;
      case 1:
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/peminjam/peminjaman');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/peminjam/profil');
        break;
    }
  }

  Future<void> _submitPeminjaman() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final jumlah = int.tryParse(_jumlahController.text);

    if (jumlah == null ||
        jumlah <= 0 ||
        _tanggalPinjam == null ||
        _tanggalKembali == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data belum lengkap')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final peminjaman = await Supabase.instance.client
          .from('peminjaman')
          .insert({
            'id_user': user.id,
            'tgl_pinjam': _tanggalPinjam!.toIso8601String(),
            'tgl_kembali_rencana': _tanggalKembali!.toIso8601String(),
            'status': 'menunggu',
          })
          .select()
          .single();

      await Supabase.instance.client.from('detail_peminjaman').insert({
        'id_peminjaman': peminjaman['id_peminjaman'],
        'id_alat': alat.idAlat,
        'jumlah': jumlah,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Peminjaman berhasil diajukan'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacementNamed(context, '/peminjam/peminjaman');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengajukan peminjaman: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Form Peminjaman'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Nama Peminjam',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _namaController,
              decoration: InputDecoration(
                hintText: 'Masukkan Nama',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Text('Alat',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  alat.gambar != null
                      ? Image.network(
                          alat.gambar!,
                          height: 120,
                          fit: BoxFit.contain,
                        )
                      : Container(
                          height: 120,
                          alignment: Alignment.center,
                          child: Icon(Icons.image,
                              size: 60, color: AppColors.primary),
                        ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      alat.namaAlat,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Text('Jumlah',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _jumlahController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Masukkan Jumlah',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    'Tanggal Pinjam',
                    _tanggalPinjam,
                    () => _selectDate(context, true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDateField(
                    'Tanggal Kembali',
                    _tanggalKembali,
                    () => _selectDate(context, false),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitPeminjaman,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Ajukan Peminjaman',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
              ),
            ),
          ]),
        ),
      ),
      bottomNavigationBar: PeminjamBottomNavbar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }

  Widget _buildDateField(
      String label, DateTime? date, VoidCallback onTap) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, size: 18),
              const SizedBox(width: 8),
              Text(
                date != null
                    ? DateFormat('dd/MM/yyyy').format(date)
                    : 'Pilih Tanggal',
              ),
            ],
          ),
        ),
      ),
    ]);
  }
}
