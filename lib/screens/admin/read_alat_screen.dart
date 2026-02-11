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
  Map<int, String> _kategoriMap = {};

  final List<String> _categories = [
    'Semua',
    'Penyimpanan',
    'Perangkat',
    'Jaringan',
    'Kabel',
  ];

  final Color primary = const Color(0xFF2F3A8F);

 @override
void initState() {
  super.initState();

  // 🔥 PAKSA REALTIME CONNECT
  Supabase.instance.client.realtime.disconnect();
  Supabase.instance.client.realtime.connect();

  _loadKategori();

  _searchController.addListener(() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
    });
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
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AlatCreateScreen(),
                  ),
                );
                // ❌ Tidak perlu refresh — realtime otomatis
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

          // Search
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

          // Filter kategori
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
                    onSelected: (_) =>
                        setState(() => _selectedCategory = cat),
                    backgroundColor: Colors.white,
                    selectedColor: primary,
                    showCheckmark: false,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // ================= REALTIME =================
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: Supabase.instance.client
                  .from('alat')
                  .stream(primaryKey: ['id_alat'])
                  .order('created_at', ascending: false),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data!;

                _allAlat = data.map((map) {
                  final alat = Alat.fromJson(map);
                  alat.namaKategori =
                      _kategoriMap[alat.idKategori] ?? 'Tidak diketahui';
                  return alat;
                }).toList();

                final filtered = _filteredAlat;

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada data alat',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
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
                    childAspectRatio: 0.62,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final alat = filtered[index];
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: primary, width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: AlatItem(
                          key: ValueKey(alat.idAlat),
                          alat: alat,
                          onEdit: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AlatUpdateScreen(alat: alat),
                              ),
                            );
                            // ❌ tidak perlu refresh
                          },
                          onHapus: () async {
                            await Supabase.instance.client
                                .from('alat')
                                .delete()
                                .eq('id_alat', alat.idAlat);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
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
