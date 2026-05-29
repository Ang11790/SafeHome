import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
    required Color color,
  }) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.2),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SafeHome')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade600, Colors.indigo.shade600],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bienvenido a SafeHome',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Selecciona un apartado para gestionar tu seguridad y bienestar.',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildActionCard(
            context: context,
            icon: Icons.person,
            title: 'Perfil',
            subtitle: 'Completa y actualiza tus datos personales.',
            route: '/profile',
            color: Colors.teal,
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            context: context,
            icon: Icons.contacts,
            title: 'Contactos de emergencia',
            subtitle: 'Registra personas de confianza para emergencias.',
            route: '/contacts',
            color: Colors.deepOrange,
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            context: context,
            icon: Icons.upload_file,
            title: 'Subir evidencias',
            subtitle: 'Carga fotos, imagenes, archivos y notas.',
            route: '/upload',
            color: Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            context: context,
            icon: Icons.quiz,
            title: 'Encuesta de riesgo',
            subtitle: 'Evalua tu situacion actual con una encuesta guiada.',
            route: '/risk',
            color: Colors.purple,
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            context: context,
            icon: Icons.menu_book,
            title: 'Recursos',
            subtitle: 'Informacion sobre violencia y rutas de ayuda.',
            route: '/resources',
            color: Colors.green,
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar sesion'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
