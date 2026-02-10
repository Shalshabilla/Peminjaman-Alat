import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  final _formKey = GlobalKey<FormState>();
  final UserService _service = UserService();

  late TextEditingController _namaController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  String? _selectedRole;

  final List<String> roles = ['admin', 'petugas', 'peminjam'];

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.user.nama);
    _emailController = TextEditingController(text: widget.user.email);
    _passwordController = TextEditingController();
    _selectedRole = widget.user.role;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nama', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2F345D))),
              const SizedBox(height: 8),
              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(
                  hintText: 'Nama',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF2F345D), width: 1.5),
                  ),
                ),
                validator: (v) => v!.trim().isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 24),

              const Text('Email', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2F345D))),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Email',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF2F345D), width: 1.5),
                  ),
                ),
                validator: (v) {
                  if (v!.trim().isEmpty) return 'Wajib diisi';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim())) {
                    return 'Email tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // =====================
              // PASSWORD BARU (OPSIONAL)
              // =====================
              const Text('Kata Sandi Baru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2F345D))),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Kosongkan jika tidak diubah',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF2F345D), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const Text('Role', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2F345D))),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF2F345D), width: 1.5),
                  ),
                ),
                items: roles.map((role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedRole = value),
                validator: (v) => v == null ? 'Pilih role' : null,
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;

                    try {
                      final updatedUser = AppUser(
                        id: widget.user.id,
                        nama: _namaController.text.trim(),
                        email: _emailController.text.trim(),
                        role: _selectedRole!,
                      );

                      await _service.updateUser(widget.user.id, updatedUser);

                      // =====================
                      // UPDATE PASSWORD JIKA DIISI
                      // =====================
                      if (_passwordController.text.isNotEmpty) {
                        final currentUser = Supabase.instance.client.auth.currentUser;

                        if (currentUser != null && currentUser.id == widget.user.id) {
                          await Supabase.instance.client.auth.updateUser(
                            UserAttributes(password: _passwordController.text),
                          );
                        }
                      }

                      Navigator.pop(context, true);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                                  content: Text('Pengguna berhasil diperbarui'),
                                  backgroundColor: Colors.green,
                        ),
                      );

                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal update: $e')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F345D),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text(
                    'Simpan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AdminBottomNavbar(currentIndex: 1, onTap: (_) {}),
    );
  }
}
