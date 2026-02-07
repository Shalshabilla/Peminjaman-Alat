import 'package:flutter/material.dart';

class TransaksiAdminScreen extends StatelessWidget {
  const TransaksiAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaksi')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _MenuTile(title: 'Data Peminjaman'),
          _MenuTile(title: 'Data Pengembalian'),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final String title;
  const _MenuTile({required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
