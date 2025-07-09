import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tinyfal/src/models/client_user.dart';
import 'package:tinyfal/src/models/preferences.dart';

class MailDisclaimer extends StatelessWidget {
  final ClientUser? clientUser;
  final Preferences? preferences;
  const MailDisclaimer({
    super.key,
    required this.clientUser,
    required this.preferences,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          Clipboard.setData(
            ClipboardData(text: "${preferences?.nickname}@literatos.net"),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Correo copiado al portapapeles'),
              duration: Duration(seconds: 1),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.primaryContainer, // Updated background color
            borderRadius: BorderRadius.circular(10), // Add rounded edges
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.primary, // Updated border color
              width: 2,
            ), // Outer border
          ),
          child: SizedBox(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 8.0,
                bottom: 8,
                left: 8,
                right: 8,
              ),
              child: Text.rich(
                TextSpan(
                  text:
                      "Para añadir un texto desde el ordenador, puedes mandarlo a esta dirección pegando el título en el asunto y el texto en el cuerpo del correo. Es exclusivo para ti. \n\n",
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  children: [
                    TextSpan(
                      text: "${preferences?.nickname}@literatos.net \n\n",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    TextSpan(
                      text: "Puedes copiar la dirección de correo tocándola!",
                      style: TextStyle(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
