import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_google_screen.dart';
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
  final authService = AuthService();

  @override
  void dispose() {
    emailC.dispose();
    passC.dispose();
    super.dispose();
  }

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

      setState(() => isSuccess = true);
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;

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
          Navigator.pushReplacementNamed(context, '/');
      }
    } on AuthException catch (e) {
      setState(() {
        passError = e.message;
        isError = true;
      });
    } finally {
      if (mounted) setState(() => isLoading = false);
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
                      SvgPicture.asset('assets/logo.svg', width: 120),
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
                      CustomTextField(
                        hint: 'Email',
                        icon: Icons.email_outlined,
                        controller: emailC,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Email wajib diisi';
                          if (!v.contains('@')) return 'Format email tidak valid';
                          return emailError;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        hint: 'Kata Sandi',
                        icon: Icons.lock_outline,
                        controller: passC,
                        obscure: isObscure,
                        suffixIcon: IconButton(
                          icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              isObscure = !isObscure;
                            });
                          },
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Kata sandi wajib diisi';
                          return passError;
                        },
                      ),
                      const SizedBox(height: 28),
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
                                  color: Colors.white, strokeWidth: 2)
                              : const Text(
                                  'Masuk',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // ===== GOOGLE LOGIN BUTTON =====
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: isLoading
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const LoginGoogleScreen()),
                                  );
                                },
                          icon: const Icon(Icons.g_mobiledata, size: 28),
                          label: const Text(
                            'Masuk dengan Google',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
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
          if (isError)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: AppColors.danger,
                padding: const EdgeInsets.all(12),
                child: const Text('Login gagal', style: TextStyle(color: Colors.white)),
              ),
            ),
          if (isSuccess)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: AppColors.success,
                padding: const EdgeInsets.all(12),
                child: const Text('Login berhasil', style: TextStyle(color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }
}
