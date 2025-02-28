import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_register_app.dart';
import 'values/app_routes.dart';
import 'screens/navigation/bottom_navigation_page.dart'; // Ruta para Bottom Navigation

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Inicializa Supabase
    await Supabase.initialize(
      url: const String.fromEnvironment('SUPABASE_URL', 
          defaultValue: 'https://nlkvnsbtrlcwwjznxhcl.supabase.co'),
      anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY',
          defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5sa3Zuc2J0cmxjd3dqem54aGNsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzk0MjMyNzEsImV4cCI6MjA1NDk5OTI3MX0.EHvnCp7c4xpEWIiMOsTlA29UBG3AdhyALuJhj_Bg93E'),
    );

    // Establece el estilo del sistema (por ejemplo, la barra de estado)
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
      ),
    );

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    runApp(const LoginRegisterApp());
  } catch (error) {
    print('Error during initialization: $error');
  }
}
