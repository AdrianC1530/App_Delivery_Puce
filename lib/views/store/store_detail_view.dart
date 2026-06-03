import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../services/firebase_service.dart';
import '../../services/cart_provider.dart';
import '../../models/store_model.dart';
import '../../models/product_model.dart';
import '../../core/theme.dart';
import '../cart/cart_view.dart';

class StoreDetailView extends StatefulWidget {
  final StoreModel store;
  const StoreDetailView({super.key, required this.store});

  @override
  State<StoreDetailView> createState() => _StoreDetailViewState();
}

class _StoreDetailViewState extends State<StoreDetailView> {
  String _selectedCategory = 'all';

  void _addProductToCart(ProductModel product) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final success = cart.addItem(product, widget.store.name);

    if (!success) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Vaciar Carrito", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text(
            "Tu carrito contiene productos de otro establecimiento (${cart.storeName}). ¿Deseas vaciarlo para pedir de ${widget.store.name}?",
            style: const TextStyle(fontSize: 14),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancelar", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () {
                cart.clearCart();
                cart.addItem(product, widget.store.name);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Carrito actualizado"), behavior: SnackBarBehavior.floating),
                );
              },
              child: const Text("Vaciar y Agregar", style: TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${product.name} agregado al carrito"),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final firebaseService = context.read<FirebaseService>();
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: CustomScrollView(
        slivers: [
          // Parallax Header
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            elevation: 0,
            backgroundColor: AppTheme.primaryColor,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white.withValues(alpha: 0.9),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.darkPurple, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.store.name,
                style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white, shadows: [Shadow(color: Colors.black45, blurRadius: 10)]),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  widget.store.imageUrl.isNotEmpty
                      ? Image.network(widget.store.imageUrl, fit: BoxFit.cover)
                      : Container(color: AppTheme.primaryColor),
                  // Dark gradient overlay for text readability
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Store Info
          SliverToBoxAdapter(
            child: Container(
              color: AppTheme.bgLight,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppTheme.lightPurple, borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.location_on_rounded, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.store.locationDescription, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                            const SizedBox(width: 4),
                            Text("${widget.store.rating} Rating", style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Products Stream
          StreamBuilder<List<ProductModel>>(
            stream: firebaseService.streamProducts(widget.store.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator())));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(40), child: Text("Sin productos."))));
              }

              final products = snapshot.data!;
              final categories = {'all', ...products.map((p) => p.category)};

              return SliverMainAxisGroup(
                slivers: [
                  // Category Pills
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _CategoryHeaderDelegate(
                      categories: categories.toList(),
                      selectedCategory: _selectedCategory,
                      onCategorySelected: (cat) => setState(() => _selectedCategory = cat),
                    ),
                  ),
                  
                  // Product List (Minimalist Cards)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = products.where((p) => _selectedCategory == 'all' || p.category == _selectedCategory).toList()[index];
                          return _buildPremiumProductCard(product);
                        },
                        childCount: products.where((p) => _selectedCategory == 'all' || p.category == _selectedCategory).length,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)), // Bottom padding for cart
                ],
              );
            },
          ),
        ],
      ),
      
      // Floating Cart Action
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: cart.itemCount > 0 && cart.storeId == widget.store.id
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: FloatingActionButton.extended(
                  backgroundColor: AppTheme.primaryColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CartView()));
                  },
                  label: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                        child: Text("${cart.itemCount}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 16),
                      const Text("Ver Pedido", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                      const SizedBox(width: 16),
                      Text("\$${cart.totalAmount.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildPremiumProductCard(ProductModel product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 90,
                height: 90,
                child: product.imageUrl.isNotEmpty
                    ? Image.network(product.imageUrl, fit: BoxFit.cover)
                    : Container(color: AppTheme.lightPurple, child: const Icon(Icons.image_outlined, color: AppTheme.primaryColor)),
              ),
            ),
            const SizedBox(width: 16),
            
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.darkPurple)),
                  const SizedBox(height: 4),
                  Text(product.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 14, color: AppTheme.primaryColor),
                      const SizedBox(width: 4),
                      Text("Aprox. ${product.preparationTimeMinutes} min", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryColor)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("\$${product.price.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppTheme.accentColor)),
                      GestureDetector(
                        onTap: product.isAvailable ? () => _addProductToCart(product) : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: product.isAvailable ? AppTheme.primaryColor : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Icon(product.isAvailable ? Icons.add_rounded : Icons.block_rounded, color: product.isAvailable ? Colors.white : Colors.grey, size: 20),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Persistent Header Delegate for Category Pills
class _CategoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  _CategoryHeaderDelegate({required this.categories, required this.selectedCategory, required this.onCategorySelected});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: AppTheme.bgLight.withValues(alpha: 0.9),
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: GestureDetector(
                  onTap: () => onCategorySelected(cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(100),
                      border: isSelected ? null : Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                    ),
                    child: Center(
                      child: Text(
                        cat == 'all' ? "Menú Completo" : cat,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 60;
  @override
  double get minExtent => 60;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}
