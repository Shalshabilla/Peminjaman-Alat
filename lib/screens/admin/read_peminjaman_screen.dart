// lib/screens/admin/read_peminjaman_screen.dart

import 'package:flutter/material.dart';
import '../../widgets/admin_bottom_navbar.dart'; // sesuaikan path

class PeminjamanListScreen extends StatelessWidget {
  const PeminjamanListScreen({super.key});

  // Data dummy sementara (nanti ganti dengan query Supabase)
  final List<Map<String, dynamic>> dummyPeminjaman = const [
    {
      'id': 'PJ001',
      'peminjam': 'Shalshabilla',
      'alat': 'Laptop Asus',
      'tanggal_pinjam': '2025-02-05',
      'status': 'Dipinjam',
    },
    {
      'id': 'PJ002',
      'peminjam': 'User C',
      'alat': 'Kabel LAN 10m',
      'tanggal_pinjam': '2025-02-06',
      'status': 'Disetujui',
    },
    {
      'id': 'PJ003',
      'peminjam': 'Petugas B',
      'alat': 'Proyektor',
      'tanggal_pinjam': '2025-02-07',
      'status': 'Menunggu Persetujuan',
    },
  ];

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
          'Data Peminjaman',
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
        child: ListView.builder(
          itemCount: dummyPeminjaman.length,
          itemBuilder: (context, index) {
            final item = dummyPeminjaman[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['id'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: navy,
                        ),
                      ),
                      _buildStatusChip(item['status'], navy),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Peminjam: ${item['peminjam']}',
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Alat: ${item['alat']}',
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tanggal Pinjam: ${item['tanggal_pinjam']}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: AdminBottomNavbar(
        currentIndex: 2, // Transaksi (karena masuk dari menu transaksi)
        onTap: (index) {
          // Gunakan navigasi yang sama seperti di halaman lain
          final currentRoute = ModalRoute.of(context)?.settings.name;
          String? targetRoute;
          switch (index) {
            case 0:
              targetRoute = '/admin/dashboard';
              break;
            case 1:
              targetRoute = '/admin/data-master';
              break;
            case 2:
              targetRoute = '/admin/transaksi';
              break;
            case 3:
              targetRoute = '/admin/log-aktifitas';
              break;
            case 4:
              targetRoute = '/admin/profil';
              break;
          }
          if (targetRoute != null && currentRoute != targetRoute) {
            Navigator.pushReplacementNamed(context, targetRoute);
          }
        },
      ),
    );
  }

  Widget _buildStatusChip(String status, Color navy) {
    Color bgColor;
    Color textColor = Colors.white;

    switch (status.toLowerCase()) {
      case 'dipinjam':
        bgColor = Colors.orange;
        break;
      case 'disetujui':
        bgColor = Colors.green;
        break;
      case 'menunggu persetujuan':
        bgColor = Colors.blue;
        break;
      default:
        bgColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.w600),
      ),
    );
  }
}