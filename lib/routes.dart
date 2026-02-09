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
import 'screens/petugas/cetak_laporan.dart';
import 'screens/petugas/profil_petugas_screen.dart';

// Peminjam
import 'screens/peminjam/dashboard_peminjam_screen.dart';
import 'screens/peminjam/daftar_alat_peminjam_screen.dart';
import 'screens/peminjam/peminjaman_pengembalian_screen.dart';
import 'screens/peminjam/profil_peminjam_screen.dart';

final Map<String, WidgetBuilder> routes = {
  // ──────────────────────────────────────────────
  // ENTRY POINT APLIKASI
  // ──────────────────────────────────────────────
  '/': (context) => const SplashScreen(),           // splash → biasanya cek auth atau langsung ke login
  '/login': (context) => const LoginScreen(),

  // ──────────────────────────────────────────────
  // ADMIN ROUTES (sudah lengkap dari sebelumnya)
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
  '/petugas/profil': (context) => const ProfilPetugasScreen(),
  //'/petugas/pengajuan': (context) => const PeminjamanPetugasScreen(),     // pengajuan / daftar peminjaman baru
  //'/petugas/cetak': (context) => const CetakLaporanScreen(),              // cetak laporan
  //'/petugas/laporan': (context) => const CetakLaporanScreen(),            // jika beda screen, ganti nama class
  //'/petugas/pengembalian': (context) => const PengembalianPetugasScreen(),// pengembalian hari ini / proses

  // ──────────────────────────────────────────────
  // PEMINJAM / SISWA ROUTES
  // ──────────────────────────────────────────────
  '/peminjam/dashboard': (context) => const DashboardPeminjamScreen(),
  '/peminjam/profil': (context) => const ProfilPeminjamScreen(),

  // Route yang dipakai di PeminjamBottomNavbar → wajib diaktifkan
  //'/peminjam/pengajuan': (context) => const DaftarAlatScreen(),           // halaman ajukan peminjaman / pilih alat
  //'/peminjam/riwayat': (context) => const PeminjamanPengembalianScreen(), // riwayat peminjaman & pengembalian
  //'/peminjam/alat': (context) => const DaftarAlatScreen(),                // jika ada menu daftar alat terpisah

};