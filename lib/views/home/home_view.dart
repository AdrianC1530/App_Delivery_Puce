import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../services/firebase_service.dart';
import '../../services/cart_provider.dart';
import '../../models/store_model.dart';
import '../../core/theme.dart';
import '../store/store_detail_view.dart';
import '../cart/cart_view.dart';
import '../entrepreneurship/entrepreneurship_hub_view.dart';
import '../orders/order_tracking_view.dart';
import '../profile/profile_view.dart';
import 'search_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const StoresTab(),
    const EntrepreneurshipHubView(),
    const OrderTrackingView(),
    const ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Needed for floating nav bar to sit over content
      body: _tabs[_currentIndex],
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.darkPurple.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: BottomNavigationBar(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: AppTheme.primaryColor,
                  unselectedItemColor: Colors.grey.shade400,
                  showSelectedLabels: false,
                  showUnselectedLabels: false,
                  iconSize: 26,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.grid_view_rounded),
                      activeIcon: Icon(Icons.grid_view_rounded, color: AppTheme.primaryColor),
                      label: 'Inicio',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.rocket_launch_outlined),
                      activeIcon: Icon(Icons.rocket_launch_rounded, color: AppTheme.primaryColor),
                      label: 'Emprender',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.receipt_long_outlined),
                      activeIcon: Icon(Icons.receipt_long_rounded, color: AppTheme.primaryColor),
                      label: 'Pedidos',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person_outline_rounded),
                      activeIcon: Icon(Icons.person_rounded, color: AppTheme.primaryColor),
                      label: 'Perfil',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StoresTab extends StatefulWidget {
  const StoresTab({super.key});

  @override
  State<StoresTab> createState() => _StoresTabState();
}

class _StoresTabState extends State<StoresTab> {
  @override
  Widget build(BuildContext context) {
    final firebaseService = context.watch<FirebaseService>();
    final cartProvider = context.watch<CartProvider>();
    final user = firebaseService.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: CustomScrollView(
        slivers: [
          // Elegant Header
          SliverAppBar(
            backgroundColor: AppTheme.bgLight,
            pinned: true,
            expandedHeight: 120,
            collapsedHeight: 80,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
              title: Text(
                "Explorar",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 28),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 24.0, top: 12),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartView()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.darkPurple.withValues(alpha: 0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(Icons.shopping_bag_outlined, color: AppTheme.darkPurple, size: 24),
                        if (cartProvider.itemCount > 0)
                          Positioned(
                            right: -6,
                            top: -6,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                gradient: AppTheme.accentGradient,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                              child: Text(
                                '${cartProvider.itemCount}',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),

          // Bento Box Content
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                
                // Search Bar
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchView()));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: AppTheme.darkPurple.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, color: AppTheme.primaryColor),
                        const SizedBox(width: 12),
                        Text("¿Qué se te antoja hoy?", style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Greeting
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppTheme.lightPurple,
                      child: Text(
                        user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
                        style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Hola, ${user?.name ?? 'Estudiante'}", style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
                        const Text("¿Qué necesitas hoy?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.darkPurple)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 24),

                // Featured Card (Bento Large)
                GestureDetector(
                  onTap: () {
                    final parent = context.findAncestorStateOfType<_HomeViewState>();
                    if (parent != null) {
                      parent.setState(() {
                        parent._currentIndex = 1; // Go to Entrepreneurships
                      });
                    }
                  },
                  child: Container(
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: AppTheme.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -30,
                          top: -30,
                          child: Icon(Icons.rocket_launch_rounded, size: 180, color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text("NOVEDAD", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                "Apoya a tu\ncomunidad",
                                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, height: 1.1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Establecimientos", style: Theme.of(context).textTheme.titleMedium),
                    const Text("Ver todos", style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 16),
              ]),
            ),
          ),

          // Stores Stream
          StreamBuilder<List<StoreModel>>(
            stream: firebaseService.streamStores(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SliverToBoxAdapter(child: Center(child: Text("No hay locales.")));
              }
              
              final stores = snapshot.data!;
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return _buildStoreBentoCard(stores[index], index);
                    },
                    childCount: stores.length,
                  ),
                ),
              );
            },
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 120)), // Offset for floating nav
        ],
      ),
    );
  }

  Widget _buildStoreBentoCard(StoreModel store, int index) {
    final isFood = store.type == 'bar';
    final cardColor = isFood ? const Color(0xFFFFF3E0) : const Color(0xFFE3F2FD);
    final iconColor = isFood ? Colors.orange.shade700 : Colors.blue.shade700;
    final icon = isFood ? Icons.fastfood_rounded : Icons.menu_book_rounded;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => StoreDetailView(store: store)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.darkPurple.withValues(alpha: 0.03),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    store.imageUrl.isNotEmpty
                        ? Image.network(store.imageUrl, fit: BoxFit.cover)
                        : Container(color: cardColor, child: Icon(icon, color: iconColor.withValues(alpha: 0.5), size: 40)),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                            const SizedBox(width: 2),
                            Text(store.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      store.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.darkPurple),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      store.locationDescription,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
