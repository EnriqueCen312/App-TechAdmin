import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController {
  
  Future<AuthResponse> signIn(String email, String password) async {
    final supabase = Supabase.instance.client;

    final AuthResponse response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    return response;
  }

  Future<AuthResponse> signUp(String name, String email, String password) async {
    final supabase = Supabase.instance.client;

    final AuthResponse response = await supabase.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );

    return response;
  }
}

