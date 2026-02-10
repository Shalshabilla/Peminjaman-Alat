// lib/screens/peminjam/profil_peminjam_screen.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/peminjam_bottom_navbar.dart';

class ProfilPeminjamScreen extends StatefulWidget {
  const ProfilPeminjamScreen({super.key});

  @override
  State<ProfilPeminjamScreen> createState() => _ProfilPeminjamScreenState();
}

class _ProfilPeminjamScreenState extends State<ProfilPeminjamScreen> {
  Map<String, dynamic>? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final res = await Supabase.instance.client
          .from('users')
          .select()
          .eq('id', currentUser.id)
          .single();

      setState(() {
        _user = res;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat profil: $e')),
      );
    }
  }

  Future<void> _showLogoutDialog() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 12),
              Text("Keluar",
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text("Anda yakin ingin keluar dari akun?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Keluar",
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await Supabase.instance.client.auth.signOut();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF0D47A1);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        toolbarHeight: 76,
        automaticallyImplyLeading: false, // ❗ penting biar ga bentrok navbar
        title: const Text(
          'Profil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: navy,
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? const Center(child: Text('Gagal memuat data profil'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
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
                        child: Column(
                          children: [
                            const Icon(Icons.person, size: 80, color: navy),
                            const SizedBox(height: 24),
                            _buildProfileField('Nama', _user!['nama'] ?? '-', navy),
                            const SizedBox(height: 16),
                            _buildProfileField('Email', _user!['email'] ?? '-', navy),
                            const SizedBox(height: 16),
                            _buildProfileField('Kata Sandi', '********', navy),
                            const SizedBox(height: 16),
                            _buildProfileField('Role', _user!['role'] ?? '-', navy),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _showLogoutDialog,
                          icon: const Icon(Icons.logout),
                          label: const Text('Keluar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: navy,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

      bottomNavigationBar: PeminjamBottomNavbar(
        currentIndex: 3,
        onTap: (index) => _handlePeminjamNav(context, index),
      ),
    );
  }

  Widget _buildProfileField(String label, String value, Color navy) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 14, color: navy, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(value, style: const TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  void _handlePeminjamNav(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/peminjam/dashboard');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/peminjam/alat');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/peminjam/peminjaman');
        break;
      case 3:
        break; // sudah di profil
    }
  }
}
