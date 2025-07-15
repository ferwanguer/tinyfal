import 'package:flutter/material.dart';
import 'package:tinyfal/src/models/client_user.dart';
import 'package:tinyfal/src/models/preferences.dart';
import 'package:tinyfal/src/services/database.dart';
import 'package:tinyfal/src/models/resource.dart';
import 'package:tinyfal/src/views/principal/home/public_tile_element.dart';
import 'package:tinyfal/src/views/principal/read/read.dart';

class Home extends StatelessWidget {
  final ClientUser? clientUser;
  final Preferences? preferences;

  const Home({super.key, this.clientUser, this.preferences});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Escrito?>>(
        stream: publicEscritos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Create a resource to see it here.'));
          } else {
            final publicescritos = snapshot.data!;
            final List<Escrito?> filteredEscritos;
            if (!preferences!.isEscuelaEscritores) {
              filteredEscritos = publicescritos
                  .where((escrito) => escrito!.visibility == 'publico')
                  .toList();
            } else {
              filteredEscritos = publicescritos;
            }
            return ListView.builder(
              itemCount: filteredEscritos.length,
              itemBuilder: (context, index) {
                final escrito = publicescritos[index];
                return PublicTileElement(
                  escrito: escrito!,
                  preferences: preferences!,
                  clientUser: clientUser,
                );
              },
            );
          }
        },
      ),
    );
  }
}
