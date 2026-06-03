import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../services/firebase_service.dart';
import '../../core/theme.dart';

class PostEntrepreneurshipView extends StatefulWidget {
  const PostEntrepreneurshipView({super.key});

  @override
  State<PostEntrepreneurshipView> createState() => _PostEntrepreneurshipViewState();
}

class _PostEntrepreneurshipViewState extends State<PostEntrepreneurshipView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _phoneController = TextEditingController();
  final _imageController = TextEditingController();

  String _selectedCategory = 'Comida';
  bool _isSubmitting = false;

  final List<String> _categories = ['Comida', 'Papelería / Diseño', 'Servicios', 'Tecnología', 'Ropa & Accesorios'];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _phoneController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final service = Provider.of<FirebaseService>(context, listen: false);
    final error = await service.postEntrepreneurship(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      category: _selectedCategory,
      contactPhone: _phoneController.text.trim(),
      imageUrl: _imageController.text.trim(),
    );

    setState(() {
      _isSubmitting = false;
    });

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Anuncio publicado exitosamente"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Publicar Emprendimiento", style: TextStyle(color: AppTheme.darkPurple, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Comparte tu negocio con el campus",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.darkPurple),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Completa los detalles de tu emprendimiento para publicarlo en la cartelera universitaria.",
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
                const SizedBox(height: 24),
                
                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: "Nombre / Título de Emprendimiento",
                    hintText: "Ej: Brownies Caseros Adrian",
                    prefixIcon: Icon(Icons.title_rounded, color: AppTheme.primaryColor),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Por favor ingresa un título";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                
                // Category Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: "Categoría",
                    prefixIcon: Icon(Icons.category_outlined, color: AppTheme.primaryColor),
                  ),
                  items: _categories.map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedCategory = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 18),
                
                // Contact Phone
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: "Teléfono / WhatsApp de Contacto",
                    hintText: "Ej: 0995551234",
                    prefixIcon: Icon(Icons.phone_outlined, color: AppTheme.primaryColor),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Por favor ingresa un número de contacto";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                
                // Image URL
                TextFormField(
                  controller: _imageController,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: "Enlace de Imagen (Opcional)",
                    hintText: "https://ejemplo.com/imagen.jpg",
                    prefixIcon: Icon(Icons.image_outlined, color: AppTheme.primaryColor),
                  ),
                ),
                const SizedBox(height: 18),
                
                // Description
                TextFormField(
                  controller: _descController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: "Descripción de productos / servicio",
                    hintText: "Describe lo que vendes, precios, horarios de entrega o si te ubicas en alguna facultad...",
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Por favor describe tu emprendimiento";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                
                // Submit Button
                _isSubmitting
                    ? const Center(child: SpinKitRing(color: AppTheme.primaryColor, size: 50, lineWidth: 4))
                    : ElevatedButton(
                        onPressed: _submit,
                        child: const Text("Publicar Anuncio"),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
