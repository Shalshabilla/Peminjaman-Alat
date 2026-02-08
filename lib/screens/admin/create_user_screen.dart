import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/user_services.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final UserService _userService = UserService();
  final _formKey = GlobalKey<FormState>();
  String _nama = '';
  String _email = '';
  String _kataSandi = '';
  String _role = 'Admin'; // Default

  final List<String> _roles = ['Admin', 'Petugas', 'Siswa', 'Peminjam'];

  void _saveUser() async {
    if (_formKey.currentState!.validate()) {
      final user = AppUser(
        id: '', // Supabase will generate
        nama: _nama,
        email: _email,
        katasandi: _kataSandi,
        role: _role,
      );
      await _userService.createUser(user);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pengguna ditambahkan')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.arrow_back, color: Colors.black),
        title: const Text('Tambah Pengguna', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                onChanged: (value) => _nama = value,
                decoration: const InputDecoration(labelText: 'Nama', hintText: 'Masukkan Nama'),
                validator: (value) => value!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                onChanged: (value) => _email = value,
                decoration: const InputDecoration(labelText: 'Email', hintText: 'Masukkan Email'),
                validator: (value) => value!.isEmpty ? 'Email tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                onChanged: (value) => _kataSandi = value,
                decoration: const InputDecoration(labelText: 'Kata Sandi', hintText: 'Masukkan Kata Sandi'),
                obscureText: true,
                validator: (value) => value!.isEmpty ? 'Kata Sandi tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(labelText: 'Role'),
                items: _roles.map((role) => DropdownMenuItem(value: role, child: Text(role))).toList(),
                onChanged: (value) => setState(() => _role = value!),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveUser,
                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF3F51B5),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.layers), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }
}