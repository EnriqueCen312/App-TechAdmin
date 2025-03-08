import 'package:flutter/material.dart';
import 'screens/home_page/home_page.dart'; // Ruta correcta para Home
import 'screens/vehicle/vehicle_screen.dart'; // Ruta correcta para Vehicle
import 'screens/appointments/appointments_screen.dart'; // Ruta correcta para Appointments
import 'screens/history/history_screen.dart'; // Ruta correcta para History
import 'screens/login_screen.dart'; // Ruta para Login
import 'screens/register_screen.dart'; // Ruta para Register
import 'screens/navigation/bottom_navigation_page.dart'; // Ruta para Bottom Navigation
import 'utils/common_widgets/invalid_route.dart';
import 'values/app_routes.dart';

class Routes {
  const Routes._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    Route<dynamic> getRoute({
      required Widget widget,
      bool fullscreenDialog = false,
    }) {
      return MaterialPageRoute<void>(
        builder: (context) => widget,
        settings: settings,
        fullscreenDialog: fullscreenDialog,
      );
    }

    switch (settings.name) {
      case AppRoutes.login:
        return getRoute(widget: const LoginPage());

      case AppRoutes.register:
        return getRoute(widget: const RegisterPage());

      case AppRoutes.homePage:
        return getRoute(widget: const HomePage()); // Actualizado a `home_screen.dart`

      case AppRoutes.vehiclePage:
        return getRoute(widget: const VehicleScreen()); // Actualizado a `vehicle_screen.dart`

      case AppRoutes.appointmentsPage:
        return getRoute(widget: const AppointmentsScreen()); // Actualizado a `appointments_screen.dart`

      case AppRoutes.historyPage:
        return getRoute(widget: const HistoryScreen()); // Actualizado a `history_screen.dart`
        

      case AppRoutes.bottomNavigationPage:
        return getRoute(widget: const BottomNavigationPage());

      // Ruta no válida
      default:
        return getRoute(widget: const InvalidRoute());
    }
  }
}
