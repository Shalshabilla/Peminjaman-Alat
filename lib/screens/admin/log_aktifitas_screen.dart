// lib/screens/admin/log_aktifitas_screen.dart

import 'package:flutter/material.dart';
import '../../services/dashboard_services.dart';
import '../../widgets/admin_bottom_navbar.dart';

class LogAktifitasScreen extends StatefulWidget {
  const LogAktifitasScreen({super.key});

  @override
  State<LogAktifitasScreen> createState() => _LogAktifitasScreenState();
}

class _LogAktifitasScreenState extends State<LogAktifitasScreen> {
  final DashboardService _service = DashboardService();
  List<Map<String, dynamic>> logs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllLogs();
  }

  Future<void> _loadAllLogs() async {
    try {
      // Ambil semua log, tanpa limit
      final allLogs = await _service.getRecentActivities(limit: 100); // atau buat method baru tanpa limit
      setState(() {
        logs = allLogs;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat log: $e')),
      );
    }
  }

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
          'Log Aktifitas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: navy,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : logs.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada aktivitas',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    final timeAgo = _getTimeAgo(log['created_at']);
                    final nama = log['nama_user'] ?? 'Pengguna Tidak Diketahui';
                    final aktifitas = log['aktifitas'] ?? 'Aktivitas tidak diketahui';

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
                      child: Row(
                        children: [
                          Icon(Icons.history, size: 22, color: navy),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$nama $aktifitas',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: navy,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  timeAgo,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      bottomNavigationBar: AdminBottomNavbar(
        currentIndex: 3, // Log
        onTap: (index) => _handleAdminNav(context, index),
      ),
    );
  }

  String _getTimeAgo(String? timestamp) {
    if (timestamp == null) return 'baru saja';
    try {
      final date = DateTime.parse(timestamp).toLocal();
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 1) return 'baru saja';
      if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
      if (diff.inHours < 24) return '${diff.inHours} jam lalu';
      return '${diff.inDays} hari lalu';
    } catch (e) {
      return 'waktu tidak diketahui';
    }
  }

  void _handleAdminNav(BuildContext context, int index) {
    switch (index) {
      case 0: Navigator.pushReplacementNamed(context, '/admin/dashboard'); break;
      case 1: Navigator.pushReplacementNamed(context, '/admin/data-master'); break;
      case 2: Navigator.pushReplacementNamed(context, '/admin/transaksi'); break;
      case 3: /* sudah di sini */ break;
      case 4: Navigator.pushReplacementNamed(context, '/admin/profil'); break;
    }
  }
}