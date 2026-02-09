import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/alat_model.dart';
import '../../widgets/alat_item.dart';
import '../../widgets/admin_bottom_navbar.dart';
import 'create_alat_screen.dart';
import 'update_alat_screen.dart';

class ReadAlatScreen extends StatefulWidget {
  const ReadAlatScreen({super.key});

  @override
  State<ReadAlatScreen> createState() => _ReadAlatScreenState();
}

class _ReadAlatScreenState extends State<ReadAlatScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  List<Alat> _allAlat = [];

  final List<String> _categories = [
    'Semua',
    'Penyimpanan',
    'Perangkat',
    'Jaringan',
    'Kabel'
  ];

  Map<int, String> _kategoriMap = {}; // ✅ TAMBAHAN

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _loadKategori(); // ✅ TAMBAHAN

    _searchController.addListener(() {
      setState(() =>
          _searchQuery = _searchController.text.trim().toLowerCase());
    });
  }

  // ✅ TAMBAHAN
  Future<void> _loadKategori() async {
    final data = await Supabase.instance.client
        .from('kategori')
        .select('id_kategori, nama_kategori');

    setState(() {
      _kategoriMap = {
        for (var k in data) k['id_kategori']: k['nama_kategori']
      };
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Alat> get _filteredAlat {
    return _allAlat.where((alat) {
      final matchSearch =
          alat.namaAlat.toLowerCase().contains(_searchQuery);

      final kategori = alat.namaKategori ?? '';

      final matchCategory = _selectedCategory == 'Semua' ||
          kategori == _selectedCategory;

      return matchSearch && matchCategory;
    }).toList();
  }

  Future<void> _refresh() async {
    setState(() {});
  }

  Future<void> _manualRefresh() async {
    try {
      final response = await Supabase.instance.client
          .from('alat')
          .select(
              'id_alat, id_kategori, nama_alat, stok, status, gambar, created_at')
          .order('created_at', ascending: false);

      setState(() {
        _allAlat = response.map((map) {
          final alat = Alat.fromJson(map);
          alat.namaKategori = _kategoriMap[alat.idKategori] ?? 'Tidak diketahui';
          return alat;
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal muat ulang data: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Daftar Alat', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_rounded, color: Colors.blueAccent, size: 28),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AlatCreateScreen()),
              );
              if (result == true) {
                print('Create berhasil, refresh data');
                await _manualRefresh(); // Refresh manual setelah create
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari alat...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = cat == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.blue[800],
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                    backgroundColor: Colors.white,
                    selectedColor: Colors.blue[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: isSelected ? Colors.transparent : Colors.blue[200]!),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    showCheckmark: false,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: RefreshIndicator(
                  key: _refreshIndicatorKey,
                  onRefresh: _manualRefresh, // Pakai manual refresh untuk pull-to-refresh juga
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: Supabase.instance.client
    .from('alat')
    .stream(primaryKey: ['id_alat'])
    .order('created_at', ascending: false),

                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        print('Stream error: ${snapshot.error}');
                        return Center(child: Text('Error memuat data: ${snapshot.error}'));
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final data = snapshot.data ?? [];
                      print('Stream received ${data.length} items');

                      _allAlat = data.map((map) {
  final alat = Alat.fromJson(map);
  alat.namaKategori =
      _kategoriMap[alat.idKategori] ?? 'Tidak diketahui';
  return alat;
}).toList();


                      final filtered = _filteredAlat;

                      if (filtered.isEmpty) {
  return Center(
    child: Text(
      _selectedCategory == 'Semua'
          ? 'Belum ada data alat'
          : 'Tidak ada alat di kategori $_selectedCategory',
      style: const TextStyle(color: Colors.grey, fontSize: 16),
    ),
  );
}


                      return GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 220,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.68,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final alat = filtered[index];
                          return AlatItem(
                            key: ValueKey(alat.idAlat),
                            alat: alat,
                            onEdit: () async {
  print('=== DEBUG EDIT ===');
  print('Alat yang dipilih: ${alat.toString()}'); // Print seluruh object
  print('ID alat sebelum kirim ke update: ${alat.idAlat}');
  if (alat.idAlat == null || alat.idAlat == 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ID alat tidak valid! Cek model fromJson'), backgroundColor: Colors.orange),
    );
    return;
  }

  final result = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => AlatUpdateScreen(alat: alat)),
  );
  if (result == true) {
    print('Update berhasil dari dialog, jalankan manual refresh');
    await _manualRefresh();
  }
},
                            onHapus: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Hapus Alat'),
                                  content: const Text('Yakin ingin menghapus alat ini? Aksi ini tidak bisa dibatalkan.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm != true) return;

                              try {
                                await Supabase.instance.client
                                    .from('alat')
                                    .delete()
                                    .eq('id_alat', alat.idAlat);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Alat berhasil dihapus'), backgroundColor: Colors.green),
                                );

                                await _manualRefresh(); // ← PASTI TER-UPDATE SETELAH HAPUS
                              } catch (e) {
                                print('Delete error: $e');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Gagal hapus: $e'), backgroundColor: Colors.red),
                                );
                              }
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AdminBottomNavbar(currentIndex: 1, onTap: (index) {}),
    );
  }
}