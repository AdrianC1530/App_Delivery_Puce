import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firebase_service.dart';
import '../../core/theme.dart';

class AdminSuggestionsView extends StatelessWidget {
  const AdminSuggestionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseService = context.read<FirebaseService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Buzón de Entrada", style: TextStyle(color: AppTheme.darkPurple)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.darkPurple),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: firebaseService.streamSuggestions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No hay sugerencias en el buzón."));
          }

          final suggestions = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(24.0),
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final sug = suggestions[index];
              final date = (sug['createdAt'] as Timestamp?)?.toDate();
              final dateString = date != null ? "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}" : "";

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person, color: AppTheme.primaryColor),
                          const SizedBox(width: 8),
                          Text(sug['studentName'] ?? 'Anónimo', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.darkPurple)),
                          const Spacer(),
                          Text(dateString, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.bgLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          sug['text'] ?? '',
                          style: const TextStyle(fontSize: 15, height: 1.4),
                        ),
                      ),
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
