import 'package:flutter/material.dart';
import 'package:pinjam_alat_lab/widgets/admin_bottom_navbar.dart';
import 'dashboard_admin_screen.dart';
import 'data_master_screen.dart';
import 'transaksi_screen.dart';
import 'log_aktifitas_screen.dart';
import 'profil_admin_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardAdminScreen(),
    const DataMasterScreen(),
    const TransaksiAdminScreen(),     // pastikan nama class ini sesuai
    const LogAktifitasScreen(),
    const ProfilAdminScreen(),
  ];

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: AdminBottomNavbar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }
}