import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'routes.dart';
import 'auth_wrapper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SchooLend',
      theme: ThemeData(
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D47A1)),
      ),
      // JANGAN pakai home: kalau sudah pakai initialRoute + routes punya '/'
      initialRoute: '/', // mulai dari route '/' yang ada di routes.dart
      routes: routes, // routes.dart sudah punya '/' → SplashScreen
      onGenerateInitialRoutes: (initialRoute) {
        // Opsional: bisa ditambahkan kalau mau custom behavior saat start
        return [
          MaterialPageRoute(
            builder: (context) => routes[initialRoute]!(context),
          ),
        ];
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder:
              (context) => Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.route_outlined,
                        size: 80,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Route tidak ditemukan:\n${settings.name}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed:
                            () => Navigator.pushReplacementNamed(context, '/'),
                        child: const Text('Kembali ke Beranda'),
                      ),
                    ],
                  ),
                ),
              ),
        );
      },
    );
  }
}
