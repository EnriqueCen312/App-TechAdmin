import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:login_register_app/connection/Home/HomeController.dart';
import 'dart:convert';

import 'package:login_register_app/values/app_routes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final HomeController controller;

  @override
  void initState() {
    super.initState();
    controller = HomeController();
    _loadWorkshops();
  }
  
  Future<void> _loadWorkshops() async {
    try {
      await controller.fetchWorkshops();
      setState(() {}); // Refresh UI after fetching workshops
    } catch (error) {
      // Handle error if needed
      print('Error loading workshops: $error');
    }
  }

  void _showBookingBottomSheet(Map<String, dynamic> workshop) async {
    setState(() {
      controller.selectWorkshop(workshop);
    });
    
    final userId = await controller.getUserId();
    if (userId != null) {
      final vehicles = await controller.fetchUserVehicles(userId);
      
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setSheetState) {
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
                            
                            // Vehicle seleccion
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
                                  value: controller.selectedVehicle,
                                  onChanged: (value) {
                                    setSheetState(() {
                                      controller.setVehicle(value!);
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
                                  initialDate: controller.selectedDate ?? DateTime.now(),
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
                                
                                if (pickedDate != null && pickedDate != controller.selectedDate) {
                                  setSheetState(() {
                                    controller.selectDate(pickedDate);
                                  });
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
                                      controller.selectedDate == null
                                          ? 'Seleccionar fecha'
                                          : '${controller.selectedDate!.day}/${controller.selectedDate!.month}/${controller.selectedDate!.year}',
                                      style: TextStyle(
                                        color: controller.selectedDate == null ? Colors.grey.shade600 : Colors.black,
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
                            
                            if (controller.selectedDate == null)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text('Seleccione una fecha primero'),
                              )
                            else if (controller.availableTimeSlots.isEmpty)
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
                                  itemCount: controller.availableTimeSlots.length,
                                  itemBuilder: (context, index) {
                                    final timeSlot = controller.availableTimeSlots[index];
                                    final isSelected = controller.selectedTime != null && 
                                        controller.selectedTime!.hour == timeSlot.hour && 
                                        controller.selectedTime!.minute == timeSlot.minute;
                                    
                                    return GestureDetector(
                                      onTap: () {
                                        setSheetState(() {
                                          controller.selectTime(timeSlot);
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
                                controller.setAppointmentDescription(value);
                              },
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Submit button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () async {
                                  final result = await controller.bookAppointment(context);
                                  if (result != null && result['success']) {
                                    Navigator.of(context).pop(); // Cierra el Bottom Sheet

                                    // Usa la ruta correcta definida en AppRoutes
                                    Navigator.pushReplacementNamed(context, AppRoutes.appointmentsPage);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(result?['error'] ?? 'Error al agendar la cita'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }


                                },
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
      body: controller.workshops.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: controller.workshops.length,
              itemBuilder: (context, index) {
                final workshop = controller.workshops[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  shadowColor: Colors.black.withOpacity(0.2),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.white, Colors.grey.shade50],
                      ),
                    ),
                    child: Column(
                      children: [
                        // Header with image as background
                        Container(
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            image: DecorationImage(
                              image: workshop['imagenes'] != null && workshop['imagenes'].isNotEmpty
                                  ? MemoryImage(base64Decode(workshop['imagenes'][0]))
                                  : const AssetImage('assets/images/descarga.jpeg') as ImageProvider,
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.3),
                                BlendMode.darken,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        workshop['nombre'] ?? 'Sin nombre',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          shadows: [
                                            Shadow(
                                              offset: Offset(0, 1),
                                              blurRadius: 3.0,
                                              color: Colors.black54,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              workshop['direccion'] ?? 'No disponible',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.white,
                                                shadows: [
                                                  Shadow(
                                                    offset: Offset(0, 1),
                                                    blurRadius: 2.0,
                                                    color: Colors.black54,
                                                  ),
                                                ],
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Details and booking button
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 14,
                                          color: Colors.grey.shade700,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${workshop['abre']?.toString().substring(0, 5) ?? '08:00'} - ${workshop['cierra']?.toString().substring(0, 5) ?? '18:00'}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade900,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'Tech Admin',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.shade600,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'Tech Admin',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => _showBookingBottomSheet(workshop),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade900,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 2,
                                ),
                                child: const Text(
                                  'Agendar',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
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