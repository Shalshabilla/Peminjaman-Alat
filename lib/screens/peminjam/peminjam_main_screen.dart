import 'package:flutter/material.dart';
import 'dashboard_peminjam_screen.dart';
import 'daftar_alat_peminjam_screen.dart';
import 'peminjaman_pengembalian_screen.dart';
import 'profil_peminjam_screen.dart';
import '../../widgets/peminjam_bottom_navbar.dart';

class PeminjamMainScreen extends StatefulWidget {
  final int initialIndex;

  const PeminjamMainScreen({super.key, this.initialIndex = 0});

  @override
  State<PeminjamMainScreen> createState() => _PeminjamMainScreenState();
}

class _PeminjamMainScreenState extends State<PeminjamMainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _screens = [
    const DashboardPeminjamScreen(),       // 0 - Beranda
    const DaftarAlatPeminjamScreen(),      // 1 - Alat
    const PeminjamanPeminjamScreen(),      // 2 - Peminjaman
    const ProfilPeminjamScreen(),          // 3 - Profil
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
      bottomNavigationBar: PeminjamBottomNavbar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}