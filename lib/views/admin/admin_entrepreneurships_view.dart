import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firebase_service.dart';
import '../../models/entrepreneurship_model.dart';
import '../../core/theme.dart';

class AdminEntrepreneurshipsView extends StatelessWidget {
  const AdminEntrepreneurshipsView({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseService = context.read<FirebaseService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Emprendimientos", style: TextStyle(color: AppTheme.darkPurple)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.darkPurple),
      ),
      body: StreamBuilder<List<EntrepreneurshipModel>>(
        stream: firebaseService.adminStreamEntrepreneurships(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No hay emprendimientos registrados."));
          }

          final posts = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(24.0),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              post.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: post.approved ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              post.approved ? "Aprobado" : "Pendiente",
                              style: TextStyle(
                                color: post.approved ? Colors.green : Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text("Por: ${post.studentName}", style: TextStyle(color: Colors.grey.shade700)),
                      const SizedBox(height: 8),
                      Text(post.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (!post.approved)
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              onPressed: () {
                                firebaseService.toggleEntrepreneurshipApproval(post.id, true);
                              },
                              icon: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
                              label: const Text("Aprobar", style: TextStyle(color: Colors.white)),
                            )
                          else
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                              onPressed: () {
                                firebaseService.toggleEntrepreneurshipApproval(post.id, false);
                              },
                              icon: const Icon(Icons.close_rounded, size: 16),
                              label: const Text("Ocultar"),
                            )
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
