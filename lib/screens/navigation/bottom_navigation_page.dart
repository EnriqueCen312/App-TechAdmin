import 'package:flutter/material.dart';
import 'package:login_register_app/screens/home_page/home_page.dart';
import 'package:login_register_app/screens/vehicle/vehicle_screen.dart';
import 'package:login_register_app/screens/appointments/appointments_screen.dart';
import 'package:login_register_app/screens/history/history_screen.dart';

class BottomNavigationPage extends StatefulWidget {
  final int initialIndex;

  const BottomNavigationPage({super.key, this.initialIndex = 0});  // Acepta un índice inicial

  @override
  _BottomNavigationPageState createState() => _BottomNavigationPageState();
}

class _BottomNavigationPageState extends State<BottomNavigationPage> {
  late int _selectedIndex;

  final List<Widget> _screens = [
    const HomePage(),            // Pantalla de Inicio (índice 0)
    const VehicleScreen(),       // Pantalla de Vehículos (índice 1)
    const AppointmentsScreen(),  // Pantalla de Citas (índice 2)
    const HistoryScreen(),       // Pantalla de Historial (índice 3)
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex; // Usa el índice inicial
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue.shade900,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'Vehículos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Citas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Historial',
          ),
        ],
      ),
    );
  }
}
