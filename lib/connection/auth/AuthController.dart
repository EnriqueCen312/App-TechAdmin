import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../screens/login_screen.dart';
import 'package:flutter/material.dart';

class AuthController {

final supabase = Supabase.instance.client;


Future<Map<String, dynamic>> signUp(String name, String email, String password) async {
  try {

    //guardar en auth.users
    final AuthResponse response = await supabase.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );

    //obtener id asignado
    String? userId = response.user?.id;

    final hashedPassword = sha256.convert(utf8.encode(password)).toString();

    final user = response.user;

    //insertar en tabla usuarios_app
    await supabase.from('usuarios_app').insert({
      'user_id': userId,
      'nombre': name,
      'email': email,
      'password': hashedPassword,
    });

    //guardar datos en preferences
    final prefs = await SharedPreferences.getInstance();

    final userJson = jsonEncode({
      'id': user?.id ?? '',
      'email': user?.email ?? '',
      'name': user?.userMetadata?['name'] ?? 'Usuario', //Asignar 'Usuario' en caso de null
    });

    await prefs.setString('user', userJson);

    return {'success': true, 'message': 'Registro exitoso'};

  } catch (e) {
      String errorMessage = e.toString();

      if (errorMessage.contains("User already registered")) {
        return {'success': false, 'error': 'El correo ya está en uso'};
      }
      return {'success': false, 'error': errorMessage};    
  }
}

Future<Map<String, dynamic>> signIn(String email, String password) async {
  try {
    final String cleanEmail = email.trim().toLowerCase();

    //buscar email en la base
    final userData = await supabase
        .from('usuarios_app')
        .select()
        .eq('email', cleanEmail)
        .maybeSingle();

    if (userData == null) {
      return {'success': false, 'error': 'Usuario no registrado en la aplicación'};
    }

    //verificar datos en auth.users
    final AuthResponse response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user;

    if (user == null) {
      return {'success': false, 'error': 'No se pudo iniciar sesión'};
    }else{

      final prefs = await SharedPreferences.getInstance();

      final userJson = jsonEncode({
      'id': user.id,
      'email': user.email,
      'name': user.userMetadata?['name'] ?? 'Usuario',
      });

      await prefs.setString('user', userJson);
    
      return {'success': true, 'message': 'Inicio de sesión exitoso'}; // Login exitoso
    }

  } on AuthException catch (e) {
    return {'success': false, 'error': e.message}; // Error de credenciales incorrectas
  } catch (e) {
    return {'success': false, 'error': e.toString()};
  }
}

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()), // Redirige a la pantalla de login
      (Route<dynamic> route) => false, // Elimina todas las pantallas anteriores
    );
  }

}