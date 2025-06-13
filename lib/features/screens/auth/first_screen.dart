// ignore_for_file: sized_box_for_whitespace

import 'package:flutter/material.dart';

class FirstScreen extends StatelessWidget {
   
  const FirstScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return PopScope(
      canPop: false,

      child: Scaffold(
        body: Container(
          width: size.width,
          height: size.height,
          
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/Background.png',
                  fit: BoxFit.cover,
                ),
              ),
      
              Positioned(
                top: size.height * 0.3,
                left: size.width * 0.05,
                child: Text(
                  'RECUERDA\nCONECTA\nAVANZA...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size.width * 0.085,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
      
              Positioned(
                bottom: size.height * 0.18,
                left: size.width * 0.05,
                child: Column(
                  children: [
                    Container(
                      width: size.width * 0.9,
                      height: size.height * 0.05,
      
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/login');
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Colors.white,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'Iniciar Sesión',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: size.width * 0.055,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      width: size.width * 0.9,
                      height: size.height * 0.05,
      
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/signup');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: Text(
                          'Registrarse',
                          style: TextStyle(
                            color: Color.fromRGBO(236, 165, 82, 1),
                            fontSize: size.width * 0.055,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ),
      
              Positioned(
                bottom: size.height * 0.07,
                left: size.width * 0.2,
      
                child: Container(
                  width: size.width * 0.55,
                  child: Image.asset(
                    'assets/images/casasco_logo_blanco.png',
                    fit: BoxFit.cover,
                  ),
                ),
              )
            ],
          ),
        )
      ),
    );
  }
}