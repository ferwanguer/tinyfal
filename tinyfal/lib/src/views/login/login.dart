import 'dart:io' if (dart.library.html) 'dart:html';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tinyfal/src/services/auth.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App Logo or Title
              Column(
                children: [
                  Text(
                    "L.",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 60,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Bienvenido a Literatos',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Inicia sesión para continuar',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      // Set font to italic
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 50),

              // Google Sign-In Button
              ElevatedButton.icon(
                onPressed: () {
                  // UserCredential googleCredentials;
                  signInWithGoogle().then((value) {
                    //googleCredentials = value;
                    //print(googleCredentials);
                  });
                },
                icon: const FaIcon(FontAwesomeIcons.google),
                label: const Text(
                  'Inicia sesión con Google',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Apple Sign-In Button
              if (true)
                ElevatedButton.icon(
                  onPressed: () {
                    signInWithApple();
                  },
                  icon: const FaIcon(FontAwesomeIcons.apple),
                  label: const Text(
                    ' Inicia sesión con Apple',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // Footer
              Text(
                'By signing in, you agree to our Terms and Privacy Policy.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
