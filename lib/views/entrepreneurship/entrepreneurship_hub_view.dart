import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../services/firebase_service.dart';
import '../../models/entrepreneurship_model.dart';
import '../../core/theme.dart';
import 'post_entrepreneurship_view.dart';

class EntrepreneurshipHubView extends StatefulWidget {
  const EntrepreneurshipHubView({super.key});

  @override
  State<EntrepreneurshipHubView> createState() => _EntrepreneurshipHubViewState();
}

class _EntrepreneurshipHubViewState extends State<EntrepreneurshipHubView> {
  String _selectedCategory = 'all';

  final List<String> _categories = ['all', 'Comida', 'Papelería / Diseño', 'Servicios', 'Tecnología', 'Ropa & Accesorios'];

  void _contactStudent(EntrepreneurshipModel post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Contactar a ${post.studentName}",
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: AppTheme.darkPurple),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Apoya su emprendimiento: \"${post.title}\"",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 32),
              
              // WhatsApp
              _buildContactTile(
                icon: Icons.chat_bubble_rounded,
                color: Colors.green,
                title: "Enviar WhatsApp",
                subtitle: post.contactPhone,
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Abriendo WhatsApp con ${post.contactPhone}...")));
                },
              ),
              const SizedBox(height: 16),
              
              // Phone
              _buildContactTile(
                icon: Icons.phone_rounded,
                color: AppTheme.primaryColor,
                title: "Llamar directamente",
                subtitle: post.contactPhone,
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Llamando a ${post.contactPhone}...")));
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactTile({required IconData icon, required Color color, required String title, required String subtitle, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firebaseService = context.read<FirebaseService>();

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: CustomScrollView(
        slivers: [
          // AppBar
          SliverAppBar(
            backgroundColor: AppTheme.bgLight,
            pinned: true,
            expandedHeight: 120,
            collapsedHeight: 80,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
              title: Text(
                "Novedades",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 28),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 24.0, top: 12),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PostEntrepreneurshipView()));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: AppTheme.accentGradient,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: AppTheme.accentColor.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 5))],
                    ),
                    child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
                  ),
                ),
              )
            ],
          ),

          // Categories
          SliverPersistentHeader(
            pinned: true,
            delegate: _CategoryHeaderDelegate(
              categories: _categories,
              selectedCategory: _selectedCategory,
              onCategorySelected: (cat) => setState(() => _selectedCategory = cat),
            ),
          ),

          // Stream Content
          StreamBuilder<List<EntrepreneurshipModel>>(
            stream: firebaseService.streamEntrepreneurships(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator())));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(Icons.rocket_launch_rounded, size: 80, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          const Text("Aún no hay anuncios", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey)),
                          const SizedBox(height: 8),
                          const Text("¡Anímate y publica el primer emprendimiento!", style: TextStyle(color: Colors.black45)),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final filteredPosts = snapshot.data!.where((post) {
                return _selectedCategory == 'all' || post.category == _selectedCategory;
              }).toList();

              if (filteredPosts.isEmpty) {
                return const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(40), child: Text("Sin resultados."))));
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final post = filteredPosts[index];
                      return _buildPremiumPostCard(post);
                    },
                    childCount: filteredPosts.length,
                  ),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)), // Bottom nav padding
        ],
      ),
    );
  }

  Widget _buildPremiumPostCard(EntrepreneurshipModel post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: AppTheme.darkPurple.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image
          if (post.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              child: SizedBox(
                height: 200,
                child: Image.network(post.imageUrl, fit: BoxFit.cover),
              ),
            ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.lightPurple,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        post.category.toUpperCase(),
                        style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  post.title,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppTheme.darkPurple),
                ),
                const SizedBox(height: 8),
                Text(
                  post.description,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),
                
                // Student Footer & Action
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppTheme.lightPurple,
                      child: Text(
                        post.studentName.isNotEmpty ? post.studentName[0].toUpperCase() : 'E',
                        style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(post.studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text("PUCE-SI", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.darkPurple,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                      ),
                      onPressed: () => _contactStudent(post),
                      child: const Text("Contactar", style: TextStyle(fontSize: 12)),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
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
                        cat == 'all' ? "Todos" : cat,
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
