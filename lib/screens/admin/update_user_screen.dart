import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/user_services.dart';
import '../../widgets/admin_bottom_navbar.dart';

class UpdateUserScreen extends StatefulWidget {
  final AppUser user;
  const UpdateUserScreen({super.key, required this.user});

  @override
  State<UpdateUserScreen> createState() => _UpdateUserScreenState();
}

class _UpdateUserScreenState extends State<UpdateUserScreen> {
  final UserService _service = UserService();

  late String nama;
  late String email;
  late String role;

  final roles = ['Admin', 'Petugas', 'Siswa'];

  @override
  void initState() {
    super.initState();
    nama = widget.user.nama;
    email = widget.user.email;
    role = widget.user.role;
  }

  InputDecoration _input() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  Future<void> _update() async {
    await _service.updateUser(
      widget.user.id,
      AppUser(
        id: widget.user.id,
        nama: nama,
        email: email,
        role: role,
      ),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Perbarui Pengguna'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF2F345D),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextFormField(
              initialValue: nama,
              decoration: _input(),
              onChanged: (v) => nama = v,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: email,
              decoration: _input(),
              onChanged: (v) => email = v,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField(
              value: role,
              decoration: _input(),
              items: roles
                  .map((e) =>
                      DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => role = v!,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _update,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F345D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Simpan'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          AdminBottomNavbar(currentIndex: 1, onTap: (_) {}),
    );
  }
}
