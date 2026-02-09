import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/colors.dart';
import '../widgets/textfield.dart';
import '../services/auth_services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailC = TextEditingController();
  final passC = TextEditingController();

  bool isObscure = true;
  bool isLoading = false;

  bool isError = false;
  bool isSuccess = false;

  String? emailError;
  String? passError;

  final supabase = Supabase.instance.client;

  @override
  void dispose() {
    emailC.dispose();
    passC.dispose();
    super.dispose();
  }

  final authService = AuthService();

 Future<void> handleLogin() async {
  setState(() {
    emailError = null;
    passError = null;
    isError = false;
    isSuccess = false;
    isLoading = true;
  });

  if (!_formKey.currentState!.validate()) {
    setState(() => isLoading = false);
    return;
  }

  try {
    final role = await authService.login(
      emailC.text.trim(),
      passC.text,
    );

    debugPrint('Login berhasil - Role: $role'); // <-- tambahkan ini untuk debug

    setState(() => isSuccess = true);

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    // Sinkronkan dengan AuthWrapper (gunakan 'peminjam' bukan 'siswa')
    switch (role.toLowerCase().trim()) {
  case 'admin':
    Navigator.pushReplacementNamed(context, '/admin/dashboard');
    break;
  case 'petugas':
    Navigator.pushReplacementNamed(context, '/petugas/dashboard');
    break;
  case 'peminjam':
    Navigator.pushReplacementNamed(context, '/peminjam/dashboard');
    break;
  default:
    debugPrint('Role tidak match: "$role"'); // <-- debug
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Role tidak dikenali: "$role"')),
    );
    Navigator.pushReplacementNamed(context, '/'); // kembali ke AuthWrapper
}
  } on AuthException catch (e) {
    debugPrint('AuthException: ${e.message}'); // <-- sangat penting untuk debug
    setState(() {
      if (e.message.contains('Invalid login credentials')) {
        passError = 'Email atau kata sandi salah';
      } else {
        passError = e.message;
      }
      isError = true;
    });
  } catch (e) {
    debugPrint('Login error lain: $e');
    setState(() {
      passError = 'Terjadi kesalahan: $e';
      isError = true;
    });
  } finally {
    if (mounted) {
      setState(() => isLoading = false);
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// LOGO
                      SvgPicture.asset(
                        'assets/logo.svg',
                        width: 120,
                      ),
                      const SizedBox(height: 12),

                      const Text(
                        'SchoolLend',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 32),

                      /// EMAIL
                      CustomTextField(
                        hint: 'Email',
                        icon: Icons.email_outlined,
                        controller: emailC,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Email wajib diisi';
                          }
                          if (!v.contains('@')) {
                            return 'Format email tidak valid';
                          }
                          return emailError;
                        },
                      ),
                      const SizedBox(height: 16),

                      /// PASSWORD
                      CustomTextField(
                        hint: 'Kata Sandi',
                        icon: Icons.lock_outline,
                        controller: passC,
                        obscure: isObscure,
                        suffixIcon: IconButton(
                          icon: Icon(
                            isObscure ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              isObscure = !isObscure;
                            });
                          },
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Kata sandi wajib diisi';
                          }
                          return passError;
                        },
                      ),
                      const SizedBox(height: 28),

                      /// BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                )
                              : const Text(
                                  'Masuk',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          /// 🔴 ERROR BADGE
          if (isError)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: AppColors.danger,
                padding: const EdgeInsets.all(12),
                child: const Text(
                  'Login gagal',
                  textAlign: TextAlign.left,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

          /// 🟢 SUCCESS BADGE
          if (isSuccess)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: AppColors.success,
                padding: const EdgeInsets.all(12),
                child: const Text(
                  'Login berhasil',
                  textAlign: TextAlign.left,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}