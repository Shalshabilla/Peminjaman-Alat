import 'package:flutter/material.dart';
import '../../models/alat_model.dart';

class AlatItemPeminjam extends StatelessWidget {
  final Alat alat;
  final VoidCallback onAjukanPeminjaman;

  const AlatItemPeminjam({
    super.key,
    required this.alat,
    required this.onAjukanPeminjaman,
  });

  @override
  Widget build(BuildContext context) {
    final bool tersedia = (alat.stok ?? 0) > 0;
    final String statusText = tersedia ? 'Tersedia' : 'Dipinjam';
    final IconData statusIcon = tersedia ? Icons.check_circle : Icons.history;
    final Color statusColor = tersedia ? Colors.green : Colors.orange;

    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Gambar - sama seperti admin
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: AspectRatio(
            aspectRatio: 1.25,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: alat.gambar != null && alat.gambar!.isNotEmpty
                  ? Image.network(
                      alat.gambar!,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                      ),
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, size: 40, color: Colors.grey),
                    ),
            ),
          ),
        ),

        // Garis pemisah - sama persis
        const Divider(
          height: 1.5,
          thickness: 1.5,
          color: Color(0xFFD0D0D0),
          indent: 0,
          endIndent: 0,
        ),

        const SizedBox(height: 10),

        // Nama alat - sama
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            alat.namaAlat,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Stok
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
          child: Text(
            'Stok: ${alat.stok ?? 0}',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
        ),

        const SizedBox(height: 2),

        // Status + ikon - sama style-nya
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
          child: Row(
            children: [
              Icon(
                statusIcon,
                size: 16,
                color: statusColor,
              ),
              const SizedBox(width: 6),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Tombol Ajukan Peminjaman - full width, warna navy
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ElevatedButton(
            onPressed: onAjukanPeminjaman,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2F3A8F), // navy sesuai tema
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              elevation: 2,
            ),
            child: const Text(
              'Ajukan Peminjaman',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),
      ],
    );
  }
}