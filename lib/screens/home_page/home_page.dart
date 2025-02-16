import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tech Admin',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      routes: {
        '/': (context) => HomePage(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  HomePage({super.key}) {
    getUserData();
  }

  Future<void> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      final decodedToken = JwtDecoder.decode(token);
      name = decodedToken['name'] ?? 'Nombre no disponible';
      email = decodedToken['email'] ?? 'Correo no disponible';
    } else {
      name = 'Nombre';
      email = 'Correo';
    }
  }

  String name = '';
  String email = '';

  @override
  Widget build(BuildContext context) {
    final categories = [
      {
        'title': 'Citas',
        'icon': Icons.event,
        'subtitle': 'Administra o genera una cita',
        'route': '/',
        'color': Colors.green
      },
      {
        'title': 'Vehículos',
        'icon': Icons.directions_car,
        'subtitle': 'Administra o añade un vehículo',
        'route': '/',
        'color': Colors.blue
      },
      {
        'title': 'Talleres',
        'icon': Icons.handyman,
        'subtitle': 'Visualiza los talleres disponibles',
        'route': '/',
        'color': Colors.orange
      },
      {
        'title': 'Perfil',
        'icon': Icons.person,
        'subtitle': 'Tu información aquí',
        'route': '/',
        'color': Colors.indigo
      },
      {
        'title': 'Historial',
        'icon': Icons.receipt_long,
        'subtitle': 'Consulta tu historial',
        'route': '/',
        'color': Colors.brown.shade700
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tech Admin',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.background,
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Card(
                elevation: 4,
                color: category['color'] as Color,
                child: InkWell(
                  onTap: () => Navigator.pushNamed(
                    context,
                    category['route'] as String,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          category['icon'] as IconData,
                          size: 40,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          category['title'] as String,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          category['subtitle'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.5),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    'TA',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
                accountName: Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                accountEmail: Text(
                  email,
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
              ),
              ...categories.map((category) => ListTile(
                    leading: Icon(
                      category['icon'] as IconData,
                      color: Colors.white,
                    ),
                    title: Text(
                      category['title'] as String,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      category['subtitle'] as String,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, category['route'] as String);
                    },
                  )),
              const Divider(color: Colors.white24),
              ListTile(
                leading: const Icon(Icons.settings, color: Colors.white),
                title: const Text('Configuración', style: TextStyle(color: Colors.white)),
                onTap: () {
                  // Implementar configuración
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.white),//boton cerrar sesion falta implementar
                title: const Text('Cerrar sesión', style: TextStyle(color: Colors.white)),
                onTap: () {
                  
                  // Implementar logout
                },
              ),
              ListTile(
                leading: const Icon(Icons.info, color: Colors.white),
                title: const Text('Acerca de', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  showAboutDialog(
                    context: context,
                    applicationName: 'Tech Administrator móvil',
                    applicationVersion: '2.0',
                    applicationIcon: Image.asset(
                      'assets/images/mecanico.png',
                      width: 50,
                      height: 50,
                      fit: BoxFit.contain,
                    ),
                    children: [
                      const Text('Desarrollado por:'),
                      const SizedBox(height: 10),
                      const Text(
                        'Tech Administrator SA de CV',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text('Desarrollo móvil'),
                      const SizedBox(height: 10),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
