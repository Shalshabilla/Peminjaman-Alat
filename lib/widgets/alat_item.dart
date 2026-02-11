import 'package:flutter/material.dart';
import '../../models/alat_model.dart';

class AlatItem extends StatelessWidget {
  final Alat alat;
  final VoidCallback onEdit;
  final VoidCallback onHapus;

  const AlatItem({
    super.key,
    required this.alat,
    required this.onEdit,
    required this.onHapus,
  });

  @override
  Widget build(BuildContext context) {
    final bool tersedia = alat.stok > 0;
    final String statusText = tersedia ? 'Tersedia' : 'Dipinjam';
    final IconData statusIcon = tersedia ? Icons.check_circle : Icons.history;
    final Color statusColor = tersedia ? Colors.green : Colors.orange;

    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Gambar
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

        const Divider(
          height: 1.5,
          thickness: 1.5,
          color: Color(0xFFD0D0D0),
          indent: 0,
          endIndent: 0,
        ),

        const SizedBox(height: 10),

        // Nama alat
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
            'Stok: ${alat.stok}',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
        ),

        const SizedBox(height: 2),

        // Status + ikon
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

        const SizedBox(height: 12),

        // Tombol Edit & Hapus – lebih ditegaskan dengan ElevatedButton
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                  label: const Text('Edit', style: TextStyle(fontSize: 13, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 1,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onHapus,
                  icon: const Icon(Icons.delete, size: 16, color: Colors.white),
                  label: const Text('Hapus', style: TextStyle(fontSize: 13, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}