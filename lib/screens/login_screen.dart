import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/colors.dart';
import '../widgets/textfield.dart';
import '  services/auth_services.dart';



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

Future<void> handleLogin() async {
  setState(() {
    emailError = null;
    passError = null;
    isError = false;
    isSuccess = false;
  });

  if (!_formKey.currentState!.validate()) return;

  setState(() => isLoading = true);

  try {
    /// 1️⃣ CEK EMAIL DI TABEL USERS
    final userData = await supabase
        .from('users')
        .select('id, role')
        .eq('email', emailC.text)
        .maybeSingle();

    /// ❌ EMAIL TIDAK TERDAFTAR
    if (userData == null) {
      setState(() {
        emailError = 'Email tidak terdaftar';
        isError = true;
      });

      _formKey.currentState!.validate();
      return;
    }

    /// 2️⃣ LOGIN AUTH
    final authResponse = await supabase.auth.signInWithPassword(
      email: emailC.text,
      password: passC.text,
    );

    /// 🟢 LOGIN BERHASIL
    setState(() {
      isSuccess = true;
    });

    final role = userData['role'];

    if (!mounted) return;

    /// 3️⃣ ARAHKAN SESUAI ROLE
    Future.delayed(const Duration(milliseconds: 800), () {
      switch (role) {
        case 'admin':
          Navigator.pushReplacementNamed(context, '/admin');
          break;
        case 'petugas':
          Navigator.pushReplacementNamed(context, '/petugas');
          break;
        default:
          Navigator.pushReplacementNamed(context, '/peminjam');
      }
    });

  } on AuthException {
    /// ❌ PASSWORD SALAH
    setState(() {
      passError = 'Kata sandi salah';
      isError = true;
    });

    _formKey.currentState!.validate();

  } finally {
    setState(() => isLoading = false);
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
          mainAxisSize: MainAxisSize.min, // 🔑 PENTING
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
                  isObscure
                      ? Icons.visibility_off
                      : Icons.visibility,
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
