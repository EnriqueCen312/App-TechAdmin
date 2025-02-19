import '../../utils/helpers/snackbar_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AuthController {
  final supabase = Supabase.instance.client;


Future<Map<String, dynamic>> signUp(String name, String email, String password) async {
  try {
    final AuthResponse response = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    String? userId = response.user?.id;

    if (userId == null) {
      final userData = await supabase
          .from('auth.users')
          .select('id')
          .eq('email', email)
          .maybeSingle();

      if (userData != null) {
        userId = userData['id'];
      }
    }

    if (userId != null) {
      final hashedPassword = sha256.convert(utf8.encode(password)).toString();

      await supabase.from('usuarios_app').insert({
        'user_id': userId,
        'nombre': name,
        'email': email,
        'password': hashedPassword,
      });

      return {'success': true, 'message': 'Registro exitoso'};
    }

    return {'success': false, 'error': 'No se pudo registrar el usuario'};
  } catch (e) {
    return {'success': false, 'error': e.toString()};
  }
}

Future<Map<String, dynamic>> signIn(String email, String password) async {
  try {
    final String cleanEmail = email.trim().toLowerCase();

    final userData = await supabase
        .from('usuarios_app')
        .select()
        .eq('email', cleanEmail)
        .maybeSingle();

    if (userData == null) {
      return {'success': false, 'error': 'Usuario no registrado en la aplicación'};
    }

    final AuthResponse response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      return {'success': false, 'error': 'No se pudo iniciar sesión'};
    }

    return {'success': true, 'user': response.user}; // Login exitoso

  } on AuthException catch (e) {
    return {'success': false, 'error': e.message}; // Error de credenciales incorrectas
  } catch (e) {
    return {'success': false, 'error': e.toString()};
  }
}
}

