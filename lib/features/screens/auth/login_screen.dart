// ignore_for_file: sized_box_for_whitespace

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
  bool obscureText = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      Navigator.of(context).pushNamed('/landing');
      context.read<BottomNavCubit>().changeSelectedIndex(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return PopScope(
      canPop: false,
      
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: size.height * 0.15,
          centerTitle: true,
          title: Text(
            textAlign: TextAlign.center,
            '¡Bienvenido de nuevo!\n¡Que gusto verte!',
            style: TextStyle(
              fontSize: size.width * 0.065,
              fontWeight: FontWeight.bold,
            ),
          ),

          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
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
              padding: EdgeInsets.all(size.width * 0.05),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Container(
                      width: size.width * 0.85,
                      margin: EdgeInsets.only(top: size.width * 0.01),
                      child: TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Correo Electrónico',
                          fillColor: Colors.grey.withValues(alpha: 0.2),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:const BorderSide(
                              color: Color.fromRGBO(232, 236, 244, 1),
                            ),
                          ),
                        ),
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
                    ),
                    
                    SizedBox(height: 24),
                    
                    Container(
                      width: size.width * 0.85,
                      child: TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          fillColor: Colors.grey.withValues(alpha: 0.2),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:const BorderSide(
                              color: Color.fromRGBO(232, 236, 244, 1),
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureText
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            ),
                            color: const Color.fromRGBO(131, 145, 161, 1),
                            onPressed: () {
                              setState(() {
                                obscureText = !obscureText;
                              });
                            },
                          ),
                        ),
                        obscureText: obscureText,
                        enabled: !isLoading,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu contraseña.';
                          }
                          return null;
                        },
                      ),
                    ),
                    
                    SizedBox(height: 14),
                    
                    isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Container(
                      width: size.width * 0.9,
                      height: size.height * 0.07,
                      margin: const EdgeInsets.symmetric(vertical: 15),
                    
                      child: ElevatedButton(
                        onPressed: _login,
                      
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(146, 122, 255, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        
                        child: Text(
                          'Iniciar Sesión',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: size.width * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    TextButton(
                      onPressed: isLoading ? null : () {
                        Navigator.of(context).pushNamed('/signup');
                      },
                      child: Text(
                        '¿No tienes una cuenta? Regístrate',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: size.width * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: size.width * 0.2),
                    Container(
                      padding: EdgeInsets.all(size.width * 0.2),
                      child: Image.asset(
                        'assets/images/casasco_logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
