import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firebase_service.dart';
import '../../models/store_model.dart';
import '../../models/product_model.dart';
import '../../core/theme.dart';

class AdminStoreDetailsView extends StatelessWidget {
  final StoreModel store;

  const AdminStoreDetailsView({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final firebaseService = context.read<FirebaseService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(store.name, style: const TextStyle(color: AppTheme.darkPurple)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.darkPurple),
      ),
      body: StreamBuilder<List<ProductModel>>(
        stream: firebaseService.streamProducts(store.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No hay productos en este local."));
          }

          final products = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(24.0),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text("\$${product.price.toStringAsFixed(2)} • ${product.category}", style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text("Preparación: ${product.preparationTimeMinutes} min", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_rounded, color: Colors.grey),
                        onPressed: () {
                          _showEditProductDialog(context, firebaseService, product);
                        },
                      ),
                      Switch(
                        value: product.isAvailable,
                        activeColor: Colors.green,
                        onChanged: (val) {
                          firebaseService.toggleProductAvailability(product.id, val);
                        },
                      ),
                    ],
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
          _showCreateProductDialog(context, firebaseService, store.id);
        },
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text("Nuevo Producto", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showCreateProductDialog(BuildContext context, FirebaseService service, String storeId) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final prepCtrl = TextEditingController();
    String category = 'Almuerzos';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Crear Producto", style: TextStyle(color: AppTheme.darkPurple)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Nombre")),
                  const SizedBox(height: 16),
                  TextField(controller: descCtrl, decoration: const InputDecoration(labelText: "Descripción"), maxLines: 2),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: priceCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: "Precio (\$)", prefixText: "\$"),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: prepCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: "Min. Prep.", suffixText: "min"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: const InputDecoration(labelText: "Categoría"),
                    items: const [
                      DropdownMenuItem(value: 'Almuerzos', child: Text("Almuerzos")),
                      DropdownMenuItem(value: 'Snacks', child: Text("Snacks")),
                      DropdownMenuItem(value: 'Bebidas', child: Text("Bebidas")),
                      DropdownMenuItem(value: 'Postres', child: Text("Postres")),
                      DropdownMenuItem(value: 'Útiles', child: Text("Útiles / Papelería")),
                      DropdownMenuItem(value: 'Servicios', child: Text("Servicios")),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => category = val);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                onPressed: () async {
                  if (nameCtrl.text.isEmpty || priceCtrl.text.isEmpty || prepCtrl.text.isEmpty) return;
                  
                  final price = double.tryParse(priceCtrl.text.replaceAll(',', '.')) ?? 0.0;
                  final prepTime = int.tryParse(prepCtrl.text) ?? 5;

                  await service.createProduct(
                    storeId: storeId,
                    name: nameCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    price: price,
                    category: category,
                    preparationTimeMinutes: prepTime,
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

  void _showEditProductDialog(BuildContext context, FirebaseService service, ProductModel product) {
    final nameCtrl = TextEditingController(text: product.name);
    final descCtrl = TextEditingController(text: product.description);
    final priceCtrl = TextEditingController(text: product.price.toStringAsFixed(2));
    final prepCtrl = TextEditingController(text: product.preparationTimeMinutes.toString());
    String category = product.category;

    // Check if category exists in list, else default
    final validCategories = ['Almuerzos', 'Snacks', 'Bebidas', 'Postres', 'Útiles', 'Servicios'];
    if (!validCategories.contains(category)) {
      category = 'Almuerzos';
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Editar Producto", style: TextStyle(color: AppTheme.darkPurple)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Nombre")),
                  const SizedBox(height: 16),
                  TextField(controller: descCtrl, decoration: const InputDecoration(labelText: "Descripción"), maxLines: 2),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: priceCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: "Precio (\$)", prefixText: "\$"),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: prepCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: "Min. Prep.", suffixText: "min"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: const InputDecoration(labelText: "Categoría"),
                    items: validCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => category = val);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                onPressed: () async {
                  if (nameCtrl.text.isEmpty || priceCtrl.text.isEmpty || prepCtrl.text.isEmpty) return;
                  
                  final price = double.tryParse(priceCtrl.text.replaceAll(',', '.')) ?? 0.0;
                  final prepTime = int.tryParse(prepCtrl.text) ?? 5;

                  await service.updateProduct(
                    productId: product.id,
                    name: nameCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    price: price,
                    category: category,
                    preparationTimeMinutes: prepTime,
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text("Guardar"),
              ),
            ],
          );
        }
      ),
    );
  }
}
