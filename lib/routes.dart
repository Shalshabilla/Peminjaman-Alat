// routes.dart

import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/admin/dashboard_admin_screen.dart';
import 'screens/admin/data_master_screen.dart'; // pastikan file & class ini ada
import 'screens/admin/transaksi_screen.dart'; // pastikan ada
import 'screens/admin/log_aktifitas_screen.dart'; // pastikan ada
import 'screens/admin/profil_admin_screen.dart';
import 'screens/admin/read_peminjaman_screen.dart';
import 'screens/admin/read_pengembalian_screen.dart'; // pastikan ada

final Map<String, WidgetBuilder> routes = {
  '/': (context) => const SplashScreen(),
  '/login': (context) => const LoginScreen(),

  // Admin routes (gunakan prefix /admin/ agar terorganisir)
  '/admin': (context) => const DashboardAdminScreen(), // ini dashboard utama
  '/admin/dashboard': (context) => const DashboardAdminScreen(),
  '/admin/data-master': (context) => const DataMasterScreen(),
  '/admin/transaksi': (context) => const TransaksiAdminScreen(),
  '/admin/log-aktifitas': (context) => const LogAktifitasScreen(),
  '/admin/profil': (context) => const ProfilAdminScreen(),
  '/admin/peminjaman': (context) => const PeminjamanListScreen(),
  '/admin/pengembalian': (context) => const PengembalianListScreen(),
};
