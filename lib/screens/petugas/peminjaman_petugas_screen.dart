// screens/petugas/peminjaman_petugas_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/peminjaman_model.dart';
import 'detail_peminjaman_petugas_screen.dart';
import '../../widgets/petugas_bottom_navbar.dart';

class PeminjamanPetugasScreen extends StatefulWidget {
  const PeminjamanPetugasScreen({super.key});

  @override
  State<PeminjamanPetugasScreen> createState() =>
      _PeminjamanPetugasScreenState();
}

class _PeminjamanPetugasScreenState extends State<PeminjamanPetugasScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatus = 'Semua';

  List<Peminjaman> _allPeminjaman = [];

  final List<String> _statuses = [
    'Semua',
    'Menunggu',
    'Disetujui',
    'Ditolak',
    'Dipinjam',
  ];

  final Color primary = const Color(0xFF0D47A1);

  @override
  void initState() {
    super.initState();
    _loadPeminjaman();

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

  Future<void> _loadPeminjaman() async {
    try {
      final res = await Supabase.instance.client.from('peminjaman').select('''
        id_peminjaman,
        status,
        tgl_pinjam,
        tgl_kembali_rencana,
        users!peminjaman_id_user_fkey ( nama ),
        detail_peminjaman (
          jumlah,
          alat ( nama_alat, gambar )
        )
      ''').order('tgl_pinjam', ascending: false);

      if (mounted) {
        setState(() {
          _allPeminjaman = (res as List<dynamic>)
              .map((e) => Peminjaman.fromJson(e as Map<String, dynamic>))
              .toList();
        });
      }
    } catch (e, st) {
      debugPrint('Error loading peminjaman petugas: $e');
      debugPrint(st.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e')),
        );
      }
    }
  }

  List<Peminjaman> get _filtered {
    return _allPeminjaman.where((p) {
      final matchSearch = p.namaPeminjam.toLowerCase().contains(_searchQuery) ||
          p.detail.any((d) => d.namaAlat.toLowerCase().contains(_searchQuery));
      final matchStatus = _selectedStatus == 'Semua' ||
          p.status.toLowerCase() == _selectedStatus.toLowerCase();
      return matchSearch && matchStatus;
    }).toList();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu':
        return Colors.orange;
      case 'disetujui':
      case 'dipinjam':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      default:
        return primary;
    }
  }

  Widget _card(Peminjaman p) {
    final alatNama = p.detail.map((e) => e.namaAlat).join(', ');
    final jumlahTotal = p.detail.fold<int>(0, (sum, e) => sum + e.jumlah);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: primary.withOpacity(0.3)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor(p.status).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                p.status,
                style: TextStyle(
                  color: _statusColor(p.status),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                p.namaPeminjam,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primary),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.build, size: 18, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(child: Text(alatNama, style: const TextStyle(fontSize: 14))),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.inventory_2, size: 18, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text('Jumlah: $jumlahTotal', style: const TextStyle(fontSize: 14)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.date_range, size: 18, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    '${DateFormat('dd MMM yyyy').format(p.tglPinjam)} - '
                    '${p.tglKembali != null ? DateFormat('dd MMM yyyy').format(p.tglKembali!) : '-'}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: IconButton(
              icon: Icon(Icons.chevron_right, size: 30, color: primary),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DetailPeminjamanPetugasScreen(peminjaman: p)),
                ).then((_) => _loadPeminjaman());
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onNavTap(int index) {
    final routes = [
      '/petugas/dashboard', // 0
      '/petugas/peminjaman', // 1
      '/petugas/pengembalian', // 2
      '/petugas/laporan', // 3
      '/petugas/profil', // 4
    ];

    if (ModalRoute.of(context)?.settings.name != routes[index]) {
      Navigator.pushReplacementNamed(context, routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Peminjaman Masuk',
          style: TextStyle(
            color: primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        foregroundColor: primary,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
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
                hintText: 'Cari peminjaman...',
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Filter chips
          SizedBox(
            height: 42,
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
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedStatus = status),
                    backgroundColor: Colors.white,
                    selectedColor: primary,
                    showCheckmark: false,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // List
          Expanded(
            child: _filtered.isEmpty
                ? const Center(child: Text('Tidak ada data peminjaman'))
                : RefreshIndicator(
                    onRefresh: _loadPeminjaman,
                    child: ListView.builder(
                      itemCount: _filtered.length,
                      itemBuilder: (context, i) => _card(_filtered[i]),
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: PetugasBottomNavbar(
        currentIndex: 1,
        onTap: _onNavTap,
      ),
    );
  }
}
