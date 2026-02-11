import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/colors.dart';

class LoginGoogleScreen extends StatelessWidget {
  const LoginGoogleScreen({super.key});

  Future<void> _handleGoogleLogin(BuildContext context) async {
    try {
      // 1️⃣ Login via Google
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutter://login-callback',
      );

      // 2️⃣ Tunggu user login dan dapat session
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final email = user.email;
      if (email == null) return;

      // 3️⃣ Ambil role dari tabel users
      final data = await Supabase.instance.client
          .from('users')
          .select('role')
          .eq('email', email)
          .maybeSingle();

      if (!context.mounted) return;

      // 4️⃣ Redirect sesuai role
      if (data == null) {
        Navigator.pushReplacementNamed(context, '/lengkapi-profil');
      } else {
        switch (data['role']) {
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
            Navigator.pushReplacementNamed(context, '/lengkapi-profil');
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login gagal: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/logo.svg', width: 120),
              const SizedBox(height: 16),
              const Text(
                'SchoolLend',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Masuk menggunakan akun Google Anda',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => _handleGoogleLogin(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/google.png', width: 22, height: 22),
                      const SizedBox(width: 12),
                      const Text(
                        'Masuk dengan Google',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Kembali ke Login Email',
                    style: TextStyle(color: AppColors.primary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
