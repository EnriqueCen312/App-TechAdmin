import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:login_register_app/values/app_routes.dart';
import '../../connection/vehicles/VehiclesController.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class VehicleScreen extends StatefulWidget {
  const VehicleScreen({Key? key}) : super(key: key);

  @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  final VehiclesController _vehicleController = VehiclesController();
  List<Map<String, dynamic>> vehicles = [];
  final List<String> vehicleTypes = ['carro', 'moto', 'camion'];
  final List<String> carBrands = [
    'Toyota',
    'Honda',
    'Nissan',
    'Mazda',
    'Subaru',
    'Suzuki',
    'Mitsubishi',
    'Lexus',
    'otros'
  ];

  final List<String> years = List.generate(
    2025 - 1950 + 1,
    (index) => (2025 - index).toString()
  );

  late TextEditingController modeloController;
  late TextEditingController colorController;
  late TextEditingController placaController;

  String selectedType = 'carro';
  String selectedBrand = 'Toyota';
  String selectedYear = '2024';

  Color pickedColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    modeloController = TextEditingController();
    colorController = TextEditingController();
    placaController = TextEditingController();
    _loadVehicles();
  }

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
    modeloController.clear();
    colorController.clear();
    placaController.clear();
    setState(() {
      selectedType = 'carro';
      selectedBrand = 'Toyota';
      selectedYear = '2024';
      pickedColor = Colors.blue;
    });
  }

  Future<void> _addVehicle() async {
    final newVehicle = {
      'marca': selectedBrand,
      'modelo': modeloController.text,
      'anio': int.parse(selectedYear),
      'color': colorController.text,
      'placa': placaController.text,
      'tipo': selectedType,
    };

    await _vehicleController.registerVehicle(newVehicle);
    _clearForm();
    _loadVehicles();
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
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await _vehicleController.deleteVehicle(id);
        _loadVehicles();
      } catch (e) {
        print('Error al eliminar el vehículo: $e');
      }
    }
  }

  Widget _buildBrandDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedBrand,
      items: carBrands.map((brand) {
        return DropdownMenuItem(
          value: brand,
          child: Text(brand.toUpperCase()),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedBrand = value!;
        });
      },
      decoration: InputDecoration(
        labelText: 'Marca',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }

  Widget _buildYearDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedYear,
      items: years.map((year) {
        return DropdownMenuItem(
          value: year,
          child: Text(year),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedYear = value!;
        });
      },
      decoration: InputDecoration(
        labelText: 'Año',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey[200],
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

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Mis',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              ' Vehículos',
              style: TextStyle(
                color: Colors.orange.shade500,
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue.shade900,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      endDrawer: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        height: MediaQuery.of(context).size.height,
        child: Drawer(
          child: Container(
            color: Colors.blue.shade900,
            child: Column(
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Tech',
                                style: TextStyle(
                                  color: Colors.orange.shade500,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Administrator',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Divider(color: Colors.white.withOpacity(0.3)),
                ListTile(
                  leading: const Icon(Icons.settings, color: Colors.white),
                  title: const Text('Configuración', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                Expanded(child: Container()),
                Divider(color: Colors.white.withOpacity(0.3)),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.white),
                  title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
                  onTap: () async {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
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
              onPressed: () => _deleteVehicle(vehicle['id'].toInt()),
            ),
          ],
        ),
      ),
    );
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
              _buildBrandDropdown(),
              const SizedBox(height: 16),
              _buildTextField(modeloController, 'Modelo'),
              const SizedBox(height: 16),
              _buildYearDropdown(),
              const SizedBox(height: 16),
              InkWell(
                onTap: _showColorPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: pickedColor,
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: colorController,
                          enabled: false,
                          decoration: const InputDecoration(
                            labelText: 'Color',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const Icon(Icons.color_lens),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(placaController, 'Placa'),
              const SizedBox(height: 16),
              _buildDropdown(),
              const SizedBox(height: 20),
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

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleccionar Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickedColor,
              onColorChanged: (Color color) {
                setState(() {
                  pickedColor = color;
                  colorController.text = _getColorName(color);
                });
              },
              pickerAreaHeightPercent: 0.8,
              enableAlpha: false,
              displayThumbColor: true,
              showLabel: true,
              paletteType: PaletteType.hsvWithHue,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Listo'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String _getColorName(Color color) {
    if (color == Colors.red) return 'Rojo';
    if (color == Colors.blue) return 'Azul';
    if (color == Colors.green) return 'Verde';
    if (color == Colors.yellow) return 'Amarillo';
    if (color == Colors.black) return 'Negro';
    if (color == Colors.white) return 'Blanco';
    if (color == Colors.grey) return 'Gris';
    if (color == Colors.brown) return 'Café';
    if (color == Colors.orange) return 'Naranja';
    if (color == Colors.purple) return 'Morado';
    if (color == Colors.pink) return 'Rosa';
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }
}
