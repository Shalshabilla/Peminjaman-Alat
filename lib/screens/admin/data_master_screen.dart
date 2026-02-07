import 'package:flutter/material.dart';

class DataMasterScreen extends StatelessWidget {
  const DataMasterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Master')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _MenuTile(title: 'Data User', icon: Icons.person),
          _MenuTile(title: 'Data Alat', icon: Icons.build),
          _MenuTile(title: 'Data Kategori', icon: Icons.category),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final String title;
  final IconData icon;

  const _MenuTile({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
