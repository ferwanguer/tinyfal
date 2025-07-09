import 'package:flutter/material.dart';
import 'package:tinyfal/src/models/client_user.dart';
import 'package:tinyfal/src/models/escrito.dart';
import 'package:tinyfal/src/models/preferences.dart';
import 'package:tinyfal/src/services/database.dart';
import 'package:tinyfal/src/views/principal/home/public_tile_element.dart';

class TheSearch extends StatefulWidget {
  final ClientUser? clientUser;
  final Preferences? preferences;

  const TheSearch({super.key, this.clientUser, this.preferences});

  @override
  _TheSearchState createState() => _TheSearchState();
}

class _TheSearchState extends State<TheSearch> {
  String searchText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 5),
            child: SearchBar(
              onTapOutside: (event) {
                FocusScope.of(context).unfocus();
              },
              leading: const Icon(Icons.search),
              hintText: "Buscar",
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Escrito>>(
              stream: searchEscritos(searchText),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No escritos found.'));
                } else {
                  final escritos = snapshot.data!;
                  final List<Escrito?> filteredEscritos;
                  if (!widget.preferences!.isEscuelaEscritores) {
                    filteredEscritos = escritos
                        .where((escrito) => escrito.visibility == 'publico')
                        .toList();
                  } else {
                    filteredEscritos = escritos;
                  }

                  return ListView.builder(
                    itemCount: filteredEscritos.length,
                    itemBuilder: (context, index) {
                      final escrito = filteredEscritos[index];

                      return PublicTileElement(
                        escrito: escrito!,
                        clientUser: widget.clientUser,
                        preferences: widget.preferences,
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
