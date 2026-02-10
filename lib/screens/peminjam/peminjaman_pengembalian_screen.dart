import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/peminjaman_model.dart';
import '../../widgets/peminjam_bottom_navbar.dart';
import 'detail_peminjaman_screen.dart';

class PeminjamanPeminjamScreen extends StatefulWidget {
  const PeminjamanPeminjamScreen({Key? key}) : super(key: key);

  @override
  State<PeminjamanPeminjamScreen> createState() =>
      _PeminjamanPeminjamScreenState();
}

class _PeminjamanPeminjamScreenState extends State<PeminjamanPeminjamScreen> {
  List<Peminjaman> _allPeminjaman = [];
  String _selectedStatus = 'Semua';

  final List<String> _statuses = [
    'Semua',
    'Menunggu',
    'Disetujui',
    'Dipinjam',
    'Dikembalikan',
  ];

  final Color primary = const Color(0xFF2F3A8F);

  @override
  void initState() {
    super.initState();
    _loadPeminjaman();
  }

  // ================= LOAD DATA =================
  Future<void> _loadPeminjaman() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final List res = await Supabase.instance.client
        .from('peminjaman')
        .select('''
          id_peminjaman,
          status,
          tgl_pinjam,
          tgl_kembali_rencana,
          users ( nama ),
          detail_peminjaman (
            jumlah,
            alat ( nama_alat, gambar )
          )
        ''')
        .eq('id_user', user.id)
        .order('tgl_pinjam', ascending: false);

    if (!mounted) return;

    setState(() {
      _allPeminjaman =
          res.map((e) => Peminjaman.fromJson(e)).toList();
    });
  }

  List<Peminjaman> get _filtered {
    return _allPeminjaman.where((p) {
      return _selectedStatus == 'Semua' ||
          p.status.toLowerCase() ==
              _selectedStatus.toLowerCase();
    }).toList();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu':
        return Colors.orange;
      case 'disetujui':
        return Colors.green;
      case 'dipinjam':
        return Colors.blue;
      case 'dikembalikan':
        return Colors.grey;
      default:
        return primary;
    }
  }

  // ================= CARD =================
 Widget _card(Peminjaman p) {
  final alatNama = p.detail.map((e) => e.namaAlat).join(', ');
  final jumlahTotal =
      p.detail.fold<int>(0, (a, b) => a + b.jumlah);

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
        // STATUS (KANAN ATAS)
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
            // NAMA
            Text(
              p.namaPeminjam,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primary,
              ),
            ),

            const SizedBox(height: 8),

            // ALAT
            Row(
              children: [
                const Icon(Icons.build, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    alatNama,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // JUMLAH
            Row(
              children: [
                const Icon(Icons.inventory_2,
                    size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  'Jumlah: $jumlahTotal',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // TANGGAL
            Row(
              children: [
                const Icon(Icons.date_range,
                    size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  '${DateFormat('dd MMM yyyy').format(p.tglPinjam)}'
                  ' - '
                  '${p.tglKembali != null
                      ? DateFormat('dd MMM yyyy')
                          .format(p.tglKembali!)
                      : '-'}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 6),
          ],
        ),

        // ICON DETAIL (KANAN BAWAH)
        Positioned(
          bottom: 0,
          right: 0,
          child: IconButton(
            icon: Icon(Icons.chevron_right,
                size: 30, color: primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      DetailPeminjamanScreen(peminjaman: p),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}


  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peminjaman Saya'),
        foregroundColor: primary,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          SizedBox(
            height: 42,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _statuses.length,
              itemBuilder: (c, i) {
                final s = _statuses[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(s),
                    selected: s == _selectedStatus,
                    onSelected: (_) =>
                        setState(() => _selectedStatus = s),
                    selectedColor: primary,
                    labelStyle: TextStyle(
                      color:
                          s == _selectedStatus ? Colors.white : primary,
                    ),
                    showCheckmark: false,
                  ),
                );
              },
            ),
          ),

          Expanded(
            child: _filtered.isEmpty
                ? const Center(child: Text('Tidak ada peminjaman'))
                : ListView.builder(
                    itemCount: _filtered.length,
                    itemBuilder: (c, i) => _card(_filtered[i]),
                  ),
          )
        ],
      ),
      bottomNavigationBar:
          PeminjamBottomNavbar(currentIndex: 2, onTap: (_) {}),
    );
  }
}
