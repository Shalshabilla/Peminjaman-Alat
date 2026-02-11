import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/pengembalian_model.dart'; 
import '../../services/pengembalian_services.dart';
import '../../widgets/admin_bottom_navbar.dart';

class PengembalianListScreen extends StatefulWidget {
  const PengembalianListScreen({super.key});

  @override
  State<PengembalianListScreen> createState() => _PengembalianListScreenState();
}

class _PengembalianListScreenState extends State<PengembalianListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatus = 'Semua';

  List<Pengembalian> _allPengembalian = [];

  final List<String> _statuses = [
    'Semua',
    'Dikembalikan',
    'Terlambat',
  ];

  final Color primary = const Color(0xFF0D47A1);

  @override
  void initState() {
    super.initState();
    _loadPengembalian();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPengembalian() async {
  try {
    final service = PengembalianService();
    final data = await service.getAllPengembalian();

    if (!mounted) return;

    setState(() {
      _allPengembalian = data;
    });
  } catch (e) {
    debugPrint('Error loading pengembalian: $e');

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal memuat data: $e')),
    );
  }
}

  List<Pengembalian> get _filtered {
    return _allPengembalian.where((p) {
      final matchSearch =
          (p.namaPeminjam?.toLowerCase().contains(_searchQuery) ?? false) ||
          p.detail.any((d) => d.namaAlat.toLowerCase().contains(_searchQuery));

      final matchStatus = _selectedStatus == 'Semua' ||
          p.status.toLowerCase() == _selectedStatus.toLowerCase();

      return matchSearch && matchStatus;
    }).toList();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'dikembalikan':
        return Colors.green;
      case 'terlambat':
        return Colors.redAccent;
      default:
        return primary;
    }
  }

  Widget _buildCard(Pengembalian p) {
    final alatNama = p.detail.map((e) => e.namaAlat).join(', ');
    final jumlahTotal = p.detail.fold<int>(0, (sum, e) => sum + e.jumlah);

    final tglKembaliFormatted = DateFormat('dd MMM yyyy').format(p.tglKembali);

    return GestureDetector(
      onTap: () {
        debugPrint('Tapped pengembalian: ${p.idPengembalian}');
        // Tambahkan navigasi ke detail jika sudah ada screen-nya
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primary.withOpacity(0.4), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: primary.withOpacity(0.18),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Status chip di kanan atas
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: _statusColor(p.status).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  p.status,
                  style: TextStyle(
                    color: _statusColor(p.status),
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.namaPeminjam ?? 'Peminjam tidak diketahui',
                  style: TextStyle(
                    fontSize: 17.5,
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    const Icon(Icons.build, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        alatNama.isEmpty ? '-' : alatNama,
                        style: const TextStyle(fontSize: 14.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                Row(
                  children: [
                    const Icon(Icons.inventory_2, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'Jumlah: $jumlahTotal',
                      style: const TextStyle(fontSize: 14.5),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    const Icon(Icons.date_range, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'Tanggal Kembali: $tglKembaliFormatted',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Denda
                Row(
                  children: [
                    const Icon(Icons.money_off, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      p.denda > 0
                          ? 'Denda: Rp ${NumberFormat('#,###').format(p.denda)}'
                          : 'Tidak Ada Denda',
                      style: TextStyle(
                        fontSize: 14,
                        color: p.denda > 0 ? Colors.red : Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            Positioned(
              bottom: 4,
              right: 4,
              child: Icon(
                Icons.chevron_right,
                size: 32,
                color: primary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
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
        backgroundColor: primary,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),

          // Search bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: primary, width: 2),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                icon: Icon(Icons.search, color: primary),
                hintText: 'Cari peminjam / alat...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: primary.withOpacity(0.6)),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Filter status chips
          SizedBox(
            height: 44,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemCount: _statuses.length,
              itemBuilder: (context, index) {
                final status = _statuses[index];
                final isSelected = status == _selectedStatus;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(
                      status,
                      style: TextStyle(
                        color: isSelected ? Colors.white : primary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedStatus = status),
                    backgroundColor: Colors.white,
                    selectedColor: primary,
                    shape: StadiumBorder(side: BorderSide(color: primary)),
                    showCheckmark: false,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: _filtered.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak ada data pengembalian',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadPengembalian,
                    child: ListView.builder(
                      itemCount: _filtered.length,
                      itemBuilder: (context, i) => _buildCard(_filtered[i]),
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: AdminBottomNavbar(
        currentIndex: 2,
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
}