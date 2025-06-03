import 'package:alzheimer_games_app/features/bloc/bottom_nav_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alzheimer_games_app/features/bloc/auth_cubit.dart';
import 'package:alzheimer_games_app/features/bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // bool _isLoading = false; // Eliminado
  // final FirebaseAuthService _authService = FirebaseAuthService(); // Eliminado

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      Navigator.of(context).pushReplacementNamed('/landing');
      context.read<BottomNavCubit>().changeSelectedIndex(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Inicio de sesión exitoso.')),
            );
            // La navegación a '/landing' ya la maneja AuthWrapperScreen.
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
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
                  return null;
                },
              ),
              const SizedBox(height: 32),
                  isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _login,
                      child: const Text('Iniciar Sesión'),
                    ),
              TextButton(
                  onPressed: isLoading ? null : () {
                  Navigator.of(context).pushNamed('/signup');
                },
                child: const Text('¿No tienes una cuenta? Regístrate'),
              )
            ],
          ),
        ),
          );
        },
      ),
    );
  }
}
