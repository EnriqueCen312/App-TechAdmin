import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:login_register_app/connection/auth/AuthController.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final SupabaseClient supabase;
  List<Map<String, dynamic>> workshops = [];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900.withOpacity(0.8),
        title: RichText(
          text: TextSpan(
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            children: [
              TextSpan(text: 'Tech', style: TextStyle(color: Colors.white)),
              TextSpan(text: 'Admin', style: TextStyle(color: Colors.orange)),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, size: 32, color: Colors.white),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue.shade900),
              child: const Text("Menú", style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Configuración"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Cerrar sesión"),
              onTap: () async {
                final AuthController logOut = AuthController();
                await logOut.logout(context);
              },
            ),
          ],
        ),
      ),
      body: workshops.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListView.builder(
                itemCount: workshops.length,
                itemBuilder: (context, index) {
                  final workshop = workshops[index];
                  return Card(
                    elevation: 6,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                          child: workshop['imagenes'].isNotEmpty
                              ? Image.memory(
                                  base64Decode(workshop['imagenes'][0]),
                                  width: double.infinity,
                                  height: 180,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  'assets/images/descarga.jpeg',
                                  width: double.infinity,
                                  height: 180,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                workshop['nombre'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                workshop['direccion'] ?? 'No disponible',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade900,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  onPressed: () {},
                                  child: const Text('Agendar cita'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
