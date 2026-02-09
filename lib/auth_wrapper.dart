import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/login_screen.dart';
import '../screens/admin/dashboard_admin_screen.dart';
import '../screens/petugas/dashboard_petugas_screen.dart';
import '../screens/peminjam/dashboard_peminjam_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _redirectBasedOnAuth();
  }

  Future<void> _redirectBasedOnAuth() async {
  final supabase = Supabase.instance.client;
  final session = supabase.auth.currentSession;

  if (session == null) {
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
    return;
  }

  try {
    // Ambil role dari JWT metadata (userMetadata)
    final jwtRole = session.user.userMetadata?['role'] as String?;
    final role = (jwtRole ?? 'peminjam').trim().toLowerCase();

    print('Role dari JWT metadata: $role'); // debug biar tahu

    if (!mounted) return;

    switch (role) {
      case 'admin':
        Navigator.pushReplacementNamed(context, '/admin/dashboard');
        break;
      case 'petugas':
        Navigator.pushReplacementNamed(context, '/petugas/dashboard');
        break;
      default:
        Navigator.pushReplacementNamed(context, '/peminjam/dashboard');
        break;
    }
  } catch (e) {
    debugPrint('AuthWrapper error: $e');
    await supabase.auth.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}