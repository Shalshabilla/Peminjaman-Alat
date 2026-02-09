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
    'Kabel',
  ];

  Map<int, String> _kategoriMap = {};

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  // Warna utama navy (sama seperti di Daftar Kategori)
  final Color primary = const Color(0xFF2F3A8F);

  @override
  void initState() {
    super.initState();
    _loadKategori();
    _searchController.addListener(() {
      setState(
        () => _searchQuery = _searchController.text.trim().toLowerCase(),
      );
    });
  }

  Future<void> _loadKategori() async {
    final data = await Supabase.instance.client
        .from('kategori')
        .select('id_kategori, nama_kategori');

    setState(() {
      _kategoriMap = {
        for (var k in data)
          k['id_kategori'] as int: k['nama_kategori'] as String,
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
      final matchSearch = alat.namaAlat.toLowerCase().contains(_searchQuery);
      final kategori = alat.namaKategori ?? '';
      final matchCategory =
          _selectedCategory == 'Semua' || kategori == _selectedCategory;
      return matchSearch && matchCategory;
    }).toList();
  }

  Future<void> _manualRefresh() async {
    try {
      final response = await Supabase.instance.client
          .from('alat')
          .select(
            'id_alat, id_kategori, nama_alat, stok, status, gambar, created_at',
          )
          .order('created_at', ascending: false);

      setState(() {
        _allAlat =
            response.map((map) {
              final alat = Alat.fromJson(map);
              alat.namaKategori =
                  _kategoriMap[alat.idKategori] ?? 'Tidak diketahui';
              return alat;
            }).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal muat ulang data: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Daftar Alat',
          style: TextStyle(color: primary, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AlatCreateScreen(),
                  ),
                );
                if (result == true) {
                  await _manualRefresh();
                }
              },
              child: CircleAvatar(
                backgroundColor: Colors.grey[400],
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          // Search box — sama persis seperti di kategori
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
                hintText: 'Cari alat...',
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Filter chips dengan warna navy
          SizedBox(
            height: 42,
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
                        color: isSelected ? Colors.white : primary,
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                    backgroundColor: Colors.white,
                    selectedColor: primary, // navy saat dipilih
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color:
                            isSelected
                                ? Colors.transparent
                                : primary.withOpacity(0.5),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    showCheckmark: false,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: _manualRefresh,
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: Supabase.instance.client
                    .from('alat')
                    .stream(primaryKey: ['id_alat'])
                    .order('created_at', ascending: false),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final data = snapshot.data ?? [];
                  _allAlat =
                      data.map((map) {
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
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 220,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.65,
                        ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final alat = filtered[index];
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: primary, width: 2),
                          color: Colors.white,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: AlatItem(
                            key: ValueKey(alat.idAlat),
                            alat: alat,
                            onEdit: () async {
                              if (alat.idAlat == null || alat.idAlat == 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('ID alat tidak valid!'),
                                  ),
                                );
                                return;
                              }
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => AlatUpdateScreen(alat: alat),
                                ),
                              );
                              if (result == true) {
                                await _manualRefresh();
                              }
                            },
                            onHapus: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: const Text('Hapus Alat'),
                                      content: const Text(
                                        'Yakin ingin menghapus alat ini?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, false),
                                          child: Text(
                                            'Batal',
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, true),
                                          child: const Text(
                                            'Hapus',
                                            style: TextStyle(color: Colors.red),
                                          ),
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
                                  const SnackBar(
                                    content: Text('Alat berhasil dihapus'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                await _manualRefresh();
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Gagal hapus: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AdminBottomNavbar(
        currentIndex: 1,
        onTap: (index) {},
      ),
    );
  }
}
