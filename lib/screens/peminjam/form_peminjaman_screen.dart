import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/alat_model.dart';
import '../../widgets/peminjam_bottom_navbar.dart';
import '../../utils/colors.dart';

class FormPeminjamanScreen extends StatefulWidget {
  final Alat? alat;

  const FormPeminjamanScreen({super.key, this.alat});

  @override
  State<FormPeminjamanScreen> createState() => _FormPeminjamanScreenState();
}

class _FormPeminjamanScreenState extends State<FormPeminjamanScreen> {
  Alat? _alat;

  final TextEditingController _jumlahController = TextEditingController();

  DateTime? _tanggalPinjam;
  DateTime? _tanggalKembali;

  String? _namaPeminjam;
  bool _isLoadingProfile = true;
  bool _isSubmitting = false;

  int _currentIndex = 1; // Karena form biasanya dibuka dari tab Alat (index 1)

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;
    _alat = widget.alat ?? (args is Alat ? args : null);

    if (_alat == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data alat tidak ditemukan')),
          );
          Navigator.pop(context);
        }
      });
      return;
    }

    if (_namaPeminjam == null) {
      _fetchUserName();
    }
  }

  Future<void> _fetchUserName() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() {
        _namaPeminjam = "User tidak terdeteksi";
        _isLoadingProfile = false;
      });
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('users')
          .select('nama')
          .eq('id', user.id)
          .maybeSingle();

      setState(() {
        _namaPeminjam = response != null && response['nama'] != null
            ? response['nama'] as String
            : "Nama tidak ditemukan";
        _isLoadingProfile = false;
      });
    } catch (e) {
      setState(() {
        _namaPeminjam = "Gagal memuat nama";
        _isLoadingProfile = false;
      });
    }
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

    if (picked != null && mounted) {
      setState(() {
        if (isPinjam) _tanggalPinjam = picked;
        else _tanggalKembali = picked;
      });
    }
  }

  void _onBottomNavTap(int index) {
    final routes = [
      '/peminjam/dashboard',
      '/peminjam/alat',
      '/peminjam/peminjaman',
      '/peminjam/profil',
    ];

    if (ModalRoute.of(context)?.settings.name != routes[index]) {
      Navigator.pushReplacementNamed(context, routes[index]);
    }
  }

  Future<void> _submitPeminjaman() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || _alat == null) return;

    final jumlahStr = _jumlahController.text.trim();
    final jumlah = int.tryParse(jumlahStr);

    if (jumlah == null || jumlah <= 0) {
      _showError('Masukkan jumlah yang valid');
      return;
    }

    if (_tanggalPinjam == null || _tanggalKembali == null) {
      _showError('Pilih tanggal pinjam dan kembali');
      return;
    }

    if (_tanggalKembali!.isBefore(_tanggalPinjam!)) {
      _showError('Tanggal kembali tidak boleh sebelum tanggal pinjam');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final peminjamanRes = await Supabase.instance.client
          .from('peminjaman')
          .insert({
            'id_user': user.id,
            'tgl_pinjam': _tanggalPinjam!.toUtc().toIso8601String(),
            'tgl_kembali_rencana': _tanggalKembali!.toUtc().toIso8601String(),
            'status': 'menunggu',
          })
          .select('id_peminjaman')
          .single();

      final idPeminjaman = peminjamanRes['id_peminjaman'] as int;

      await Supabase.instance.client.from('detail_peminjaman').insert({
        'id_peminjaman': idPeminjaman,
        'id_alat': _alat!.idAlat,
        'jumlah': jumlah,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Peminjaman berhasil diajukan'),
          backgroundColor: Colors.green,
        ),
      );

      // Kembali ke tab Peminjaman setelah submit
      Navigator.pushReplacementNamed(context, '/peminjam/peminjaman');
    } catch (e) {
      _showError('Gagal mengajukan peminjaman: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_alat == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nama Peminjam', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary, width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade50,
                ),
                child: _isLoadingProfile
                    ? const SizedBox(height: 20, child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)))
                    : Text(_namaPeminjam ?? 'Memuat nama...', style: const TextStyle(fontSize: 16)),
              ),

              const SizedBox(height: 24),

              const Text('Alat yang Dipinjam', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    if (_alat!.gambar != null && _alat!.gambar!.isNotEmpty)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                        child: Image.network(
                          _alat!.gambar!,
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 80),
                        ),
                      )
                    else
                      Container(
                        height: 140,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _alat!.namaAlat,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text('Jumlah', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 8),
              TextField(
                controller: _jumlahController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Masukkan jumlah unit',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(child: _buildDateField('Tanggal Pinjam', _tanggalPinjam, () => _selectDate(context, true))),
                  const SizedBox(width: 16),
                  Expanded(child: _buildDateField('Tanggal Kembali', _tanggalKembali, () => _selectDate(context, false))),
                ],
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSubmitting || _isLoadingProfile || _namaPeminjam == null ? null : _submitPeminjaman,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                      : const Text('Ajukan Peminjaman', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: PeminjamBottomNavbar(
        currentIndex: 1, // Form dibuka dari tab Alat
        onTap: _onBottomNavTap,
      ),
    );
  }

  Widget _buildDateField(String label, DateTime? date, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 12),
                Text(
                  date != null ? DateFormat('dd MMM yyyy').format(date) : 'Pilih tanggal',
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }


  @override
  void dispose() {
    _jumlahController.dispose();
    super.dispose();
  }
}