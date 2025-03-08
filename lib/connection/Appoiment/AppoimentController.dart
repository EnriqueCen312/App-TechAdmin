import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AppointmentsController {
  final SupabaseClient supabase = Supabase.instance.client;

  // Get auth ID for the current authenticated user
  Future<int?> _getAuthId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      
      if (userJson != null) {
        final Map<String, dynamic> user = jsonDecode(userJson);
        int authId = user['id'];
        return authId;
      }
      
      return null;
    } catch (e) {
      print('Error obteniendo auth_id: $e');
      return null;
    }
  }

  // Fetch appointments for the authenticated user
  Future<List<Map<String, dynamic>>> fetchAppointments() async {
    try {
      final authId = await _getAuthId();
      
      if (authId == null) {
        throw Exception('No se encontró usuario autenticado');
      }
      
      // Query the citas table with join to vehiculos to get vehicle info
      final response = await supabase
          .from('citas')
          .select('''
            id, 
            fecha, 
            hora, 
            estado, 
            descripcion,
            vehiculos:automovil_id (
              id, 
              marca, 
              modelo, 
              placa
            ),
            talleres:taller_id (
              nombre
            )
          ''')
          .eq('auth_id', authId)
          .order('fecha', ascending: true);
      
      // Format the response for use in the UI
      final List<Map<String, dynamic>> formattedResponse = [];
      
      for (final item in response) {
        final vehicleInfo = item['vehiculos'] as Map<String, dynamic>;
        final tallerInfo = item['talleres'] as Map<String, dynamic>;
        
        formattedResponse.add({
          'id': item['id'],
          'fecha': item['fecha'],
          'hora': item['hora'],
          'estado': item['estado'] ?? 'pendiente',
          'descripcion': item['descripcion'] ?? 'Sin descripción',
          'vehiculo': '${vehicleInfo['marca']} ${vehicleInfo['modelo']} - ${vehicleInfo['placa']}',
          'taller': tallerInfo['nombre'],
          'automovil_id': vehicleInfo['id'],
        });
      }
      
      return formattedResponse;
    } catch (e) {
      print('Error al obtener las citas: $e');
      throw Exception('Error al obtener las citas: $e');
    }
  }
  
  // Update appointment status
  Future<void> updateAppointmentStatus(int appointmentId, String status) async {
    try {
      final response = await supabase
          .from('citas')
          .update({'estado': status, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', appointmentId);
      
      // The trigger will automatically move the appointment to history when status is "finalizada"
      
    } catch (e) {
      print('Error al actualizar el estado de la cita: $e');
      throw Exception('Error al actualizar el estado de la cita: $e');
    }
  }
  
  // Create a new appointment
  
  
  // Get all vehicles for the user (to use when creating a new appointment)
  Future<List<Map<String, dynamic>>> getUserVehicles() async {
    try {
      final authId = await _getAuthId();
      
      if (authId == null) {
        throw Exception('No se encontró usuario autenticado');
      }
      
      final response = await supabase
          .from('vehiculos')
          .select('id, marca, modelo, placa')
          .eq('auth_id', authId);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error al obtener los vehículos: $e');
      throw Exception('Error al obtener los vehículos: $e');
    }
  }
  
  // Get available workshops (talleres)
  Future<List<Map<String, dynamic>>> getWorkshops() async {
    try {
      final response = await supabase
          .from('talleres')
          .select('id, nombre, direccion');
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error al obtener los talleres: $e');
      throw Exception('Error al obtener los talleres: $e');
    }
  }
}