import 'package:flutter/material.dart';
import 'package:tinyfal/src/models/preferences.dart';
import 'package:tinyfal/src/services/database.dart';
import 'package:tinyfal/src/models/escrito.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:tinyfal/src/models/client_user.dart';
import 'package:tinyfal/src/views/principal/profile/header.dart';
import 'package:tinyfal/src/views/principal/profile/tile_element.dart';
import 'package:tinyfal/src/views/principal/read/read.dart';
import 'package:tinyfal/src/views/write/write.dart';

class Profile extends StatelessWidget {
  final ClientUser? clientUser;
  final Preferences preferences;

  const Profile({
    super.key,
    required this.clientUser,
    required this.preferences,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Escrito>>(
        stream: getEscritosStream(clientUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No escritos found.'));
          } else {
            final escritos = snapshot.data!;
            return ListView.builder(
              itemCount: escritos.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Header(
                    clientUser: clientUser,
                    preferences: preferences,
                  );
                } else {
                  final escrito = escritos[index - 1];
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              Read(escrito: escrito, preferences: preferences),
                        ),
                      );
                    },
                    child: TileElement(
                      escrito: escrito,
                      preferences: preferences,
                      clientUser: clientUser,
                    ),
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}
