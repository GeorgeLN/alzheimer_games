import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alzheimer_games_app/features/bloc/auth_cubit.dart';
import 'package:alzheimer_games_app/features/bloc/auth_state.dart';
// PlayerModel no es necesario aquí directamente si AuthCubit lo maneja.
// import 'package:alzheimer_games_app/data/models/user_model/user_model.dart'; 
// FirebaseAuthService y FirestoreUserService no son necesarios aquí.
// import 'package:alzheimer_games_app/data/services/authentication/firebase_auth_service.dart';
// import 'package:alzheimer_games_app/data/services/firestore/firestore_user_service.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Eliminadas las instancias de servicios y _isLoading
  // final FirebaseAuthService _authService = FirebaseAuthService();
  // final FirestoreUserService _userService = FirestoreUserService();
  // bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Las contraseñas no coinciden.')),
        );
        return;
      }
      context.read<AuthCubit>().signUp(
            _emailController.text.trim(),
            _passwordController.text.trim(),
            _nameController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Registro exitoso.')),
            );
            // AuthWrapperScreen se encargará de la redirección.
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error en el registro: ${state.message}')),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nombre Completo'),
                    enabled: !isLoading,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu nombre.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Correo Electrónico'),
                keyboardType: TextInputType.emailAddress,
                enabled: !isLoading,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu correo.';
                  }
                  if (!value.contains('@')) {
                    return 'Por favor ingresa un correo válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                enabled: !isLoading,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu contraseña.';
                  }
                  if (value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Confirmar Contraseña'),
                obscureText: true,
                enabled: !isLoading,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor confirma tu contraseña.';
                  }
                  if (value != _passwordController.text) {
                    return 'Las contraseñas no coinciden.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _signUp,
                      child: const Text('Registrarse'),
                    ),
              TextButton(
                onPressed: isLoading ? null : () {
                  Navigator.of(context).pushNamed('/login');
                },
                child: const Text('¿Ya tienes una cuenta? Inicia Sesión'),
              ),
            ],
          ),
        ),
          );
        },
      ),
    );
  }
}
