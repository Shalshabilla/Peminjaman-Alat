import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/peminjaman_model.dart';

class DetailPeminjamanPetugasScreen extends StatefulWidget {
  final Peminjaman peminjaman;

  const DetailPeminjamanPetugasScreen({
    super.key,
    required this.peminjaman,
  });

  @override
  State<DetailPeminjamanPetugasScreen> createState() => _DetailPeminjamanPetugasScreenState();
}

class _DetailPeminjamanPetugasScreenState extends State<DetailPeminjamanPetugasScreen> {
  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu':
        return Colors.orange;
      case 'disetujui':
      case 'dipinjam':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      case 'dikembalikan':
        return Colors.grey;
      default:
        return Colors.indigo;
    }
  }

  Future<void> _handleSetujui() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Yakin ingin menyetujui peminjaman ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Setujui'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await Supabase.instance.client
          .from('peminjaman')
          .update({'status': 'disetujui'})
          .eq('id_peminjaman', widget.peminjaman.idPeminjaman);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Peminjaman disetujui'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e')),
        );
      }
    }
  }

  Future<void> _handleTolak() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Penolakan'),
        content: const Text('Yakin ingin menolak peminjaman ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Tolak'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await Supabase.instance.client
          .from('peminjaman')
          .update({'status': 'Ditolak'})
          .eq('id_peminjaman', widget.peminjaman.idPeminjaman);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Peminjaman ditolak'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e')),
        );
      }
    }
  }
Future<void> _handleDikembalikan() async {
  try {
    await Supabase.instance.client
        .from('peminjaman')
        .update({
          'status': 'dikembalikan',
          'tgl_kembali': DateTime.now().toIso8601String(),
        })
        .eq('id_peminjaman', widget.peminjaman.idPeminjaman);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alat berhasil dikembalikan')),
    );

    Navigator.pop(context);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal update: $e')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final p = widget.peminjaman;
    final isMenunggu = p.status.toLowerCase() == 'menunggu';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Peminjaman'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // HEADER ── persis sama seperti contoh
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.namaPeminjam,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.date_range, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '${DateFormat('dd MMM yyyy').format(p.tglPinjam)}'
                      ' - '
                      '${p.tglKembaliRencana != null ? DateFormat('dd MMM yyyy').format(p.tglKembaliRencana!) : '-'}',
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _statusColor(p.status).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      p.status,
                      style: TextStyle(
                        color: _statusColor(p.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // DAFTAR ALAT ── persis sama
          ...p.detail.map((d) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                  )
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: d.gambar != null
                        ? Image.network(
                            d.gambar!,
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 90,
                              height: 90,
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.broken_image),
                            ),
                          )
                        : Container(
                            width: 90,
                            height: 90,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.image),
                          ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d.namaAlat,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Jumlah dipinjam: ${d.jumlah}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),

          // AKSI PETUGAS ── hanya muncul kalau masih menunggu
          if (isMenunggu) ...[
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _handleSetujui,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('SETUJUI'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _handleTolak,
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('TOLAK'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
// AKSI PETUGAS ── jika status dipinjam
if (p.status.toLowerCase() == 'dipinjam') ...[
  const SizedBox(height: 24),
  SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: _handleDikembalikan,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text('DIKEMBALIKAN'),
    ),
  ),
],

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}