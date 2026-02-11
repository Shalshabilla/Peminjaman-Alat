import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';

// Admin
import 'screens/admin/dashboard_admin_screen.dart';
import 'screens/admin/data_master_screen.dart';
import 'screens/admin/transaksi_screen.dart';
import 'screens/admin/log_aktifitas_screen.dart';
import 'screens/admin/profil_admin_screen.dart';
import 'screens/admin/read_peminjaman_screen.dart';
import 'screens/admin/read_pengembalian_screen.dart';

// Petugas
import 'screens/petugas/dashboard_petugas_screen.dart';
import 'screens/petugas/peminjaman_petugas_screen.dart';
import 'screens/petugas/pengembalian_petugas_screen.dart';
import 'screens/petugas/laporan_petugas_screen.dart';
import 'screens/petugas/profil_petugas_screen.dart';

// Peminjam
import 'screens/peminjam/peminjam_main_screen.dart';
import 'screens/peminjam/dashboard_peminjam_screen.dart';
import 'screens/peminjam/daftar_alat_peminjam_screen.dart';
import 'screens/peminjam/peminjaman_pengembalian_screen.dart';
import 'screens/peminjam/form_peminjaman_screen.dart';
import 'screens/peminjam/profil_peminjam_screen.dart';

final Map<String, WidgetBuilder> routes = {
  '/': (context) => const SplashScreen(),           
  '/login': (context) => const LoginScreen(),

  // ──────────────────────────────────────────────
  // ADMIN ROUTES 
  // ──────────────────────────────────────────────
  '/admin': (context) => const DashboardAdminScreen(),
  '/admin/dashboard': (context) => const DashboardAdminScreen(),
  '/admin/data-master': (context) => const DataMasterScreen(),
  '/admin/transaksi': (context) => const TransaksiAdminScreen(),
  '/admin/log-aktifitas': (context) => const LogAktifitasScreen(),
  '/admin/profil': (context) => const ProfilAdminScreen(),
  '/admin/peminjaman': (context) => const PeminjamanListScreen(),
  '/admin/pengembalian': (context) => const PengembalianListScreen(),

  // ──────────────────────────────────────────────
  // PETUGAS ROUTES
  // ──────────────────────────────────────────────
  '/petugas/dashboard': (context) => const DashboardPetugasScreen(),
  '/petugas/peminjaman': (context) => const PeminjamanPetugasScreen(),
  //'/petugas/pengembalian': (context) => const PengembalianPetugasScreen(),
  //'/petugas/cetak-laporan': (context) => const CetakLaporanScreen(),
  '/petugas/profil': (context) => const ProfilPetugasScreen(),

  // ──────────────────────────────────────────────
  // PEMINJAM / SISWA ROUTES
  // ──────────────────────────────────────────────
  '/peminjam': (context) => const PeminjamMainScreen(),
  '/peminjam/dashboard': (context) => const DashboardPeminjamScreen(),
  '/peminjam/alat': (context) => const DaftarAlatPeminjamScreen(),
  '/peminjam/form-peminjaman': (context) => const FormPeminjamanScreen(),
  '/peminjam/peminjaman': (context) => const PeminjamanPeminjamScreen(),
  '/peminjam/profil': (context) => const ProfilPeminjamScreen(),

//lengkapi-profil': (context) => const LengkapiProfilScreen(),

};