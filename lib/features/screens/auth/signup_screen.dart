// ignore_for_file: sized_box_for_whitespace

import 'package:alzheimer_games_app/features/bloc/bottom_nav_cubit.dart';
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
  bool obscureText = true;
  bool obscureConfirmText = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    FocusScope.of(context).unfocus();
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
              textAlign: TextAlign.start,
              'Hola!\nRegistrate para comenzar',
              style: TextStyle(
                fontSize: size.width * 0.06,
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
                  children: [
                    Container(
                      width: size.width * 0.85,
                      margin: EdgeInsets.only(top: size.width * 0.01),
                      child: TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Nombre Completo',
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
                        enabled: !isLoading,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu nombre.';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: size.width * 0.85,
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
                    const SizedBox(height: 16),
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
                              color: Colors.grey,
                            ),
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
                          if (value.length < 6) {
                            return 'La contraseña debe tener al menos 6 caracteres.';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: size.width * 0.85,
                      child: TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Confirmar Contraseña',
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
                              obscureConfirmText
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                obscureConfirmText = !obscureConfirmText;
                              });
                            },
                          ),
                        ),
                        obscureText: obscureConfirmText,
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
                    ),
                    const SizedBox(height: 32),
                    isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Container(
                      width: size.width * 0.9,
                      height: size.height * 0.07,
                      margin: const EdgeInsets.symmetric(vertical: 15),
                      
                      child: ElevatedButton(
                        onPressed: _signUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(236, 165, 82, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text('Registrarse',
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
                        Navigator.of(context).pushNamed('/login');
                      },
                      child: Text('¿Ya tienes una cuenta? Inicia Sesión',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: size.width * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
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
