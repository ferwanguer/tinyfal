import 'package:flutter/material.dart';
import 'package:tinyfal/src/models/client_user.dart';
import 'package:tinyfal/src/models/resource.dart';
import 'package:tinyfal/src/models/preferences.dart';
import 'package:tinyfal/src/views/write/write.dart';

class TileElement extends StatelessWidget {
  final Escrito escrito;
  final Preferences preferences;
  final ClientUser? clientUser;
  const TileElement({
    super.key,
    required this.escrito,
    required this.preferences,
    required this.clientUser,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(escrito.title ?? "", style: TextStyle(fontSize: 19)),
          subtitle: Text(
            escrito.text ?? "",
            overflow: TextOverflow.ellipsis,
            maxLines: 5, // Optional: limit to a specific number of lines
            style: TextStyle(fontSize: preferences.textFontSize),
            textAlign: TextAlign.justify, // Add this line to justify the text
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'editar':
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => Write(
                        clientUser: clientUser,
                        escrito: escrito,
                        preferences: preferences,
                      ),
                    ),
                  );
                  break;
                case 'eliminar':
                  bool confirm = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Confirmar eliminación'),
                        content: Text(
                          '¿Estás seguro de que deseas eliminar este escrito? Esta acción no se puede deshacer.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            child: Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                            child: Text('Eliminar'),
                          ),
                        ],
                      );
                    },
                  );
                  if (confirm) {
                    await escrito.deleteFromFirestore();
                    // Optionally, you can add code to update the UI after deletion
                  }
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(value: 'editar', child: Text('Editar')),
                PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
              ];
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (escrito.visibility == 'publico')
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      10.0,
                    ), // Add rounded edges
                    color: const Color.fromARGB(
                      255,
                      149,
                      177,
                      201,
                    ), // Add background color
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      "Público",
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              if (escrito.visibility == 'privado')
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      10.0,
                    ), // Add rounded edges
                    color: Theme.of(
                      context,
                    ).colorScheme.tertiaryFixed, // Add background color
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      "Privado",
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              if (escrito.visibility == 'escueladeescritores')
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      10.0,
                    ), // Add rounded edges
                    color: const Color.fromARGB(
                      255,
                      225,
                      150,
                      74,
                    ), // Add background color
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      "Escuela de escritores",
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              Text(
                ' ${escrito.category}',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Divider(
            color: Theme.of(context).colorScheme.tertiary,
            thickness: 0.3,
          ),
        ),
      ],
    );
  }
}
