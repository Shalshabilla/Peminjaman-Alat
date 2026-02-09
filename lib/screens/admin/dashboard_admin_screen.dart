import 'package:flutter/material.dart';
import '../../services/dashboard_services.dart';
import '../../widgets/admin_bottom_navbar.dart';

class DashboardAdminScreen extends StatefulWidget {
  const DashboardAdminScreen({super.key});

  @override
  State<DashboardAdminScreen> createState() => _DashboardAdminScreenState();
}

class _DashboardAdminScreenState extends State<DashboardAdminScreen> {
  final DashboardService _service = DashboardService();

  int totalUser = 0;
  int totalAlat = 0;
  int peminjamanAktif = 0;
  int dikembalikanHariIni = 0;

  List<Map<String, dynamic>> recentActivities = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final dashboardData = await _service.getDashboardData();
      final activities = await _service.getRecentActivities(limit: 6);

      if (!mounted) return;

      setState(() {
        totalUser = dashboardData['totalUser'] ?? 0;
        totalAlat = dashboardData['totalAlat'] ?? 0;
        peminjamanAktif = dashboardData['peminjamanAktif'] ?? 0;
        dikembalikanHariIni = dashboardData['dikembalikanHariIni'] ?? 0;
        recentActivities = activities;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat data: $e';
      });
    }
  }

  void _handleNavigation(int index) {
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
  }

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF0D47A1);
    const navyShadow = Color(0xFF0D47A1);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        toolbarHeight: 76,
        title: const Text(
          'Selamat Datang, Admin!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: navy,
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.notifications, color: Colors.white, size: 28),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 60, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_errorMessage!, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: navy,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  color: navy,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Statistik Cards
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 1.65, 
                            children: [
                              _buildStatCard(Icons.person, 'Total User', '$totalUser', navy),
                              _buildStatCard(Icons.work, 'Total Alat', '$totalAlat', navy),
                              _buildStatCard(Icons.swap_horiz, 'Peminjaman Aktif', '$peminjamanAktif', navy),
                              _buildStatCard(
                                Icons.assignment_turned_in,
                                'Dikembalikan\nHari Ini',
                                '$dikembalikanHariIni',
                                navy,
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Judul Log
                          Text(
                            'Log Aktifitas Terbaru',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: navy,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Card Log Aktifitas
                          Container(
                            constraints: BoxConstraints(
                              minHeight: 100,
                            ),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: navy, width: 1.4),
                              boxShadow: [
                                BoxShadow(
                                  color: navyShadow.withOpacity(0.28),
                                  blurRadius: 16,
                                  spreadRadius: 3,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: recentActivities.isEmpty
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(vertical: 32),
                                      child: Text(
                                        'Belum ada aktivitas terbaru',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  )
                                : Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: recentActivities.map((log) {
                                      final timeAgo = _getTimeAgo(log['created_at']);
                                      final nama = log['nama_user'] ?? 'Pengguna Tidak Diketahui';
                                      final aktifitas = log['aktifitas'] ?? 'Aktivitas tidak diketahui';

                                      return Column(
                                        children: [
                                          _buildLogItem('$nama $aktifitas', timeAgo, navy),
                                          const Divider(height: 24, thickness: 0.8),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                          ),

                          const SizedBox(height: 120), 
                        ],
                      ),
                    ),
                  ),
                ),

      bottomNavigationBar: AdminBottomNavbar(
        currentIndex: 0,
        onTap: _handleNavigation,
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String title, String value, Color navy) {
    return Container(
      clipBehavior: Clip.hardEdge, 
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: navy),
          const SizedBox(height: 8),

          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: navy,
                    height: 1.15,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: Color(0xFF424242),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogItem(String title, String time, Color navy) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.history, size: 22, color: navy),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: navy,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            time,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
        ],
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
}