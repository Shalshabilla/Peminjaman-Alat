import 'package:flutter/material.dart';
import '../../models/kategori_model.dart';
import '../../services/kategori_services.dart';
import 'create_update_kategori_screens.dart';
import '../../widgets/admin_bottom_navbar.dart';

class DaftarKategoriPage extends StatefulWidget {
  const DaftarKategoriPage({super.key});

  @override
  State<DaftarKategoriPage> createState() => _DaftarKategoriPageState();
}

class _DaftarKategoriPageState extends State<DaftarKategoriPage> {
  final KategoriService _service = KategoriService();
  final TextEditingController _searchController = TextEditingController();
  List<Kategori> _kategoriList = [];
  List<Kategori> _filteredList = [];
  bool _isLoading = true;

  final Color primary = const Color(0xFF2F3A8F);
  late final Stream<List<Map<String, dynamic>>> _kategoriStream;

  @override
  void initState() {
    super.initState();
    _fetchKategori();
    _searchController.addListener(_filterKategori);

    // Realtime subscription
    _kategoriStream = _service.supabase
        .from('kategori')
        .stream(primaryKey: ['id_kategori']);
    _kategoriStream.listen((data) {
      setState(() {
        _kategoriList = data.map((e) => Kategori.fromJson(e)).toList();
        _filterKategori();
      });
    });
  }

  Future<void> _fetchKategori() async {
    setState(() => _isLoading = true);
    try {
      _kategoriList = await _service.getAllKategori();
      _filteredList = _kategoriList;
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
    setState(() => _isLoading = false);
  }

  void _filterKategori() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredList = _kategoriList
          .where((k) => k.namaKategori.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _showDeleteDialog(Kategori kategori) async {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Colors.red, size: 50),
              const SizedBox(height: 10),
              const Text(
                'Hapus Kategori',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text('Anda yakin ingin menghapus kategori?'),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20))),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _service.deleteKategori(kategori.id!);
                        _fetchKategori();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20))),
                      child: const Text('Hapus'),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAddEditDialog({Kategori? kategori}) async {
    final result = await AddEditKategoriDialog.show(
      context,
      kategori: kategori,
    );
    if (result == true) _fetchKategori();
  }

  Widget _searchBox() {
    return Container(
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
          hintText: 'Cari kategori...',
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _kategoriCard(Kategori kat) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary, width: 2),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kat.namaKategori,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  kat.deskripsikategori,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _iconAction(
                icon: Icons.edit,
                color: Colors.blue,
                onTap: () => _showAddEditDialog(kategori: kat),
              ),
              const SizedBox(width: 8),
              _iconAction(
                icon: Icons.delete,
                color: Colors.red,
                onTap: () => _showDeleteDialog(kat),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _iconAction({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 1.8),
        color: Colors.white,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: 18,
        icon: Icon(icon, color: color),
        onPressed: onTap,
      ),
    );
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
          'Daftar Kategori',
          style: TextStyle(color: primary, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => _showAddEditDialog(),
              child: CircleAvatar(
                backgroundColor: Colors.grey[400],
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          _searchBox(),
          const SizedBox(height: 10),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchKategori,
                    child: ListView.builder(
                      itemCount: _filteredList.length,
                      itemBuilder: (context, index) =>
                          _kategoriCard(_filteredList[index]),
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar:
          AdminBottomNavbar(currentIndex: 1, onTap: (index) {}),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
