import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:login_register_app/connection/auth/AuthController.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final SupabaseClient supabase;
  List<Map<String, dynamic>> workshops = [];
  bool isBooking = false;
  Map<String, dynamic>? selectedWorkshop; // Cambiado a nullable
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String? selectedVehicle;
  String? appointmentDescription;
  List<TimeOfDay> availableTimeSlots = [];

  @override
  void initState() {
    super.initState();
    supabase = Supabase.instance.client;
    _fetchWorkshops();
  }

  Future<void> _fetchWorkshops() async {
    try {
      final response = await supabase.from('talleres').select().limit(10);
      setState(() {
        workshops = List<Map<String, dynamic>>.from(response);
      });
    } catch (error) {
      print('Error fetching workshops: $error');
    }
  }

  Future<int?> _getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      if (userJson != null) {
        final Map<String, dynamic> user = jsonDecode(userJson);
        return user['id'];
      }
      return null;
    } catch (e) {
      print('Error al obtener el ID: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> _fetchUserVehicles(int userId) async {
    final response = await supabase.from('vehiculos').select().eq('usuario_app_id', userId);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> _bookAppointment() async {
    final userId = await _getUserId();
    if (userId != null && selectedDate != null && selectedTime != null && selectedVehicle != null && appointmentDescription != null) {
      try {
        final response = await supabase.from('citas').insert([
          {
            'automovil_id': selectedVehicle,
            'fecha': selectedDate?.toIso8601String(),
            'hora': selectedTime?.format(context),
            'auth_id': userId,
            'taller_id': selectedWorkshop!['id'],
            'estado': 'pendiente',
            'descripcion': appointmentDescription,
          },
        ]);
        
        if (response == null) { // Cambiado para compatibilidad con Supabase reciente
          Navigator.of(context).pop(); // Close bottom sheet
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cita agendada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushNamed(context, '/appointments');
        } else {
          print('Error al agendar la cita');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al agendar la cita'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        print('Exception al agendar la cita: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al agendar la cita: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor complete todos los campos'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _generateAvailableTimeSlots() {
    if (selectedDate == null || selectedWorkshop == null) return;
    
    // Parse workshop opening and closing times
    final String opensStr = selectedWorkshop!['abre'] ?? '08:00:00';
    final String closesStr = selectedWorkshop!['cierra'] ?? '18:00:00';
    final int intervalMinutes = selectedWorkshop!['intervalo_minutes'] ?? 30;
    
    // Parse time strings to TimeOfDay
    final TimeOfDay opens = _parseTimeString(opensStr);
    final TimeOfDay closes = _parseTimeString(closesStr);
    
    // Generate time slots
    List<TimeOfDay> slots = [];
    
    // Start with opening time
    int currentHour = opens.hour;
    int currentMinute = opens.minute;
    
    while (true) {
      // Add interval to current time
      currentMinute += intervalMinutes;
      if (currentMinute >= 60) {
        currentHour += currentMinute ~/ 60;
        currentMinute = currentMinute % 60;
      }
      
      // Create time slot
      final TimeOfDay timeSlot = TimeOfDay(hour: currentHour, minute: currentMinute);
      
      // Check if we've passed closing time
      if (_timeOfDayToMinutes(timeSlot) > _timeOfDayToMinutes(closes)) {
        break;
      }
      
      slots.add(timeSlot);
    }
    
    setState(() {
      availableTimeSlots = slots;
      // Reset selected time if it's not in available slots
      if (selectedTime != null && !_isTimeInSlots(selectedTime!, slots)) {
        selectedTime = null;
      }
    });
  }

  TimeOfDay _parseTimeString(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  int _timeOfDayToMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  bool _isTimeInSlots(TimeOfDay time, List<TimeOfDay> slots) {
    final timeMinutes = _timeOfDayToMinutes(time);
    return slots.any((slot) => _timeOfDayToMinutes(slot) == timeMinutes);
  }

  void _showBookingBottomSheet(Map<String, dynamic> workshop) async {
    setState(() {
      isBooking = true;
      selectedWorkshop = workshop;
      selectedDate = null;
      selectedTime = null;
      selectedVehicle = null;
      appointmentDescription = null;
    });
    
    final userId = await _getUserId();
    if (userId != null) {
      final vehicles = await _fetchUserVehicles(userId);
      
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 10,
                    )
                  ],
                ),
                child: Column(
                  children: [
                    // Workshop header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade900,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: workshop['imagenes'] != null && workshop['imagenes'].isNotEmpty
                                  ? Image.memory(
                                      base64Decode(workshop['imagenes'][0]),
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      'assets/images/descarga.jpeg',
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      workshop['nombre'] ?? 'Sin nombre',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      workshop['direccion'] ?? 'No disponible',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Abre: ${workshop['abre']?.toString().substring(0, 5) ?? '08:00'}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              Text(
                                'Cierra: ${workshop['cierra']?.toString().substring(0, 5) ?? '18:00'}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              Text(
                                'Intervalo: ${workshop['intervalo_minutes'] ?? '30'} min',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Booking form
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Información de la cita',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Vehicle selection
                            const Text(
                              'Seleccione su vehículo:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  hint: const Text('Seleccionar vehículo'),
                                  value: selectedVehicle,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedVehicle = value;
                                    });
                                  },
                                  items: vehicles.map<DropdownMenuItem<String>>((vehicle) {
                                    return DropdownMenuItem<String>(
                                      value: vehicle['id'].toString(),
                                      child: Text('${vehicle['marca']} ${vehicle['modelo']} (${vehicle['placa']})'),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Date selection
                            const Text(
                              'Seleccione fecha:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () async {
                                final DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDate ?? DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 30)),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: ColorScheme.light(
                                          primary: Colors.blue.shade900,
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                
                                if (pickedDate != null && pickedDate != selectedDate) {
                                  setState(() {
                                    selectedDate = pickedDate;
                                    selectedTime = null; // Reset time when date changes
                                  });
                                  
                                  // Generate time slots for the selected date
                                  _generateAvailableTimeSlots();
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      selectedDate == null
                                          ? 'Seleccionar fecha'
                                          : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                                      style: TextStyle(
                                        color: selectedDate == null ? Colors.grey.shade600 : Colors.black,
                                      ),
                                    ),
                                    Icon(Icons.calendar_today, color: Colors.blue.shade900),
                                  ],
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Time selection
                            const Text(
                              'Seleccione hora:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            if (selectedDate == null)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text('Seleccione una fecha primero'),
                              )
                            else if (availableTimeSlots.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text('No hay horarios disponibles'),
                              )
                            else
                              SizedBox(
                                height: 50,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: availableTimeSlots.length,
                                  itemBuilder: (context, index) {
                                    final timeSlot = availableTimeSlots[index];
                                    final isSelected = selectedTime != null && 
                                        selectedTime!.hour == timeSlot.hour && 
                                        selectedTime!.minute == timeSlot.minute;
                                    
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedTime = timeSlot;
                                        });
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(right: 8),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: isSelected ? Colors.blue.shade900 : Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: isSelected ? Colors.blue.shade900 : Colors.grey.shade300,
                                          ),
                                        ),
                                        child: Text(
                                          '${timeSlot.hour.toString().padLeft(2, '0')}:${timeSlot.minute.toString().padLeft(2, '0')}',
                                          style: TextStyle(
                                            color: isSelected ? Colors.white : Colors.black,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              
                            const SizedBox(height: 24),
                            
                            // Description field
                            const Text(
                              'Descripción del servicio:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: 'Describa el servicio que necesita...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                contentPadding: const EdgeInsets.all(12),
                              ),
                              onChanged: (value) {
                                appointmentDescription = value;
                              },
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Submit button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _bookAppointment,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade900,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 2,
                                ),
                                child: const Text(
                                  'Solicitar cita',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Talleres'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: ListView.builder(
        itemCount: workshops.length,
        itemBuilder: (context, index) {
          final workshop = workshops[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            elevation: 5,
            shadowColor: Colors.black.withOpacity(0.2),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen del taller
                  workshop['imagenes'] != null && workshop['imagenes'].isNotEmpty
                      ? Image.memory(
                          base64Decode(workshop['imagenes'][0]),
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          'assets/images/descarga.jpeg',
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                  const SizedBox(width: 16),
                  // Información del taller
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workshop['nombre'] ?? 'Sin nombre',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          workshop['direccion'] ?? 'No disponible',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Texto "Tech Admin" en dos colores
                        Text(
                          'Tech Admin',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue.shade900,
                          ),
                        ),
                        Text(
                          'Tech Admin',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.orange.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Botón "Agendar"
                  ElevatedButton(
                    onPressed: () => _showBookingBottomSheet(workshop),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade900,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Agendar',
                      style: TextStyle(fontSize: 12), // Texto más pequeño
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}