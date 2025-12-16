import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  File? _imageFile;
  String _selectedRole = 'auxiliar'; // Valor por defecto
  
  final List<String> _roles = [
    'auxiliar',
    'técnico redes',
    'servicios generales',
    'operador logístico',
    'contador',
    'subgerente',
    'otro',
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
  
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }
  
  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        role: _selectedRole,
        photo: _imageFile,
      );
      
      if (success && mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Error al registrarse'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Foto de perfil
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                    child: _imageFile == null
                        ? const Icon(Icons.add_a_photo, size: 40, color: Colors.grey)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Nombre completo
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su nombre completo';
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
                  labelText: 'Correo electrónico',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su correo electrónico';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Por favor ingrese un correo electrónico válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Contraseña
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese una contraseña';
                  }
                  if (value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Teléfono
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Número telefónico',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su número telefónico';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Cargo (rol)
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Cargo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.work),
                ),
                items: _roles.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedRole = value;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor seleccione un cargo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Botón de registro
              ElevatedButton(
                onPressed: authProvider.isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: authProvider.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('REGISTRARSE', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 16),
              
              // Enlace a Login
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/login');
                },
                child: const Text('¿Ya tienes cuenta? Inicia sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}