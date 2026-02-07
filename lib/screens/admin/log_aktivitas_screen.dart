import 'package:flutter/material.dart';

class LogAktivitasScreen extends StatelessWidget {
  const LogAktivitasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Aktifitas')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, index) {
          return const ListTile(
            leading: Icon(Icons.history),
            title: Text('User melakukan aktivitas'),
            subtitle: Text('2 menit lalu'),
          );
        },
      ),
    );
  }
}
