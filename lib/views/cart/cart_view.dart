import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:ui';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import '../../services/cart_provider.dart';
import '../../services/firebase_service.dart';
import '../../models/order_model.dart';
import '../../models/product_model.dart';
import '../../models/store_model.dart';
import '../../core/theme.dart';
import '../home/home_view.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  final _locationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPlacingOrder = false;

  String _paymentMethod = 'cash';
  String? _receiptBase64;
  StoreModel? _storeModel;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchStoreDetails();
    });
  }

  Future<void> _fetchStoreDetails() async {
    final cart = context.read<CartProvider>();
    if (cart.storeId == null) return;
    final service = context.read<FirebaseService>();
    final doc = await service.db.collection('stores').doc(cart.storeId).get();
    if (doc.exists && mounted) {
      setState(() {
        _storeModel = StoreModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      });
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  void _checkout() async {
    if (context.read<CartProvider>().items.isEmpty) return;
    if (!_formKey.currentState!.validate()) return;
    if (_paymentMethod == 'transfer' && _receiptBase64 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor sube la captura del comprobante de transferencia", style: TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() {
      _isPlacingOrder = true;
    });

    final cart = context.read<CartProvider>();
    final firebaseService = context.read<FirebaseService>();

    final error = await firebaseService.placeOrder(
      storeId: cart.storeId!,
      storeName: cart.storeName!,
      items: cart.items.values.toList(),
      total: cart.totalAmount + 0.50, // Including delivery fee
      deliveryLocation: _locationController.text.trim(),
      paymentMethod: _paymentMethod,
      paymentReceiptBase64: _receiptBase64,
    );

    setState(() {
      _isPlacingOrder = false;
    });

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
      );
    } else {
      cart.clearCart();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
              SizedBox(width: 8),
              Text("¡Pedido Recibido!", style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.darkPurple)),
            ],
          ),
          content: const Text(
            "Tu pedido ha sido enviado al bar/papelería. Puedes realizar el seguimiento en tiempo real desde la sección de Pedidos.",
            style: TextStyle(fontSize: 14),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeView()),
                  (route) => false,
                );
              },
              child: const Text("Entendido", style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    const double deliveryFee = 0.50;

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: const Text("Mi Carrito", style: TextStyle(color: AppTheme.darkPurple, fontWeight: FontWeight.bold)),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.grey.withValues(alpha: 0.1))),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.darkPurple, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: AppTheme.lightPurple, shape: BoxShape.circle),
                    child: const Icon(Icons.shopping_bag_outlined, size: 80, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Tu carrito está vacío",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.darkPurple),
                  ),
                  const SizedBox(height: 8),
                  const Text("¡Explora los locales y agrega algo delicioso!", style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            )
          : Form(
              key: _formKey,
              child: Column(
                children: [
                  // Merchant Name Pill
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 5))],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.storefront_rounded, color: Colors.white),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Comprando en: ${cart.storeName}",
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Cart items list
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(24),
                      itemCount: cart.items.length,
                      itemBuilder: (context, index) {
                        final item = cart.items.values.toList()[index];
                        return _buildCartItemTile(item, cart);
                      },
                    ),
                  ),
                  
                  // Glassmorphic Bottom Checkout panel
                  ClipRRect(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.5), width: 1.5)),
                          boxShadow: [
                            BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.05), blurRadius: 30, offset: const Offset(0, -10)),
                          ],
                        ),
                        padding: const EdgeInsets.fromLTRB(32, 32, 32, 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Delivery Location Form
                            TextFormField(
                              controller: _locationController,
                              decoration: InputDecoration(
                                labelText: "Lugar de Entrega (Ej: Aula 204)",
                                prefixIcon: const Icon(Icons.location_on_outlined, color: AppTheme.primaryColor),
                                fillColor: Colors.white.withValues(alpha: 0.9),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Por favor especifica dónde entregamos tu pedido";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            
                            // Costs Summary
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Subtotal", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                                Text("\$${cart.totalAmount.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Costo de Envío", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                                Text("\$${deliveryFee.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Tiempo de Preparación", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                                Text("~${cart.maxPreparationTime} min", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Divider(height: 1),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Total a Pagar", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.darkPurple)),
                                Text(
                                  "\$${(cart.totalAmount + deliveryFee).toStringAsFixed(2)}",
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: AppTheme.primaryColor),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            
                            // Payment Method
                            const Text("Método de Pago", style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.darkPurple)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: ChoiceChip(
                                    label: const Text("Efectivo"),
                                    selected: _paymentMethod == 'cash',
                                    onSelected: (val) {
                                      if (val) setState(() => _paymentMethod = 'cash');
                                    },
                                    selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                                    labelStyle: TextStyle(color: _paymentMethod == 'cash' ? AppTheme.primaryColor : Colors.grey),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ChoiceChip(
                                    label: const Text("Transferencia"),
                                    selected: _paymentMethod == 'transfer',
                                    onSelected: (val) {
                                      if (val) setState(() => _paymentMethod = 'transfer');
                                    },
                                    selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                                    labelStyle: TextStyle(color: _paymentMethod == 'transfer' ? AppTheme.primaryColor : Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                            if (_paymentMethod == 'transfer') ...[
                              const SizedBox(height: 16),
                              if (_storeModel?.paymentQrBase64 != null && _storeModel!.paymentQrBase64!.isNotEmpty)
                                Center(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.memory(base64Decode(_storeModel!.paymentQrBase64!), height: 180, width: 180, fit: BoxFit.cover),
                                  ),
                                ),
                              if (_storeModel?.paymentAccountInfo != null && _storeModel!.paymentAccountInfo!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(_storeModel!.paymentAccountInfo!, style: const TextStyle(fontSize: 13, color: Colors.grey), textAlign: TextAlign.center),
                                ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final XFile? image = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 600, imageQuality: 50);
                                  if (image != null) {
                                    final bytes = await image.readAsBytes();
                                    setState(() {
                                      _receiptBase64 = base64Encode(bytes);
                                    });
                                  }
                                },
                                icon: Icon(_receiptBase64 != null ? Icons.check_circle_rounded : Icons.upload_file_rounded, color: AppTheme.primaryColor),
                                label: Text(_receiptBase64 != null ? "Comprobante Subido" : "Subir Captura del Comprobante", style: const TextStyle(color: AppTheme.primaryColor)),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, side: const BorderSide(color: AppTheme.primaryColor)),
                              ),
                            ],
                            const SizedBox(height: 24),
                            
                            // Checkout Button
                            _isPlacingOrder
                                ? const Center(child: SpinKitRing(color: AppTheme.primaryColor, size: 50, lineWidth: 4))
                                : Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: _checkout,
                                      child: const Text("Confirmar Pedido", style: TextStyle(fontSize: 18)),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCartItemTile(CartItem item, CartProvider cart) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.darkPurple),
                ),
                const SizedBox(height: 4),
                Text(
                  "\$${item.price.toStringAsFixed(2)} c/u",
                  style: const TextStyle(color: AppTheme.primaryColor, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          
          // Quantity Adjuster
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.bgLight,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => cart.removeSingleItem(item.productId),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.remove, size: 16, color: AppTheme.primaryColor),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    "${item.quantity}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    cart.addItem(
                      ProductModel(
                        id: item.productId,
                        storeId: cart.storeId!,
                        name: item.name,
                        description: '',
                        price: item.price,
                        imageUrl: '',
                        isAvailable: true,
                        category: '',
                      ),
                      cart.storeName!,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.add, size: 16, color: AppTheme.primaryColor),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Delete
          GestureDetector(
            onTap: () => cart.removeItem(item.productId),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
              child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
