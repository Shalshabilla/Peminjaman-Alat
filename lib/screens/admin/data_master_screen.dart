import 'package:flutter/material.dart';
import 'read_user_screen.dart';
import 'read_alat_screen.dart';
import 'read_kategori_screen.dart';
import '../../widgets/admin_bottom_navbar.dart';

class DataMasterScreen extends StatelessWidget {
  const DataMasterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF0D47A1);
    const navyShadow = Color(0xFF0D47A1);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        toolbarHeight: 76,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Data Master',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: navy,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildMasterCard(
              icon: Icons.person,
              title: 'Data User',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserListScreen()),
              ),
              navy: navy,
            ),
            const SizedBox(height: 16),
            _buildMasterCard(
              icon: Icons.work,
              title: 'Data Alat',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReadAlatScreen()),
              ),
              navy: navy,
            ),
            const SizedBox(height: 16),
            _buildMasterCard(
              icon: Icons.category,
              title: 'Data Kategori',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DaftarKategoriPage()),
              ),
              navy: navy,
            ),
          ],
        ),
      ),
      bottomNavigationBar: AdminBottomNavbar(
        currentIndex: 1, // Data Master
        onTap: (index) => _handleAdminNav(context, index),
      ),
    );
  }

  Widget _buildMasterCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color navy,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: navy, width: 1.4),
          boxShadow: [
            BoxShadow(
              color: navy.withOpacity(0.28),
              blurRadius: 16,
              spreadRadius: 3,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: navy),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: navy,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: navy, size: 28),
          ],
        ),
      ),
    );
  }

  void _handleAdminNav(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/admin/dashboard');
        break;
      case 1:
        // Sudah di sini
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/admin/transaksi');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/admin/log-aktifitas');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/admin/profil');
        break;
    }
  }
}