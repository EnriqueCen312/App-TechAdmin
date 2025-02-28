import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../connection/vehicles/VehiclesController.dart';

class VehicleScreen extends StatefulWidget {
  const VehicleScreen({Key? key}) : super(key: key);

  @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  final VehiclesController _vehicleController = VehiclesController();
  List<Map<String, dynamic>> vehicles = [];
  final List<String> vehicleTypes = ['carro', 'moto', 'camion'];

  late TextEditingController marcaController;
  late TextEditingController modeloController;
  late TextEditingController anioController;
  late TextEditingController colorController;
  late TextEditingController placaController;

  String selectedType = 'carro';

  @override
  void initState() {
    super.initState();
    marcaController = TextEditingController();
    modeloController = TextEditingController();
    anioController = TextEditingController();
    colorController = TextEditingController();
    placaController = TextEditingController();
    _loadVehicles();
  }

  // Modificado para manejar un String en lugar de int
  Future<void> _loadVehicles() async {
    try {
      final fetchedVehicles = await _vehicleController.fetchVehicles();
      setState(() {
        vehicles = fetchedVehicles;
      });
    } catch (e) {
      print('Error al cargar los vehículos: $e');
    }
  }

  void _clearForm() {
    marcaController.clear();
    modeloController.clear();
    anioController.clear();
    colorController.clear();
    placaController.clear();
    setState(() {
      selectedType = 'carro';
    });
  }

  Future<void> _addVehicle() async {
    final newVehicle = {
      'marca': marcaController.text,
      'modelo': modeloController.text,
      'anio': int.tryParse(anioController.text) ?? 0,
      'color': colorController.text,
      'placa': placaController.text,
      'tipo': selectedType,
    };

    await _vehicleController.registerVehicle(newVehicle);
    _clearForm();
    _loadVehicles(); // Recargar la lista de vehículos

    // Cerrar el BottomSheet y actualizar la UI
    Navigator.of(context).pop();
  }

  Future<void> _deleteVehicle(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: const Text('¿Estás seguro de que deseas eliminar este vehículo? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Cancelar
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Confirmar
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await _vehicleController.deleteVehicle(id);
        _loadVehicles(); // Recargar la lista de vehículos después de eliminar
      } catch (e) {
        print('Error al eliminar el vehículo: $e');
      }
    }
  }


  void _showAddVehicleBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Agregar Vehículo',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildTextField(marcaController, 'Marca'),
              _buildTextField(modeloController, 'Modelo'),
              _buildTextField(anioController, 'Año', keyboardType: TextInputType.number),
              _buildTextField(colorController, 'Color'),
              _buildTextField(placaController, 'Placa'),
              const SizedBox(height: 12),
              _buildDropdown(),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addVehicle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.grey[200],
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedType,
      items: vehicleTypes.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type.toUpperCase()),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedType = value!;
        });
      },
      decoration: InputDecoration(
        labelText: 'Tipo de Vehículo',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }

  Widget _getVehicleIcon(String type) {
    switch (type) {
      case 'moto':
        return const Icon(Icons.motorcycle, color: Colors.blueAccent, size: 32);
      case 'camion':
        return const Icon(Icons.local_shipping, color: Colors.blueAccent, size: 32);
      default:
        return const Icon(Icons.directions_car, color: Colors.blueAccent, size: 32);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            children: const [
              TextSpan(
                text: 'Mis',
                style: TextStyle(color: Colors.white),
              ),
              TextSpan(
                text: ' Vehículos',
                style: TextStyle(color: Colors.orange),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddVehicleBottomSheet,
        backgroundColor: Colors.blueAccent,
        icon: const Icon(Icons.add),
        label: Text(
          'Agregar',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (vehicles.isEmpty) {
      return const Center(
        child: Text(
          'No tienes vehículos registrados',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: vehicles.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final vehicle = vehicles[index];
        return _buildVehicleCard(vehicle);
      },
    );
  }

  Widget _buildVehicleCard(Map<String, dynamic> vehicle) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _getVehicleIcon(vehicle['tipo']),
        title: Text(
          '${vehicle['marca']} ${vehicle['modelo']}',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          'Año: ${vehicle['anio']} - Placa: ${vehicle['placa']}',
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
        ),
        trailing: Wrap(
          spacing: 8,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.green),
              onPressed: () {
                // Lógica de edición (se puede agregar después)
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteVehicle(vehicle['id'].toInt()), // ID como String
            ),
          ],
        ),
      ),
    );
  }
}
