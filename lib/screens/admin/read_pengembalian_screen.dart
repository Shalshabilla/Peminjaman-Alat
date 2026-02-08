// lib/screens/admin/read_pengembalian_screen.dart

import 'package:flutter/material.dart';
import '../../widgets/admin_bottom_navbar.dart';

class PengembalianListScreen extends StatelessWidget {
  const PengembalianListScreen({super.key});

  // Data dummy sementara (nanti ganti dengan query Supabase)
  final List<Map<String, dynamic>> dummyPengembalian = const [
    {
      'id': 'PG001',
      'peminjam': 'Shalshabilla',
      'alat': 'Laptop Asus',
      'tanggal_kembali': '2025-02-08',
      'kondisi': 'Baik',
      'denda': 0,
    },
    {
      'id': 'PG002',
      'peminjam': 'User C',
      'alat': 'Kabel LAN 10m',
      'tanggal_kembali': '2025-02-07',
      'kondisi': 'Rusak Ringan',
      'denda': 15000,
    },
    {
      'id': 'PG003',
      'peminjam': 'Petugas B',
      'alat': 'Proyektor',
      'tanggal_kembali': '2025-02-06',
      'kondisi': 'Baik',
      'denda': 0,
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
          'Data Pengembalian',
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
          itemCount: dummyPengembalian.length,
          itemBuilder: (context, index) {
            final item = dummyPengembalian[index];
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
                      _buildDendaChip(item['denda'], navy),
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
                    'Tanggal Kembali: ${item['tanggal_kembali']}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kondisi: ${item['kondisi']}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: AdminBottomNavbar(
        currentIndex: 2, // Transaksi
        onTap: (index) {
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

  Widget _buildDendaChip(int denda, Color navy) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: denda > 0 ? Colors.red : Colors.green,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        denda > 0 ? 'Denda: Rp $denda' : 'Tidak Ada Denda',
        style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }
}