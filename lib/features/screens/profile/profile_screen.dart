import 'package:flutter/material.dart';

// import '../../../data/models/user_model/user_model.dart';

class ProfileScreen extends StatelessWidget {
   
  const ProfileScreen({super.key});
  
  @override
  Widget build(BuildContext context) {


    // Ejemplo de usuario (esto debería venir de tu lógica real de usuario)
    // final user = PlayerModel(
    //   name: 'Juan Pérez',
    //   email: 'juan.perez@email.com',
    // );

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.account_circle, size: 80, color: Colors.blueGrey),
              const SizedBox(height: 24),
              TextFormField(
                //initialValue: ,
                decoration: const InputDecoration(
                  labelText: 'Nombre de usuario',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                readOnly: true,
              ),
              const SizedBox(height: 16),
              TextFormField(
                //initialValue: user.email,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                readOnly: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}