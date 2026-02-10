import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/peminjaman_model.dart';
import 'detail_peminjaman_petugas_screen.dart';
import '../../widgets/petugas_bottom_navbar.dart';

class PeminjamanPetugasScreen extends StatefulWidget {
  const PeminjamanPetugasScreen({super.key});

  @override
  State<PeminjamanPetugasScreen> createState() => _PeminjamanPetugasScreenState();
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
      final res = await Supabase.instance.client
          .from('peminjaman')
          .select('''
            id_peminjaman,
            status,
            tgl_pinjam,
            tgl_kembali_rencana,
            tgl_kembali,
            users!peminjaman_id_user_fkey ( nama ),
            detail_peminjaman (
              jumlah,
              alat ( nama_alat, gambar )
            )
          ''')
          .order('tgl_pinjam', ascending: false);

      if (mounted) {
        setState(() {
          _allPeminjaman = res.map((e) => Peminjaman.fromJson(e)).toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading peminjaman petugas: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e')),
        );
      }
    }
  }

  List<Peminjaman> get _filtered {
    return _allPeminjaman.where((p) {
      final matchSearch = (p.namaPeminjam.toLowerCase().contains(_searchQuery)) ||
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

  void _onNavTap(int index) {
    final routes = [
      '/petugas/dashboard',      // 0 - Beranda
      '/petugas/pengajuan',      // 1 - Pengajuan (halaman ini)
      '/petugas/pengembalian',   // 2
      '/petugas/laporan',        // 3
      '/petugas/profil',         // 4
    ];

    // Hindari reload halaman yang sama
    if (index != 1 && index >= 0 && index < routes.length) {
      Navigator.pushReplacementNamed(context, routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: const Text('Peminjaman Masuk', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari peminjam atau alat...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),

          // Filter chips
          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _statuses.length,
              itemBuilder: (context, i) {
                final status = _statuses[i];
                final selected = status == _selectedStatus;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(status),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedStatus = status),
                    selectedColor: primary,
                    labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87),
                    backgroundColor: Colors.white,
                    shape: StadiumBorder(side: BorderSide(color: primary)),
                  ),
                );
              },
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadPeminjaman,
              child: _filtered.isEmpty
                  ? const Center(child: Text('Tidak ada data peminjaman'))
                  : ListView.builder(
                      itemCount: _filtered.length,
                      itemBuilder: (context, i) {
                        final p = _filtered[i];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            title: Text(
                              p.namaPeminjam,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              p.detail.map((d) => d.namaAlat).join(', '),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _statusColor(p.status).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                p.status,
                                style: TextStyle(
                                  color: _statusColor(p.status),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailPeminjamanPetugasScreen(peminjaman: p),
                                ),
                              ).then((_) => _loadPeminjaman());
                            },
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: PetugasBottomNavbar(
        currentIndex: 1, // Pengajuan
        onTap: _onNavTap,
      ),
    );
  }
}