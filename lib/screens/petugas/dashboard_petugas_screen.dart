import 'package:flutter/material.dart';
import '../../services/petugas_dashboard_services.dart';
import '../../widgets/petugas_bottom_navbar.dart';

class DashboardPetugasScreen extends StatefulWidget {
  const DashboardPetugasScreen({super.key});

  @override
  State<DashboardPetugasScreen> createState() => _DashboardPetugasScreenState();
}

class _DashboardPetugasScreenState extends State<DashboardPetugasScreen> {
  final PetugasDashboardService _service = PetugasDashboardService();

  int pengajuanBaru = 0;
  int peminjamanAktif = 0;
  int pengembalianHariIni = 0;
  int terlambat = 0;

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
      final data = await _service.getStatusCounts();
      if (mounted) {
        setState(() {
          pengajuanBaru = data['pengajuanBaru'] ?? 0;
          peminjamanAktif = data['peminjamanAktif'] ?? 0;
          pengembalianHariIni = data['pengembalianHariIni'] ?? 0;
          terlambat = data['terlambat'] ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Gagal memuat data: $e';
        });
      }
    }
  }

  void _onNavTap(int index) {
    final routes = [
      '/petugas/dashboard',      // 0
      '/petugas/peminjaman',      // 1
      '/petugas/pengembalian',   // 2
      '/petugas/laporan',        // 3
      '/petugas/profil',         // 4
    ];

    if (index != 0) {  // hindari reload halaman yang sama
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
        title: const Text(
          'Selamat Datang, Petugas!',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
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
              ? Center(child: Text(_errorMessage!))
              : RefreshIndicator(
                  onRefresh: _loadData,
                  color: navy,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Status Peminjaman',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: navy),
                          ),
                          const SizedBox(height: 20),
                          _buildStatusCard(Icons.assignment, 'Pengajuan peminjaman baru', pengajuanBaru, Colors.amber),
                          const SizedBox(height: 12),
                          _buildStatusCard(Icons.inventory_2, 'Peminjaman Aktif', peminjamanAktif, Colors.green),
                          const SizedBox(height: 12),
                          _buildStatusCard(Icons.assignment_return, 'Pengembalian hari ini', pengembalianHariIni, Colors.blue),
                          const SizedBox(height: 12),
                          _buildStatusCard(Icons.warning_amber_rounded, 'Terlambat', terlambat, Colors.red),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () {}, // arahkan ke laporan jika perlu
                              style: ElevatedButton.styleFrom(
                                backgroundColor: navy,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Cetak Laporan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
      bottomNavigationBar: PetugasBottomNavbar(
        currentIndex: 0,  // Dashboard = index 0
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildStatusCard(IconData icon, String title, int count, Color color) {
    // kode card tetap sama seperti sebelumnya...
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(30)),
            child: Text(
              count.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}