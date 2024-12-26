import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';
import 'splash_screen.dart';
import 'page/dashboard_page.dart';
import 'page/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Row Level Security btw
  await Supabase.initialize(
    url: 'https://ywuapxenhjsvitjyyvts.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl3dWFweGVuaGpzdml0anl5dnRzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzUxNDA3NTksImV4cCI6MjA1MDcxNjc1OX0.skFfMY_BJ5klcPKvL9xCaywqKpFnoctkTwFi6Yzqhno',
    authCallbackUrlHostname: 'login-callback',
    debug: false,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const SplashScreenWrapper(),
    );
  }
}

class SplashScreenWrapper extends StatefulWidget {
  const SplashScreenWrapper({super.key});

  @override
  State<SplashScreenWrapper> createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  @override
  void initState() {
    super.initState();
    _navigateToAuth();
  }

  _navigateToAuth() async {
    await Future.delayed(const Duration(seconds: 3)); // Adjust duration as needed
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthWrapper()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}

class AuthWrapper extends StatelessWidget {
  final _authService = AuthService();

  AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return _authService.isAuthenticated ? const DashboardPage() : const LoginPage();
  }
}