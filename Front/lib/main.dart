import 'package:flutter/material.dart';
import 'home.dart';
import 'login.dart';
import 'profile.dart';
import 'register_step1.dart';
import 'register_step2.dart';
import 'emergency_contacts.dart';
import 'upload_evidence.dart';
import 'risk_level.dart';
import 'resources.dart';

const String _defaultInitialRoute = '/home';
const String _configuredInitialRoute = String.fromEnvironment(
  'SAFEHOME_INITIAL_ROUTE',
  defaultValue: _defaultInitialRoute,
);

const Set<String> _validInitialRoutes = <String>{
  '/login',
  '/home',
  '/profile',
  '/register1',
  '/register2',
  '/contacts',
  '/emergency_contacts',
  '/upload',
  '/upload_evidence',
  '/risk',
  '/risk_level',
  '/resources',
};

String getInitialRoute() {
  if (_validInitialRoutes.contains(_configuredInitialRoute)) {
    return _configuredInitialRoute;
  }
  return _defaultInitialRoute;
}

void main() {
  runApp(SafeHomeApp(initialRoute: getInitialRoute()));
}

class SafeHomeApp extends StatelessWidget {
  final String initialRoute;
  const SafeHomeApp({Key? key, required this.initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeHome',
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/profile': (context) => ProfileScreen(),
        '/register1': (context) => RegisterStep1Screen(),
        '/register2': (context) => RegisterStep2Screen(),
        '/contacts': (context) => EmergencyContactsScreen(),
        '/emergency_contacts': (context) => EmergencyContactsScreen(),
        '/upload': (context) => UploadEvidenceScreen(),
        '/upload_evidence': (context) => UploadEvidenceScreen(),
        '/risk': (context) => RiskLevelScreen(),
        '/risk_level': (context) => RiskLevelScreen(),
        '/resources': (context) => ResourcesScreen(),
      },
    );
  }
}
