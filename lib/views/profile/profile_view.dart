import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firebase_service.dart';
import '../../core/theme.dart';
import '../auth/login_view.dart';
import 'voice_suggestion_view.dart';
import '../admin/admin_dashboard_view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  void _logout(BuildContext context) async {
    final service = Provider.of<FirebaseService>(context, listen: false);
    await service.signOut();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginView()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<FirebaseService>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi Perfil", style: TextStyle(color: AppTheme.darkPurple, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User Avatar & Name Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: AppTheme.lightPurple,
                        child: Text(
                          user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
                          style: const TextStyle(color: AppTheme.primaryColor, fontSize: 36, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.name ?? "Usuario PUCE-SI",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.darkPurple),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user?.role == 'merchant' ? "Establecimiento / Bar" : "Estudiante",
                          style: const TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Detail List Title
              const Padding(
                padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
                child: Text("Información Personal", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.grey)),
              ),

              // User Info Details
              Card(
                child: Column(
                  children: [
                    _buildInfoTile(Icons.email_outlined, "Correo electrónico", user?.email ?? '-'),
                    const Divider(height: 1),
                    _buildInfoTile(Icons.phone_iphone_outlined, "Teléfono de contacto", user?.phoneNumber ?? '-'),
                    const Divider(height: 1),
                    _buildInfoTile(Icons.school_outlined, "Institución", "PUCE Sede Ibarra"),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Admin Dashboard Button
              if (user?.role == 'admin') ...[
                Card(
                  color: AppTheme.accentColor.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: AppTheme.accentColor.withValues(alpha: 0.5), width: 1.5),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboardView()));
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(color: AppTheme.accentColor, shape: BoxShape.circle),
                            child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Panel de Control (Admin)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.darkPurple)),
                                SizedBox(height: 4),
                                Text("Gestiona la app y usuarios", style: TextStyle(fontSize: 13, color: Colors.grey)),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppTheme.accentColor),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Voice Suggestion Button
              Card(
                color: AppTheme.lightPurple,
                child: InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const VoiceSuggestionView()));
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.record_voice_over_rounded, color: AppTheme.primaryColor),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Buzón de Sugerencias", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.darkPurple)),
                              SizedBox(height: 4),
                              Text("Graba un audio con tus ideas", style: TextStyle(fontSize: 13, color: Colors.grey)),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppTheme.primaryColor),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Log Out Button
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout_rounded),
                label: const Text("Cerrar Sesión", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.darkPurple)),
    );
  }
}
