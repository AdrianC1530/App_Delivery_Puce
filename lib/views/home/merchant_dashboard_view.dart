import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../services/firebase_service.dart';
import '../../models/store_model.dart';
import '../../core/theme.dart';
import '../orders/order_tracking_view.dart';
import '../admin/admin_store_details_view.dart';
import '../profile/profile_view.dart';

class MerchantDashboardView extends StatefulWidget {
  const MerchantDashboardView({super.key});

  @override
  State<MerchantDashboardView> createState() => _MerchantDashboardViewState();
}

class _MerchantDashboardViewState extends State<MerchantDashboardView> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final firebaseService = context.watch<FirebaseService>();
    final merchantStoreId = firebaseService.merchantStoreId;

    if (merchantStoreId == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
              const SizedBox(height: 16),
              const Text("Error: Local no asignado a esta cuenta.", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => firebaseService.signOut(),
                child: const Text("Cerrar Sesión"),
              )
            ],
          ),
        ),
      );
    }

    return StreamBuilder<List<StoreModel>>(
      stream: firebaseService.streamStores(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        
        final stores = snapshot.data!;
        final storeIndex = stores.indexWhere((s) => s.id == merchantStoreId);
        
        if (storeIndex == -1) {
          return const Scaffold(body: Center(child: Text("Local no encontrado.")));
        }

        final myStore = stores[storeIndex];

        final List<Widget> tabs = [
          const OrderTrackingView(),
          AdminStoreDetailsView(store: myStore),
          const ProfileView(),
        ];

        return Scaffold(
          extendBody: true,
          body: tabs[_currentIndex],
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
                          icon: Icon(Icons.receipt_long_outlined),
                          activeIcon: Icon(Icons.receipt_long_rounded, color: AppTheme.primaryColor),
                          label: 'Pedidos',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.storefront_outlined),
                          activeIcon: Icon(Icons.storefront_rounded, color: AppTheme.primaryColor),
                          label: 'Mi Menú',
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
      },
    );
  }
}
