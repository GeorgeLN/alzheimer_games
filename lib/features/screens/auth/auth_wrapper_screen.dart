import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alzheimer_games_app/features/bloc/auth_cubit.dart';
import 'package:alzheimer_games_app/features/bloc/auth_state.dart';

class AuthWrapperScreen extends StatelessWidget {
  const AuthWrapperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is Authenticated) {
          // Usuario autenticado, mostrar LandingScreen
          // return const LandingScreen(); // O navegar si es preferible
          // Para mantener la consistencia con la navegación de rutas:
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (ModalRoute.of(context)?.settings.name != '/landing') {
               Navigator.of(context).pushReplacementNamed('/landing');
            }
          });
          // Muestra un loader mientras se redirige para evitar parpadeos
          return const Scaffold(body: Center(child: CircularProgressIndicator()));


        } else if (state is Unauthenticated || state is AuthError) {
          // Usuario no autenticado o error, mostrar LoginScreen
          // return const LoginScreen(); // O navegar si es preferible
          // Para mantener la consistencia con la navegación de rutas:
           WidgetsBinding.instance.addPostFrameCallback((_) {
             if (ModalRoute.of(context)?.settings.name != '/first') {
              Navigator.of(context).pushReplacementNamed('/first');
             }
           });
          // Muestra un loader mientras se redirige para evitar parpadeos
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        // Estado por defecto o inesperado
        return const Scaffold(
          body: Center(
            child: Text('Error inesperado en el flujo de autenticación.'),
          ),
        );
      },
    );
  }
}
