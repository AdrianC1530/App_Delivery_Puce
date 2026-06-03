import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firebase_service.dart';
import '../../models/store_model.dart';
import '../../core/theme.dart';
import 'admin_store_details_view.dart';

class AdminStoresView extends StatelessWidget {
  const AdminStoresView({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseService = context.read<FirebaseService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestión de Locales", style: TextStyle(color: AppTheme.darkPurple)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.darkPurple),
      ),
      body: StreamBuilder<List<StoreModel>>(
        stream: firebaseService.streamStores(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No hay locales registrados."));
          }

          final stores = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(24.0),
            itemCount: stores.length,
            itemBuilder: (context, index) {
              final store = stores[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: store.isOpen ? Colors.green.shade100 : Colors.red.shade100,
                    child: Icon(
                      store.type == 'bar' ? Icons.fastfood_rounded : Icons.menu_book_rounded,
                      color: store.isOpen ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(store.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(store.locationDescription),
                  trailing: Switch(
                    value: store.isOpen,
                    activeColor: Colors.green,
                    onChanged: (val) {
                      firebaseService.toggleStoreStatus(store.id, val);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryColor,
        onPressed: () {
          _showCreateStoreDialog(context, firebaseService);
        },
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text("Nuevo Local", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showCreateStoreDialog(BuildContext context, FirebaseService service) {
    final nameCtrl = TextEditingController();
    final locCtrl = TextEditingController();
    String type = 'bar';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Crear Nuevo Local", style: TextStyle(color: AppTheme.darkPurple)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: "Nombre del Local"),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: type,
                    decoration: const InputDecoration(labelText: "Tipo de Local"),
                    items: const [
                      DropdownMenuItem(value: 'bar', child: Text("Bar / Cafetería")),
                      DropdownMenuItem(value: 'stationery', child: Text("Papelería / Copiadora")),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => type = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: locCtrl,
                    decoration: const InputDecoration(labelText: "Ubicación (Ej: Bloque A)"),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                onPressed: () async {
                  if (nameCtrl.text.isEmpty || locCtrl.text.isEmpty) return;
                  await service.createStore(
                    name: nameCtrl.text.trim(),
                    type: type,
                    locationDescription: locCtrl.text.trim(),
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text("Crear"),
              ),
            ],
          );
        }
      ),
    );
  }
}
