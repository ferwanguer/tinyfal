import 'package:flutter/material.dart';
import 'package:tinyfal/src/models/client_user.dart';
import 'package:tinyfal/src/models/escrito.dart';
import 'package:tinyfal/src/models/preferences.dart';
import 'package:tinyfal/src/services/database.dart';
import 'package:tinyfal/src/services/utils.dart';
import 'package:tinyfal/src/views/principal/read/read.dart';
import 'package:provider/provider.dart';

class PublicTileElement extends StatelessWidget {
  final Escrito escrito;
  final ClientUser? clientUser;
  final Preferences? preferences;

  const PublicTileElement({
    super.key,
    required this.escrito,
    required this.preferences,
    required this.clientUser,
  });

  @override
  Widget build(BuildContext context) {
    return StreamProvider<Preferences?>.value(
      value: getPreferencesStream(escrito.clientUser!.uid),
      initialData: null,
      child: Consumer<Preferences?>(
        builder: (context, escritoPreferences, child) {
          if (escritoPreferences == null) {
            return CircularProgressIndicator();
          }
          return Column(
            children: [
              ListTile(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          Read(escrito: escrito, preferences: preferences),
                    ),
                  );
                },
                contentPadding: EdgeInsets.only(
                  left: 10,
                  right: 10,
                ), // Removes default padding
                title: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      Text(
                        escrito.title ?? "",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 5,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 19,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
                subtitle: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          escritoPreferences.username ?? "",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (escritoPreferences.isEscuelaEscritores)
                          Padding(
                            padding: const EdgeInsets.only(left: 6.0),
                            child: Icon(
                              Icons.verified,
                              color: Color.fromARGB(255, 235, 145, 53),
                              size: 13,
                            ),
                          ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        escrito.text ?? "",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 5,
                        style: TextStyle(fontSize: preferences!.textFontSize),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${calculateReadingTime(escrito.text!)} min",
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                    Text(
                      escrito.category,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Divider(
                  color: Theme.of(context).colorScheme.tertiary,
                  thickness: 0.3,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
