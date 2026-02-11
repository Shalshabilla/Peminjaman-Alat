import 'package:flutter/material.dart';
import '../../widgets/petugas_bottom_navbar.dart';
import 'dashboard_petugas_screen.dart';
import 'peminjaman_petugas_screen.dart';       
import 'pengembalian_petugas_screen.dart';
import 'laporan_petugas_screen.dart';
import 'profil_petugas_screen.dart';

class PetugasMainScreen extends StatefulWidget {
  final int initialIndex;

  const PetugasMainScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<PetugasMainScreen> createState() => _PetugasMainScreenState();
}

class _PetugasMainScreenState extends State<PetugasMainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  // Daftar halaman sesuai urutan di bottom navbar
  final List<Widget> _screens = [
    const DashboardPetugasScreen(),       // 0 - Beranda
    const PeminjamanPetugasScreen(),       // 1 -   Peminjaman
    //const PengembalianPetugasScreen(),    // 2 - Pengembalian
    //const LaporanPetugasScreen(),         // 3 - Laporan
    const ProfilPetugasScreen(),          // 4 - Profil
  ];

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: PetugasBottomNavbar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}