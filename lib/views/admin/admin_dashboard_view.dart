import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'admin_stores_view.dart';
import 'admin_entrepreneurships_view.dart';
import 'admin_suggestions_view.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Panel de Administrador", style: TextStyle(color: AppTheme.darkPurple, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.darkPurple),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Gestión de la App",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.darkPurple),
              ),
              const SizedBox(height: 8),
              const Text(
                "Selecciona el módulo que deseas administrar.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),

              _buildAdminCard(
                context,
                title: "Emprendimientos",
                subtitle: "Aprobar o rechazar nuevas solicitudes",
                icon: Icons.rocket_launch_rounded,
                color: Colors.orange,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminEntrepreneurshipsView()));
                },
              ),
              const SizedBox(height: 16),
              
              _buildAdminCard(
                context,
                title: "Bares y Papelerías",
                subtitle: "Añadir o editar locales y productos",
                icon: Icons.storefront_rounded,
                color: AppTheme.primaryColor,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminStoresView()));
                },
              ),
              const SizedBox(height: 16),

              _buildAdminCard(
                context,
                title: "Buzón de Sugerencias",
                subtitle: "Leer los mensajes de los estudiantes",
                icon: Icons.inbox_rounded,
                color: Colors.green,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminSuggestionsView()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Card(
      elevation: 4,
      shadowColor: color.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.darkPurple)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
