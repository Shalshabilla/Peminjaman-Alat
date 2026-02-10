import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/alat_model.dart';
import '../../widgets/alat_item_peminjam.dart';
import '../../widgets/peminjam_bottom_navbar.dart';
import 'form_peminjaman_screen.dart';

class DaftarAlatPeminjamScreen extends StatefulWidget {
  const DaftarAlatPeminjamScreen({super.key});

  @override
  State<DaftarAlatPeminjamScreen> createState() => _DaftarAlatPeminjamScreenState();
}

class _DaftarAlatPeminjamScreenState extends State<DaftarAlatPeminjamScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  List<Alat> _allAlat = [];
  final List<String> _categories = ['Semua', 'Perangkat', 'Jaringan', 'Penyimpanan'];
  Map<int, String> _kategoriMap = {};
  final Color primary = const Color(0xFF2F3A8F);

  @override
  void initState() {
    super.initState();
    _loadKategori();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
  }

  Future<void> _loadKategori() async {
    final data = await Supabase.instance.client
        .from('kategori')
        .select('id_kategori, nama_kategori');

    setState(() {
      _kategoriMap = {for (var k in data) k['id_kategori'] as int: k['nama_kategori'] as String};
    });
    _refreshData(); // load data setelah kategori siap
  }

  List<Alat> get _filteredAlat {
    return _allAlat.where((alat) {
      final matchSearch = alat.namaAlat.toLowerCase().contains(_searchQuery);
      final kategori = alat.namaKategori ?? '';
      final matchCategory = _selectedCategory == 'Semua' || kategori == _selectedCategory;
      return matchSearch && matchCategory;
    }).toList();
  }

  Future<void> _refreshData() async {
    final response = await Supabase.instance.client
        .from('alat')
        .select('id_alat, id_kategori, nama_alat, stok, status, gambar, created_at')
        .order('created_at', ascending: false);

    setState(() {
      _allAlat = response.map((map) {
        final alat = Alat.fromJson(map);
        alat.namaKategori = _kategoriMap[alat.idKategori] ?? 'Tidak diketahui';
        return alat;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Daftar Alat',
          style: TextStyle(color: primary, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          // SEARCH
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

          const SizedBox(height: 16),

          // FILTER CHIP
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
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                    backgroundColor: Colors.white,
                    selectedColor: primary,
                    showCheckmark: false,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // LIST ALAT
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: Supabase.instance.client
                    .from('alat')
                    .stream(primaryKey: ['id_alat'])
                    .order('created_at', ascending: false),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                  final data = snapshot.data!;
                  _allAlat = data.map((map) {
                    final alat = Alat.fromJson(map);
                    alat.namaKategori = _kategoriMap[alat.idKategori] ?? 'Tidak diketahui';
                    return alat;
                  }).toList();

                  final filtered = _filteredAlat;
                  if (filtered.isEmpty) return const Center(child: Text('Belum ada data alat'));

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.62,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final alat = filtered[index];
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: primary, width: 1.5),
                          color: Colors.white,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: AlatItemPeminjam(
                            alat: alat,
                            onAjukanPeminjaman: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FormPeminjamanScreen(alat: alat),
                                ),
                              );
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
      bottomNavigationBar: PeminjamBottomNavbar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 1) return;
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/peminjam/dashboard');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/peminjam/peminjaman');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/peminjam/profil');
              break;
          }
        },
      ),
    );
  }
}
