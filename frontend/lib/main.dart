import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/task_provider.dart';
import 'screens/login_screen.dart';
import 'screens/tasks_screen.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize API service
  await ApiService().init();

  runApp(const TaskManagementApp());
}

class TaskManagementApp extends StatelessWidget {
  const TaskManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: MaterialApp(
        title: 'Task Management',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366F1), // Indigo 500
            primary: const Color(0xFF4F46E5), // Indigo 600
            secondary: const Color(0xFFEC4899), // Pink 500
            background: const Color(0xFFF3F4F6), // Gray 100
            surface: Colors.white,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF3F4F6),
          textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme)
              .apply(
                bodyColor: const Color(0xFF1F2937), // Gray 800
                displayColor: const Color(0xFF111827), // Gray 900
              ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1F2937),
            elevation: 0,
            centerTitle: false,
            scrolledUnderElevation: 0,
            titleTextStyle: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
              letterSpacing: -0.5,
            ),
            iconTheme: const IconThemeData(color: Color(0xFF4B5563)),
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            margin: EdgeInsets.zero,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF4F46E5),
              textStyle: const TextStyle(fontWeight: FontWeight.w600),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
            labelStyle: TextStyle(color: Colors.grey.shade600),
            hintStyle: TextStyle(color: Colors.grey.shade400),
            floatingLabelBehavior: FloatingLabelBehavior.always,
          ),
          dialogTheme: DialogThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Colors.white,
            elevation: 8,
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

/// Wrapper widget that handles authentication state
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Initialize auth state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Show loading while initializing
    if (!authProvider.isInitialized) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading...'),
            ],
          ),
        ),
      );
    }

    // Navigate based on auth state
    return authProvider.isAuthenticated
        ? const TasksScreen()
        : const LoginScreen();
  }
}
