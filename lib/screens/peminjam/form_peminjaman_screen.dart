import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import '../../widgets/peminjam_bottom_navbar.dart'; // Pastikan path ini benar

class FormPeminjamanPage extends StatefulWidget {
  final String namaAlat; 
  final String gambarAlat; 

  const FormPeminjamanPage({
    Key? key,
    required this.namaAlat,
    required this.gambarAlat,
  }) : super(key: key);

  @override
  _FormPeminjamanPageState createState() => _FormPeminjamanPageState();
}

class _FormPeminjamanPageState extends State<FormPeminjamanPage> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _jumlahController = TextEditingController();
  DateTime? _tanggalPinjam;
  DateTime? _tanggalKembali;

  // Index untuk bottom navbar (Pengajuan = 1)
  int _currentIndex = 1;

  Future<void> _selectDate(BuildContext context, bool isPinjam) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0D47A1),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
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

  @override
  void initState() {
    super.initState();
    _namaController.text = 'Masukkan Nama'; 
    _jumlahController.text = '1';
    _tanggalPinjam = DateTime.now().add(const Duration(days: 1));
    _tanggalKembali = DateTime.now().add(const Duration(days: 2));
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    // Navigasi sesuai index (sesuaikan dengan route aplikasi kamu)
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/beranda');
        break;
      case 1:
        // Sudah di halaman pengajuan, tidak perlu navigasi
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/riwayat');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profil');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Form Peminjaman'),
        centerTitle: true,
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(  // Ditambahkan agar bisa scroll jika konten panjang
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nama Peminjam'),
              TextField(
                controller: _namaController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                ),
              ),
              const SizedBox(height: 16.0),
              const Text('Alat'),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        widget.gambarAlat,
                        width: 50,
                        height: 50,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.image),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        widget.namaAlat,
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              const Text('Jumlah'),
              TextField(
                controller: _jumlahController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tanggal Pinjam'),
                        GestureDetector(
                          onTap: () => _selectDate(context, true),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                            child: Text(
                              _tanggalPinjam != null
                                  ? DateFormat('dd/MM/yyyy').format(_tanggalPinjam!)
                                  : 'Pilih Tanggal',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tanggal Kembali'),
                        GestureDetector(
                          onTap: () => _selectDate(context, false),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                            child: Text(
                              _tanggalKembali != null
                                  ? DateFormat('dd/MM/yyyy').format(_tanggalKembali!)
                                  : 'Pilih Tanggal',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Logika pengajuan (bisa tambah validasi di sini nanti)
                    Navigator.pushReplacementNamed(context, '/peminjaman_pengembalian');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: const Text(
                    'Ajukan',
                    style: TextStyle(color: Colors.white, fontSize: 18.0),
                  ),
                ),
              ),
              const SizedBox(height: 80.0), // Ruang agar tidak tertutup navbar
            ],
          ),
        ),
      ),
      bottomNavigationBar: PeminjamBottomNavbar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }
}