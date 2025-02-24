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

    final hashedPassword = sha256.convert(utf8.encode(password)).toString();


    //insertar en tabla usuarios_app
    await supabase.from('usuarios_app').insert({
      'nombre': name,
      'email': email,
      'password': hashedPassword,
    });

    //obtener datos de usuario 
    final usuario = await supabase
        .from('usuarios_app')
        .select('*')
        .eq('email', email) // Filtrar por email
        .maybeSingle(); // Devuelve null si no encuentra un usuario

    if (usuario != null){
    
        //guardar datos en preferences
        final prefs = await SharedPreferences.getInstance();

        final userJson = jsonEncode({
           'id': usuario['id'] ?? '',
           'email': usuario['email'] ?? '',
           'name': usuario['nombre'] ?? '', 
         });

        print(userJson);

    await prefs.setString('user', userJson);

    return {'success': true, 'message': 'Registro exitoso'};

    }

    return {'success': false, 'message': 'Error inesperado'};

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

    final user = await supabase
        .from('usuarios_app')
        .select('*')
        .eq('email', cleanEmail) // Filtrar por email
        .maybeSingle(); // Devuelve null si no encuentra un usuario

    if (user == null) {
      return {'success': false, 'error': 'No se pudo iniciar sesión'};
    }else{

      final prefs = await SharedPreferences.getInstance();

      final userJson = jsonEncode({     
        'id': user['id'] ?? '',
        'email': user['email'] ?? '',
        'name': user['nombre'] ?? '', 
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

  Future<int?> getUserId() async {
    try {

      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');

      if (userJson != null) {
        final Map<String, dynamic> user = jsonDecode(userJson);

        int id = user['id'];
        return id;

      }
      return null;

    } catch (e) {
      print('Error al obtener el ID: $e');
      return null;
    }
  }

}
