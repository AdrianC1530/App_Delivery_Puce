import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../services/firebase_service.dart';
import '../../core/theme.dart';
import '../home/home_view.dart';
import '../home/merchant_dashboard_view.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  
  String _selectedRole = 'student';
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final service = Provider.of<FirebaseService>(context, listen: false);
    final error = await service.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      name: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      role: _selectedRole,
    );

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      // Clear navigation stack and go to Home or Dashboard
      Widget nextView = const HomeView();
      if (service.currentUser?.role == 'merchant') {
        nextView = const MerchantDashboardView();
      }
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => nextView),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<FirebaseService>().isLoading;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.primaryColor, AppTheme.darkPurple],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Crear Cuenta",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Únete a la comunidad de delivery de la PUCE-SI",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Register Form Card
                    Card(
                      elevation: 8,
                      shadowColor: Colors.black26,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 28.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Full Name
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: "Nombre Completo",
                                prefixIcon: Icon(Icons.person_outline_rounded, color: AppTheme.primaryColor),
                                fillColor: Color(0xFFF1F5F9),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Por favor ingresa tu nombre";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            // Email
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: "Correo Electrónico",
                                hintText: "ejemplo@pucesi.edu.ec",
                                prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primaryColor),
                                fillColor: Color(0xFFF1F5F9),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Por favor ingresa tu correo";
                                }
                                if (!value.contains('@')) {
                                  return "Ingresa un correo válido";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            // Phone
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                labelText: "Número de Teléfono",
                                hintText: "0999999999",
                                prefixIcon: Icon(Icons.phone_outlined, color: AppTheme.primaryColor),
                                fillColor: Color(0xFFF1F5F9),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Por favor ingresa tu número";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            // Password
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: "Contraseña",
                                prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.primaryColor),
                                fillColor: const Color(0xFFF1F5F9),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    color: AppTheme.primaryColor,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Por favor ingresa una contraseña";
                                }
                                if (value.length < 6) {
                                  return "La contraseña debe tener al menos 6 caracteres";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            // Role selector
                            DropdownButtonFormField<String>(
                              initialValue: _selectedRole,
                              decoration: const InputDecoration(
                                labelText: "Tipo de Usuario",
                                prefixIcon: Icon(Icons.badge_outlined, color: AppTheme.primaryColor),
                                fillColor: Color(0xFFF1F5F9),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'student', child: Text("Estudiante")),
                                DropdownMenuItem(value: 'merchant', child: Text("Comerciante / Bar")),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _selectedRole = val;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 28),
                            // Submit
                            isLoading
                                ? const Center(
                                    child: SpinKitRing(
                                      color: AppTheme.primaryColor,
                                      size: 50,
                                      lineWidth: 4,
                                    ),
                                  )
                                : ElevatedButton(
                                    onPressed: _submit,
                                    child: const Text("Registrarse"),
                                  ),
                          ],
                        ),
                      ),
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
