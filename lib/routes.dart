import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/admin/dashboard_admin_screen.dart';


final Map<String, WidgetBuilder> routes = {
  '/': (context) => const SplashScreen(),
  '/login': (context) => const LoginScreen(),
  '/admin': (context) => const DashboardAdminScreen(),
  //'/petugas': (context) => const DashboardPetugas(),
  //'/peminjam': (context) => const DashboardPeminjam(),
};
