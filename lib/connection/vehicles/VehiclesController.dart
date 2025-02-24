import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:login_register_app/connection/auth/AuthController.dart';

class VehiclesController {
  final supabase = Supabase.instance.client;
  final AuthController _authController = AuthController();

  Future<int> getUserId() async {
    final userId = await _authController.getUserId();
    if (userId == null) {
      throw Exception('User ID not found');
    }
    return userId;
  }

  Future<List<Map<String, dynamic>>> fetchVehicles() async {
    try {
      final userId = await getUserId();
      
      final response = await supabase
          .from('vehiculos')
          .select()
          .eq('usuario_app_id', userId);
      
      print('Vehículos obtenidos para usuario $userId: ${response.length}');
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      print('Error al obtener los vehículos: $error');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> registerVehicle(Map<String, dynamic> vehicle) async {
    try {
      final userId = await getUserId();
      
      // Asignar el ID del usuario al vehículo
      vehicle['usuario_app_id'] = userId;
      
      print('Registrando vehículo para usuario $userId: $vehicle');

      final response = await supabase
          .from('vehiculos')
          .insert(vehicle)
          .select()
          .single();
      
      print('Vehículo registrado exitosamente: $response');
      return response;
    } catch (error) {
      print('Error al registrar el vehículo: $error');
      throw Exception('No se pudo registrar el vehículo: $error');
    }
  }

  Future<void> deleteVehicle(int vehicleId) async {
    try {
      final userId = await getUserId();
      
      print('Eliminando vehículo $vehicleId del usuario $userId');

      final response = await supabase
          .from('vehiculos')
          .delete()
          .match({
            'id': vehicleId,
            'usuario_app_id': userId // Verificación adicional de seguridad
          });
      
      if (response.error != null) {
        throw Exception(response.error!.message);
      }
      
      print('Vehículo eliminado exitosamente');
    } catch (error) {
      print('Error al eliminar el vehículo: $error');
      throw Exception('No se pudo eliminar el vehículo: $error');
    }
  }

  Future<Map<String, dynamic>> editVehicle(int vehicleId, Map<String, dynamic> updatedVehicle) async {
    try {
      final userId = await getUserId();
      
      // Asegurarse de que no se pueda modificar el usuario_app_id
      updatedVehicle.remove('usuario_app_id');
      
      print('Actualizando vehículo $vehicleId del usuario $userId');

      final response = await supabase
          .from('vehiculos')
          .update(updatedVehicle)
          .match({
            'id': vehicleId,
            'usuario_app_id': userId // Verificación adicional de seguridad
          })
          .select()
          .single();
      
      print('Vehículo actualizado exitosamente: $response');
      return response;
    } catch (error) {
      print('Error al actualizar el vehículo: $error');
      throw Exception('No se pudo actualizar el vehículo: $error');
    }
  }

  Future<Map<String, dynamic>?> getVehicleById(int vehicleId) async {
    try {
      final userId = await getUserId();
      
      final response = await supabase
          .from('vehiculos')
          .select()
          .match({
            'id': vehicleId,
            'usuario_app_id': userId
          })
          .single();
      
      return response;
    } catch (error) {
      print('Error al obtener el vehículo: $error');
      return null;
    }
  }
}