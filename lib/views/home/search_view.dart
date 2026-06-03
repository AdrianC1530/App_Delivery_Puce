import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firebase_service.dart';
import '../../models/store_model.dart';
import '../../models/product_model.dart';
import '../../core/theme.dart';
import '../store/store_detail_view.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firebaseService = context.read<FirebaseService>();

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.darkPurple),
        title: Container(
          height: 45,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.darkPurple.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            onChanged: (val) {
              setState(() {
                _searchQuery = val.toLowerCase();
              });
            },
            decoration: InputDecoration(
              hintText: "¿Qué se te antoja hoy?",
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primaryColor),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.grey, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = "");
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ),
      body: _searchQuery.isEmpty
          ? _buildEmptyState()
          : StreamBuilder<List<StoreModel>>(
              stream: firebaseService.streamStores(),
              builder: (context, storesSnapshot) {
                if (!storesSnapshot.hasData) return const Center(child: CircularProgressIndicator());

                return StreamBuilder<List<ProductModel>>(
                  stream: firebaseService.streamAllProducts(),
                  builder: (context, productsSnapshot) {
                    if (!productsSnapshot.hasData) return const Center(child: CircularProgressIndicator());

                    final stores = storesSnapshot.data!;
                    final products = productsSnapshot.data!;

                    // Filtramos Locales
                    final matchedStores = stores.where((s) => s.name.toLowerCase().contains(_searchQuery)).toList();

                    // Filtramos Productos
                    final matchedProducts = products.where((p) => 
                      p.name.toLowerCase().contains(_searchQuery) || 
                      p.category.toLowerCase().contains(_searchQuery)
                    ).toList();

                    if (matchedStores.isEmpty && matchedProducts.isEmpty) {
                      return _buildNoResultsState();
                    }

                    return ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        if (matchedStores.isNotEmpty) ...[
                          const Text("Locales", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.darkPurple)),
                          const SizedBox(height: 12),
                          ...matchedStores.map((store) => _buildStoreResult(context, store)),
                          const SizedBox(height: 24),
                        ],
                        if (matchedProducts.isNotEmpty) ...[
                          const Text("Productos", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.darkPurple)),
                          const SizedBox(height: 12),
                          ...matchedProducts.map((product) {
                            // Find the store for this product
                            final store = stores.firstWhere((s) => s.id == product.storeId, orElse: () => stores.first);
                            return _buildProductResult(context, product, store);
                          }),
                        ],
                      ],
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_rounded, size: 80, color: AppTheme.primaryColor.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          const Text("Busca empanadas, almuerzos, papelerías...", style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sentiment_dissatisfied_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text("No encontramos nada con ese nombre.", style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildStoreResult(BuildContext context, StoreModel store) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppTheme.lightPurple,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(store.type == 'bar' ? Icons.fastfood_rounded : Icons.menu_book_rounded, color: AppTheme.primaryColor),
        ),
        title: Text(store.name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.darkPurple)),
        subtitle: Text(store.locationDescription, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppTheme.primaryColor),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => StoreDetailView(store: store)));
        },
      ),
    );
  }

  Widget _buildProductResult(BuildContext context, ProductModel product, StoreModel store) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.restaurant_rounded, color: Colors.orange),
        ),
        title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("En ${store.name} • \$${product.price.toStringAsFixed(2)}", style: const TextStyle(fontSize: 12, color: AppTheme.primaryColor)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => StoreDetailView(store: store)));
        },
      ),
    );
  }
}
