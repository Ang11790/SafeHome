import 'package:flutter/material.dart';

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  Widget _buildInfoCard({
    required String title,
    required String body,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 6),
                Text(body),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recursos')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Informacion sobre violencia y rutas de ayuda',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            title: 'Senales de alerta',
            body:
                'Control excesivo, amenazas, humillaciones, aislamiento social, golpes o presion economica son indicadores de violencia.',
            icon: Icons.warning_amber,
            color: Colors.deepOrange,
          ),
          _buildInfoCard(
            title: 'Plan de seguridad basico',
            body:
                'Ten una palabra clave con alguien de confianza, guarda documentos importantes, define una ruta de salida y un lugar seguro.',
            icon: Icons.shield,
            color: Colors.blue,
          ),
          _buildInfoCard(
            title: 'Como pedir ayuda',
            body:
                'Habla con una persona de confianza, contacta lineas de atencion, y acude a instituciones de salud o justicia segun el riesgo.',
            icon: Icons.support_agent,
            color: Colors.green,
          ),
          _buildInfoCard(
            title: 'Que puedes documentar',
            body:
                'Registra fechas, hechos, mensajes, fotos y testigos. Esta evidencia puede ser util para apoyo legal y proteccion.',
            icon: Icons.folder_copy,
            color: Colors.indigo,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Lineas recomendadas',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text('• Emergencias generales: 123'),
                  Text('• Policia nacional: 112 o lineas locales'),
                  Text('• Lineas de orientacion para violencia: revisa las de tu ciudad/pais'),
                  SizedBox(height: 8),
                  Text(
                    'Si hay peligro inminente, prioriza salir a un lugar seguro y llamar a emergencias.',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
