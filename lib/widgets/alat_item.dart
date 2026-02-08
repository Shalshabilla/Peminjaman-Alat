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
    final isTersedia = alat.stok > 0;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: Image.network(
              alat.gambar ?? '',
              height: 120,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) =>
                      const Icon(Icons.error, size: 120),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              alat.namaAlat,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isTersedia ? Icons.check_circle : Icons.warning,
                  color: isTersedia ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  isTersedia
                      ? 'Stok: ${alat.stok} Tersedia'
                      : 'Stok: 0 Dipinjam',
                  style: TextStyle(
                    color: isTersedia ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: onHapus,
                  icon: const Icon(Icons.delete),
                  label: const Text('Hapus'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
