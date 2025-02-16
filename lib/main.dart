import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_register_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
  );

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
    (_) => runApp(const LoginRegisterApp()),
  );

  await Supabase.initialize(
    url: 'https://nlkvnsbtrlcwwjznxhcl.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5sa3Zuc2J0cmxjd3dqem54aGNsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzk0MjMyNzEsImV4cCI6MjA1NDk5OTI3MX0.EHvnCp7c4xpEWIiMOsTlA29UBG3AdhyALuJhj_Bg93E',
  );

}
