import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/user_services.dart';

class UpdateUserScreen extends StatefulWidget {
  final AppUser user;

  const UpdateUserScreen({super.key, required this.user});

  @override
  State<UpdateUserScreen> createState() => _UpdateUserScreenState();
}

class _UpdateUserScreenState extends State<UpdateUserScreen> {
  final UserService _userService = UserService();
  final _formKey = GlobalKey<FormState>();
  late String _nama;
  late String _email;
  late String _kataSandi;
  late String _role;

  final List<String> _roles = ['Admin', 'Petugas', 'Siswa', 'Peminjam'];

  @override
  void initState() {
    super.initState();
    _nama = widget.user.nama;
    _email = widget.user.email;
    _kataSandi = widget.user.katasandi;
    _role = widget.user.role;
  }

  void _updateUser() async {
    if (_formKey.currentState!.validate()) {
      final updatedUser = AppUser(
        id: widget.user.id,
        nama: _nama,
        email: _email,
        katasandi: _kataSandi,
        role: _role,
      );
      await _userService.updateUser(widget.user.id, updatedUser);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pengguna diperbarui')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.arrow_back, color: Colors.black),
        title: const Text('Perbarui Pengguna', style: TextStyle(color: Colors.black)),
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
                initialValue: _nama,
                onChanged: (value) => _nama = value,
                decoration: const InputDecoration(labelText: 'Nama'),
                validator: (value) => value!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _email,
                onChanged: (value) => _email = value,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Email tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _kataSandi,
                onChanged: (value) => _kataSandi = value,
                decoration: const InputDecoration(labelText: 'Kata Sandi'),
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
                  onPressed: _updateUser,
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