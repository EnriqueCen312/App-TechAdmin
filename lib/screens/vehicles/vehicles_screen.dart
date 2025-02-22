import 'package:flutter/material.dart';
import 'add_vehicle_screen.dart';

class VehicleScreen extends StatelessWidget {
  const VehicleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool hasVehicles = false; // Simula que no hay vehículos registrados

    return Scaffold(
      appBar: AppBar(
        title: const Text("Vehículos"),
      ),
      body: Center(
        child: hasVehicles
            ? const Text("Tienes vehículos registrados.")
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("No tienes vehículos registrados."),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddVehicleScreen(),
                        ),
                      );
                    },
                    child: const Text("Agregar vehículo"),
                  ),
                ],
              ),
      ),
    );
  }
}
