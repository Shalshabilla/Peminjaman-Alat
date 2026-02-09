import 'package:flutter/material.dart';
import '../../services/user_services.dart';
import '../../widgets/admin_bottom_navbar.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserService _service = UserService();

  String nama = '';
  String email = '';
  String password = '';
  String role = '';

  final roles = ['Admin', 'Petugas', 'Peminjam'];

  InputDecoration _input(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      );

Future<void> _save() async {
  if (!_formKey.currentState!.validate()) return;

  try {
    await _service.createUser(
  nama: nama,
  email: email,
  password: password,
  role: role,
);


    Navigator.pop(context, true);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal menambahkan user: $e')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Tambah Pengguna'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF2F345D),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: _input('Masukkan Nama'),
                onChanged: (v) => nama = v,
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: _input('Masukkan Email'),
                onChanged: (v) => email = v,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: _input('Masukkan Kata Sandi'),
                obscureText: true,
                onChanged: (v) => password = v,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField(
                decoration: _input('Masukkan Role'),
                items: roles
                    .map((e) =>
                        DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => role = v!,
                validator: (v) => v == null ? 'Pilih role' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F345D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Simpan',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar:
          AdminBottomNavbar(currentIndex: 1, onTap: (_) {}),
    );
  }
}
