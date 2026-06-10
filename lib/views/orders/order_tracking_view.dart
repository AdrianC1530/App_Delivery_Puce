import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firebase_service.dart';
import '../../models/order_model.dart';
import '../../core/theme.dart';

class OrderTrackingView extends StatelessWidget {
  const OrderTrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseService = context.read<FirebaseService>();
    final user = firebaseService.currentUser;
    final isMerchant = user?.role == 'merchant' || user?.role == 'admin';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isMerchant ? "Pedidos Recibidos" : "Mis Pedidos",
            style: const TextStyle(color: AppTheme.darkPurple, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: const TabBar(
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.primaryColor,
            tabs: [
              Tab(text: "Activos"),
              Tab(text: "Historial"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            isMerchant ? const MerchantOrdersList(isActive: true) : const StudentOrdersList(isActive: true),
            isMerchant ? const MerchantOrdersList(isActive: false) : const StudentOrdersList(isActive: false),
          ],
        ),
      ),
    );
  }
}

// --- STUDENT FLOW ---
class StudentOrdersList extends StatelessWidget {
  final bool isActive;
  const StudentOrdersList({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final service = context.read<FirebaseService>();

    return StreamBuilder<List<OrderModel>>(
      stream: service.streamClientOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        }

        final allOrders = snapshot.data!;
        final orders = allOrders.where((o) {
          final isCompletedOrCancelled = o.status == 'completed' || o.status == 'cancelled';
          return isActive ? !isCompletedOrCancelled : isCompletedOrCancelled;
        }).toList();

        if (orders.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return _buildOrderCard(context, order, isMerchantFlow: false);
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 70, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(isActive ? "No tienes pedidos activos" : "Tu historial está vacío", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 6),
          Text(isActive ? "Tus pedidos en curso se listarán aquí." : "Tus pedidos pasados aparecerán aquí.", style: const TextStyle(color: Colors.black38)),
        ],
      ),
    );
  }
}

// --- MERCHANT FLOW ---
class MerchantOrdersList extends StatelessWidget {
  final bool isActive;
  const MerchantOrdersList({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final service = context.read<FirebaseService>();

    return StreamBuilder<List<OrderModel>>(
      stream: service.streamAllOrders(), // Simplified for mockup, showing all orders to manage
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        }

        final allOrders = snapshot.data!;
        final orders = allOrders.where((o) {
          final isCompletedOrCancelled = o.status == 'completed' || o.status == 'cancelled';
          return isActive ? !isCompletedOrCancelled : isCompletedOrCancelled;
        }).toList();

        if (orders.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return _buildOrderCard(context, order, isMerchantFlow: true);
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.storefront_rounded, size: 70, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(isActive ? "Aún no hay pedidos para tu bar" : "No tienes pedidos pasados", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }
}

// --- ORDER CARD COMPONENT ---
Widget _buildOrderCard(BuildContext context, OrderModel order, {required bool isMerchantFlow}) {
  final service = context.read<FirebaseService>();

  Color statusColor;
  String statusLabel;

  switch (order.status) {
    case 'pending':
      statusColor = Colors.orangeAccent;
      statusLabel = "En espera";
      break;
    case 'preparing':
      statusColor = AppTheme.primaryColor;
      statusLabel = "Preparando";
      break;
    case 'ready_for_pickup':
      statusColor = Colors.teal;
      statusLabel = "Listo p/ retirar";
      break;
    case 'delivering':
      statusColor = Colors.blue;
      statusLabel = "En camino";
      break;
    case 'completed':
      statusColor = Colors.green;
      statusLabel = "Entregado";
      break;
    case 'cancelled':
      statusColor = Colors.redAccent;
      statusLabel = "Cancelado";
      break;
    default:
      statusColor = Colors.grey;
      statusLabel = order.status;
  }

  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.storeName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.darkPurple),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: statusColor, width: 1.5),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Items List
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${item.quantity}x ${item.name}", style: const TextStyle(fontSize: 14)),
                      Text("\$${(item.price * item.quantity).toStringAsFixed(2)}", style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                )),
            
            const Divider(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Dirección de Entrega:", style: TextStyle(color: Colors.grey, fontSize: 11)),
                    const SizedBox(height: 2),
                    Text(order.deliveryLocation, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  ],
                ),
                Text(
                  "Total: \$${order.total.toStringAsFixed(2)}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.accentColor),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon((order.paymentMethod == 'transfer' || order.paymentMethod == 'deuna') ? Icons.account_balance_wallet_rounded : Icons.money_rounded, size: 16, color: AppTheme.primaryColor),
                      const SizedBox(width: 4),
                      Text(order.paymentMethod == 'deuna' ? "DeUna!" : (order.paymentMethod == 'transfer' ? "Transferencia" : "Efectivo"), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.darkPurple)),
                    ],
                  ),
                ),
                if (isMerchantFlow && (order.paymentMethod == 'transfer' || order.paymentMethod == 'deuna') && order.paymentReceiptBase64 != null)
                  TextButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Comprobante de Pago", style: TextStyle(color: AppTheme.darkPurple)),
                          content: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.memory(base64Decode(order.paymentReceiptBase64!), fit: BoxFit.contain),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text("Cerrar"),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.receipt_long_rounded, size: 18),
                    label: const Text("Ver Comprobante", style: TextStyle(fontWeight: FontWeight.bold)),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  ),
              ],
            ),
            
            // Merchant Status Controller Panel
            if (isMerchantFlow && order.status != 'completed' && order.status != 'cancelled') ...[
              const SizedBox(height: 16),
              const Divider(height: 8),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Cambiar Estado:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.darkPurple)),
                  Row(
                    children: [
                      if (order.status == 'pending')
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => service.updateOrderStatus(order.id, 'preparing'),
                          child: const Text("Preparar", style: TextStyle(fontSize: 12)),
                        ),
                      if (order.status == 'preparing')
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => service.updateOrderStatus(order.id, 'ready_for_pickup'),
                          child: const Text("Listo", style: TextStyle(fontSize: 12)),
                        ),
                      if (order.status == 'ready_for_pickup')
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => service.updateOrderStatus(order.id, 'delivering'),
                          child: const Text("Enviar", style: TextStyle(fontSize: 12)),
                        ),
                      if (order.status == 'delivering')
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => service.updateOrderStatus(order.id, 'completed'),
                          child: const Text("Completar", style: TextStyle(fontSize: 12)),
                        ),
                      const SizedBox(width: 8),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        onPressed: () => service.updateOrderStatus(order.id, 'cancelled'),
                        child: const Text("Cancelar", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
            
            // Student Status Controller (Confirm received)
            if (!isMerchantFlow && (order.status == 'delivering' || order.status == 'ready_for_pickup')) ...[
              const SizedBox(height: 16),
              const Divider(height: 8),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => service.updateOrderStatus(order.id, 'completed'),
                  icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
                  label: const Text("Confirmar recepción del pedido", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ]
          ],
        ),
      ),
    ),
  );
}
