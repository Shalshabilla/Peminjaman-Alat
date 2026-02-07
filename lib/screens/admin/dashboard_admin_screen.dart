import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class DashboardAdminScreen extends StatefulWidget {
  const DashboardAdminScreen({super.key});

  @override
  State<DashboardAdminScreen> createState() => _DashboardAdminPageState();
}

class _DashboardAdminPageState extends State<DashboardAdminScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// 🔵 APP BAR
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.white),
        title: const Text(
          'Selamat Datang, Admin!',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.notifications_none, color: Colors.white),
          ),
        ],
      ),

      /// 🟢 BODY
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🧩 DASHBOARD CARD
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _dashboardCard(
                  icon: Icons.person,
                  title: 'Total User',
                  value: '120',
                ),
                _dashboardCard(
                  icon: Icons.work,
                  title: 'Total Alat',
                  value: '87',
                ),
                _dashboardCard(
                  icon: Icons.assignment,
                  title: 'Peminjaman Aktif',
                  value: '45',
                ),
                _dashboardCard(
                  icon: Icons.assignment_turned_in,
                  title: 'Dikembalikan\nHari Ini',
                  value: '6',
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// 📝 JUDUL LOG
            const Text(
              'Log Aktivitas Terbaru',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),

            /// 📦 BOX LOG
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  )
                ],
              ),
              child: Column(
                children: [
                  _logItem(
                    text: 'Shalshabilla mengajukan peminjaman',
                    time: '2 menit lalu',
                  ),
                  _logItem(
                    text: 'Petugas menyetujui peminjaman',
                    time: '15 menit lalu',
                  ),
                  _logItem(
                    text: 'Kania mengajukan peminjaman',
                    time: '20 menit lalu',
                  ),
                  _logItem(
                    text: 'Petugas menolak peminjaman',
                    time: '20 menit lalu',
                  ),
                  _logItem(
                    text: 'Icel mengembalikan barang',
                    time: '20 menit lalu',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      /// 🔻 BOTTOM NAVBAR
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => setState(() => currentIndex = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.primary,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.layers),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '',
          ),
        ],
      ),
    );
  }

  /// 🔷 DASHBOARD CARD
  Widget _dashboardCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 LOG ITEM
  Widget _logItem({required String text, required String time}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.history, size: 18, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
