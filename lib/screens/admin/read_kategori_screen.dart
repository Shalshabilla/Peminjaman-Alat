import 'package:flutter/material.dart';
import '../../models/kategori_model.dart';
import '../../services/kategori_services.dart';
import 'create_update_kategori_screens.dart';

class DaftarKategoriPage extends StatefulWidget {
  const DaftarKategoriPage({super.key});

  @override
  State<DaftarKategoriPage> createState() => _DaftarKategoriPageState();
}

class _DaftarKategoriPageState extends State<DaftarKategoriPage> {
  final KategoriService _service = KategoriService();
  List<Kategori> _kategoriList = [];
  List<Kategori> _filteredList = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchKategori();
    _searchController.addListener(_filterKategori);
  }

  Future<void> _fetchKategori() async {
    setState(() => _isLoading = true);
    try {
      _kategoriList = await _service.getAllKategori();
      _filteredList = _kategoriList;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
    setState(() => _isLoading = false);
  }

  void _filterKategori() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredList = _kategoriList.where((k) => k.namaKategori.toLowerCase().contains(query)).toList();
    });
  }

  Future<void> _showDeleteDialog(Kategori kategori) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 30),
            const SizedBox(width: 10),
            const Text('Hapus Kategori', style: TextStyle(color: Colors.red)),
          ],
        ),
        content: const Text('Anda yakin ingin menghapus kategori?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.red)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _service.deleteKategori(kategori.id!);
                _fetchKategori();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

Future<void> _showAddEditDialog({Kategori? kategori}) async {
  final result = await AddEditKategoriDialog.show(
    context,
    kategori: kategori,
  );
  if (result == true) {
    _fetchKategori();
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue[800]),
          onPressed: () => Navigator.pop(context),  // Sesuaikan jika bukan pop
        ),
        title: Text('Daftar Kategori', style: TextStyle(color: Colors.blue[800])),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: CircleAvatar(
              backgroundColor: Colors.grey[400],
              child: const Icon(Icons.add, color: Colors.white),
            ),
            onPressed: () => _showAddEditDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                hintText: 'Cari kategori...',
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchKategori,
                    child: ListView.builder(
                      itemCount: _filteredList.length,
                      itemBuilder: (context, index) {
                        final kat = _filteredList[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Card(
                            child: ListTile(
                              title: Text(kat.namaKategori, style: Theme.of(context).textTheme.titleLarge),
                              subtitle: Text(kat.deskripsikategori, style: Theme.of(context).textTheme.bodyMedium),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _showAddEditDialog(kategori: kat),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _showDeleteDialog(kat),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}