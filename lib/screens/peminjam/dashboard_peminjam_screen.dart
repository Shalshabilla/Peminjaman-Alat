import 'package:flutter/material.dart';
import '../../services/peminjam_dashboard_services.dart';
import '../../widgets/peminjam_bottom_navbar.dart';

class DashboardPeminjamScreen extends StatefulWidget {
  const DashboardPeminjamScreen({super.key});

  @override
  State<DashboardPeminjamScreen> createState() => _DashboardPeminjamScreenState();
}

class _DashboardPeminjamScreenState extends State<DashboardPeminjamScreen> {
  final PeminjamDashboardService _service = PeminjamDashboardService();

  int menungguPersetujuan = 0;
  int peminjamanAktif = 0;
  int terlambat = 0;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = await _service.getStatusCounts();
    if (!mounted) return;
    setState(() {
      menungguPersetujuan = data['menungguPersetujuan'] ?? 0;
      peminjamanAktif = data['peminjamanAktif'] ?? 0;
      terlambat = data['terlambat'] ?? 0;
      _isLoading = false;
    });
  }

  void _onNavTap(int index) {
    final routes = [
      '/peminjam/dashboard',
      '/peminjam/alat',
      '/peminjam/peminjaman',
      '/peminjam/profil',
    ];

    if (ModalRoute.of(context)?.settings.name != routes[index]) {
      Navigator.pushReplacementNamed(context, routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF0D47A1);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        toolbarHeight: 76,
        title: const Text('Selamat Datang, Peminjam!', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
        backgroundColor: navy,
        elevation: 0,
        actions: const [Padding(padding: EdgeInsets.only(right: 16), child: Icon(Icons.notifications, color: Colors.white, size: 28))],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Status Peminjaman', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: navy)),
                      const SizedBox(height: 20),

                      _buildStatusCard(Icons.hourglass_empty, 'Menunggu Persetujuan', menungguPersetujuan, Colors.amber),
                      const SizedBox(height: 12),
                      _buildStatusCard(Icons.inventory_2, 'Peminjaman Aktif', peminjamanAktif, Colors.green),
                      const SizedBox(height: 12),
                      _buildStatusCard(Icons.warning_amber_rounded, 'Terlambat', terlambat, Colors.red),

                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/peminjam/alat');
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: navy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          child: const Text('Ajukan Peminjaman', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: PeminjamBottomNavbar(
        currentIndex: 0,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildStatusCard(IconData icon, String title, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(30)),
            child: Text(count.toString(), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}